USE [ReportServer]
GO
/****** Object:  StoredProcedure [dbo].[DeletePersistedStream]    Script Date: 08/11/2020 07:35:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeletePersistedStream]
@SessionID varchar(32),
@Index int
AS

delete from [ReportServerTempDB].dbo.PersistedStream where SessionID = @SessionID and [Index] = @Index
GO
