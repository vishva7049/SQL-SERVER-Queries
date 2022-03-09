--1. Create a database named db_{yourfirstname}
--2.Create Customer table with at least the following columns: (1/2 mark)
		--ID INT NOT NULL
		--CustomerID INT NOT NULL
		--FirstName Nvarchar(50 ) NOT NULL
		--LastName Nvarchar(50) NOT NULL

--3. Create Orders table as follows: (1/2 mark)
		--OrderID INT Not NULL
		--CustomerID INT NOT NULL
		--OrderDate datetime Not NULL
--4. Use triggers to impose the following constraints. 

	--A). Customer with Orders cannot be deleted from Customer table.
	--B).   Create a custom error and use Raiserror to notify when delete Customer with Orders fails.
create or alter trigger DeleteCustomer ON customer
AFTER DELETE 
AS 
	BEGIN
		
		SET nocount on;
		IF EXISTS
		(
		select *  FROM deleted
		join orders 
		on deleted.customerId  = orders.customerId
		where deleted.customerId =orders.customerId
		)

		Begin 
			Raiserror ('Orders fails.',16,1);
			ROLLBACK TRAN;
			RETURN;
	END;
END;
GO

--Testing data.

INSERT INTO Customer(ID, CustomerId, FirstName, LastName )
VALUES( 1,1, 'vishva', 'patel' );

INSERT INTO Customer( ID,CustomerId, FirstName, LastName )
VALUES( 2,2, 'Sid', 'Patel' );

INSERT INTO Customer( ID,CustomerId, FirstName, LastName )
VALUES( 3, 5, 'xyz', 'abc' );

INSERT INTO Orders( OrderID, CustomerID, OrderDate )
VALUES( 4, 4, CONVERT(datetime, GETDATE()) );

INSERT INTO Orders( OrderID, CustomerID, OrderDate )
VALUES( 5, 5, CONVERT(datetime, GETDATE()) );
  GO

    
DELETE Customer
WHERE CustomerId = 1;
GO
 
  --select * from Customer;
  --select * from orders;


  -- query 4.(c)  If CustomerID is updated in Customers, referencing rows in Orders must be updated accordingly.
create trigger UpdateCustomer on Customer
AFTER UPDATE
AS 
BEGIN 
	SET NOCOUNT ON;
	DECLARE @id INT;
	SELECT @id = customerId
	from inserted;

	UPDATE orders 
	set 
	customerId=@Id;
end;
go


--testing
update customer 
set CustomerId = 9
where CustomerId =1;
select * from orders;
go


--query 4 (d)Updating and Insertion of rows in Orders table must verify that CustomerID exists in Customer table, otherwise Raiserror to notify.

create or alter trigger verifyID 
on orders
after update ,insert 
as
begin 
set nocount on;
	if exists
	(
		select 'True'
		from inserted 
			left join customer 
			on inserted.CustomerId = Customer.CustomerId
			where customer.CustomerId is null
	)
	begin 
		raiserror ('Customer Id is not found !!',16,1);
		rollback tran;
		return;

	end;
end;
go

--testing
update orders 
set CustomerId = 115
where OrderId =3;


--query 5 Create a scalar function named fn_CheckName(@FirstName, @LastName) to check that the FirstName and LastName are not the same.

CREATE FUNCTION dbo.fn_CheckName
(
@FirstName nvarchar(200),
@LastName nvarchar(200)
)
returns bit
as
begin 
declare @string bit;
	if (@FirstName = @LastName)
		set @string ='false';
	else
		set  @string = 'true';
	return @string

end;
go

--testing
SELECT *, dbo.fn_CheckName( FirstName, LastName )
FROM Customer
WHERE CustomerID = 2;
GO


--query 6
create procedure sp_InsertCustomer 
@firstname nvarchar(200),
@lastname nvarchar(200),
@custId int

as
begin 
set nocount on;
declare @result bit;
	set @result = dbo.fn_CheckName(@firstname, @lastname)

--a) If CustomerID is not provided, increment the last CustomerID and use that.

	 IF(@custID = 0)
            BEGIN
                SET @custID =
                (
                    SELECT MAX(CustomerID)
                    FROM Customer
                ) + 1;
        END;
		
--b) Use the fn_CheckName function to verify that the customer name is correct. Do not insert record if verification fails. 

	if(@result =1)
		begin 
		insert into Customer (CustomerId, LastName,FirstName)
		values (@custId, @firstname,@lastname);
	end;
	end;
go

-- query 7  Log all updates to Customer table to CusAudit table. Indicate the previous and new values of data, the date and time and the login name of the person who made the changes. 
set nocount on;
if exists
(
    SELECT TABLE_NAME
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = N'CusAudit'
)
 BEGIN
        SELECT 'CusAudit Table Already Created' AS Message;
END;
ELSE
    BEGIN
        CREATE TABLE CusAudit
        (CusAuditID INTEGER IDENTITY(1, 1) PRIMARY KEY, 
         CustomerId INT NOT NULL,           
         FirstName  NVARCHAR(50) NOT NULL, 
         LastName   NVARCHAR(50) NOT NULL,          
         UpdatedBy  NVARCHAR(50) NOT NULL, 
         UpdatedOn  DATETIME NOT NULL,
        );
        
        SELECT 'CusAudit Table Created' AS Message;
END;
GO

CREATE TRIGGER CustTableUpdates ON Customer
AFTER UPDATE, INSERT
AS
     BEGIN
         SET NOCOUNT ON;
		 INSERT INTO CusAudit
         (CustomerId, 
          FirstName, 
          LastName, 
          UpdatedBy, 
          UpdatedOn
         )
                SELECT i.CustomerId, 
                       i.FirstName, 
                       i.LastName, 
                       SUSER_NAME(), 
                       GETDATE()
                FROM Customer C
                     INNER JOIN inserted i ON C.CustomerID = i.CustomerID;
     END;
GO










