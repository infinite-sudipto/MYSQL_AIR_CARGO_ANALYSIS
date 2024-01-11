


    
    drop database if exists air;
    create database if not exists air;
    use air;
    
    
  set @@sql_mode = SYS.LIST_DROP(@@SQL_MODE,'ONLY FULL GROUP BY');
  SELECT@@sql_mode;
    
    
 /* #1.  Write a query to create route_details table using suitable data types for the fields, 
 such as route_id, flight_num, origin_airport, destination_airport, aircraft_id, and distance_miles.
 Implement the check constraint for the flight number and unique constraint for the route_id fields.
 Also, make sure that the distance miles field is greater than 0.*/
    
    # creating customer table
    
    DROP TABLE CUSTOMER;
    CREATE TABLE CUSTOMER 
    ( 
    CUSTOMER_ID INT DEFAULT NULL,
    FIRST_NAME VARCHAR(25),
    LAST_NAME VARCHAR(25),
    DOB VARCHAR(25),
    GENDER VARCHAR(25)
    );
 
  # CREATING PASSENGER ON FLIGHTS TABLE.
  
  DROP TABLE IF EXISTS P_ON_FLIGHTS;
  
  CREATE TABLE P_ON_FLIGHTS
  ( CUSTOMER_ID INT DEFAULT NULL,
  AIRCRAFT_ID VARCHAR(25),
  ROUTE_ID INT DEFAULT NULL,
  DEPART VARCHAR(255),
  ARRIVAL VARCHAR(255),
  SEAT_NO VARCHAR(25),
  CLASS_ID VARCHAR(25),
  TRAVEL_DATE VARCHAR(255),
  FLIGHT_NUM VARCHAR(255)
  );
  

  
# CREATING ROUTES TABLE.

DROP TABLE IF EXISTS ROUTES;

CREATE TABLE IF NOT EXISTS ROUTES
( ROUTE_ID INT DEFAULT NULL,
FLIGHT_NO INT DEFAULT NULL CHECK (FLIGHT_NO LIKE "11%"),
ORIGIN_AIRPORT VARCHAR(25),
DESTINATION_AIRPORT VARCHAR(25),
AIRCRAFT_ID VARCHAR(25),
DISTANCE_MILES INT DEFAULT NULL CHECK(DISTANCE_MILES > 0)
);

# CREATING TICKET_INFO TABLE.
DROP TABLE IF EXISTS TICKET_INFO;

CREATE TABLE IF NOT EXISTS TICKET_INFO
(    
  P_DATE VARCHAR(255),
  CUSTOMER_ID INT DEFAULT NULL,
  AIRCRAFT_ID VARCHAR(255),
  CLASS_ID VARCHAR(255),
  NO_OF_TICKETS INT DEFAULT NULL,
  A_CODE VARCHAR(255),
  PRICE INT DEFAULT NULL,
  BRAND VARCHAR(255)
  );
    
    
  
    
    # INSERT DATA
    
    INSERT  INTO CUSTOMER
    SELECT *
    FROM CUSTOMERC;
    
    INSERT INTO P_ON_FLIGHTS
    SELECT *
    FROM 
    passengers_on_flights;
    
    INSERT INTO ROUTES
    SELECT *
    FROM
    ROUTESS;
    
    INSERT INTO TICKET_INFO
    SELECT * 
    FROM 
     TICKET_DETAILS;
    
    
    #2. Write a query to display all the passengers (customers) who have travelled in routes 01 to 25. Take data  from the passengers_on_flights table.
    
  WITH CTE AS 
  (SELECT CUSTOMER_ID,ROUTE_ID FROM P_ON_FLIGHTS WHERE ROUTE_ID BETWEEN 1 AND 25)
  SELECT CTE.CUSTOMER_ID,C.FIRST_NAME,C.LAST_NAME, C.GENDER,C.DOB,CTE.ROUTE_ID
  FROM CTE JOIN
  CUSTOMER AS C 
  ON
  C.CUSTOMER_ID = CTE.CUSTOMER_ID;  

  #3.Write a query to identify the number of passengers and total revenue in business class from the ticket_details table.  
    
SELECT CLASS_ID, COUNT(CUSTOMER_ID) AS NO_OF_PASSENGER , SUM(PRICE) AS REVENUE
FROM
TICKET_INFO
WHERE CLASS_ID = 'BUSSINESS';    
    
#4. Write a query to display the full name of the customer by extracting the first name and last name from the customer table.

SELECT CONCAT(FIRST_NAME, ' ',LAST_NAME) AS FULL_NAME    
FROM
CUSTOMER;

#5.Write a query to extract the customers who have registered and booked a ticket. Use data from the customer and ticket_details tables.

    SELECT C.CUSTOMER_ID, C.FIRST_NAME, C.LAST_NAME, C.GENDER, C.DOB, T.CLASS_ID, T.BRAND
    FROM CUSTOMER AS C 
    JOIN
    TICKET_INFO AS T
    ON C.CUSTOMER_ID = T.CUSTOMER_ID
    ORDER BY C.CUSTOMER_ID;
    
#6.Write a query to identify the customer’s first name and last name based on their customer ID and brand (Emirates) from the ticket_details table.
    
    SELECT C.CUSTOMER_ID, C.FIRST_NAME, C.LAST_NAME, T.BRAND
    FROM
    CUSTOMER AS C 
    JOIN
    TICKET_INFO AS T 
    ON C.CUSTOMER_ID = T.CUSTOMER_ID
    WHERE T.BRAND = 'EmirateS';
    
#7.Write a query to identify the customers who have travelled by Economy Plus class using Group By and Having clause on the passengers_on_flights table.
    SELECT CUSTOMER_ID , CLASS_ID
    FROM P_ON_FLIGHTS
    WHERE CLASS_ID = 'ECONOMY PLUS'
    GROUP BY CUSTOMER_ID
    HAVING COUNT(CUSTOMER_ID) >= 1;
    
#8.Write a query to identify whether the revenue has crossed 10000 using the IF clause on the ticket_details table.

WITH T1 AS 
(
SELECT  SUM(PRICE) AS TOTAL_REVENUE
FROM
TICKET_INFO) 
SELECT T1.TOTAL_REVENUE,IF (T1.TOTAL_REVENUE > 10000 , 'CROSSED 10K','BELOW 10K') AS REVENUE_STATUS
FROM 
T1;

#9.Write a query to create and grant access to a new user to perform operations on a database. 
CREATE USER 'NEW_USER'@'LOCALHOST' IDENTIFIED BY 'AVI';
GRANT ALL ON AIR.* TO 'NEW_USER'@'LOCALHOST';

#10. Write a query to find the maximum ticket price for each class using window functions on the ticket_details table.

WITH T1 AS 
(
SELECT CLASS_ID,MAX(PRICE) AS MAX_PRICE
FROM
TICKET_INFO
GROUP BY CLASS_ID)
SELECT *, DENSE_RANK() OVER W AS RANKING
FROM T1 
WINDOW W AS ( ORDER BY T1.MAX_PRICE DESC);

#11.Write a query to extract the passengers whose route ID is 4 by improving the speed and performance of the passengers_on_flights table.
#For the route ID 4, write a query to view the execution plan of the passengers_on_flights table.

CREATE INDEX IDX_ROUTE_ID ON P_ON_FLIGHTS(ROUTE_ID);
SELECT 
    CUSTOMER_ID
FROM
    P_ON_FLIGHTS
WHERE
    ROUTE_ID = 4;
    
  #12. For the route ID 4, write a query to view the execution plan of the passengers_on_flights table.  
  
  SELECT *
  FROM 
  P_ON_FLIGHTS
  WHERE ROUTE_ID = 4;
  
#13. Write a query to calculate the total price of all tickets booked by a customer across different aircraft IDs using rollup function.
SELECT CUSTOMER_ID,  AIRCRAFT_ID, SUM(PRICE) AS TOTAL_PRICE
FROM
TICKET_INFO 
GROUP BY CUSTOMER_ID, AIRCRAFT_ID
WITH ROLLUP
ORDER BY CUSTOMER_ID;

#14.Write a query to create a view with only business class customers along with the brand of airlines.

CREATE OR REPLACE VIEW INFO AS
SELECT C.CUSTOMER_ID, C.FIRST_NAME,C.LAST_NAME,T.CLASS_ID, T.BRAND
FROM 
CUSTOMER AS C
JOIN
TICKET_INFO AS T 
ON T.CUSTOMER_ID = C.CUSTOMER_ID
WHERE CLASS_ID = 'BUSSINESS';
 
 #CALLING VIEW
 SELECT * FROM air.info;
 
/* #15.Write a query to create a stored procedure to get the details of all passengers flying between a range of routes defined in run time. 
     Also, return an error message if the table doesn't exist.*/
DROP PROCEDURE IF EXISTS P_ON_FLIGHTS;
DELIMITER $$
CREATE PROCEDURE P_ON_FLIGHTS()
BEGIN



END $$
DELIMITER ;
DELIMITER $$

/*#16.Write a query to create a stored procedure that extracts all the details from the routes table
 where the travelled distance is more than 2000 miles.*/

DROP PROCEDURE IF EXISTS MILES;
DELIMITER $$
CREATE PROCEDURE  MILES()
BEGIN
 SELECT * 
 FROM 
 ROUTES 
 WHERE DISTANCE_MILES > 2000;
 END $$ 
DELIMITER ;
CALL MILES();


/*#17. Write a query to create a stored procedure that groups the distance travelled by each flight into three categories. 
The categories are, short distance travel (SDT) for >=0 AND <= 2000 miles,intermediate distance travel (IDT) for >2000 AND <=6500,
 and long-distance travel (LDT) for >6500. */
    
    DROP PROCEDURE DISTANCE_STAT;
    DELIMITER $$
    CREATE PROCEDURE DISTANCE_STAT()
BEGIN
SELECT 
     *,
CASE 
     WHEN DISTANCE_MILES >=0 AND DISTANCE_MILES<=2000 THEN 'SDT' 
     WHEN DISTANCE_MILES >2000 AND DISTANCE_MILES <=6500 THEN 'IDT' 
     WHEN DISTANCE_MILES > 6500 THEN 'LDT' END AS DISTANCE_STAT
FROM
       ROUTES ;
END $$
DELIMITER ;
    
CALL DISTANCE_STAT();
    
 /*#18.  Write a query to extract ticket purchase date, customer ID, class ID and specify 
if the complimentary services are provided for the specific class using a stored function in stored procedure on the ticket_details table.
Condition:

If the class is Business and Economy Plus, then complimentary services are given as Yes, else it is No*/ 
    DROP PROCEDURE COMPLIMENTARY_SERVICE ;
    DELIMITER $$
    CREATE PROCEDURE COMPLIMENTARY_SERVICE()
    BEGIN
    SELECT 
    P_DATE,
    CUSTOMER_ID,
    CLASS_ID,
    CASE
        WHEN
            CLASS_ID = 'BUSSINESS'
                OR CLASS_ID = 'ECONOMY PLUS'
        THEN
            'YES'
        ELSE 'NO'
    END AS COMPLIMENTARY_SERVICE
FROM
    TICKET_INFO
ORDER BY CUSTOMER_ID;
END $$
DELIMITER ;

CALL AIR.COMPLIMENTARY_SERVICE();


 #19. Write a query to extract the first record of the customer whose last name ends with Scott using a cursor from the customer table.   
 #N:B: SOLVING IT BASED ON PARAMETRIC STORED PROCEDURE. KINDLY PROVIDE CURSOR BASED SOLUTION. AS CURSOR BASED SOLUTION'S OUTPUT CONSISTS ONLY ONE OUTPUT INSTEAD OF TWO.
  DROP PROCEDURE IF EXISTS NAME;
  DELIMITER $$
  CREATE PROCEDURE NAME( IN I_L_NAME VARCHAR(25))
  BEGIN
  SELECT 
  CUSTOMER_ID 
  FROM
  CUSTOMER AS C
  WHERE C.LAST_NAME like  I_L_NAME;
  END $$
  DELIMITER ;
  
  call air.name('%Scott');
 