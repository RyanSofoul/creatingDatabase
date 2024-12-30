--RAWNursery Week12
USE master
IF (NOT EXISTS (
		SELECT [Name] 
		FROM sys.databases 
		WHERE ([Name] = 'RAWNursery') 
	)
)
BEGIN
	CREATE DATABASE RAWNursery;
	PRINT 'Created RAWNursery'
	END
ELSE
	PRINT 'RAWNursery Already Exists'

GO



USE RAWNursery
GO

CREATE TABLE [dbo].[Customer](
	[CustomerID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[FirstName] VARCHAR(256) NOT NULL,
	[LastName] VARCHAR(256) NOT NULL,
	[EmailAddress] VARCHAR(256) NOT NULL,
	[PhoneNumber] VARCHAR(13) NOT NULL,
	[ModifiedBy] VARCHAR(256) NOT NULL,
	[DateModified] DATETIME NOT NULL,
	[IsDeleted] BIT NOT NULL
);

CREATE TABLE [dbo].[CustomerAddress](
	[CustomerAddressID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[CustomerID] INT NOT NULL REFERENCES Customer(CustomerID),
	[AddressLine1] VARCHAR(256) NOT NULL,
	[AddressLine2] VARCHAR(256) NOT NULL,
	[City] VARCHAR(256) NOT NULL,
	[State] CHAR(2) NOT NULL,
	[ZipCode] VARCHAR(256) NOT NULL,
	[ModifiedBy] VARCHAR(256) NOT NULL,
	[DateModified] DATETIME NOT NULL,
	[IsDeleted] BIT NOT NULL
);

CREATE TABLE [dbo].[EmploymentType](
	[EmploymentTypeID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[EmploymentTypeName] VARCHAR(256) NOT NULL,
	[ModifiedBy] VARCHAR(256) NOT NULL,
	[DateModified] DATETIME NOT NULL,
	[IsDeleted] BIT NOT NULL
);

CREATE TABLE [dbo].[Position](
	[PositionID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[PositionName] VARCHAR(256) NOT NULL,
	[EmploymentTypeID] INT NOT NULL REFERENCES EmploymentType(EmploymentTypeID),
	[ModifiedBy] VARCHAR(256) NOT NULL,
	[DateModified] DATETIME NOT NULL,
	[IsDeleted] BIT NOT NULL
);

CREATE TABLE [dbo].[Employee](
	[EmployeeID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[SSN] VARCHAR(11) NOT NULL,
	[FirstName] VARCHAR(256) NOT NULL,
	[LastName] VARCHAR(256) NOT NULL,
	[PositionID] INT NOT NULL REFERENCES Position(PositionID),
	[EmailAddress] VARCHAR(256) NOT NULL,
	[PhoneNumber] VARCHAR(13) NOT NULL,
	[ManagerID] INT NOT NULL REFERENCES Employee(EmployeeID),
	[StartDate] DATETIME NOT NULL,
	[EndDate] DATETIME,
	[ModifiedBy] VARCHAR(256) NOT NULL,
	[DateModified] DATETIME NOT NULL,
	[IsDeleted] BIT NOT NULL
);

CREATE TABLE [dbo].[EmployeeAddress](
	[EmployeeAddressID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[EmployeeID] INT NOT NULL REFERENCES Employee(EmployeeID),
	[AddressLine1] VARCHAR(256) NOT NULL,
	[AddressLine2] VARCHAR(256) NOT NULL,
	[City] VARCHAR(256) NOT NULL,
	[State] CHAR(2) NOT NULL,
	[ZipCode] VARCHAR(256) NOT NULL,
	[ModifiedBy] VARCHAR(256) NOT NULL,
	[DateModified] DATETIME NOT NULL,
	[IsDeleted] BIT NOT NULL
);

CREATE TABLE [dbo].[PaymentType](
	[PaymentTypeID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[PaymentTypeName] VARCHAR(256) NOT NULL,
	[ModifiedBy] VARCHAR(256) NOT NULL,
	[DateModified] DATETIME NOT NULL,
	[IsDeleted] BIT NOT NULL
);

CREATE TABLE [dbo].[SalesOrder](
	[SalesOrderID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[OrderDate] DATETIME NOT NULL,
	[CustomerID] INT NOT NULL REFERENCES Customer(CustomerID),
	[EmployeeID] INT NOT NULL REFERENCES Employee(EmployeeID),
	[DatePickedUp] DATETIME NULL,
	[ModifiedBy] VARCHAR(256) NOT NULL,
	[DateModified] DATETIME NOT NULL,
	[IsDeleted] BIT NOT NULL
);

GO

CREATE FUNCTION udf_CalculateTax
(
	@OrderAmount MONEY
)

RETURNS MONEY

AS

BEGIN
	DECLARE @ReturnVal MONEY

	SET @ReturnVal=@OrderAmount*0.08

	RETURN @ReturnVal
	
END
GO


CREATE TABLE [dbo].[SalesOrderPayment](
	[SalesOrderPaymentID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[SalesOrderID] INT NOT NULL REFERENCES [SalesOrder](SalesOrderID),
	[PaymentTypeID] INT NOT NULL REFERENCES PaymentType(PaymentTypeID),
	[OrderAmount] MONEY NOT NULL,	
	[PaymentAmount] AS ROUND(OrderAmount+dbo.udf_CalculateTax(OrderAmount),2),	
	[ModifiedBy] VARCHAR(256) NOT NULL,
	[DateModified] DATETIME NOT NULL,
	[IsDeleted] BIT NOT NULL
);

CREATE TABLE [dbo].[Promotion](
	[PromotionID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[PromotionDescription] VARCHAR(256) NOT NULL,
	[PromotionCode] VARCHAR(16) NOT NULL,
	[StartDate] DATETIME NULL,
	[EndDate] DATETIME NULL,
	[DiscountPercentage] MONEY NOT NULL,
	[ModifiedBy] VARCHAR(256) NOT NULL,
	[DateModified] DATETIME NOT NULL,
	[IsDeleted] BIT NOT NULL
);
GO


CREATE TABLE [dbo].[Zone](
    [ZoneID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [ZoneName] VARCHAR(256) NOT NULL,
    [TemperatureRange] VARCHAR(256) NOT NULL,
    [ModifiedBy] VARCHAR(256) NOT NULL,
    [DateModified] DATETIME NOT NULL,
    [IsDeleted] BIT NOT NULL
);

CREATE TABLE [dbo].[LightRequirement](
    [LightRequirementID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [Description] VARCHAR(256) NOT NULL,
    [ModifiedBy] VARCHAR(256) NOT NULL,
    [DateModified] DATETIME NOT NULL,
    [IsDeleted] BIT NOT NULL
);

CREATE TABLE [dbo].[ProductType](
    [ProductTypeID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [ProductTypeName] VARCHAR(256) NOT NULL,
	[ProductTypeDescription] VARCHAR(256) NOT NULL,
    [ModifiedBy] VARCHAR(256) NOT NULL,
    [DateModified] DATETIME NOT NULL,
    [IsDeleted] BIT NOT NULL
);

CREATE TABLE [dbo].[Product](
    [ProductID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [ProductTypeID] INT NOT NULL REFERENCES ProductType(ProductTypeID),
	[ProductName] VARCHAR(256) NOT NULL,
	[ProductDescription] VARCHAR(256) NOT NULL,
	[UnitOfMeasurement] VARCHAR(256) NOT NULL,
	[ProductSalesPrice] MONEY NOT NULL,  
    [ModifiedBy] VARCHAR(256) NOT NULL,
    [DateModified] DATETIME NOT NULL,
    [IsDeleted] BIT NOT NULL
);

CREATE TABLE [dbo].[Plant](
    [PlantID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [ProductID] INT NOT NULL REFERENCES Product(ProductID),
	[CommonName] VARCHAR(256) NOT NULL,
	[ScientificName] VARCHAR(256) NOT NULL,
	[HeightMin] MONEY NOT NULL, 
	[HeightMax] MONEY NOT NULL,
    [ModifiedBy] VARCHAR(256) NOT NULL,
    [DateModified] DATETIME NOT NULL,
    [IsDeleted] BIT NOT NULL
);

CREATE TABLE [dbo].[PlantLightRequirement](
    [PlantLightRequirementID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [PlantID] INT NOT NULL REFERENCES Plant(PlantID),
	[LightRequirementID] INT NOT NULL REFERENCES LightRequirement(LightRequirementID),
    [ModifiedBy] VARCHAR(256) NOT NULL,
    [DateModified] DATETIME NOT NULL,
    [IsDeleted] BIT NOT NULL
);

CREATE TABLE [dbo].[PlantZone](
    [PlantZoneID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [PlantID] INT NOT NULL REFERENCES Plant(PlantID),
	[ZoneID] INT NOT NULL REFERENCES Zone(ZoneID),
    [ModifiedBy] VARCHAR(256) NOT NULL,
    [DateModified] DATETIME NOT NULL,
    [IsDeleted] BIT NOT NULL
);

CREATE TABLE [dbo].[Inventory](
    [InventoryID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [ProductID] INT NOT NULL REFERENCES Product(ProductID),
	[Quantity] MONEY NOT NULL, 
    [ModifiedBy] VARCHAR(256) NOT NULL,
    [DateModified] DATETIME NOT NULL,
    [IsDeleted] BIT NOT NULL
);


CREATE TABLE [dbo].[Vendor](
	[VendorID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[CompanyName] VARCHAR(256) NOT NULL,
	[Website] VARCHAR(256) NOT NULL,
	[EmailAddress] VARCHAR(256) NOT NULL,
	[PhoneNumber] VARCHAR(13) NOT NULL,
	[ModifiedBy] VARCHAR(256) NOT NULL,
	[DateModified] DATETIME NOT NULL,
	[IsDeleted] BIT NOT NULL
);


CREATE TABLE [dbo].[VendorAddress](
	[VendorAddressID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[VendorID] INT NOT NULL REFERENCES Vendor(VendorID),
	[AddressLine1] VARCHAR(256) NOT NULL,
	[AddressLine2] VARCHAR(256) NOT NULL,
	[City] VARCHAR(256) NOT NULL,
	[State] CHAR(2) NOT NULL,
	[ZipCode] VARCHAR(256) NOT NULL,
	[ModifiedBy] VARCHAR(256) NOT NULL,
	[DateModified] DATETIME NOT NULL,
	[IsDeleted] BIT NOT NULL
);
GO


CREATE TABLE [dbo].[OrderItem](
	[OrderItemID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[SalesOrderID] INT NOT NULL REFERENCES SalesOrder(SalesOrderID),
	[ProductID] INT NOT NULL REFERENCES Product(ProductID),
	[Quantity] MONEY NOT NULL,
	[SalesPrice] MONEY NOT NULL,
	[SalesAmount] MONEY NOT NULL,
	[ModifiedBy] VARCHAR(256) NOT NULL,
	[DateModified] DATETIME NOT NULL,
	[IsDeleted] BIT NOT NULL
);

	
CREATE TABLE [dbo].[OrderPromotion](
	[OrderPromotionID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[SalesOrderID] INT NOT NULL REFERENCES SalesOrder(SalesOrderID),
	[PromotionID] INT NOT NULL REFERENCES Promotion(PromotionID),
	[ModifiedBy] VARCHAR(256) NOT NULL,
	[DateModified] DATETIME NOT NULL,
	[IsDeleted] BIT NOT NULL
);

	
CREATE TABLE [dbo].[ProductVendor](
	[ProductVendorID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[ProductID] INT NOT NULL REFERENCES Product(ProductID),
	[VendorID] INT NOT NULL REFERENCES Vendor(VendorID),
	[ModifiedBy] VARCHAR(256) NOT NULL,
	[DateModified] DATETIME NOT NULL,
	[IsDeleted] BIT NOT NULL
);
GO


CREATE TABLE [dbo].[CustomerCommunicationPreference](
	[CustomerCommunicationPreferenceID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[CustomerID] INT NOT NULL REFERENCES Customer(CustomerID),
	[ReceiveEmailPromotions] BIT NOT NULL,
	[ReceiveSMSPromotions] BIT NOT NULL,
	[ModifiedBy] VARCHAR(256) NOT NULL,
	[DateModified] DATETIME NOT NULL,
	[IsDeleted] BIT NOT NULL
);
GO


--FUNCTIONS---------------------------------------------------------------------------------------------------------------------------------------


-- =============================================
-- Author:		 Bill Weiss
-- Create date:  13-NOV-2024
-- Description:	 Checks if a promotion is greater than the max allowed percentage .15
-- =============================================
CREATE FUNCTION udf_CheckOrderPromotionMax 
(
	@Discount MONEY
)

RETURNS BIT

AS

BEGIN
	DECLARE @ReturnVal BIT

	IF (@Discount<=0.15) BEGIN
		SET @ReturnVal = 1
		END
	ELSE BEGIN
		SET @ReturnVal = 0
	END

	RETURN @ReturnVal
	
END
GO

ALTER TABLE [Promotion] ADD CONSTRAINT chk_PromotionMaxPercentage CHECK (dbo.udf_CheckOrderPromotionMax(DiscountPercentage)=1)
GO

--test
--select dbo.udf_CheckOrderPromotionMax(0.15);



-- =============================================
-- Author:		 Ryan Sofoul
-- Create date:  19-NOV-2024
-- Description:	 Function for Number of Employees by a Position'
-- =============================================

CREATE FUNCTION udf_EmployeeCountByPosition
(
	@Position VARCHAR(50)
)

RETURNS INT

AS

BEGIN
	DECLARE @EmployeeCount INT;
	
	SELECT 
		@EmployeeCount = COUNT(*)
	FROM 
		Employee E INNER JOIN
		Position P ON (E.PositionID = P.PositionID)
	WHERE P.PositionName = @Position;

	RETURN @EmployeeCount;

END
GO

--test
--select dbo.udf_EmployeeCountByPosition ('Manager')


-- =============================================
-- Author:		 Alex Pavlukov
-- Create date:  18-NOV-2024'
-- Description:	 Function to get light and zone requirements for a given plantid
-- =============================================

CREATE FUNCTION dbo.GetPlantRequirements (@PlantID INT)

RETURNS VARCHAR(400)

AS

BEGIN
    DECLARE @Requirements VARCHAR(400) = '';

    SELECT @Requirements = @Requirements + 
        CASE WHEN LEN(@Requirements) > 0 THEN ', ' ELSE '' END + z.ZoneName
    FROM Zone z
    JOIN PlantZone pz ON z.ZoneID = pz.ZoneID
    WHERE pz.PlantID = @PlantID;

    SELECT @Requirements = @Requirements + 
        CASE WHEN LEN(@Requirements) > 0 THEN ', ' ELSE '' END + lr.Description
    FROM LightRequirement lr
    JOIN PlantLightRequirement plr ON lr.LightRequirementID = plr.LightRequirementID
    WHERE plr.PlantID = @PlantID;;

    RETURN @Requirements;
END;
GO

--test
--SELECT dbo.GetPlantRequirements(5) AS PlantRequirements;

-- =============================================
-- Author:		 Bill Weiss
-- Create date:  13-NOV-2024
-- Description:	 Checks if a promotion is greater than the max allowed percentage .15
-- =============================================



--VIEWS---------------------------------------------------------------------------------------------------------------------------------------


-- =============================================
-- Author:		 Bill Weiss
-- Create date:  12-NOV-2024
-- Description:	 View for Sales Orders'
-- =============================================
CREATE VIEW vw_SalesOrderPayment 

AS

SELECT 
	SO.SalesOrderID,
	SO.OrderDate,
	SO.CustomerID,
	EMP.FirstName + ' ' + EMP.LastName 'EmployeeName',
	PT.PaymentTypeName,
	SOP.PaymentAmount
FROM
	SalesOrder SO INNER JOIN
	Employee EMP ON (SO.EmployeeID = EMP.EmployeeID) INNER JOIN
	SalesOrderPayment SOP ON (SO.SalesOrderID = SOP.SalesOrderID) INNER JOIN
	PaymentType PT ON (SOP.PaymentTypeID = PT.PaymentTypeID)

GO


-- =============================================
-- Author:		 Ryan Sofoul
-- Create date:  19-NOV-2024
-- Description:	 View for Customer Communication List'
-- =============================================
CREATE VIEW vw_CustomerCommunicationList 

AS

SELECT 
	C.CustomerID,
	C.FirstName + ' ' + C.LastName AS CustomerName,
	C.EmailAddress,
	C.PhoneNumber,
	CASE
		WHEN CCP.ReceiveEmailPromotions = 1 AND CCP.ReceiveSMSPromotions = 1 THEN 'Email and SMS'
		WHEN CCP.ReceiveEmailPromotions = 1 THEN 'Email Only'
		WHEN CCP.ReceiveSMSPromotions = 1 THEN 'SMS Only'
		ELSE 'None'
	END AS CommunicationPreference
FROM
	Customer C INNER JOIN
	CustomerCommunicationPreference CCP ON (C.CustomerID = CCP.CustomerID)

GO


-- =============================================
-- Author:		 Alex Pavlukov
-- Create date:  18-NOV-2024'
-- Description:	 View for Product Inventory
-- =============================================
CREATE VIEW vw_ProductInventory 

AS

SELECT
    p.ProductID,
    p.ProductName,
    p.ProductDescription,
    p.UnitOfMeasurement,
    p.ProductSalesPrice AS Price,
    SUM(i.Quantity) AS TotalStock, 
    pt.ProductTypeName,
    pt.ProductTypeDescription
FROM Product p
	JOIN Inventory i ON p.ProductID = i.ProductID
	JOIN ProductType pt ON p.ProductTypeID = pt.ProductTypeID
WHERE i.IsDeleted = 0
GROUP BY 
    p.ProductID, 
    p.ProductName, 
    p.ProductDescription, 
    p.UnitOfMeasurement, 
    p.ProductSalesPrice,
    pt.ProductTypeName,
    pt.ProductTypeDescription;

GO

--PROCEDURES----------------------------------------------------------------
-- =============================================
-- Author:		 Bill Weiss
-- Create date:  14-NOV-2024
-- Description:	 Create a new OrderItem
-- =============================================


CREATE PROCEDURE [dbo].[sp_CreateOrderItem]
(
	@SalesOrderID INT,
	@ProductID INT,
	@Quantity MONEY,
	@SalesPrice MONEY,
	@SalesAmount MONEY,
	@ModifiedBy VARCHAR(256),
	@DateModified DATETIME,
	@IsDeleted BIT
)

AS

BEGIN
	
INSERT INTO dbo.OrderItem
(
	SalesOrderID,
	ProductID,
	Quantity,
	SalesPrice,
	SalesAmount,
	ModifiedBy,
	DateModified,
	IsDeleted
)

VALUES
(	
	@SalesOrderID,
	@ProductID,
	@Quantity,
	@SalesPrice,
	@SalesAmount,
	@ModifiedBy,
	@DateModified,
	@IsDeleted
)

END

GO


-- =============================================
-- Author:		 Bill Weiss
-- Create date:  14-NOV-2024
-- Description:	 Create a new OrderPromotion
-- =============================================

CREATE PROCEDURE [dbo].[sp_CreateOrderPromotion]
(
	@SalesOrderID INT,
	@PromotionID INT,
	@ModifiedBy VARCHAR(256),
	@DateModified DATETIME,
	@IsDeleted BIT
)

AS

BEGIN
	
INSERT INTO dbo.OrderPromotion
(
	SalesOrderID,
	PromotionID,
	ModifiedBy,
	DateModified,
	IsDeleted
)

VALUES
(	
	@SalesOrderID,
	@PromotionID,
	@ModifiedBy,
	@DateModified,
	@IsDeleted
)

END



GO


-- =============================================
-- Author:		 Bill Weiss
-- Create date:  14-NOV-2024
-- Description:	 Create a new ProductVendor
-- =============================================

CREATE PROCEDURE [dbo].[sp_CreateProductVendor]
(
	@ProductID INT,
	@VendorID INT,
	@ModifiedBy VARCHAR(256),
	@DateModified DATETIME,
	@IsDeleted BIT
)

AS

BEGIN
	
INSERT INTO dbo.ProductVendor
(
	ProductID,
	VendorID,
	ModifiedBy,
	DateModified,
	IsDeleted
)

VALUES
(	
	@ProductID,
	@VendorID,
	@ModifiedBy,
	@DateModified,
	@IsDeleted
)

END

GO


-- =============================================
-- Author:		 Bill Weiss
-- Create date:  08-NOV-2024
-- Description:	 Create a new customer'
-- =============================================

CREATE PROCEDURE [dbo].[sp_CreateCustomer] 
(
	@FirstName [VARCHAR](256),
	@LastName [VARCHAR](256),
	@EmailAddress [VARCHAR](256),
	@PhoneNumber [VARCHAR](13),
	@ModifiedBy [VARCHAR](256),
	@DateModified [DATETIME],
	@IsDeleted [BIT]
)
AS

BEGIN
	
INSERT INTO dbo.Customer
(
	 FirstName,
	 LastName,
	 EmailAddress,
	 PhoneNumber,
	 ModifiedBy,
	 DateModified,
	 IsDeleted
)

VALUES
(	
	@FirstName, 
    @LastName, 
    @EmailAddress, 
    @PhoneNumber,
    @ModifiedBy,
    @DateModified,
    @IsDeleted
)

END

GO


-- =============================================
-- Author:		 Bill Weiss
-- Create date:  08-NOV-2024
-- Description:	 Create a new customer address
-- =============================================

CREATE PROCEDURE [dbo].[sp_CreateCustomerAddress] 
(
	@CustomerID INT,
	@AddressLine1 VARCHAR(256),
	@AddressLine2 VARCHAR(256),
	@City VARCHAR(256),
	@State CHAR(2),
	@ZipCode VARCHAR(256),
	@ModifiedBy VARCHAR(256),
	@DateModified DATETIME,
	@IsDeleted BIT
)

AS

BEGIN
	
INSERT INTO dbo.CustomerAddress
(
	 CustomerID,
	 AddressLine1,
	 AddressLine2,
	 City,
	 State,
	 ZipCode,
	 ModifiedBy,
	 DateModified,
	 IsDeleted
)

VALUES
(	
	@CustomerID,
	@AddressLine1,
	@AddressLine2,
	@City,
	@State,
	@ZipCode,
	@ModifiedBy,
	@DateModified,
	@IsDeleted
)

END

GO

-- =============================================
-- Author:		 Bill Weiss
-- Create date:  08-NOV-2024
-- Description:	 Create a new employee
-- =============================================

CREATE PROCEDURE [dbo].[sp_CreateEmployee]
(
	@SSN VARCHAR(11),
	@FirstName VARCHAR(256),
	@LastName VARCHAR(256),
	@PositionID INT,
	@EmailAddress VARCHAR(256),
	@PhoneNumber VARCHAR(13),
	@ManagerID INT,
	@StartDate DATETIME,
	@EndDate DATETIME,
	@ModifiedBy VARCHAR(256),
	@DateModified DATETIME,
	@IsDeleted BIT
)

AS

BEGIN
	
INSERT INTO dbo.Employee
(
	 SSN,
	 FirstName,
	 LastName,
	 PositionID,
	 EmailAddress,
	 PhoneNumber,
	 ManagerID,
	 StartDate,
	 EndDate,
	 ModifiedBy,
	 DateModified,
	 IsDeleted
)

VALUES
(	
	@SSN,
	@FirstName,
	@LastName,
	@PositionID,
	@EmailAddress,
	@PhoneNumber,
	@ManagerID,
	@StartDate,
	@EndDate,
	@ModifiedBy,
	@DateModified,
	@IsDeleted
)

END

GO

-- =============================================
-- Author:		 Bill Weiss
-- Create date:  08-NOV-2024
-- Description:	 Create a new employee address
-- =============================================

CREATE PROCEDURE [dbo].[sp_CreateEmployeeAddress] 
(
	@EmployeeID INT,
	@AddressLine1 VARCHAR(256),
	@AddressLine2 VARCHAR(256),
	@City VARCHAR(256),
	@State CHAR(2),
	@ZipCode VARCHAR(256),
	@ModifiedBy VARCHAR(256),
	@DateModified DATETIME,
	@IsDeleted BIT
)

AS

BEGIN
	
INSERT INTO dbo.EmployeeAddress
(
	 EmployeeID,
	 AddressLine1,
	 AddressLine2,
	 City,
	 State,
	 ZipCode,
	 ModifiedBy,
	 DateModified,
	 IsDeleted
)

VALUES
(	
	@EmployeeID,
	@AddressLine1,
	@AddressLine2,
	@City,
	@State,
	@ZipCode,
	@ModifiedBy,
	@DateModified,
	@IsDeleted
)

END

GO
-- =============================================
-- Author:		 Bill Weiss
-- Create date:  08-NOV-2024
-- Description:	 Create a new employment type
-- =============================================

CREATE PROCEDURE [dbo].[sp_CreateEmploymentType]
(
	@EmploymentTypeName VARCHAR(256),
	@ModifiedBy VARCHAR(256),
	@DateModified DATETIME,
	@IsDeleted BIT
)

AS

BEGIN
	
INSERT INTO dbo.EmploymentType
(
	 EmploymentTypeName,
	 ModifiedBy,
	 DateModified,
	 IsDeleted
)

VALUES
(	
	@EmploymentTypeName,
	@ModifiedBy,
	@DateModified,
	@IsDeleted
)

END

GO
-- =============================================
-- Author:		 Bill Weiss
-- Create date:  08-NOV-2024
-- Description:	 Create a new payment type
-- =============================================

CREATE PROCEDURE [dbo].[sp_CreatePaymentType]
(
	@PaymentTypeName VARCHAR(256),
	@ModifiedBy VARCHAR(256),
	@DateModified DATETIME,
	@IsDeleted BIT
)

AS

BEGIN
	
INSERT INTO dbo.PaymentType
(
	 PaymentTypeName,
	 ModifiedBy,
	 DateModified,
	 IsDeleted
)

VALUES
(	
	@PaymentTypeName,
	@ModifiedBy,
	@DateModified,
	@IsDeleted
)

END

GO
-- =============================================
-- Author:		 Bill Weiss
-- Create date:  08-NOV-2024
-- Description:	 Create a new position
-- =============================================

CREATE PROCEDURE [dbo].[sp_CreatePosition]
(
	@PositionName VARCHAR(256),
	@EmploymentTypeID INT,
	@ModifiedBy VARCHAR(256),
	@DateModified DATETIME,
	@IsDeleted BIT
)

AS

BEGIN
	
INSERT INTO dbo.Position
(
	 PositionName,
	 EmploymentTypeID,
	 ModifiedBy,
	 DateModified,
	 IsDeleted
)

VALUES
(	
	@PositionName,
	@EmploymentTypeID,
	@ModifiedBy,
	@DateModified,
	@IsDeleted
)

END

GO
-- =============================================
-- Author:		 Bill Weiss
-- Create date:  08-NOV-2024
-- Description:	 Create a new promotion
-- =============================================

CREATE PROCEDURE [dbo].[sp_CreatePromotion]
(
	@PromotionDescription VARCHAR(256),
	@PromotionCode VARCHAR(16),
	@StartDate DATETIME,
	@EndDate DATETIME,
	@DiscountPercentage MONEY,
	@ModifiedBy VARCHAR(256),
	@DateModified DATETIME,
	@IsDeleted BIT
)



AS

BEGIN
	
INSERT INTO dbo.Promotion
(
	PromotionDescription,
	PromotionCode,
	StartDate,
	EndDate,
	DiscountPercentage,
	ModifiedBy,
	DateModified,
	IsDeleted
)

VALUES
(	
	@PromotionDescription,
	@PromotionCode,
	@StartDate,
	@EndDate,
	@DiscountPercentage,
	@ModifiedBy,
	@DateModified,
	@IsDeleted
)

END

GO
-- =============================================
-- Author:		 Bill Weiss
-- Create date:  08-NOV-2024
-- Description:	 Create a new sales order
-- =============================================

CREATE PROCEDURE [dbo].[sp_CreateSalesOrder]
(
	@OrderDate DATETIME,
	@CustomerID INT,
	@EmployeeID INT,
	@DatePickedUp DATETIME,
	@ModifiedBy VARCHAR(256),
	@DateModified DATETIME,
	@IsDeleted BIT
)

AS

BEGIN
	
INSERT INTO [dbo].[SalesOrder]
(
	OrderDate,
	CustomerID,
	EmployeeID,
	DatePickedUp,
	ModifiedBy,
	DateModified,
	IsDeleted
)

VALUES
(	
	@OrderDate,
	@CustomerID,
	@EmployeeID,
	@DatePickedUp,
	@ModifiedBy,
	@DateModified,
	@IsDeleted
)

END

GO
-- =============================================
-- Author:		 Bill Weiss
-- Create date:  08-NOV-2024
-- Description:	 Create a sales order payment
-- =============================================

CREATE PROCEDURE [dbo].[sp_CreateSalesOrderPayment]
(
	@SalesOrderID INT,
	@PaymentTypeID INT,	
	@OrderAmount MONEY,
	@ModifiedBy VARCHAR(256),
	@DateModified DATETIME,
	@IsDeleted BIT
)

AS

BEGIN
	
INSERT INTO [dbo].[SalesOrderPayment]
(
	SalesOrderID,
	PaymentTypeID,
	OrderAmount,
	ModifiedBy,
	DateModified,
	IsDeleted
)

VALUES
(	
	@SalesOrderID,
	@PaymentTypeID,
	@OrderAmount,
	@ModifiedBy,
	@DateModified,
	@IsDeleted
)

END

GO
-- =============================================
-- Author:		 Bill Weiss
-- Create date:  08-NOV-2024
-- Description:	 Create a new vendor
-- =============================================

CREATE PROCEDURE [dbo].[sp_CreateVendor]
(
	@CompanyName VARCHAR(256),
	@Website VARCHAR(256),
	@EmailAddress VARCHAR(256),
	@PhoneNumber VARCHAR(13),
	@ModifiedBy VARCHAR(256),
	@DateModified DATETIME,
	@IsDeleted BIT
)



AS

BEGIN
	
INSERT INTO dbo.Vendor
(
	CompanyName,
	Website,
	EmailAddress,
	PhoneNumber,
	ModifiedBy,
	DateModified,
	IsDeleted
)

VALUES
(	
	@CompanyName,
	@Website,
	@EmailAddress,
	@PhoneNumber,
	@ModifiedBy,
	@DateModified,
	@IsDeleted
)

END

GO
-- =============================================
-- Author:		 Bill Weiss
-- Create date:  08-NOV-2024
-- Description:	 Create a new vendor address
-- =============================================

CREATE PROCEDURE [dbo].[sp_CreateVendorAddress] 
(
	@VendorID INT,
	@AddressLine1 VARCHAR(256),
	@AddressLine2 VARCHAR(256),
	@City VARCHAR(256),
	@State CHAR(2),
	@ZipCode VARCHAR(256),
	@ModifiedBy VARCHAR(256),
	@DateModified DATETIME,
	@IsDeleted BIT
)

AS

BEGIN
	
INSERT INTO dbo.VendorAddress
(
	 VendorID,
	 AddressLine1,
	 AddressLine2,
	 City,
	 State,
	 ZipCode,
	 ModifiedBy,
	 DateModified,
	 IsDeleted
)

VALUES
(	
	@VendorID,
	@AddressLine1,
	@AddressLine2,
	@City,
	@State,
	@ZipCode,
	@ModifiedBy,
	@DateModified,
	@IsDeleted
)

END


GO

-- =============================================
-- Author:		 Alex Pauvlukov
-- Create date:  14-NOV-2024
-- Description:	 Create a new Zone
-- =============================================
CREATE PROCEDURE [dbo].[sp_CreateZone]
    @ZoneName VARCHAR(256),
    @TemperatureRange VARCHAR(256),
    @ModifiedBy VARCHAR(256),
    @DateModified DATETIME,
    @IsDeleted BIT
AS
BEGIN
    INSERT INTO [dbo].[Zone] (
        [ZoneName], 
        [TemperatureRange], 
        [ModifiedBy], 
        [DateModified], 
        [IsDeleted]
    )
    VALUES (
        @ZoneName, 
        @TemperatureRange, 
        @ModifiedBy, 
        @DateModified, 
        @IsDeleted
    );
	END;
GO

-- =============================================
-- Author:		 Alex Pauvlukov
-- Create date:  14-NOV-2024
-- Description:	 Create a new Light Requirement
-- =============================================

CREATE PROCEDURE [dbo].[sp_CreateLightRequirement]
    @Description VARCHAR(256),
    @ModifiedBy VARCHAR(256),
    @DateModified DATETIME,
    @IsDeleted BIT
AS
BEGIN
    INSERT INTO [dbo].[LightRequirement] (
        [Description], 
        [ModifiedBy], 
        [DateModified], 
        [IsDeleted]
    )
    VALUES (
        @Description, 
        @ModifiedBy, 
        @DateModified, 
        @IsDeleted
    );
    END;
  
GO


-- =============================================
-- Author:		 Alex Pauvlukov
-- Create date:  14-NOV-2024
-- Description:	 Create a new Product Type
-- =============================================
CREATE PROCEDURE [dbo].[sp_CreateProductType]
    @ProductTypeName VARCHAR(256),
    @ProductTypeDescription VARCHAR(256),
    @ModifiedBy VARCHAR(256),
    @DateModified DATETIME,
    @IsDeleted BIT
AS
BEGIN
    INSERT INTO [dbo].[ProductType] (
        [ProductTypeName], 
        [ProductTypeDescription], 
        [ModifiedBy], 
        [DateModified], 
        [IsDeleted]
    )
    VALUES (
        @ProductTypeName, 
        @ProductTypeDescription, 
        @ModifiedBy, 
        @DateModified, 
        @IsDeleted
    );
    END;
GO


-- =============================================
-- Author:		 Alex Pauvlukov
-- Create date:  14-NOV-2024
-- Description:	 Create a new Product
-- =============================================
CREATE PROCEDURE [dbo].[sp_CreateProduct]
    @ProductTypeID INT,
    @ProductName VARCHAR(256),
    @ProductDescription VARCHAR(256),
    @UnitOfMeasurement VARCHAR(256),
    @ProductSalesPrice MONEY,
    @ModifiedBy VARCHAR(256),
    @DateModified DATETIME,
    @IsDeleted BIT
AS
BEGIN
    INSERT INTO [dbo].[Product] (
        [ProductTypeID], 
        [ProductName], 
        [ProductDescription], 
        [UnitOfMeasurement], 
        [ProductSalesPrice], 
        [ModifiedBy], 
        [DateModified], 
        [IsDeleted]
    )
    VALUES (
        @ProductTypeID, 
        @ProductName, 
        @ProductDescription, 
        @UnitOfMeasurement, 
        @ProductSalesPrice, 
        @ModifiedBy, 
        @DateModified, 
        @IsDeleted
    );
    END;
GO  


-- =============================================
-- Author:		 Alex Pauvlukov
-- Create date:  14-NOV-2024
-- Description:	 Create a new Plant
-- =============================================
CREATE PROCEDURE [dbo].[sp_CreatePlant]
    @ProductID INT,
    @CommonName VARCHAR(256),
    @ScientificName VARCHAR(256),
    @HeightMin MONEY,
    @HeightMax MONEY,
    @ModifiedBy VARCHAR(256),
    @DateModified DATETIME,
    @IsDeleted BIT
AS
BEGIN
    INSERT INTO [dbo].[Plant] (
        [ProductID], 
        [CommonName], 
        [ScientificName], 
        [HeightMin], 
        [HeightMax], 
        [ModifiedBy], 
        [DateModified], 
        [IsDeleted]
    )
    VALUES (
        @ProductID, 
        @CommonName, 
        @ScientificName, 
        @HeightMin, 
        @HeightMax, 
        @ModifiedBy, 
        @DateModified, 
        @IsDeleted
    );
    END;

GO  
  


-- =============================================
-- Author:		 Alex Pauvlukov
-- Create date:  14-NOV-2024
-- Description:	 Create a new Plant Light Requirement
-- =============================================

CREATE PROCEDURE [dbo].[sp_CreatePlantLightRequirement]
    @PlantID INT,
    @LightRequirementID INT,
    @ModifiedBy VARCHAR(256),
    @DateModified DATETIME,
    @IsDeleted BIT
AS
BEGIN
    INSERT INTO [dbo].[PlantLightRequirement] (
        [PlantID], 
        [LightRequirementID], 
        [ModifiedBy], 
        [DateModified], 
        [IsDeleted]
    )
    VALUES (
        @PlantID, 
        @LightRequirementID, 
        @ModifiedBy, 
        @DateModified, 
        @IsDeleted
    );
	END;

GO



-- =============================================
-- Author:		 Alex Pauvlukov
-- Create date:  14-NOV-2024
-- Description:	 Create a new Plant Zone
-- =============================================
CREATE PROCEDURE [dbo].[sp_CreatePlantZone]
    @PlantID INT,
    @ZoneID INT,
    @ModifiedBy VARCHAR(256),
    @DateModified DATETIME,
    @IsDeleted BIT
AS
BEGIN
    INSERT INTO [dbo].[PlantZone] (
        [PlantID], 
        [ZoneID], 
        [ModifiedBy], 
        [DateModified], 
        [IsDeleted]
    )
    VALUES (
        @PlantID, 
        @ZoneID, 
        @ModifiedBy, 
        @DateModified, 
        @IsDeleted
    );
    END;
GO



-- =============================================
-- Author:		 Alex Pauvlukov
-- Create date:  14-NOV-2024
-- Description:	 Create a new Inventory
-- =============================================
CREATE PROCEDURE [dbo].[sp_CreateInventory]
    @ProductID INT,
    @Quantity MONEY,
    @ModifiedBy VARCHAR(256),
    @DateModified DATETIME,
    @IsDeleted BIT
AS
BEGIN
    INSERT INTO [dbo].[Inventory] (
        [ProductID], 
        [Quantity], 
        [ModifiedBy], 
        [DateModified], 
        [IsDeleted]
    )
    VALUES (
        @ProductID, 
        @Quantity, 
        @ModifiedBy, 
        @DateModified, 
        @IsDeleted
    );
    END;
	GO


-- =============================================
-- Author:		 Ryan Sofoul
-- Create date:  18-NOV-2024
-- Description:	 Create a new Customer Communication Preference
-- =============================================

CREATE PROCEDURE [dbo].[sp_CreateCustomerCommunicationPreference] 
(
	@CustomerID INT,
	@ReceiveEmailPromotions BIT,
	@ReceiveSMSPromotions BIT,
	@ModifiedBy VARCHAR(256),
	@DateModified DATETIME,
	@IsDeleted BIT
)

AS

BEGIN
	
INSERT INTO dbo.CustomerCommunicationPreference
(
	CustomerID,
	 ReceiveEmailPromotions,
	 ReceiveSMSPromotions,
	 ModifiedBy,
	 DateModified,
	 IsDeleted
)

VALUES
(	
	@CustomerID,
	@ReceiveEmailPromotions,
	@ReceiveSMSPromotions,
	@ModifiedBy,
	@DateModified,
	@IsDeleted
)

END


GO



-- =============================================
-- Author:		 RAW Nursery Team
-- Create date:  08-NOV-2024
-- Description:	 Create seed data
-- =============================================

CREATE PROCEDURE [dbo].[sp_CreateSeedData]

AS

DECLARE @CurrentDateTime DATETIME
DECLARE @ModifiedBy VARCHAR(255)

SET @CurrentDateTime = GETDATE()
SET @ModifiedBy = 'Initial Setup'

BEGIN




--DATA INSERT---------------------------------------------------------------------------------------------------------------------------------------


	/* -------------- Vendor  ------------------------------------------------------------------------------------- */
	EXEC sp_CreateVendor 'Dewalt','https://dewalt.com', 'vendor1@dewalt.com','(111) 155-1212',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateVendor 'Wiggleworm','https://vermiculture.com', 'vendor1@vermiculture.com','(111) 255-1212',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateVendor 'Happy Frog','https://foxfarm.com', 'vendor1@foxfarm.com','(111) 355-1212',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateVendor 'Bully Tools','https://bullytools.com', 'vendor1@bullytools.com','(111) 455-1212',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateVendor 'Flexrake','https://www.flexrakellc.com', 'vendor1@flexrakellc.com','(111) 555-1212',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateVendor 'Garden Weasel','https://www.gardenweasel.com', 'vendor1@gardenweasel.com','(111) 655-1212',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateVendor 'Algreen Products','https://algreenproducts.com', 'vendor1@algreenproducts.com','(111) 755-1212',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateVendor 'Fiskers','https://www.fiskars.com', 'vendor1@fiskars.com','(111) 855-1212',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateVendor 'Victor','https://www.victorpest.com', 'vendor1@victorpest.com','(111) 955-1212',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateVendor 'Jonathan Green','https://www.jonathangreen.com', 'vendor1@jonathangreen.com','(111) 105-1212',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateVendor 'Ecopots','https://www.ecopots.com', 'vendor1@ecopots.com','(111) 115-1212',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateVendor 'Holly Tone','https://www.espoma.com', 'vendor1@espoma.com','(111) 125-1212',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateVendor 'Lesco','https://www.lesco.com', 'vendor1@lesco.com','(111) 135-1212',@ModifiedBy,@CurrentDateTime,0
	/* -------------- Vendor  ------------------------------------------------------------------------------------- */


	/* -------------- VendorAddress  ------------------------------------------- */
	EXEC sp_CreateVendorAddress 1,'123 Dewalt Lane', 'PO BOX 1111','Dewaltville','PA','11111',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateVendorAddress 2,'123 Wiggleworm Lane', 'PO BOX 1111','Wigglewormille','PA','11111',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateVendorAddress 3,'123 Frog Lane', 'PO BOX 1111','Frogville','PA','11111',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateVendorAddress 4,'123 Bully Lane', 'PO BOX 1111','Bullyville','PA','11111',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateVendorAddress 5,'123 Flexrake Lane', 'PO BOX 1111','Flexville','PA','11111',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateVendorAddress 6,'123 Weasel Lane', 'PO BOX 1111','Weaselville','PA','11111',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateVendorAddress 7,'123 Algreen Lane', 'PO BOX 1111','Algreenville','PA','11111',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateVendorAddress 8,'123 Fiskers Lane', 'PO BOX 1111','Fiskersville','PA','11111',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateVendorAddress 9,'123 Victor Lane', 'PO BOX 1111','Victorville','PA','11111',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateVendorAddress 10,'123 Green Lane', 'PO BOX 1111','Greenville','PA','11111',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateVendorAddress 11,'123 Ecopots Lane', 'PO BOX 1111','Ecopotsville','PA','11111',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateVendorAddress 12,'123 Holly Lane', 'PO BOX 1111','Hollyville','PA','11111',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateVendorAddress 13,'123 Lesco Lane', 'PO BOX 1111','Lescoville','PA','11111',@ModifiedBy,@CurrentDateTime,0
	/* -------------- VendorAddress  ------------------------------------------- */
	

	/* -------------- Customer  ------------------------------------------- */
	EXEC sp_CreateCustomer 'Emily','Johnson','emily.johnson@email.com','(555) 123-4567',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateCustomer 'Michael','Miller','michael.miller@email.com','(555) 234-5678',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateCustomer 'Olivia','Davis','olivia.davis@email.com','(555) 345-6789',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateCustomer 'James','Wilson','james.wilson@email.com','(555) 456-7890',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateCustomer 'Sophia','Martinez','sophia.martinez@email.com','(555) 567-8901',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateCustomer 'Ethan','Brown','ethan.brown@email.com','(555) 678-9012',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateCustomer 'Ava','Anderson','ava.anderson@email.com','(555) 789-0123',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateCustomer 'Alexander','Thompson','alexander.thompson@email.com','(555) 890-1234',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateCustomer 'Mia','White','mia.white@email.com','(555) 901-2345',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateCustomer 'Noah','Harris','noah.harris@email.com','(555) 012-3456',@ModifiedBy,@CurrentDateTime,0
	/* -------------- Customer  ------------------------------------------- */


	/* -------------- CustomerAddress  ------------------------------------------- */
	EXEC sp_CreateCustomerAddress 1,'123 Maple St', 'Apt 1A','Springfield','CA','90210',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateCustomerAddress 2,'456 Oak Dr', 'Suite 200','Riverside','TX','73301',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateCustomerAddress 3,'789 Pine Ln', 'Unit 3B','Centerville','FL','33101',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateCustomerAddress 4,'101 Birch Ave', 'Floor 4','Lakeview','NY','10001',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateCustomerAddress 5,'202 Cedar Rd', 'Apt 5C','Greenfield','IL','60601',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateCustomerAddress 6,'303 Elm Blvd', 'Suite 6D','Fairview','OH','44101',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateCustomerAddress 7,'404 Willow Cir', 'Unit 7E','Oakwood','GA','30301',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateCustomerAddress 8,'505 Spruce Way', 'Floor 8','Maplewood','NC','27501',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateCustomerAddress 9,'606 Walnut St', 'Apt 9F','Brighton','PA','19101',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateCustomerAddress 10,'707 Ash Pl', 'Suite 10G','Pleasantville','MI','48201',@ModifiedBy,@CurrentDateTime,0
	/* -------------- CustomerAddress  ------------------------------------------- */

	/* -------------- CustomerCommunicationPreference ---------------------------- */
	EXEC sp_CreateCustomerCommunicationPreference 1,1,1,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateCustomerCommunicationPreference 2,1,0,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateCustomerCommunicationPreference 3,0,0,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateCustomerCommunicationPreference 4,0,1,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateCustomerCommunicationPreference 5,1,0,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateCustomerCommunicationPreference 6,0,1,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateCustomerCommunicationPreference 7,0,0,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateCustomerCommunicationPreference 8,0,1,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateCustomerCommunicationPreference 9,1,1,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateCustomerCommunicationPreference 10,1,1,@ModifiedBy,@CurrentDateTime,0


	/* -------------- EmploymentType  ------------------------------------------- */
	--There will only be 3 records for this type as there are only 3 types
	EXEC sp_CreateEmploymentType 'Full Time',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateEmploymentType 'Part Time',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateEmploymentType 'Contractor',@ModifiedBy,@CurrentDateTime,0
	/* -------------- EmploymentType  ------------------------------------------- */


	/* -------------- Position  ------------------------------------------- */
	EXEC sp_CreatePosition 'Cashier',2,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreatePosition 'Gardener',1,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreatePosition 'Manager',1,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreatePosition 'Landscaper',3,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreatePosition 'Sales Associate',1,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreatePosition 'Greenhouse Technician',1,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreatePosition 'Customer Service',1,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreatePosition 'Pest Control',3,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreatePosition 'Inventory Coordinator',1,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreatePosition 'Owner',1,@ModifiedBy,@CurrentDateTime,0
	/* -------------- Position  ------------------------------------------- */

	
	/* -------------- Employee  ------------------------------------------- */
	EXEC sp_CreateEmployee '123-45-6789','Emma','Robinson', 10,'emma.robinson@email.com','(555) 123-9876',1,'1/15/2021',NULL,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateEmployee '234-56-7890','Liam','Clark',3,'liam.clark@email.com','(555) 234-8765',1,'5/20/2022',NULL,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateEmployee '345-67-8901','Isabella','Lewis',3,'isabella.lewis@email.com','(555) 345-7654',1,'8/10/2021',NULL,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateEmployee '456-78-9012','William','Walker',1,'william.walker@email.com','(555) 456-6543',2,'3/25/2023','3/25/2024',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateEmployee '567-89-0123','Amelia','Hall',2,'amelia.hall@email.com','(555) 567-5432',3,'11/1/2022',NULL,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateEmployee '678-90-1234','Lucas','Young',4,'lucas.young@email.com','(555) 678-4321',2,'6/18/2021','6/18/2022',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateEmployee '789-01-2345','Harper','King',5,'harper.king@email.com','(555) 789-3210',3,'7/30/2023','7/30/2024',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateEmployee '890-12-3456','Benjamin','Wright',6,'benjamin.wright@email.com','(555) 890-2109',2,'12/9/2022',NULL,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateEmployee '901-23-4567','Evelyn','Scott',7,'evelyn.scott@email.com','(555) 901-1098',3,'9/14/2021',NULL,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateEmployee '012-34-5678','Mason','Green',8,'mason.green@email.com','(555) 012-0987',2,'2/28/2023',NULL,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateEmployee '123-54-9876','Ryan','Soul',9,'ryan.soul@email.com','(555) 321-6789',3,'3/14/2022','3/14/2023',@ModifiedBy,@CurrentDateTime,0
	/* -------------- Employee  ------------------------------------------- */


	/* -------------- EmployeeAddress  ------------------------------------------- */
	EXEC sp_CreateEmployeeAddress 1,'321 River Rd', 'Apt 101','Brookfield','NY','10010',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateEmployeeAddress 2,'653 Mountain Ave', 'Suite 202','Hillcrest','TX','73344',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateEmployeeAddress 3,'987 Forest Dr', 'Unit 303','Silverton','CA','90002',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateEmployeeAddress 4,'111 Sunset Blvd', 'Floor 4','Woodbury','IL','60603',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateEmployeeAddress 5,'222 Highland Ct', 'Apt 505','Fairview','FL','33122',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateEmployeeAddress 6,'333 Lakeview St', 'Suite 606','Pleasanton','WA','98104',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateEmployeeAddress 7,'444 Meadow Ln', 'Unit 707','Riverdale','CO','80203',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateEmployeeAddress 8,'555 Valley Rd', 'Floor 8','Kingsport','MA','02116',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateEmployeeAddress 9,'666 Sunrise Ave', 'Apt 909','Maple Grove','TN','37013',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateEmployeeAddress 10,'777 Hilltop Dr', 'Suite 1010','Stone Ridge','OR','97201',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateEmployeeAddress 11,'135 Evergreen Terrace', 'Apt A','Parkside','NV','89101',@ModifiedBy,@CurrentDateTime,0
	/* -------------- EmployeeAddress  ------------------------------------------- */


	/* -------------- PaymentType  ------------------------------------------- */
	--There will only be 3 records for this type as there are only 3 types
	EXEC sp_CreatePaymentType 'Cash',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreatePaymentType 'Credit Card',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreatePaymentType 'Debit Card',@ModifiedBy,@CurrentDateTime,0
	/* -------------- PaymentType  ------------------------------------------- */
	
	/* -------------- SalesOrder  ------------------------------------------- */
	EXEC sp_CreateSalesOrder  '1/1/2022 12:35PM', 1, 11, '1/1/2022 12:35PM',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateSalesOrder '3/22/2022 10:35PM', 2, 10, '3/22/2022 10:35PM',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateSalesOrder '3/29/2022 9:07AM', 3, 9, '3/29/2022 9:07AM',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateSalesOrder '6/23/2022 11:02AM', 4, 7, '6/23/2022 3:39PM',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateSalesOrder '10/19/2022 7:25AM', 5, 8, '10/19/2022 7:25AM',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateSalesOrder '12/30/2022 5:44PM', 6, 6, '12/30/2022 5:44PM',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateSalesOrder '3/27/2023 8:21AM', 9, 5, '3/27/2023 4:51PM',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateSalesOrder '6/22/2024 10:10PM', 10, 4, '6/22/2024 10:10PM',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateSalesOrder '6/27/2024 6:11PM', 1, 3, '6/27/2024 6:11PM',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateSalesOrder '9/19/2024 7:37AM', 4, 2, '9/19/2024 7:37AM',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateSalesOrder '10/1/2024 3:15PM', 3, 2, '10/1/2024 3:15PM',@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateSalesOrder '10/30/2024 5:25PM', 8, 1, NULL,@ModifiedBy,@CurrentDateTime,0
	/* -------------- SalesOrder  ------------------------------------------- */

	/* -------------- SalesOrderPayment  ------------------------------------------- */
	-- Values include promos applied, OrderID 1 only one without promo
	EXEC sp_CreateSalesOrderPayment 1, 2,99.90,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateSalesOrderPayment 2, 1,71.91,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateSalesOrderPayment 3, 3,22.03,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateSalesOrderPayment 4, 2,9.89,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateSalesOrderPayment 5, 1,58.47,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateSalesOrderPayment 6, 3,39.56,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateSalesOrderPayment 7, 2,22.49,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateSalesOrderPayment 8, 1,53.98,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateSalesOrderPayment 9, 3,107.97,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateSalesOrderPayment 10, 2,45.00,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateSalesOrderPayment 11, 1,16.18,@ModifiedBy,@CurrentDateTime,0
	--12 intentionally missing, since the order was not picked up yet - NULL Date Picked Up
	/* -------------- SalesOrderPayment  ------------------------------------------- */

	
	/* -------------- Promotion  ------------------------------------------- */
	EXEC sp_CreatePromotion 'Spring Fever Fun 2021', 'SFF2021','3/21/2021','3/30/2021',.10,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreatePromotion 'Summer Time Fun 2021', 'STF2021','6/22/2021','6/30/2021',.10,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreatePromotion 'Fall Spooky Deals 2021', 'FSD2021','10/1/2021','10/30/2021',.10,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreatePromotion 'Winter Holiday Deals 2021', 'WHD2021','12/23/2021','12/31/2021',.10,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreatePromotion 'Spring Fever Fun 2022', 'SFF2022','3/21/2022','3/30/2022',.10,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreatePromotion 'Summer Time Fun 2022', 'STF2022','6/22/2022','6/30/2022',.10,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreatePromotion 'Fall Spooky Deals 2022', 'FSD2022','10/1/2022','10/30/2022',.10,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreatePromotion 'Winter Holiday Deals 2022', 'WHD2022','12/23/2022','12/31/2022',.10,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreatePromotion 'Spring Fever Fun 2023', 'SFF2023','3/21/2023','3/30/2023',.10,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreatePromotion 'Summer Time Fun 2023', 'STF2023','6/22/2023','6/30/2023',.10,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreatePromotion 'Fall Spooky Deals 2023', 'FSD2023','10/1/2023','10/30/2023',.10,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreatePromotion 'Winter Holiday Deals 2023', 'WHD2023','12/23/2023','12/31/2023',.10,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreatePromotion 'Spring Fever Fun 2024', 'SFF2024','3/21/2024','3/30/2024',.10,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreatePromotion 'Summer Time Fun 2024', 'STF2024','6/22/2024','6/30/2024',.10,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreatePromotion 'Fall Spooky Deals 2024', 'FSD2024','10/1/2024','10/30/2024',.10,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreatePromotion 'Winter Holiday Deals 2024', 'WHD2024','12/23/2024','12/31/2024',.10,@ModifiedBy,@CurrentDateTime,0
	/* -------------- Promotion  ------------------------------------------- */


	/* -------------- OrderPromotion  ------------------------------------------- */
	EXEC sp_CreateOrderPromotion 2,5,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateOrderPromotion 3,5,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateOrderPromotion 4,6,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateOrderPromotion 5,7,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateOrderPromotion 6,8,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateOrderPromotion 7,9,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateOrderPromotion 8,14,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateOrderPromotion 9,14,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateOrderPromotion 10,15,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateOrderPromotion 11,15,@ModifiedBy,@CurrentDateTime,0
	/* -------------- OrderPromotion  ------------------------------------------- */


	/* -------------- ZONE  ------------------------------------------- */
	EXEC sp_CreateZone 'USDA Zone 1', 'Below -50°F', @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateZone 'USDA Zone 2', '-50°F to -40°F', @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateZone 'USDA Zone 3', '-40°F to -30°F', @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateZone 'USDA Zone 4', '-30°F to -20°F', @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateZone 'USDA Zone 5', '-20°F to -10°F', @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateZone 'USDA Zone 6', '-10°F to 0°F', @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateZone 'USDA Zone 7', '0°F to 10°F', @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateZone 'USDA Zone 8', '10°F to 20°F', @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateZone 'USDA Zone 9', '20°F to 30°F', @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateZone 'USDA Zone 10', '30°F to 40°F', @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateZone 'USDA Zone 11', '40°F to 50°F', @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateZone 'USDA Zone 12', '50°F to 60°F', @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateZone 'USDA Zone 13', '60°F and above', @ModifiedBy, @CurrentDateTime, 0;
	/* -------------- ZONE  ------------------------------------------- */

	/* -------------- LightRequirement  ------------------------------------------- */
	EXEC sp_CreateLightRequirement 'Full Sun', @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateLightRequirement 'Partial Sun', @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateLightRequirement 'Partial Shade', @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateLightRequirement 'Full Shade', @ModifiedBy, @CurrentDateTime, 0;
	/* -------------- LightRequirement  ------------------------------------------- */

	/* -------------- ProductType  ------------------------------------------- */
	EXEC sp_CreateProductType 'Plants', 'Live plants for gardens and landscaping', @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateProductType 'Seeds and Bulbs', 'Various types of seeds, bulbs', @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateProductType 'Gardening Supplies', 'Includes tools and equipment.', @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateProductType 'Soil and Mulch', 'Various soil, compost, and mulch', @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateProductType 'Lawn Care and Fertilizers', 'Fertilizers and other products for lawn care including lawn additives, grass seed, etc.', @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateProductType 'Outdoor Furniture', 'Patio furniture, garden chairs, and accessories', @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateProductType 'Pots and Planters', 'Pots, planters, and accessories.', @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateProductType 'Pest Control', 'Products for controlling pests, bugs, and rodents', @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateProductType 'Garden Decor', 'Decorative items for gardens, statues, solar lights, etc.', @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateProductType 'Miscellaneous', 'Non-gardening items such as t-shirts, hats, books and other miscellaneous products.', @ModifiedBy, @CurrentDateTime, 0;
	/* -------------- ProductType  ------------------------------------------- */

	/* -------------- Product  ------------------------------------------- */
	EXEC sp_CreateProduct 1,'Rose Bush', 'Flowering shrub for full sun.', 'Each', 15.99, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateProduct 2,'Tulip Bulbs (Pack of 10)',  'Colorful spring bulbs.', 'Pack of 10', 9.99, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateProduct 1,'Cherry Tree Sapling',  'Fast growing and sweet cherry producing tree.', 'Each', 39.99, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateProduct 3,'Shovel',  'Durable steel garden shovel.', 'Each', 12.5, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateProduct 5,'Garden Fertilizer (10 lb)', 'Balanced fertilizer for healthy plant growth.', 'Bag (10 lb)', 19.99, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateProduct 4,'Mulch (2 cubic feet)', 'Organic mulch for moisture and weed control.', 'Bag (2 cu ft)', 7.99, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateProduct 3,'Gardening Gloves', 'Heavy duty gloves for gardening tasks.', 'Pair', 8.99, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateProduct 10,'T-shirt (Unisex)', 'Cotton t-shirt with a fun gardening graphic.', 'Each', 14.99, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateProduct 10,'RAW Gardening Hat', 'Sun protection hat with RAW logo.', 'Each', 19.99, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateProduct 10,'Bottled Water (24 pack)', 'Bottled water.', 'Pack of 24', 9.49, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateProduct 3,'Watering Can (2-gal)', 'Lightweight watering can.', 'Each', 10.99, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateProduct 1,'Succulent Assortment (Pack of 3)', 'Low-maintenance succulents in pots.', 'Pack of 3', 24.99, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateProduct 3,'Hose (50 ft)', 'Kink-resistant garden hose.', 'Each', 29.99, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateProduct 1,'Tomato Seedlings (Pack of 6)', 'Sweet red grape tomato seedlings.', 'Pack of 6', 12.99, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateProduct 1,'Lavender Plant', 'Aromatic flowering shrub.', 'Each', 14.99, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateProduct 2,'Sunflower Seeds (Pack of 20)', 'Bright yellow flowers, annual variety.', 'Pack of 20', 5.99, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateProduct 2,'Daffodil Bulbs (Pack of 10)', 'Spring bloomers, easy to grow.', 'Pack of 10', 7.49, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateProduct 2,'Lily Bulbs (Pack of 5)', 'Fragrant flowers in various colors.', 'Pack of 5', 12.99, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateProduct 2,'Marigold Seeds (Pack of 20)', 'Hardy yellow flowers, ideal for garden borders.', 'Pack of 20', 3.99, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateProduct 1,'Azalea Shrub', 'Compact pink flowering shrub.', 'Each', 19.99, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateProduct 1,'Hydrangea Plant', 'Large bush with colorful blooms.', 'Each', 24.99, @ModifiedBy, @CurrentDateTime, 0;
	/* -------------- Product  ------------------------------------------- */


	/* -------------- OrderItem  ------------------------------------------- */
	EXEC sp_CreateOrderItem 1,2,10.00,9.99,99.90,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateOrderItem 2,4,10.00,7.99,79.90,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateOrderItem 3,8,1.00,14.99,14.99,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateOrderItem 3,10,1.00,9.49,9.49,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateOrderItem 4,11,1.00,10.99,10.99,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateOrderItem 5,20,2.00,19.99,39.98,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateOrderItem 5,21,1.00,24.99,24.99,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateOrderItem 6,18,2.00,12.99,25.98,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateOrderItem 6,16,3.00,5.99,17.97,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateOrderItem 7,21,1.00,24.99,24.99,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateOrderItem 8,13,2.00,29.99,59.98,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateOrderItem 9,3,3.00,39.99,119.97,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateOrderItem 10,4,4.00,12.50,50.00,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateOrderItem 11,7,2.00,8.99,17.98,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateOrderItem 12,11,1.00,10.99,10.99,@ModifiedBy,@CurrentDateTime,0
	/* -------------- OrderItem  ------------------------------------------- */


	/* -------------- ProductVendor  ------------------------------------------- */

	EXEC sp_CreateProductVendor 1,2,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateProductVendor 1,3,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateProductVendor 2,3,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateProductVendor 2,4,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateProductVendor 3,1,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateProductVendor 4,5,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateProductVendor 5,6,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateProductVendor 6,7,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateProductVendor 7,8,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateProductVendor 8,9,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateProductVendor 9,10,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateProductVendor 9,11,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateProductVendor 9,12,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateProductVendor 10,13,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateProductVendor 11,6,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateProductVendor 12,5,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateProductVendor 13,8,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateProductVendor 14,12,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateProductVendor 15,7,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateProductVendor 16,6,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateProductVendor 17,8,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateProductVendor 18,13,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateProductVendor 19,13,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateProductVendor 19,5,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateProductVendor 19,4,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateProductVendor 19,9,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateProductVendor 20,5,@ModifiedBy,@CurrentDateTime,0
	EXEC sp_CreateProductVendor 21,12,@ModifiedBy,@CurrentDateTime,0
	/* -------------- ProductVendor  ------------------------------------------- */

	/* -------------- Plant  ------------------------------------------- */
	EXEC sp_CreatePlant 1, 'Rose Bush', 'Rosa', 12, 60, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlant 2, 'Tulip', 'Tulipa', 12, 24, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlant 3, 'Cherry Tree Sapling', 'Prunus avium', 24, 72, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlant 12, 'Succulent Assortment', 'Various', 4, 8, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlant 14, 'Cherry Tomato', 'Solanum lycopersicum', 10, 36, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlant 15, 'Lavender', 'Lavandula angustifolia', 12, 36, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlant 16, 'Sunflower', 'Helianthus annuus', 24, 96, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlant 17, 'Daffodil', 'Narcissus', 6, 24, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlant 18, 'Lily', 'Lilium', 18, 48, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlant 19, 'Marigold', 'Tagetes', 8, 24, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlant 20, 'Azalea', 'Rhododendron', 12, 48, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlant 21, 'Hydrangea', 'Hydrangea macrophylla', 24, 72, @ModifiedBy, @CurrentDateTime, 0;
	/* -------------- Plant  ------------------------------------------- */

	/* -------------- PlantLightRequirement  ------------------------------------------- */
	EXEC sp_CreatePlantLightRequirement 1, 1, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantLightRequirement 1, 2, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantLightRequirement 2, 1, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantLightRequirement 2, 3, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantLightRequirement 3, 1, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantLightRequirement 3, 2, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantLightRequirement 4, 2, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantLightRequirement 4, 3, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantLightRequirement 5, 1, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantLightRequirement 5, 2, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantLightRequirement 6, 1, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantLightRequirement 6, 3, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantLightRequirement 7, 1, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantLightRequirement 7, 2, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantLightRequirement 8, 1, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantLightRequirement 8, 2, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantLightRequirement 9, 1, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantLightRequirement 9, 3, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantLightRequirement 10, 1, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantLightRequirement 10, 3, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantLightRequirement 11, 3, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantLightRequirement 11, 4, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantLightRequirement 12, 1, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantLightRequirement 12, 3, @ModifiedBy, @CurrentDateTime, 0;
	/* -------------- PlantLightRequirement  ------------------------------------------- */


	/* -------------- PlantZone  ------------------------------------------- */
	EXEC sp_CreatePlantZone 1, 4, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantZone 1, 5, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantZone 1, 6, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantZone 2, 4, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantZone 2, 5, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantZone 2, 6, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantZone 3, 7, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantZone 3, 8, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantZone 4, 6, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantZone 4, 7, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantZone 4, 8, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantZone 5, 5, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantZone 5, 6, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantZone 5, 7, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantZone 6, 5, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantZone 6, 6, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantZone 6, 7, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantZone 7, 4, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantZone 7, 5, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantZone 7, 6, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantZone 8, 6, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantZone 8, 7, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantZone 8, 8, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantZone 9, 4, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantZone 9, 5, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantZone 9, 6, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantZone 10, 5, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantZone 10, 6, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantZone 10, 7, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantZone 11, 6, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantZone 11, 7, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantZone 11, 8, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantZone 12, 4, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantZone 12, 5, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreatePlantZone 12, 6, @ModifiedBy, @CurrentDateTime, 0;
	/* -------------- PlantZone  ------------------------------------------- */


	/* -------------- Inventory  ------------------------------------------- */
	EXEC sp_CreateInventory 1, 50, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateInventory 2, 110, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateInventory 3, 30, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateInventory 4, 57, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateInventory 5, 260, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateInventory 6, 960, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateInventory 7, 80, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateInventory 8, 48, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateInventory 9, 36, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateInventory 10, 52, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateInventory 11, 37, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateInventory 12, 21, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateInventory 13, 45, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateInventory 14, 71, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateInventory 15, 34, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateInventory 16, 29, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateInventory 17, 94, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateInventory 18, 85, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateInventory 19, 27, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateInventory 20, 17, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateInventory 21, 24, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateInventory 1, 5, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateInventory 2, 20, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateInventory 3, 5, @ModifiedBy, @CurrentDateTime, 0;
	EXEC sp_CreateInventory 4, 3, @ModifiedBy, @CurrentDateTime, 0;
	/* -------------- Inventory  ------------------------------------------- */


END

GO
EXEC [sp_CreateSeedData]


--SELECT * FROM vw_SalesOrderPayment

--	EXEC sp_CreatePromotion 'Spring Fever Fun 2025', 'SFF2025','3/21/2025','3/30/2025',.10,@ModifiedBy,@CurrentDateTime,0
--	EXEC sp_CreatePromotion 'Summer Time Fun 2025', 'STF2025','6/22/2025','6/30/2025',.16,'Alex','12-01-2024',0

/*

-- USE this for the queries to investigate insert results
SELECT 'SELECT * FROM ' + name 
FROM sys.tables ORDER BY NAME


--Commented out so that we dont accidentally drop the database

USE master
IF (EXISTS (
		SELECT [Name] 
		FROM sys.databases 
		WHERE ([Name] = 'RAWNursery') 
	)
)
BEGIN
	DROP DATABASE RAWNursery;
END


*/