/* Northwind Database Analysis */
USE northwind;

/* Database Schema Overview */
-- The Northwind database contains various tables related to customers, orders, products, and suppliers.
-- Key tables and attributes:
-- Categories: Stores product categories.
-- Customers: Contains customer details and demographics.
-- Employees: Stores employee information, including reporting hierarchy.
-- Orders: Tracks customer orders and shipping details.
-- OrderDetails: Links orders to products and records quantities and prices.
-- Products: Stores details about items available for sale.
-- Suppliers: Contains supplier company information.

------------------------------------------------------------
-- Query: Retrieve product names along with their categories.
-- Business Insight: Helps understand product distribution across categories.
------------------------------------------------------------
SELECT
	ProductID,
	ProductName,
    CategoryName
FROM Products AS P
INNER JOIN Categories AS C ON P.CategoryID = C.CategoryID
ORDER BY CategoryName, ProductName;

------------------------------------------------------------
-- Query: Identify customers with high purchasing activity.
-- Business Insight: Helps target high-value customers for marketing efforts.
------------------------------------------------------------
SELECT
	C.CustomerID,
	C.CompanyName,
    COUNT(O.OrderID) AS total_orders
FROM Customers C
INNER JOIN Orders O ON C.CustomerID = O.CustomerID
GROUP BY C.CustomerID
HAVING COUNT(O.OrderID) > 10
ORDER BY total_orders DESC;

------------------------------------------------------------
-- Query: Identify inactive customers (no orders placed).
-- Business Insight: Helps sales teams re-engage inactive customers.
------------------------------------------------------------
SELECT
	C.CustomerID,
	C.ContactName
FROM Customers C
LEFT JOIN Orders O ON C.CustomerID = O.CustomerID
WHERE O.OrderID IS NULL;

------------------------------------------------------------
-- Query: Find top three shipping destinations with the highest average freight charges.
-- Business Insight: Helps optimize logistics and cost estimation.
------------------------------------------------------------
SELECT
	ShipCountry,
    ROUND(AVG(Freight), 2) AS average_freight
FROM Orders
GROUP BY ShipCountry
ORDER BY average_freight DESC
LIMIT 3;

------------------------------------------------------------
-- Query: Supplier Analysis – Number of products supplied and total quantity ordered.
-- Business Insight: Helps assess supplier performance and demand trends.
------------------------------------------------------------
SELECT
	S.SupplierID,
	S.CompanyName,
    COUNT(P.ProductID) AS total_products_supplied,
    COALESCE(SUM(OD.Quantity), 0) AS total_quantity_ordered
FROM Suppliers S
INNER JOIN Products P ON S.SupplierID = P.SupplierID
LEFT JOIN OrderDetails OD ON P.ProductID = OD.ProductID
GROUP BY S.SupplierID, S.CompanyName;

------------------------------------------------------------
-- Query: Order Analysis – Identify high-value orders.
-- Business Insight: Helps track revenue and prioritize large orders.
------------------------------------------------------------
SELECT
	O.OrderID,
	O.CustomerID,
    COUNT(OD.ProductID) AS num_products_in_order,
    SUM(OD.Quantity) AS total_units_in_order,
    SUM(OD.Quantity * OD.UnitPrice) AS total_order_value
FROM Orders O
INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
GROUP BY O.OrderID
HAVING total_order_value > 10000
ORDER BY total_order_value DESC;

------------------------------------------------------------
-- Query: Supplier Revenue Analysis (2014) – Total revenue and discount applied.
-- Business Insight: Assesses supplier contribution to total sales and discount strategies.
------------------------------------------------------------
SELECT
	S.SupplierID,
	S.CompanyName,
    YEAR(O.OrderDate) AS order_year,
    SUM(OD.Quantity * OD.UnitPrice) AS total_revenue,
    SUM(OD.Quantity * OD.UnitPrice * OD.Discount) AS total_discount
FROM Orders O
INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
INNER JOIN Products P ON OD.ProductID = P.ProductID
INNER JOIN Suppliers S ON P.SupplierID = S.SupplierID
WHERE YEAR(O.OrderDate) = 2014
GROUP BY S.SupplierID, S.CompanyName, order_year
HAVING total_revenue > 10000;

------------------------------------------------------------
-- Query: Customer Segmentation Based on Spending (2016)
-- Business Insight: Helps classify customers into spending tiers for personalized marketing.
------------------------------------------------------------
SELECT
	C.CustomerID,
	C.CompanyName,
    IFNULL(TotalSpent.total_spent, 0) AS total_spent_before_discount,
    IFNULL(TotalSpent.total_discount, 0) AS total_discount_applied,
    CASE
		WHEN IFNULL(TotalSpent.total_spent_after_discount, 0) > 5000 THEN 'High'
        WHEN IFNULL(TotalSpent.total_spent_after_discount, 0) > 1000 THEN 'Medium'
        ELSE 'Low'
	END AS SpendingCategory
FROM Customers C
LEFT JOIN (
	SELECT
		O.CustomerID,
        SUM(OD.Quantity * OD.UnitPrice) AS total_spent,
        SUM(OD.Quantity * OD.UnitPrice * OD.Discount) AS total_discount,
        SUM(OD.Quantity * OD.UnitPrice) - SUM(OD.Quantity * OD.UnitPrice * OD.Discount) AS total_spent_after_discount
	FROM Orders O
	INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
	WHERE YEAR(O.OrderDate) = 2016
	GROUP BY O.CustomerID
) AS TotalSpent ON C.CustomerID = TotalSpent.CustomerID
ORDER BY SpendingCategory DESC, total_spent_after_discount DESC;
