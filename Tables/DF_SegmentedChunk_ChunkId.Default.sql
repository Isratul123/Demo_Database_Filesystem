USE [ReportServer]
GO
/****** Object:  Default [DF_SegmentedChunk_ChunkId]    Script Date: 08/11/2020 07:35:15 ******/
ALTER TABLE [dbo].[SegmentedChunk] ADD  CONSTRAINT [DF_SegmentedChunk_ChunkId]  DEFAULT (newsequentialid()) FOR [ChunkId]
GO
