--First I created the Database
CREATE DATABASE Bike Store;
DROP TABLE IF EXISTS orders;
--Then, I created the tables of the sales from the Excel Database. 
CREATE TABLE customers(
customer_id SMALLINT PRIMARY KEY,
first_name VARCHAR(100),
last_name VARCHAR(100),
email VARCHAR(100),
street VARCHAR(100),
city VARCHAR(100),
state VARCHAR(100),
zip_code INT
);

CREATE TABLE stores(
store_id SMALLINT PRIMARY KEY,
store_name VARCHAR(100),
phone VARCHAR(100),
email VARCHAR(100),
street VARCHAR(100),
city VARCHAR(100),
state VARCHAR(100),
zip_code INT
);

CREATE TABLE staffs(
staff_id SMALLINT PRIMARY KEY,
first_name VARCHAR(100),
last_name VARCHAR(100),
email VARCHAR(100),
phone VARCHAR(100),
active VARCHAR(100),
store_id INT,
FOREIGN KEY (store_id) REFERENCES stores (store_id)
);

CREATE TABLE orders(
order_id SMALLINT PRIMARY KEY,
customer_id INT,
order_status VARCHAR(100),
order_date DATE,
shipped_date DATE,
store_id INT,
staff_id INT,
FOREIGN KEY (customer_id) REFERENCES customers (customer_id),
FOREIGN KEY (store_id) REFERENCES stores (store_id),
FOREIGN KEY (staff_id) REFERENCES staffs (staff_id)
);

--Then I uploaded the information from the Bike Store Sales.
--Customers
COPY customers (customer_id, first_name, last_name,
			   email, street, city, state, zip_code)
FROM 'C:\Users\Public\Public Doc4SQL\dataset\customers.csv' DELIMITER ','
CSV Header ;

--Stores
COPY stores (store_id, store_name, phone,
			   email, street, city, state, zip_code)
FROM 'C:\Users\Public\Public Doc4SQL\dataset\stores.csv' DELIMITER ','
CSV Header ;

--Staffs
COPY staffs (staff_id, first_name, last_name,
			   email, phone, active, store_id)
FROM 'C:\Users\Public\Public Doc4SQL\dataset\staffs.csv' DELIMITER ','
CSV Header ;

--Orders
COPY orders (order_id, customer_id, order_status, order_date,
			   shipped_date, store_id, staff_id)
FROM 'C:\Users\Public\Public Doc4SQL\dataset\orders.csv' DELIMITER ','
CSV Header ;

--Then I verified everything individually using the SELECT command
SELECT * FROM customers;
SELECT * FROM stores;
SELECT * FROM staffs;
SELECT * FROM orders;

--After the creation of these table I conducted various analysis

--I conducted a customer order analysis by store, to allow us to see which customers made what orders at what store.
SELECT c.customer_id, c.first_name, s.store_name, 
o.order_id, o.order_date, o.shipped_date
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
INNER JOIN stores s ON o.store_id = s.store_id;

--Then I showed the amount of orders by customer, the max being 3. 
SELECT c.customer_id, c.first_name, c.last_name, COUNT(o.order_id) AS total_orders
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_orders DESC;


--Here, I identified the sales per store and state which these shops were in.
SELECT s.store_id, s.store_name, s.state, COUNT(o.order_id) AS total_orders
FROM stores s
LEFT JOIN orders o ON s.store_id = o.store_id
GROUP BY s.store_id, s.store_name, s.state
ORDER BY total_orders DESC;
-- From this we can see that Baldwin bikes in NY is the best performing shop based on number of orders. 

-- Staff Analysis 
--First I wanted to know the amount of staff per store
SELECT s.store_id, st.store_name, COUNT(*) AS staff_count
FROM staffs s
JOIN stores st ON s.store_id = st.store_id
GROUP BY s.store_id, st.store_name
ORDER BY staff_count DESC;
--The most staff members are in the Santa Cruiz location.

--TO analyse the staff further, and see if we are overstaffed, I displayed the sales by staff member showing their location. 
SELECT s.staff_id, s.first_name, s.last_name, st.city, COUNT(DISTINCT o.customer_id) AS total_customers_served
FROM staffs s
LEFT JOIN orders o ON s.staff_id = o.staff_id
LEFT JOIN stores st ON s.store_id = st.store_id
GROUP BY s.staff_id, s.first_name, s.last_name, st.city
ORDER BY total_customers_served DESC;
-- From this we can see the top 2 staff members are from Baldwin, with a significant difference from the other stores.
--This is concerning due to difference in sales rates in Santa cruiz. 
--They should consider why this is, as the total customers served by two staff members from santa monica is 0. 

--Below displays the top employees in each store. 
WITH RankedEmployees AS (
    SELECT s.store_id, s.staff_id, s.first_name, s.last_name, COUNT(o.order_id) AS total_orders,
           ROW_NUMBER() OVER (PARTITION BY s.store_id ORDER BY COUNT(o.order_id) DESC) AS rank
    FROM staffs s
    LEFT JOIN orders o ON s.staff_id = o.staff_id
    GROUP BY s.store_id, s.staff_id, s.first_name, s.last_name
)
SELECT re.store_id, re.staff_id, re.first_name, re.last_name, re.total_orders, st.store_name
FROM RankedEmployees re
JOIN stores st ON re.store_id = st.store_id
WHERE re.rank = 1 ORDER BY re.total_orders DESC ;

--Distribution analysis by store, here I showed the average delivery processing time by store
SELECT s.store_id, s.store_name, AVG(o.shipped_date - o.order_date) AS avg_processing_time
FROM stores s
INNER JOIN orders o ON s.store_id = o.store_id
GROUP BY s.store_id, s.store_name;
-- This showed me the best average time was Baldwin bikes.

--My analysis provides a comprehensive view of customer behavior, store performance, and staff efficiency. 
--Allowing for informed decision-making to optimize business operations and improve customer satisfaction.