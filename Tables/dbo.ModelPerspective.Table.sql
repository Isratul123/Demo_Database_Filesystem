USE [ReportServer]
GO
/****** Object:  Table [dbo].[ModelPerspective]    Script Date: 08/11/2020 07:35:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ModelPerspective](
	[ID] [uniqueidentifier] NOT NULL,
	[ModelID] [uniqueidentifier] NOT NULL,
	[PerspectiveID] [ntext] NOT NULL,
	[PerspectiveName] [ntext] NULL,
	[PerspectiveDescription] [ntext] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ModelPerspective]  WITH NOCHECK ADD  CONSTRAINT [FK_ModelPerspectiveModel] FOREIGN KEY([ModelID])
REFERENCES [dbo].[Catalog] ([ItemID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ModelPerspective] CHECK CONSTRAINT [FK_ModelPerspectiveModel]
GO
