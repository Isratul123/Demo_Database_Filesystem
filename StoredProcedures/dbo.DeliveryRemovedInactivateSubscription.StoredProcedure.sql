USE [ReportServer]
GO
/****** Object:  StoredProcedure [dbo].[DeliveryRemovedInactivateSubscription]    Script Date: 08/11/2020 07:35:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeliveryRemovedInactivateSubscription] 
@DeliveryExtension nvarchar(260),
@Status nvarchar(260)
AS
update 
    Subscriptions
set
    [DeliveryExtension] = '',
    [InactiveFlags] = [InactiveFlags] | 1, -- Delivery Provider Removed Flag == 1
    [LastStatus] = @Status
where
    [DeliveryExtension] = @DeliveryExtension
GO
