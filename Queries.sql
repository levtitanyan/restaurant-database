USE restaurant;


-- 1. How many items are there in each menu type.
SELECT Menutype,COUNT(id)
FROM Menu USE INDEX (iMenuType)
INNER JOIN menuitem 
USING(menuid)
GROUP BY MenuID;

-- 2. find minimal 3 avergare salaries in each job position.
WITH min_3_salaries AS (
    SELECT JobPosition, ROUND(AVG(salary), 2) AS avg_salary
    FROM Employee USE INDEX (iPhone)
    GROUP BY JobPosition
    ORDER BY avg_salary ASC
    LIMIT 3
)
SELECT JobPosition, CONCAT('$', avg_salary) avg_salary
from min_3_salaries;

-- 3. Create a view of customers,their budget, spending starting from the highest.
CREATE VIEW Customer_Spending AS
SELECT c.customerid, c.budget,p.amount spent 
	FROM customer c  
    LEFT JOIN payment p USING(customerid)
    ORDER BY spent DESC;

SELECT * FROM Customer_Spending;

-- 4. Find employees that are from Russia (we expect them to have 'ov' at the end of their surname).

SELECT FirstName Name, LastName Surname 
FROM employee
HAVING Surname LIKE '%ov';

-- 4.2 What proportion of employees are russians?
SELECT 
    RussianEmployees, TotalEmployees, 
    CONCAT(ROUND((RussianEmployees / TotalEmployees) * 100,2),'%') AS Proportion
FROM 
(SELECT 
        COUNT(CASE WHEN LastName LIKE '%ov' THEN 1 END) AS RussianEmployees,
        COUNT(*) AS TotalEmployees
FROM employee)  AS counts;

-- 5 Function to calculate the the total price of a specific product.


DELIMITER //
CREATE FUNCTION Total_Price(price DECIMAL(10, 2), quantity INT)
RETURNS DECIMAL(10, 2)
READS SQL DATA
BEGIN
    DECLARE total DECIMAL(10, 2);
    SET total = price * quantity;
    RETURN total;
END//
DELIMITER ;

-- 5.2 How much can the restaurant earn,if sells all the products available.
SELECT
    CONCAT('$',SUM(Total_Price(Price, Quantity)))
FROM MenuItem;



-- 6 Create a view of Breakfast Menu.
CREATE VIEW Breakfast_Menu AS
SELECT ItemName, Price, Descriptions
FROM MenuItem
LEFT JOIN Menu USING (MenuID)
WHERE MenuID = 1;

SELECT * FROM Breakfast_Menu;

-- 7 A View of high-priced desserts and cocktails.

CREATE VIEW High_Priced_Items AS
SELECT ItemName, Price,MenuType, Descriptions
FROM MenuItem INNER JOIN Menu USING(MenuId)
WHERE (MenuID = 2 AND Price > 10) OR (MenuID = 3 AND Price > 8);

select * from High_Priced_Items;

-- 8 Find place where the most wealthy people go to.
SELECT t.location,ROUND(AVG(budget),1) avg_budget
FROM customer c
LEFT JOIN reservation r USING(customerid) 
LEFT JOIN TheTable t USING(TableNumber)
GROUP BY t.location
ORDER BY avg_budget desc
LIMIT 1;

-- 9 Find which locations are popular and which are not.  (<10% not popular, >50% poopular else ordinary).
SELECT
    t.location,
    ROUND(AVG(c.budget)) AS avg_budget,
    CASE
        WHEN COUNT(*) < 0.1 * (SELECT COUNT(*) FROM reservation WHERE tablenumber IS NOT NULL) THEN 'Not Popular'
        WHEN COUNT(*) >= 0.5 * (SELECT COUNT(*) FROM reservation WHERE tablenumber IS NOT NULL) THEN 'Popular'
        ELSE 'Ordinary'
    END AS popularity_status
    -- COUNT(*) * 100.0 / (SELECT COUNT(*) FROM reservation WHERE tablenumber IS NOT NULL) AS percent.
FROM
    customer c
LEFT JOIN reservation r ON c.customerid = r.customerid
LEFT JOIN TheTable t ON r.tablenumber = t.tablenumber
WHERE
    r.tablenumber IS NOT NULL
GROUP BY
    t.location;
    
    
    
-- 10 calculate total price of each Order.

SELECT c.FirstName, c.LastName, o.OrderNumber, oi.Quantity, mi.Price,
       SUM(oi.Quantity * mi.Price) AS Payment
FROM Customer c
LEFT JOIN Orders o USING (CustomerID)
LEFT JOIN OrderItem oi USING (OrderNumber)
LEFT JOIN MenuItem mi USING (ID)
GROUP BY c.CustomerID, c.Budget, o.OrderNumber, oi.Quantity, mi.Price;


-- 11 calculate payment for each customer (top 4).
SELECT c.CustomerID, SUM(oi.Quantity * mi.Price) AS TotalPayment
FROM Customer c
LEFT JOIN Orders o USING (CustomerID)
LEFT JOIN OrderItem oi USING (OrderNumber)
LEFT JOIN MenuItem mi USING (ID)
GROUP BY c.CustomerID, c.Budget
ORDER BY TotalPayment desc
LIMIT 4;



-- 12 Assume we are interested in increasing the amount of products that are expensive;
-- Find items that are more expensive than $10 and there are less than 15 left.

SELECT m.itemname,m.price,m.quantity 
FROM menuitem m 
WHERE m.itemname IN 
		(SELECT mm.itemname FROM menuitem mm 
        WHERE mm.price > 10.00 
		AND mm.quantity < 15);


-- 13 Find employeees who have completed an order.
    
SELECT FirstName, LastName
FROM Employee
WHERE EXISTS (
    SELECT *
    FROM Orders
    WHERE Orders.EmployeeID = Employee.EmployeeID
    AND OrderStatus = 'Completed'
);


-- 14 Create Function for increasing the price of product by 1,5x and see it's description .



DELIMITER //
CREATE FUNCTION Update_Describe_Orders(ItemID INT) RETURNS VARCHAR(255)
READS SQL DATA
BEGIN
    DECLARE ItemDescription VARCHAR(255);
    DECLARE NewPrice DECIMAL(10, 2);
    DECLARE Name VARCHAR(50);
    
    SELECT Descriptions INTO ItemDescription FROM MenuItem WHERE ID = ItemID;
    SELECT Price * 1.5 INTO NewPrice FROM MenuItem WHERE ID = ItemID;
    SELECT ItemName INTO Name FROM MenuItem WHERE ID = ItemID;
    
    UPDATE MenuItem SET Price = NewPrice WHERE ID = ItemID;
    
    RETURN CONCAT(Name,': ', ItemDescription, ', New Price: ', NewPrice);
END //
DELIMITER ;

-- Check the existing price.
SELECT ItemName Name, Price OldPrice FROM MenuITem WHERE id = 201;
-- New price.
SELECT Update_Describe_Orders(201);





-- 15 Find items amout of which varies from 10 to 20 in Breakfast and Main Dishes Menus and which are cheaper than any Dessert.
-- EXPLAIN.
SELECT ItemName as Name, Price,Quantity,MenuType
FROM MenuItem mi
INNER JOIN Menu m USING (MenuID)
WHERE m.MenuType  IN ('Breakfast', 'Main Dishes') 
AND Quantity BETWEEN 10 and 15
AND mi.Price > ALL 
(
    SELECT Price
    FROM MenuItem
    INNER JOIN Menu USING (MenuID)
    WHERE MenuType = 'Desserts'
)
ORDER BY Price;

-- See the most expensive dessert.
SELECT MAX(Price) FROM Menu LEFT JOIN MenuItem USING(MenuID) WHERE MenuType = 'Desserts';




-- 16  Increase the quantity by 10 for the items that are less than 15 left.

DELIMITER //

CREATE FUNCTION Increase_Quantity()
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE rowsAffected INT;
    
    UPDATE MenuItem
    SET Quantity = Quantity + 10
    WHERE Quantity < 15 and MenuID between 0 and 1000;
    
	SELECT ROW_COUNT() INTO rowsAffected;
    
    RETURN rowsAffected;
END //

DELIMITER ;
-- let's find out how many of them there exists to see if the function works well .
SELECT COUNT(*) FROM menuitem WHERE Quantity < 15;

SELECT Increase_Quantity();



-- 17.  Write a Function to create a table of specific job position.

DELIMITER //

CREATE PROCEDURE EmployeeOf(IN pJobPosition VARCHAR(30))
BEGIN
    SELECT *
    FROM Employee
    WHERE JobPosition = pJobPosition;
END //

DELIMITER ;

CALL EmployeeOf('cooker');
CALL EmployeeOf('director');

-- 18. View with Rank for menu items.

CREATE VIEW Item_Rank AS
SELECT RANK() OVER (ORDER BY Price DESC) AS PriceRank,
       ItemName,
       Price
FROM MenuItem;

SELECT * FROM Item_Rank;






