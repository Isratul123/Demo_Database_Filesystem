USE [ReportServer]
GO
/****** Object:  StoredProcedure [dbo].[RemoveRunningJob]    Script Date: 08/11/2020 07:35:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RemoveRunningJob]
@JobID as nvarchar(32)
AS
SET NOCOUNT OFF
DELETE FROM RunningJobs WHERE JobID = @JobID
GO
