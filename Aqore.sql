CREATE DATABASE SalesTransactionApp;

USE SalesTransactionApp;

--CREATION OF ALL THE TABLES

CREATE TABLE Product(
ProductID INT IDENTITY(1,1) PRIMARY KEY,
ProductName VARCHAR(50) NOT NULL,
Quantity INT NOT NULL,
RemainingQuantity INT NOT NULL,
Price DECIMAL(10,2) NOT NULL,
Category VARCHAR(50) NOT NULL,
CONSTRAINT ProductConstraint UNIQUE (ProductName, Category)
);

CREATE TABLE Customer(
CustomerID INT IDENTITY(1,1) PRIMARY KEY,
FirstName VARCHAR(100) NOT NULL,
LastName VARCHAR(100) NOT NULL,
PhoneNumber VARCHAR(100) NOT NULL,
CONSTRAINT CustomerConstraint UNIQUE (FirstName, LastName, PhoneNumber)
);

CREATE TABLE SalesTransaction(
TransactionID INT IDENTITY(1,1) PRIMARY KEY,
CustomerID INT NOT NULL,
ProductID INT NOT NULL,
QuantityPurchased INT NOT NULL,
TransactionDate DATE NOT NULL,

FOREIGN KEY(CustomerID) REFERENCES Customer(CustomerID),
FOREIGN KEY(ProductID) REFERENCES Product(ProductID),

CONSTRAINT SalesConstraint UNIQUE (TransactionID, CustomerID, ProductID)

);

CREATE TABLE Invoice(
InvoiceID INT IDENTITY(1,1) PRIMARY KEY,
CustomerID INT NOT NULL,
InvoiceDate DATE NOT NULL,
TotalAmt  DECIMAL(10,2) NOT NULL,
Discount Decimal(10,2),

FOREIGN KEY(CustomerID) REFERENCES Customer(CustomerID),
CONSTRAINT InvoiceConstraint UNIQUE (InvoiceID, CustomerID)

);

ALTER TABLE Invoice ADD DiscountedPrice DECIMAL(10,2);
GO

SELECT * FROM Product;
SELECT * FROM Customer;
SELECT * FROM SalesTransaction;
SELECT * FROM Invoice;

GO

--STORE PROCEDURE FOR CRUD OPERATION OF PRODUCT TABLE

CREATE or ALTER PROCEDURE ProductCRUDOperations
(
@ProductInfoList VARCHAR(MAX),
@Action VARCHAR(10)
)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;

		IF @Action='Create'
		BEGIN
			INSERT INTO Product(ProductName, Quantity, RemainingQuantity, Price, Category)
			SELECT
				JSON_VALUE(ProductInfo, '$.ProductName'),
				JSON_VALUE(ProductInfo, '$.Quantity'),
				JSON_VALUE(ProductInfo, '$.RemainingQuantity'),
				JSON_VALUE(ProductInfo, '$.Price'),
				JSON_VALUE(ProductInfo, '$.Category')
			FROM OPENJSON(@ProductInfoList) WITH(
				ProductInfo NVARCHAR(MAX) '$' AS JSON
			);
			SELECT * FROM Product;
		END 
		ELSE IF @Action= 'Read'
		BEGIN
			SELECT * FROM Product;
		END
		ELSE IF @Action='Update'
		BEGIN
			UPDATE Product
			SET
				ProductName=JSON_VALUE(ProductInfo, '$.ProductName'),
				Quantity=JSON_VALUE(ProductInfo, '$.Quantity'),
				RemainingQuantity=JSON_VALUE(ProductInfo, '$.RemainingQuantity'),
				Price=JSON_VALUE(ProductInfo, '$.Price'),
				Category=JSON_VALUE(ProductInfo, '$.Category')
			FROM OPENJSON(@ProductInfoList) WITH (
				ProductInfo NVARCHAR(MAX) '$' AS JSON
			)
			WHERE
				ProductID = JSON_VALUE(ProductInfo, '$.ProductID');
			SELECT * FROM Product;
		END
		ELSE IF @Action ='Delete'
		BEGIN
			DELETE FROM Product
			WHERE ProductID IN (
				SELECT JSON_VALUE(ProductInfo, '$.ProductID')
				FROM OPENJSON(@ProductInfoList) WITH (
					ProductInfo NVARCHAR(MAX) '$' AS JSON
				)
			);
			SELECT * FROM Product;
		END

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(100);
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		SET @ErrorMessage = ERROR_MESSAGE(); 

		PRINT 'ERROR IN TRANSACTION: ' + @ErrorMessage;
	END CATCH

END

GO

--INSERTING VALUES IN PRODUCT TABLE

DECLARE @ProductInfo VARCHAR(MAX)='[
	{
		"ProductName": "T-Shirt",
		"Quantity": 50,
		"RemainingQuantity": 45,
		"Price": 1150.55,
		"Category": "Top"
	},
	{
		"ProductName": "Shirt",
		"Quantity": 40,
		"RemainingQuantity": 38,
		"Price": 1600,
		"Category": "Top"
	},
	{
		"ProductName": "Pant",
		"Quantity": 60,
		"RemainingQuantity": 50,
		"Price": 2000,
		"Category": "Bottoms"
	},
	{
		"ProductName": "Floral Dress",
		"Quantity": 30,
		"RemainingQuantity": 29,
		"Price": 3000,
		"Category": "Dress"
	},
	{
		"ProductName": "Party Dress",
		"Quantity": 36,
		"RemainingQuantity": 30,
		"Price": 4000,
		"Category": "Dress"
	},
	{
		"ProductName": "Skirt",
		"Quantity": 80,
		"RemainingQuantity": 65,
		"Price": 1500,
		"Category": "Bottoms"
	}
]';

DECLARE @StmtType VARCHAR(10)='Create';

EXEC ProductCRUDOperations
	@ProductInfoList=@ProductInfo,
	@Action=@StmtType;
GO

--READING THE VALUES OF PRODUCT TABLE

DECLARE @StmtType VARCHAR(10)='Read';

EXEC ProductCRUDOperations
	@ProductInfoList='[]',
	@Action=@StmtType;
GO

--UPDATING THE VALUES OF PRODUCT TABLE

DECLARE @ProductInfo VARCHAR(MAX)='[
	{
		"ProductID": 1,
		"ProductName": "Cami",
		"Quantity": 50,
		"RemainingQuantity": 45,
		"Price": 1150.55,
		"Category":"Top"
	},
	{
		"ProductID": 4,
		"ProductName": "Floral Dress",
		"Quantity": 45,
		"RemainingQuantity": 40,
		"Price": 3000.00,
		"Category":"Dress"
	}

]';

DECLARE @StmtType VARCHAR(10)='Update';

EXEC ProductCRUDOperations
	@ProductInfoList=@ProductInfo,
	@Action=@StmtType;
GO

--DELETING THE VALUES OF PRODUCT TABLE

DECLARE @ProductInfo VARCHAR(MAX)='[
	{
		"ProductID": 6
	}
]';

DECLARE @StmtType VARCHAR(10)='Delete';

EXEC ProductCRUDOperations
	@ProductInfoList=@ProductInfo,
	@Action=@StmtType;

GO

--STORE PROCEDURE FOR CRUD OPERATION OF CUSTOMER TABLE

CREATE or ALTER PROCEDURE CustomerCRUDOperations
(
@CustomerInfoList VARCHAR(MAX),
@Action VARCHAR(10)
)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;

		IF @Action='Create'
		BEGIN
			INSERT INTO Customer(FirstName, LastName, PhoneNumber)
			SELECT
				JSON_VALUE(CustomerInfo, '$.FirstName'),
				JSON_VALUE(CustomerInfo, '$.LastName'),
				JSON_VALUE(CustomerInfo, '$.PhoneNumber')
			FROM OPENJSON(@CustomerInfoList) WITH(
				CustomerInfo NVARCHAR(MAX) '$' AS JSON
			);
			SELECT * FROM Customer;
		END 
		ELSE IF @Action= 'Read'
		BEGIN
			SELECT * FROM Customer;
		END
		ELSE IF @Action='Update'
		BEGIN
			UPDATE Customer
			SET
				FirstName=JSON_VALUE(CustomerInfo, '$.FirstName'),
				LastName=JSON_VALUE(CustomerInfo, '$.LastName'),
				PhoneNumber=JSON_VALUE(CustomerInfo, '$.PhoneNumber')
			FROM OPENJSON(@CustomerInfoList) WITH (
				CustomerInfo NVARCHAR(MAX) '$' AS JSON
			)
			WHERE
				CustomerID = JSON_VALUE(CustomerInfo, '$.CustomerID');
			SELECT * FROM Customer;
		END
		ELSE IF @Action ='Delete'
		BEGIN
            DELETE FROM Customer
			WHERE CustomerID IN (
				SELECT JSON_VALUE(CustomerInfo, '$.CustomerID')
				FROM OPENJSON(@CustomerInfoList) WITH (
					CustomerInfo NVARCHAR(MAX) '$' AS JSON
				)
			);
			SELECT * FROM Customer;
		END

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(100);
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		SET @ErrorMessage = ERROR_MESSAGE(); 

		PRINT 'ERROR IN TRANSACTION: ' + @ErrorMessage;
	END CATCH

END
GO

--INSERTING VALUES IN THE CUSTOMER TABLE

DECLARE @CustomerInfo VARCHAR(MAX)='[
	{
		"FirstName": "Rashmi",
		"LastName": "Maharjan",
		"PhoneNumber": "9823319399"
	},
	{
		"FirstName": "Shyam",
		"LastName": "Dangol",
		"PhoneNumber": "9867834567"
	},
	{
		"FirstName": "Ashish",
		"LastName": "Thapa",
		"PhoneNumber": "9878976543"
	},
	{
		"FirstName": "Reeya",
		"LastName": "Shrestha",
		"PhoneNumber": "9456789013"
	}
	{
		"FirstName": "Akanshya",
		"LastName": "Shrestha",
		"PhoneNumber": "9456689013"
	}
]';

DECLARE @StmtType VARCHAR(10)='Create';

EXEC CustomerCRUDOperations
	@CustomerInfoList=@CustomerInfo,
	@Action=@StmtType;
GO

--READING THE VALUES OF CUSTOMER TABLE

DECLARE @StmtType VARCHAR(10)='Read';

EXEC CustomerCRUDOperations
	@CustomerInfoList='[]',
	@Action=@StmtType;
GO

--UPDATING THE VALUES OF CUSTOMER TABLE

DECLARE @CustomerInfo VARCHAR(MAX)='[
	{
		"CustomerID": 6,
		"FirstName": "Asish",
		"LastName": "Thapa",
		"PhoneNumber":"98765432123"
	},
	{
		"CustomerID": 7,
		"FirstName": "Riya",
		"LastName": "Shrestha",
		"PhoneNumber": "9876567854"
	}

]';

DECLARE @StmtType VARCHAR(10)='Update';

EXEC CustomerCRUDOperations
	@CustomerInfoList=@CustomerInfo,
	@Action=@StmtType;
GO

--DELETING THE VALUES OF CUSTOMER TABLE

DECLARE @CustomerInfo VARCHAR(MAX)='[
	{
		"CustomerID": 5
	}
]';

DECLARE @StmtType VARCHAR(10)='Delete';

EXEC CustomerCRUDOperations
	@CustomerInfoList=@CustomerInfo,
	@Action=@StmtType;

GO

--STORE PROCEDURE FOR CRUD OPERATION OF SALES TRANSACTION TABLE

CREATE or ALTER PROCEDURE SalesTransactionCRUDOperations
(
@TransactionInfoList VARCHAR(MAX),
@Action VARCHAR(10)
)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;

		IF @Action='Create'
		BEGIN
			INSERT INTO SalesTransaction(CustomerID, ProductID, QuantityPurchased, TransactionDate)
			SELECT
				JSON_VALUE(TransactionInfo, '$.CustomerID'),
				JSON_VALUE(TransactionInfo, '$.ProductID'),
				JSON_VALUE(TransactionInfo, '$.QuantityPurchased'),
				JSON_VALUE(TransactionInfo, '$.TransactionDate')
			FROM OPENJSON(@TransactionInfoList) WITH(
				TransactionInfo NVARCHAR(MAX) '$' AS JSON
			);
			SELECT * FROM SalesTransaction;
		END 
		ELSE IF @Action= 'Read'
		BEGIN
			SELECT * FROM SalesTransaction;
		END
		ELSE IF @Action='Update'
		BEGIN
			UPDATE SalesTransaction
			SET
				CustomerID = JSON_VALUE(TransactionInfo, '$.CustomerID'),
				ProductID = JSON_VALUE(TransactionInfo, '$.ProductID'),
				QuantityPurchased = JSON_VALUE(TransactionInfo, '$.QuantityPurchased'),
				TransactionDate = JSON_VALUE(TransactionInfo, '$.TransactionDate')
			FROM OPENJSON(@TransactionInfoList) WITH (
				TransactionInfo NVARCHAR(MAX) '$' AS JSON
			)
			WHERE
				TransactionID = JSON_VALUE(TransactionInfo, '$.TransactionID');
			SELECT * FROM SalesTransaction;
		END
		ELSE IF @Action ='Delete'
		BEGIN
			DELETE FROM SalesTransaction
			WHERE TransactionID IN (
				SELECT JSON_VALUE(TransactionInfo, '$.TransactionID')
				FROM OPENJSON(@TransactionInfoList) WITH (
					TransactionInfo NVARCHAR(MAX) '$' AS JSON
				)
			);
			SELECT * FROM SalesTransaction;
		END

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(100);
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		SET @ErrorMessage = ERROR_MESSAGE(); 

		PRINT 'ERROR IN TRANSACTION: ' + @ErrorMessage;
	END CATCH

END
Go

--INSERTING THE VLAUES IN SALES TRANSACTION TABLE

DECLARE @SalesTransactionInfo VARCHAR(MAX)='[
	{
		"CustomerID": 6,
		"ProductID": 3,
		"QuantityPurchased": 2,
		"TransactionDate": "' + CONVERT(VARCHAR(10), GETDATE(), 120) + '"
	},
	{
		"CustomerID": 4,
		"ProductID": 1,
		"QuantityPurchased": 1,
		"TransactionDate": "' + CONVERT(VARCHAR(10), GETDATE(), 120) + '"
	},
	{
		"CustomerID": 7,
		"ProductID": 4,
		"QuantityPurchased": 3,
		"TransactionDate": "' + CONVERT(VARCHAR(10), GETDATE(), 120) + '"
	},
	{
		"CustomerID": 4,
		"ProductID": 5,
		"QuantityPurchased": 1,
		"TransactionDate": "' + CONVERT(VARCHAR(10), GETDATE(), 120) + '"
	},
	{
		"CustomerID": 7,
		"ProductID": 1,
		"QuantityPurchased": 3,
		"TransactionDate": "' + CONVERT(VARCHAR(10), GETDATE(), 120) + '"
	},
	{
		"CustomerID": 6,
		"ProductID": 2,
		"QuantityPurchased": 1,
		"TransactionDate": "' + CONVERT(VARCHAR(10), GETDATE(), 120) + '"
	}
]';

DECLARE @StmtType VARCHAR(10)='Create';

EXEC SalesTransactionCRUDOperations
	@TransactionInfoList=@SalesTransactionInfo,
	@Action=@StmtType;
GO

--READING THE VALUES OF SALES TRANSACTION TABLE

DECLARE @StmtType VARCHAR(10)='Read';

EXEC SalesTransactionCRUDOperations
	@TransactionInfoList='[]',
	@Action=@StmtType;
GO

--UPDATING THE VALUES OF SALES TRANSACTION TABLE

DECLARE @SalesTransactionInfo VARCHAR(MAX)='[
	{
		"TransactionID": 5,
		"CustomerID": 7,
		"ProductID": 1,
		"QuantityPurchased":1,
		"TransactionDate": "2023-02-10"
	}

]';

DECLARE @StmtType VARCHAR(10)='Update';

EXEC SalesTransactionCRUDOperations
	@TransactionInfoList=@SalesTransactionInfo,
	@Action=@StmtType;
GO

--DELETING THE VALUES OF SALES TRANSACTION TABLE

DECLARE @SalesTransactionInfo VARCHAR(MAX)='[
	{
		"TransactionID": 4
	}
]';

DECLARE @StmtType VARCHAR(10)='Delete';

EXEC SalesTransactionCRUDOperations
	@TransactionInfoList=@SalesTransactionInfo,
	@Action=@StmtType;

GO

--STORE PROCEDURE FOR CRUD OPERATION OF INVOICE TABLE (GENERATING INVOICE)

CREATE or ALTER PROCEDURE GenerateReadUpdateAndDeleteInvoice
(
@InvoiceInfoList VARCHAR(MAX),
@Action VARCHAR(10)
)
AS
BEGIN

    BEGIN TRY
		BEGIN TRANSACTION;

        IF @Action='Generate'
		BEGIN
			DECLARE @CustomerID INT;

			SELECT @CustomerID = JSON_VALUE(@InvoiceInfoList, '$.CustomerID');

			DECLARE @TotalAmt DECIMAL(10, 2) = (
				SELECT SUM(St.QuantityPurchased * P.Price)
				FROM SalesTransaction St
				INNER JOIN Product P ON St.ProductID = P.ProductID
				WHERE St.CustomerID = @CustomerID
			);


			DECLARE @DisPercentage DECIMAL(10, 2)

				IF @TotalAmt <= 1000
				   SET @DisPercentage = 0.05
				ELSE
				   SET @DisPercentage = 0.1 

			DECLARE @DiscountedPrice DECIMAL(10, 2) = @TotalAmt - (@TotalAmt * @DisPercentage);

			INSERT INTO Invoice (InvoiceDate, CustomerID, TotalAmt, Discount, DiscountedPrice)
			VALUES (GETDATE(), @CustomerID, @TotalAmt, @DisPercentage, @DiscountedPrice);
			
			SELECT * FROM Invoice;
		END

		ELSE IF @Action='Read'
		BEGIN
			SELECT * FROM Invoice;
		END

		ELSE IF @Action='Update'
		BEGIN
			UPDATE Invoice
			SET
				CustomerID = JSON_VALUE(InvoiceInfo, '$.CustomerID'),
				InvoiceDate = JSON_VALUE(InvoiceInfo, '$.TransactionDate'),
				TotalAmt = JSON_VALUE(InvoiceInfo, '$.TotalAmt'),
				Discount = JSON_VALUE(InvoiceInfo, '$.Discount')
			FROM OPENJSON(@InvoiceInfoList) WITH (
				InvoiceInfo NVARCHAR(MAX) '$' AS JSON
			)
			WHERE
				InvoiceID = JSON_VALUE(InvoiceInfo, '$.InvoiceID');
			SELECT * FROM Invoice;
		END

		ELSE IF @Action ='Delete'
		BEGIN
			DELETE FROM Invoice
			WHERE InvoiceID IN (
				SELECT JSON_VALUE(InvoiceInfo, '$.InvoiceID')
				FROM OPENJSON(@InvoiceInfoList) WITH (
					InvoiceInfo NVARCHAR(MAX) '$' AS JSON
				)
			);
			SELECT * FROM Invoice;
		END
        COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(100);
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		SET @ErrorMessage = ERROR_MESSAGE(); 

		PRINT 'ERROR IN TRANSACTION: ' + @ErrorMessage;
	END CATCH

END
GO

--INSERTING VALUES IN INVOICE TABLE

DECLARE @InvoiceInfo VARCHAR(MAX)='{

"CustomerID":7

}';

DECLARE @StmtType VARCHAR(10)='Generate';

EXEC GenerateReadUpdateAndDeleteInvoice
	@InvoiceInfoList=@InvoiceInfo,
	@Action=@StmtType;
GO

--READING THE VALUES OF INVOICE TABLE

DECLARE @StmtType VARCHAR(10)='Read';

EXEC GenerateReadUpdateAndDeleteInvoice
	@InvoiceInfoList='[]',
	@Action=@StmtType;
GO

--UPDATING THE VALUES OF INVOICE TABLE

DECLARE @InvoiceInfo VARCHAR(MAX)='[
	{
		"InvoiceID": 2,
		"CustomerID": 6,
		"TransactionDate": "2023-04-13",
		"TotalAmt": 1100,
		"Disount":0.10,
		"DiscountedPrice":11880
	}

]';

DECLARE @StmtType VARCHAR(10)='Update';

EXEC GenerateReadUpdateAndDeleteInvoice
	@InvoiceInfoList=@InvoiceInfo,
	@Action=@StmtType;
GO

--DELETING THE VALUES OF INVOICE TABLE

DECLARE @InvoiceInfo VARCHAR(MAX)='[
	{
		"InvoiceID": 1
	}
]';

DECLARE @StmtType VARCHAR(10)='Delete';

EXEC GenerateReadUpdateAndDeleteInvoice
	@InvoiceInfoList=@InvoiceInfo,
	@Action=@StmtType;

GO

--TRIGGER TO UPDATE THE DISCOUNT PERCENTAGE AND DISCOUNTED AMOUNT ACCORDING TO THE QUESTION AFTER THE UPDATION OF INVOICE TABLE

CREATE OR ALTER TRIGGER UpdateDiscountAndDiscountedAmt
ON Invoice
AFTER UPDATE
AS
BEGIN
    UPDATE I
    SET
        Discount = CASE
                        WHEN I.TotalAmt <= 1000 THEN 0.05
                        ELSE 0.10
                   END,
        DiscountedPrice = I.TotalAmt - (I.TotalAmt * CASE
                        WHEN I.TotalAmt <= 1000 THEN 0.05
                        ELSE 0.10
                   END)
    FROM Invoice AS I
    JOIN inserted AS Updated ON I.InvoiceID = Updated.InvoiceID;

    -- PRINT THE UPDATED RECORDS
    SELECT InvoiceID, CustomerID, InvoiceDate, TotalAmt, Discount AS UpdatedDiscount, DiscountedPrice AS UpdatedDiscountedPrice
	FROM Invoice WHERE InvoiceID IN (SELECT InvoiceID FROM inserted);
END
GO

--NO. 3 QUERIES 

--1.

SELECT * FROM Customer
WHERE (FirstName LIKE 'A%K%' OR FirstName LIKE '%K%S')

--2.

SELECT * FROM Customer
WHERE CustomerID NOT IN (SELECT CustomerID FROM Invoice);

--3.

SELECT TOP 1 c.FirstName, c.LastName, SUM(st.QuantityPurchased * p.Price) AS TotalCostSpentByCustomer 
FROM Customer c
INNER JOIN SalesTransaction st ON st.CustomerID = c.CustomerID
INNER JOIN Product p ON p.ProductID = st.ProductID
WHERE st.TransactionDate BETWEEN '2023-04-13' AND '2023-05-14'
GROUP BY c.CustomerID, c.FirstName, c.LastName
ORDER BY TotalCostSpentByCustomer DESC;

--4.

DELETE FROM Product WHERE ProductId NOT IN (
    SELECT DISTINCT ProductId
    FROM SalesTransaction
    WHERE YEAR(TransactionDate) = YEAR(GETDATE())
);

--5. TRIGGER FOR UPDATING THE REMAINING QUANTITY OF THE PRODUCT TABLE 

CREATE or ALTER  TRIGGER UpdateRemainingQuantity
ON SalesTransaction
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
   
    UPDATE Product
    SET RemainingQuantity = Quantity- (
        SELECT SUM(QuantityPurchased)
        FROM SalesTransaction
        WHERE Product.ProductID = SalesTransaction.ProductID
    )
    WHERE ProductID IN (
        SELECT ProductID
        FROM SalesTransaction
    );
	IF EXISTS (
        SELECT 1
        FROM Product
        WHERE RemainingQuantity <= 0
    )
    BEGIN
        RAISERROR('The quantity available is not enough or has reached 0.', 16, 1);
        ROLLBACK;
    END
END

DECLARE @SalesTransactionInfo VARCHAR(MAX)='[
	{
		"CustomerID": 6,
		"ProductID": 1,
		"QuantityPurchased": 1,
		"TransactionDate": "' + CONVERT(VARCHAR(10), GETDATE(), 120) + '"
	}
]';

DECLARE @StmtType VARCHAR(10)='Create';

EXEC SalesTransactionCRUDOperations
	@TransactionInfoList=@SalesTransactionInfo,
	@Action=@StmtType;
GO

--5. CONTINUE

SELECT *
FROM Product
WHERE RemainingQuantity < 2;

--6.

SELECT TOP 1 p.ProductID, p.ProductName, SUM(QuantityPurchased) AS TotalQuantitySold 
FROM Product p
INNER JOIN SalesTransaction st  ON st.ProductID=p.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY TotalQUantitySold DESC;

--7.

SELECT c.FirstName, c.LastName, c.PhoneNumber , SUM(st.QuantityPurchased) AS QuantityOFProductBought FROM Customer c
INNER JOIN SalesTransaction st ON st.CustomerID=c.CustomerID
GROUP BY c.CustomerID,c.FirstName, c.LastName, c.PhoneNumber
HAVING SUM(st.QuantityPurchased) > 10;

GO

--NO. 4 FUNCTION TO RETURN TOTAL BILL AMOUNT OF THE CUSTOMER IN THE GIVE DATE RANGE.

CREATE or ALTER FUNCTION GetTotalBillAmt
(
    @CustomerIDs VARCHAR(MAX),
    @StartDate DATE,
    @EndDate DATE
)
RETURNS TABLE
AS
RETURN
    SELECT c.CustomerID, c.FirstName,c.LastName, SUM(i.DiscountedPrice) AS TotalAmount
    FROM  Invoice AS i
    INNER JOIN Customer AS c ON c.CustomerID = i.CustomerID
    WHERE c.CustomerID IN (SELECT value FROM STRING_SPLIT(@CustomerIDs, ','))
    AND i.InvoiceDate BETWEEN @StartDate AND @EndDate
    GROUP BY c.CustomerID, c.FirstName, c.LastName;
Go

DECLARE @CustomerIDs VARCHAR(MAX) = '6,4,7';
DECLARE @StartDate DATE = '2023-04-15';
DECLARE @EndDate DATE = '2023-05-15';

SELECT CustomerID, FirstName, LastName, TotalAmount
FROM GetTotalBillAmt(@CustomerIDs, @StartDate, @EndDate);

GO

--NO.5 STORE PROCEDURE 

Create or ALTER PROCEDURE GetTotalBillAmtOrAllInfo
(
  @GetTotalBillAmtOrAllInfo VARCHAR(MAX)
)
AS
BEGIN
  DECLARE @CustomerID INT
  DECLARE @StartDate DATE
  DECLARE @EndDate DATE

  SELECT @CustomerID = JSON_VALUE(@GetTotalBillAmtOrAllInfo, '$.CustomerID')
  SELECT @StartDate = CONVERT(DATE, JSON_VALUE(@GetTotalBillAmtOrAllInfo, '$.StartDate'), 120)
  SELECT @EndDate = CONVERT(DATE, JSON_VALUE(@GetTotalBillAmtOrAllInfo, '$.EndDate'), 120)

  IF @CustomerID IS NULL OR @CustomerID = 0
  BEGIN
    SELECT c.*
	FROM Customer c
    INNER JOIN SalesTransaction st ON st.CustomerID = c.CustomerID
    WHERE st.TransactionDate BETWEEN @StartDate AND @EndDate
	FOR JSON AUTO;
  END
  ELSE
  BEGIN
    SELECT c.CustomerID, c.FirstName, c.LastName,c.PhoneNumber, SUM(i.DiscountedPrice) AS TotalBillAmount
    FROM Customer c
    INNER JOIN Invoice i ON i.CustomerID = c.CustomerID
    INNER JOIN SalesTransaction st ON st.CustomerID = i.CustomerID
    WHERE st.TransactionDate BETWEEN @StartDate AND @EndDate
    AND c.CustomerID = @CustomerID
    GROUP BY c.CustomerID, c.FirstName, c.LastName, c.PhoneNumber
	FOR JSON AUTO;
  END
END
GO

--FOR CUSTOMER ID IS NOT NULL
DECLARE @GetTotalBillAmtOrAllInfo VARCHAR(MAX)='{

		"CustomerID": 6,
		"StartDate":"2023-05-14",
		"EndDate":"2023-05-14"
	}';

EXEC GetTotalBillAmtOrAllInfo
	@GetTotalBillAmtOrAllInfo=@GetTotalBillAmtOrAllInfo;

GO

--FOR CUSTOMER ID IS NULL
DECLARE @GetTotalBillAmtOrAllInfo VARCHAR(MAX)='{

		"StartDate":"2023-05-14",
		"EndDate":"2023-05-14"
	}';

EXEC GetTotalBillAmtOrAllInfo
	@GetTotalBillAmtOrAllInfo=@GetTotalBillAmtOrAllInfo;

GO