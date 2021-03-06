USE [ReportServer]
GO
/****** Object:  StoredProcedure [dbo].[CopyExecutionSnapshot]    Script Date: 08/11/2020 07:35:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CopyExecutionSnapshot]
@SourceReportID uniqueidentifier,
@TargetReportID uniqueidentifier,
@ReservedUntilUTC datetime
AS

DECLARE @SourceSnapshotDataID uniqueidentifier
SET @SourceSnapshotDataID = (SELECT SnapshotDataID FROM Catalog WHERE ItemID = @SourceReportID)
DECLARE @TargetSnapshotDataID uniqueidentifier
SET @TargetSnapshotDataID = newid()
DECLARE @ChunkID uniqueidentifier

IF @SourceSnapshotDataID IS NOT NULL BEGIN
   -- We need to copy entries in SnapshotData and ChunkData tables.
   INSERT INTO SnapshotData
      (SnapshotDataID, CreatedDate, ParamsHash, QueryParams, EffectiveParams, Description, PermanentRefcount, TransientRefcount, ExpirationDate)
   SELECT
      @TargetSnapshotDataID, SD.CreatedDate, SD.ParamsHash, SD.QueryParams, SD.EffectiveParams, SD.Description, 1, 0, @ReservedUntilUTC
   FROM
      SnapshotData as SD
   WHERE
      SD.SnapshotDataID = @SourceSnapshotDataID

   INSERT INTO ChunkData
      (ChunkID, SnapshotDataID, ChunkName, ChunkType, ChunkFlags, Content, Version)
   SELECT
      newid(), @TargetSnapshotDataID, CD.ChunkName, CD.ChunkType, CD.ChunkFlags, CD.Content, CD.Version
   FROM
      ChunkData as CD
   WHERE
      CD.SnapshotDataID = @SourceSnapshotDataID

   UPDATE Target
   SET
      Target.SnapshotDataID = @TargetSnapshotDataID,
      Target.ExecutionTime = Source.ExecutionTime
   FROM
      Catalog Target,
      Catalog Source
   WHERE
     Source.ItemID = @SourceReportID AND
      Target.ItemID = @TargetReportID
   END
GO
