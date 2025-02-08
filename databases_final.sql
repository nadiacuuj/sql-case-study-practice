/* NORTHWIND DATABASE */
USE northwind;
-- these are the tables in the northwind database, and their respective attributes: 
-- Categories -> CategoryID, CategoryName, Description
-- CustomerGroupThresholds -> CustomerGroupName, RangeBottom, RangeTop
-- Customers -> CustomerID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone
-- Employees -> EmployeeID, LastName, FirstName, Title, TitleOfCourtesy, BirthDate, HireDate, Address, City, Region, PostalCode, Country, HomePhone, Extension, Notes, ReportsTo, PhotoPath
-- OrderDetails -> OrderID, ProductID, UnitPrice, Quantity, Discount
-- Orders -> OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry
-- Products -> ProductID, ProductName, SupplierID, CategoryID, QuantityPerUnit, UnitPrice, UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued
-- Shippers -> ShipperID, CompanyName, Phone
-- Suppliers -> SupplierID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, Fax, Homepage

/* Q11:
Retrieve the names of products along with the category name they belong to. 
Display the ProductID, ProductName, and CategoryName. 
Sort the results by CategoryName and then by ProductName */
SELECT
	ProductID,
	ProductName,
    CategoryName
FROM Products AS P INNER JOIN Categories AS C
	ON P.CategoryID = C.CategoryID
ORDER BY CategoryName AND ProductName;

/* Q12:
Find the customers who have placed more than 10 orders.
Display the CustomerID, CompanyName, and the total number of orders they have placed. */
SELECT
	C.CustomerID, C.CompanyName,
    COUNT(OrderID) AS total_num_orders
FROM Customers C INNER JOIN Orders O ON C.CustomerID=O.CustomerID
GROUP BY C.CustomerID
HAVING	COUNT(OrderID)>10
ORDER BY total_num_orders ASC;

/* Q13:
List the names and id of customers who have never placed an order.
Display the CustomerID and ContactName. */
-- Customers -> CustomerID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone
-- Orders -> OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry
SELECT
	C.CustomerID, C.ContactName,
    O.OrderID -- also select OrderID from Orders table (will be NULL for customers with no orders)
FROM Orders O RIGHT JOIN Customers C ON O.CustomerID=C.CustomerID
WHERE O.OrderID IS NULL;  -- show only customers who have no corresponding orders (i.e. OrderID is NULL)

/* Q14:
We want to identify the ship countries with the highest average freight charges.
Return the top-three ship countries with the highest average freight overall, in descending order by average freight.
You only need the Orders table. */
-- Orders -> OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry
SELECT
	ShipCountry,
    ROUND(AVG(Freight), 2) AS average_freight -- round to 2 d.p.
FROM Orders
GROUP BY ShipCountry
ORDER BY average_freight DESC
LIMIT 3;

/* Q15:
For each supplier, list:
- The TOTAL number of products they supply, 
- and the total quantity of these products that have been ordered.
Display the SuplierID, CompanyName, TotalProducts, and TotalQuantityOrdered. */
-- Suppliers -> SupplierID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, Fax, Homepage
-- Products -> ProductID, ProductName, SupplierID, CategoryID, QuantityPerUnit, UnitPrice, UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued
-- OrderDetails -> OrderID, ProductID, UnitPrice, Quantity, Discount
SELECT
	S.SupplierID, S.CompanyName, -- for each supplier
    COUNT(P.ProductID) AS total_num_products_supplied,
    COALESCE(SUM(OD.Quantity), 0) AS total_quantity_of_these_ordered -- without coalesce, NULL will appear for suppliers with no orders
FROM Suppliers S 
	INNER JOIN Products P ON S.SupplierID=P.SupplierID
    INNER JOIN OrderDetails OD ON P.ProductID=OD.ProductID
GROUP BY S.SupplierID, S.CompanyName;

/* Q16: For each order:
- Show the customerID who placed the order, 
- and list the number of products in the order, 
- the total units in the order 
	- (Each order may contain multiple units of a product as reported in the "Quantity" field or OrderDetails), 
- and the total order price for all the products being the Quantity and UnitPrice fields in the OrderDetails table; ignore the Discount field). 
- Sort the results by decreasing total price and display only orders where the total price is above 10,000 */
-- Orders -> OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry
-- OrderDetails -> OrderID, ProductID, UnitPrice, Quantity, Discount
SELECT
	O.OrderID,
	O.CustomerID,
    COUNT(OD.ProductID) AS num_products_in_order,
    SUM(OD.Quantity) AS total_units_in_order,
    SUM(OD.Quantity*OD.UnitPrice) AS total_price_of_order
FROM Orders O INNER JOIN OrderDetails OD ON O.OrderID=OD.OrderID
GROUP BY O.OrderID
HAVING total_price_of_order > 10000
ORDER BY total_price_of_order DESC;

/* Q17: 
- For each supplier, we want to calculate how much revenue they generated from product sales in 2014, 
and display suppliers who generated more than $10,000 in revenue.
- Show the:
	- SupplierID and CompanyName for each supplier,
	- The total revenue generated from their products (use Quantity and UnitPrice fields in the OrderDetails table; the revenue for each product is Quantity*UnitPrice)
	- The total discount applied to their products (consider the Discount field in the  OrderDetails table, together with Quantity and UnitPrice fields; the applied discount is Quantity*UnitPrice*Discount) */
-- Orders -> OrderDate (to filter for year 2014), OrderID (to connect O and OD)
-- OrderDetails -> OrderID, ProductID, UnitPrice, Quantity, Discount
-- Products -> ProductID, SupplierID (to connect OD and S)
-- Suppliers -> SupplierID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, Fax, Homepage
SELECT
	S.SupplierID, S.CompanyName,
    YEAR(O.OrderDate) AS year_ordered, 
    SUM(OD.Quantity * OD.UnitPrice) AS total_revenue_generated,
    SUM(OD.Quantity * OD.UnitPrice * OD.Discount) AS total_discount_applied
FROM Orders O
	INNER JOIN OrderDetails OD ON O.OrderID=OD.ORderID
    INNER JOIN Products P ON OD.ProductID=P.ProductID
    INNER JOIN Suppliers S ON P.SupplierID=S.SupplierID
WHERE YEAR(O.OrderDate) = 2014
GROUP BY S.SupplierID, S.CompanyName, year_ordered
HAVING total_revenue_generated > 10000;
    
/* Q18 - HARD QUESTION - Requires use of subqueries and CASE WHEN:
- We want to create groups of customers based on their total amount spent after discounts, in 2016. 
- We will create three groups:
	- Low (for customers spending between 0 and 1000),
	- Medium (for customers spending between 1000 and 5000),
	- High (for customers spending above 5000)
- The output should list the CustomerID, the CompanyName, the total amount spent before discounts, the total discount applied, and the grouping
	- *from prev Q: The total discount applied to their products (consider the Discount field in the  OrderDetails table, together with Quantity and UnitPrice fields; the applied discount is Quantity*UnitPrice*Discount)
- You will need to use the results from the question "Total amount spent per customer in 2016" as a subquery, and then use the CASE WHEN structure to define the three groups. 
- Do not worry about edge cases for the three groups (i.e. for amounts spent equal to 1000 and 5000) */
-- Orders -> OrderID, CustomerID, EmployeeID, OrderDate (year 2016)
-- Customers -> CustomerID, CompanyName, ContactName
-- OrderDetails -> OrderID, ProductID, UnitPrice, Quantity, Discount

SELECT
	C.CustomerID, C.CompanyName,
    IFNULL(TotalAmountSpentPerCustomer_2016.total_spent_before_discount, 0) AS total_spent_before_discount, -- IFNULL ensures that customers with no orders are reflected as 0
    IFNULL(TotalAmountSpentPerCustomer_2016.total_discount_applied, 0) AS total_discount_applied,    
    TotalAmountSpentPerCustomer_2016.total_spent_after_discount,
    CASE -- create groupings as per instructions
		WHEN IFNULL(TotalAmountSpentPerCustomer_2016.total_spent_after_discount,0) > 5000 THEN 'High' -- don't worry about edge cases
        WHEN IFNULL(TotalAmountSpentPerCustomer_2016.total_spent_after_discount,0) > 1000 THEN 'Medium'
        ELSE 'Low'
	END AS CustomerGroup
    
FROM Customers C
	LEFT JOIN ( -- include customers with no orders
				SELECT -- define subquery as per instructions
					O.CustomerID,
                    SUM(OD.Quantity * OD.UnitPrice) AS total_spent_before_discount,
                    SUM(OD.Quantity * OD.UnitPrice * OD.Discount) AS total_discount_applied,
                    SUM(OD.Quantity*OD.UnitPrice) - SUM(OD.Quantity*OD.UnitPrice*OD.Discount) AS total_spent_after_discount
				FROM Orders O
					INNER JOIN OrderDetails OD ON O.OrderID=OD.OrderID
				WHERE YEAR(O.OrderDate) = 2016
                GROUP BY O.CustomerID
                ) AS  TotalAmountSpentPerCustomer_2016 
		ON C.CustomerID=TotalAmountSpentPerCustomer_2016.CustomerID

ORDER BY 
	CustomerGroup DESC,
    TotalAmountSpentPerCustomer_2016.total_spent_after_discount DESC
;

/* FLIGHTS DATABASE */
USE flights;
-- these are the tables in the flights database, and their respective attributes: 
-- m_airports -> airport(ABE,ABI,...), state (PA,TX,...), state_name
-- m_ticket_prices -> origin(ABE,...), dest(ATL,AUS,BHM,...), carrier(DL,AA), fare, fare_per_mile, passengers, distance
-- raw_market -> ItinID, MktID, MktCoupons, Year, Quarter, OriginAirportID, OriginAirportSeqID, OriginCityMarketID, Origin, OriginCountry, OriginStateFips, OriginState, OriginStateName, OriginWac, DestAirportSeqID, DestAirportSeqID, DestCityMarketID, Dest, DestCountry, DestStateFips, DestState, DestStateName, DestWac, AirportGroup, WacGroup, TkCarrierChange, TKCarrierGroup, OpCarrierChange, OpCarrierGroup, RPCarrier, TkCarrier, OpCarrier, BulkFare, Passengers, MktFare, MktDistance, MktDistanceGroup, MktMilesFlown, NonStopMiles, ItinGeoType, MktFeoType, Unnamed: 41
-- raw_ticket -> ItinID, Coupons, Year, Quarter, Origin, OriginAirportID, OriginAirportSeqID, ORiginCityMarketID, OriginCountry, OriginStateFips, OriginState, OriginStateName, OriginWac, RoundTrip, OnLine, DollarCred, FarePerMile, RPCarrier, Passenfers, ItinFare, BulkFare, Distance, DistanceGroup, MilesFlown, ItinGeoType, Unnamed: 25

/* Q19: Using the flights.m_ticket_prices and the m_airports table:
- Find the distinct routes (route is a distinct origin-destination pair), where the origin and the destination are part of the same state.
- In the output show the origin, dest, and the state of the airports. */
SELECT DISTINCT
	TP.origin, TP.dest, 
    AO.state AS state_origin_airport,
    AD.state AS state_dest_airport
FROM m_ticket_prices TP
	INNER JOIN m_airports AO ON TP.origin=AO.airport
    INNER JOIN m_airports AD ON TP.dest=AD.airport
WHERE (AO.state=AD.state) AND (AO.state_name=AD.state_name); -- only show when origin and dest airport are in same state

/* Q20: Use the table flights.m_ticket_prices.
For each route (origin-destination pair), list the following statistics:
- cheapest fare
- most expensive fare
- the average fare
- number of carriers serving the route
- total number of passengers for the route
Report results only for routes with at least 3 carriers and more than 10,000 total passengers. */
-- m_ticket_prices -> origin(ABE,...), dest(ATL,AUS,BHM,...), carrier(DL,AA), fare, fare_per_mile, passengers, distance
SELECT DISTINCT 
	origin, dest,
    MIN(fare) AS cheapest_fare,
    MAX(fare) AS most_expensive_fare,
    AVG(fare) AS average_fare,
    COUNT(DISTINCT(carrier)) AS num_carriers_serving_route,
    SUM(passengers) AS total_num_passengers_for_route
FROM m_ticket_prices TP
GROUP BY origin, dest
HAVING (num_carriers_serving_route>=3) AND (total_num_passengers_for_route>10000);

/* Q21: Use the m_ticket_prices and the m_airports tables to find the information that you need.
For each state of the origin airport, calculate the follwing metrics:
- The number of origin airports in the state,
- The number of carriers operating flights that originate from the state,
- The total number of passengers originating from the  state, and the average fare per mile. */
-- m_airports -> airport(ABE,ABI,...), state (PA,TX,...), state_name

SELECT
	A.state as state_origin_airport,
    COUNT(DISTINCT(A.airport)) AS num_origin_airports_in_state,
    COUNT(DISTINCT(TP.carrier)) AS num_carriers,
    SUM(TP.passengers) AS total_num_passengers,
    AVG(TP.fare_per_mile) AS average_fare_per_mile
FROM m_ticket_prices TP
	INNER JOIN m_airports A ON TP.origin=A.airport
GROUP BY state_origin_airport;

/* Q22:
Using the table flights.m_ticket_prices:
For each carrier, report the number of routes they maintain, the number of airports their flights leave from, and their average fare per mile.
Report results only for carriers having more than 20,000 passengers across all their flights. */
SELECT
	carrier, 
    -- number of unique routes (origin-destination pairs):
    COUNT(DISTINCT CONCAT(origin, '-', dest)) AS num_routes_maintained, -- e.g. if origin is JFK and dest is LAX, displays string "JFK-LAX"
    -- number of unique departure airports:
    COUNT(DISTINCT origin) AS num_departure_airports, 
    AVG(fare_per_mile) AS average_fare_per_mile
FROM m_ticket_prices
GROUP BY carrier
HAVING SUM(passengers) > 20000;

