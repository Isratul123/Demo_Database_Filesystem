USE [ReportServer]
GO
/****** Object:  StoredProcedure [dbo].[DeletePersistedStreams]    Script Date: 08/11/2020 07:35:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeletePersistedStreams]
@SessionID varchar(32)
AS
SET NOCOUNT OFF
delete 
    [ReportServerTempDB].dbo.PersistedStream
from 
    (select top 1 * from [ReportServerTempDB].dbo.PersistedStream PS2 where PS2.SessionID = @SessionID) as e1
where 
    e1.SessionID = [ReportServerTempDB].dbo.PersistedStream.[SessionID] and
    e1.[Index] = [ReportServerTempDB].dbo.PersistedStream.[Index]
GO
