USE [ReportServer]
GO
/****** Object:  StoredProcedure [dbo].[DeleteNotification]    Script Date: 08/11/2020 07:35:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteNotification] 
@ID uniqueidentifier
AS
delete from [Notifications] where [NotificationID] = @ID
GO
