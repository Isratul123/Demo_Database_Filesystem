USE [ReportServer]
GO
/****** Object:  StoredProcedure [dbo].[CleanOrphanedSnapshots]    Script Date: 08/11/2020 07:35:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CleanOrphanedSnapshots]
@Machine nvarchar(512),
@PermanentSnapshotCount int, 
@TemporarySnapshotCount int,
@PermanentChunkCount int, 
@TemporaryChunkCount int, 
@PermanentMappingCount int, 
@TemporaryMappingCount int, 
@PermanentSegmentCount int, 
@TemporarySegmentCount int,
@SnapshotsCleaned int OUTPUT,
@ChunksCleaned int OUTPUT,
@MappingsCleaned int OUTPUT,
@SegmentsCleaned int OUTPUT
AS 
    SELECT	@SnapshotsCleaned = 0, 
		@ChunksCleaned = 0, 
		@MappingsCleaned = 0, 
		@SegmentsCleaned = 0 ;
    
    -- use readpast rather than NOLOCK.  using 
    -- nolock could cause us to identify snapshots
    -- which have had the refcount decremented but
    -- the transaction is uncommitted which is dangerous.
    
    SET DEADLOCK_PRIORITY LOW
    
	-- cleanup of segmented chunk information happens 
	-- top->down.  meaning we delete chunk metadata, then 
	-- mappings, then segment data.  the reason for doing
	-- this is because it minimizes the io read cost since
	-- each delete step tells us the work that we need to 
	-- do in the next step.  however, there is the potential 
	-- for failure at any step which can leave orphaned data 
	-- structures.  we have another cleanup tasks 
	-- which will scavenge this orphaned data and clean it up
	-- so we don't need to be 100% robust here.  this also 
	-- means that we can play tricks like using readpast in the 
	-- dml operations so that concurrent deletes will minimize
	-- blocking of each other.	
	-- also, we optimize this cleanup for the scenario where the chunk is
	-- not shared.  this means that if we detect that a chunk is shared
	-- we will not delete any of its mappings.  there is potential for this
	-- to miss removing a chunk because it is shared and we are concurrently
	-- deleting the other snapshot (both see the chunk as shared...).  however
	-- we don't deal with that case here, and will instead orphan the chunk
	-- mappings and segments.  that is ok, we will just remove them when we 
	-- scan for orphaned mappings/segments.
		
	declare @cleanedSnapshots table (SnapshotDataId uniqueidentifier) ;  	
   	declare @cleanedChunks table (ChunkId uniqueidentifier) ; 
   	declare @cleanedSegments table (ChunkId uniqueidentifier, SegmentId uniqueidentifier) ;   	
   	declare @deleteCount int ;   	   	
  	
	begin transaction
	-- remove the actual snapshot entry
	-- we do this transacted with cleaning up chunk 
	-- data because we do not lazily clean up old ChunkData table.
	-- we also do this before cleaning up segmented chunk data to 
	-- get this SnapshotData record out of the table so another parallel 
	-- cleanup task does not attempt to delete it which would just cause 
	-- contention and reduce cleanup throughput.	
    DELETE TOP (@PermanentSnapshotCount) SnapshotData 
    output deleted.SnapshotDataID into @cleanedSnapshots (SnapshotDataId)
    FROM SnapshotData with(readpast) 
    WHERE   SnapshotData.PermanentRefCount = 0 AND
            SnapshotData.TransientRefCount = 0 ; 
    SET @SnapshotsCleaned = @@ROWCOUNT ;    
    
	-- clean up RS2000/RS2005 chunks
    DELETE ChunkData FROM ChunkData INNER JOIN @cleanedSnapshots cs
    ON ChunkData.SnapshotDataID = cs.SnapshotDataId
    SET @ChunksCleaned = @@ROWCOUNT ;	
    commit
   	
   	-- clean up chunks
   	set @deleteCount = 1 ; 
   	while (@deleteCount > 0)
   	begin		
		delete top (@PermanentChunkCount) SC 
		output deleted.ChunkId into @cleanedChunks(ChunkId)
		from SegmentedChunk SC with (readpast)	
		join @cleanedSnapshots cs on SC.SnapshotDataId = cs.SnapshotDataId ;	
		set @deleteCount = @@ROWCOUNT ; 
		set @ChunksCleaned =  @ChunksCleaned + @deleteCount ;
	end ;
	
	-- clean up unused mappings
	set @deleteCount = 1 ;	
	while (@deleteCount > 0)
	begin		
		delete top(@PermanentMappingCount) CSM
		output deleted.ChunkId, deleted.SegmentId into @cleanedSegments (ChunkId, SegmentId)
		from ChunkSegmentMapping CSM with (readpast)
		join @cleanedChunks cc ON CSM.ChunkId = cc.ChunkId
		where not exists (
			select 1 from SegmentedChunk SC
			where SC.ChunkId = cc.ChunkId ) 
		and not exists (
			select 1 from [ReportServerTempDB].dbo.SegmentedChunk TSC
			where TSC.ChunkId = cc.ChunkId ) ;
		set @deleteCount = @@ROWCOUNT ;
		set @MappingsCleaned = @MappingsCleaned + @deleteCount ;
	end ;
	
	-- clean up segments
	set @deleteCount = 1
	while (@deleteCount > 0)
	begin
		delete top (@PermanentSegmentCount) S
		from Segment S with (readpast)
		join @cleanedSegments cs on S.SegmentId = cs.SegmentId
		where not exists (
			select 1 from ChunkSegmentMapping csm
			where csm.SegmentId = cs.SegmentId ) ;
		set @deleteCount = @@ROWCOUNT ;
		set @SegmentsCleaned = @SegmentsCleaned + @deleteCount ;
	end
    
    DELETE FROM @cleanedSnapshots ;
    DELETE FROM @cleanedChunks ;
    DELETE FROM @cleanedSegments ;
       	
    begin transaction	
    DELETE TOP (@TemporarySnapshotCount) [ReportServerTempDB].dbo.SnapshotData 
    output deleted.SnapshotDataID into @cleanedSnapshots(SnapshotDataId)
    FROM [ReportServerTempDB].dbo.SnapshotData with(readpast) 
    WHERE   [ReportServerTempDB].dbo.SnapshotData.PermanentRefCount = 0 AND
            [ReportServerTempDB].dbo.SnapshotData.TransientRefCount = 0 AND
            [ReportServerTempDB].dbo.SnapshotData.Machine = @Machine ;
    SET @SnapshotsCleaned = @SnapshotsCleaned + @@ROWCOUNT ;
    
    DELETE [ReportServerTempDB].dbo.ChunkData FROM [ReportServerTempDB].dbo.ChunkData 
	INNER JOIN @cleanedSnapshots cs
    ON [ReportServerTempDB].dbo.ChunkData.SnapshotDataID = cs.SnapshotDataId
    SET @ChunksCleaned = @ChunksCleaned + @@ROWCOUNT	
    commit
     
   	set @deleteCount = 1 ; 
   	while (@deleteCount > 0)
   	begin		
		delete SC 
		output deleted.ChunkId into @cleanedChunks(ChunkId)
		from [ReportServerTempDB].dbo.SegmentedChunk SC with (readpast)	
		join @cleanedSnapshots cs on SC.SnapshotDataId = cs.SnapshotDataId ;	
		set @deleteCount = @@ROWCOUNT ; 
		set @ChunksCleaned =  @ChunksCleaned + @deleteCount ;
	end ;
	
	-- clean up unused mappings
	set @deleteCount = 1 ;	
	while (@deleteCount > 0)
	begin		
		delete top(@TemporaryMappingCount) CSM
		output deleted.ChunkId, deleted.SegmentId into @cleanedSegments (ChunkId, SegmentId)
		from [ReportServerTempDB].dbo.ChunkSegmentMapping CSM with (readpast)
		join @cleanedChunks cc ON CSM.ChunkId = cc.ChunkId
		where not exists (
			select 1 from [ReportServerTempDB].dbo.SegmentedChunk SC
			where SC.ChunkId = cc.ChunkId ) ;
		set @deleteCount = @@ROWCOUNT ;
		set @MappingsCleaned = @MappingsCleaned + @deleteCount ;
	end ;
		
	select distinct ChunkId from @cleanedSegments ;
		
	-- clean up segments
	set @deleteCount = 1
	while (@deleteCount > 0)
	begin
		delete top (@TemporarySegmentCount) S
		from [ReportServerTempDB].dbo.Segment S with (readpast)
		join @cleanedSegments cs on S.SegmentId = cs.SegmentId
		where not exists (
			select 1 from [ReportServerTempDB].dbo.ChunkSegmentMapping csm
			where csm.SegmentId = cs.SegmentId ) ;
		set @deleteCount = @@ROWCOUNT ;
		set @SegmentsCleaned = @SegmentsCleaned + @deleteCount ;
	end
GO
