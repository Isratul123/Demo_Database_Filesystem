USE [ReportServer]
GO
/****** Object:  StoredProcedure [dbo].[DeepCopySegment]    Script Date: 08/11/2020 07:35:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[DeepCopySegment]
	@ChunkId		uniqueidentifier,
	@IsPermanent	bit,
	@SegmentId		uniqueidentifier,
	@NewSegmentId	uniqueidentifier out
as
begin
	select @NewSegmentId = newid() ;
	if (@IsPermanent = 1) begin
		insert Segment(SegmentId, Content)
		select @NewSegmentId, seg.Content
		from Segment seg
		where seg.SegmentId = @SegmentId ;
				
		update ChunkSegmentMapping
		set SegmentId = @NewSegmentId
		where ChunkId = @ChunkId and SegmentId = @SegmentId ;
	end
	else begin
		insert [ReportServerTempDB].dbo.Segment(SegmentId, Content)
		select @NewSegmentId, seg.Content
		from [ReportServerTempDB].dbo.Segment seg
		where seg.SegmentId = @SegmentId ;
		
		update [ReportServerTempDB].dbo.ChunkSegmentMapping
		set SegmentId = @NewSegmentId
		where ChunkId = @ChunkId and SegmentId = @SegmentId ; 
	end
end
GO
