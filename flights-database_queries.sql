------------------------------------------------------------
-- Flights Database Analysis
-- Business Insight: Identifying high-traffic routes and optimizing pricing strategies.
------------------------------------------------------------
USE flights;

------------------------------------------------------------
-- Query: Find routes where origin and destination are within the same state.
-- Business Insight: Helps identify intra-state travel trends.
------------------------------------------------------------
SELECT DISTINCT
	TP.origin,
    TP.dest,
    AO.state AS state_origin,
    AD.state AS state_dest
FROM m_ticket_prices TP
INNER JOIN m_airports AO ON TP.origin = AO.airport
INNER JOIN m_airports AD ON TP.dest = AD.airport
WHERE AO.state = AD.state;

------------------------------------------------------------
-- Query: Route Analysis – Cheapest, most expensive, and average fares.
-- Business Insight: Helps analyze fare distribution and competitive pricing.
------------------------------------------------------------
SELECT
	origin,
    dest,
    MIN(fare) AS cheapest_fare,
    MAX(fare) AS most_expensive_fare,
    AVG(fare) AS average_fare,
    COUNT(DISTINCT carrier) AS num_carriers,
    SUM(passengers) AS total_passengers
FROM m_ticket_prices
GROUP BY origin, dest
HAVING num_carriers >= 3 AND total_passengers > 10000;

------------------------------------------------------------
-- Query: Carrier Performance – Number of routes and average fare per mile.
-- Business Insight: Helps assess airline performance and pricing efficiency.
------------------------------------------------------------
SELECT
	carrier,
    COUNT(DISTINCT CONCAT(origin, '-', dest)) AS num_routes,
    COUNT(DISTINCT origin) AS num_departure_airports,
    AVG(fare_per_mile) AS average_fare_per_mile
FROM m_ticket_prices
GROUP BY carrier
HAVING SUM(passengers) > 20000;
