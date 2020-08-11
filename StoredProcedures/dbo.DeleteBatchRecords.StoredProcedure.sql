USE [ReportServer]
GO
/****** Object:  StoredProcedure [dbo].[DeleteBatchRecords]    Script Date: 08/11/2020 07:35:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteBatchRecords]
@BatchID uniqueidentifier
AS
SET NOCOUNT OFF
DELETE
FROM [Batch]
WHERE BatchID = @BatchID
GO
