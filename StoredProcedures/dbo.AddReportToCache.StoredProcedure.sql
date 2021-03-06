USE [ReportServer]
GO
/****** Object:  StoredProcedure [dbo].[AddReportToCache]    Script Date: 08/11/2020 07:35:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddReportToCache]
@ReportID as uniqueidentifier,
@ExecutionDate datetime,
@SnapshotDataID uniqueidentifier,
@ExpirationDate datetime OUTPUT,
@ScheduleID uniqueidentifier OUTPUT
AS
DECLARE @ExpirationFlags as int
DECLARE @Timeout as int

SET @ExpirationDate = NULL
SET @ScheduleID = NULL
SET @ExpirationFlags = (SELECT ExpirationFlags FROM CachePolicy WHERE ReportID = @ReportID)
IF @ExpirationFlags = 1 -- timeout based
BEGIN
    SET @Timeout = (SELECT CacheExpiration FROM CachePolicy WHERE ReportID = @ReportID)
    SET @ExpirationDate = DATEADD(n, @Timeout, @ExecutionDate)
END
ELSE IF @ExpirationFlags = 2 -- schedule based
BEGIN
    SELECT @ScheduleID=s.ScheduleID, @ExpirationDate=s.NextRunTime 
    FROM Schedule s WITH(UPDLOCK) INNER JOIN ReportSchedule rs ON rs.ScheduleID = s.ScheduleID and rs.ReportAction = 3 WHERE rs.ReportID = @ReportID
END
ELSE
BEGIN
    -- Ignore NULL case. It means that a user set the Report not to be cached after the report execution fired.
    IF @ExpirationFlags IS NOT NULL
    BEGIN
        RAISERROR('Invalid cache flags', 16, 1)
    END
    RETURN
END

-- and to the report cache
INSERT INTO [ReportServerTempDB].dbo.ExecutionCache
(ExecutionCacheID, ReportID, ExpirationFlags, AbsoluteExpiration, RelativeExpiration, SnapshotDataID)
VALUES
(newid(), @ReportID, @ExpirationFlags, @ExpirationDate, @Timeout, @SnapshotDataID )

UPDATE [ReportServerTempDB].dbo.SnapshotData
SET PermanentRefcount = PermanentRefcount + 1,
	IsCached = CONVERT(BIT, 1)
WHERE SnapshotDataID = @SnapshotDataID;
GO
