USE [ReportServer]
GO
/****** Object:  StoredProcedure [dbo].[CreateNewActiveSubscription]    Script Date: 08/11/2020 07:35:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CreateNewActiveSubscription]
@ActiveID uniqueidentifier,
@SubscriptionID uniqueidentifier
AS


-- Insert into the activesubscription table
insert into [ActiveSubscriptions] 
    (
    [ActiveID], 
    [SubscriptionID],
    [TotalNotifications],
    [TotalSuccesses],
    [TotalFailures]
    )
values
    (
    @ActiveID,
    @SubscriptionID,
    NULL,
    0,
    0
    )
GO
