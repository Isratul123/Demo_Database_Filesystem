USE [ReportServer]
GO
/****** Object:  StoredProcedure [dbo].[AddDataSource]    Script Date: 08/11/2020 07:35:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddDataSource]
@DSID [uniqueidentifier],
@ItemID [uniqueidentifier] = NULL, -- null for future suport dynamic delivery
@SubscriptionID [uniqueidentifier] = NULL,
@Name [nvarchar] (260) = NULL, -- only for scoped data sources, MUST be NULL for standalone!!!
@Extension [nvarchar] (260) = NULL,
@LinkID [uniqueidentifier] = NULL, -- link id is trusted, if it is provided - we use it
@LinkPath [nvarchar] (425) = NULL, -- if LinkId is not provided we try to look up LinkPath
@CredentialRetrieval [int],
@Prompt [ntext] = NULL,
@ConnectionString [image] = NULL,
@OriginalConnectionString [image] = NULL,
@OriginalConnectStringExpressionBased [bit] = NULL,
@UserName [image] = NULL,
@Password [image] = NULL,
@Flags [int],
@AuthType [int],
@Version [int]
AS

DECLARE @ActualLinkID uniqueidentifier
SET @ActualLinkID = NULL

IF (@LinkID is NULL) AND (@LinkPath is not NULL) BEGIN
   SELECT
      Type, ItemID, NtSecDescPrimary
   FROM
      Catalog LEFT OUTER JOIN SecData ON Catalog.PolicyID = SecData.PolicyID AND SecData.AuthType = @AuthType
   WHERE
      Path = @LinkPath
   SET @ActualLinkID = (SELECT ItemID FROM Catalog WHERE Path = @LinkPath)
END
ELSE BEGIN
   SET @ActualLinkID = @LinkID
END

INSERT
    INTO DataSource
        ([DSID], [ItemID], [SubscriptionID], [Name], [Extension], [Link],
        [CredentialRetrieval], [Prompt],
        [ConnectionString], [OriginalConnectionString], [OriginalConnectStringExpressionBased], 
        [UserName], [Password], [Flags], [Version])
    VALUES
        (@DSID, @ItemID, @SubscriptionID, @Name, @Extension, @ActualLinkID,
        @CredentialRetrieval, @Prompt,
        @ConnectionString, @OriginalConnectionString, @OriginalConnectStringExpressionBased,
        @UserName, @Password, @Flags, @Version)
GO
