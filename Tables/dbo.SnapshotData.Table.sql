USE [ReportServer]
GO
/****** Object:  Table [dbo].[SnapshotData]    Script Date: 08/11/2020 07:35:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SnapshotData](
	[SnapshotDataID] [uniqueidentifier] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ParamsHash] [int] NULL,
	[QueryParams] [ntext] NULL,
	[EffectiveParams] [ntext] NULL,
	[Description] [nvarchar](512) NULL,
	[DependsOnUser] [bit] NULL,
	[PermanentRefcount] [int] NOT NULL,
	[TransientRefcount] [int] NOT NULL,
	[ExpirationDate] [datetime] NOT NULL,
	[PageCount] [int] NULL,
	[HasDocMap] [bit] NULL,
	[PaginationMode] [smallint] NULL,
	[ProcessingFlags] [int] NULL,
 CONSTRAINT [PK_SnapshotData] PRIMARY KEY CLUSTERED 
(
	[SnapshotDataID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
