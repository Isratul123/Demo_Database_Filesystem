USE [ReportServer]
GO
/****** Object:  StoredProcedure [dbo].[TempChunkExists]    Script Date: 08/11/2020 07:35:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[TempChunkExists]
	@ChunkId uniqueidentifier
AS
BEGIN
	SELECT COUNT(1) FROM [ReportServerTempDB].dbo.SegmentedChunk
	WHERE ChunkId = @ChunkId
END
GO
