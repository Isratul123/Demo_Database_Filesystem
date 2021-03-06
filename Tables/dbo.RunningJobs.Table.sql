USE [ReportServer]
GO
/****** Object:  Table [dbo].[RunningJobs]    Script Date: 08/11/2020 07:35:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RunningJobs](
	[JobID] [nvarchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[ComputerName] [nvarchar](32) NOT NULL,
	[RequestName] [nvarchar](425) NOT NULL,
	[RequestPath] [nvarchar](425) NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[Description] [ntext] NULL,
	[Timeout] [int] NOT NULL,
	[JobAction] [smallint] NOT NULL,
	[JobType] [smallint] NOT NULL,
	[JobStatus] [smallint] NOT NULL,
 CONSTRAINT [PK_RunningJobs] PRIMARY KEY CLUSTERED 
(
	[JobID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
