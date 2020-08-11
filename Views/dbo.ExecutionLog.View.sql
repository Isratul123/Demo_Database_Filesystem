USE [ReportServer]
GO
/****** Object:  View [dbo].[ExecutionLog]    Script Date: 08/11/2020 07:35:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  VIEW [dbo].[ExecutionLog]
AS
SELECT top 100
	[InstanceName], 
	[ReportID], 
	[UserName], 
	[RequestType],
	[Format],
	[Parameters],
	[TimeStart],
	[TimeEnd],
	[TimeDataRetrieval],
	[TimeProcessing],
	[TimeRendering],
	CASE([Source])
		WHEN 6 THEN 3
		ELSE [Source]
	END AS Source,		-- Session source doesn't exist in yukon, mark source as snapshot
						-- for in-session requests
	[Status],
	[ByteCount],
	[RowCount]
FROM [ExecutionLogStorage] WITH (NOLOCK)
WHERE [ReportAction] = 1 -- Backwards compatibility log only contains render requests
GO
