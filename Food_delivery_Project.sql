USE food_delivery_db;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(50),
    area VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    registration_date DATE,
    age INT,
    gender VARCHAR(20),
    loyalty_tier VARCHAR(20)
); 

CREATE TABLE swiggy_restaurants (
    restaurant_id INT PRIMARY KEY,
    area VARCHAR(100),
    city VARCHAR(50),
    restaurant_name VARCHAR(150),
    price DECIMAL(10,2),
    avg_rating DECIMAL(3,1),
    total_ratings INT,
    food_type VARCHAR(500),
    address VARCHAR(255),
    delivery_time INT
);

CREATE TABLE menu (
    menu_id INT PRIMARY KEY,
    restaurant_id INT,
    item_name VARCHAR(150),
    price DECIMAL(10,2),
    cuisine_type VARCHAR(100),
    is_available BOOLEAN
);

CREATE TABLE promotions (
    promo_id INT PRIMARY KEY,
    promo_code VARCHAR(50),
    discount_type VARCHAR(30),
    discount_value DECIMAL(10,2),
    min_order_value DECIMAL(10,2),
    valid_from DATE,
    valid_to DATE,
    max_uses INT
);

CREATE TABLE delivery_partners (
    partner_id INT PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(50),
    vehicle_type VARCHAR(30),
    rating DECIMAL(3,1),
    joined_date DATE,
    is_active BOOLEAN,
    total_deliveries INT
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    restaurant_id INT,
    partner_id INT,
    promo_id INT,
    order_date DATE,
    order_time TIME,
    order_status VARCHAR(30),
    subtotal DECIMAL(10,2),
    discount_amount DECIMAL(10,2),
    delivery_fee DECIMAL(10,2),
    total_amount DECIMAL(10,2),
    payment_method VARCHAR(30),
    city VARCHAR(50)
);

CREATE TABLE order_items (
    item_id INT PRIMARY KEY,
    order_id INT,
    menu_item_name VARCHAR(150),
    quantity INT,
    unit_price DECIMAL(10,2),
    total_price DECIMAL(10,2)
);

CREATE TABLE delivery_tracking (
    tracking_id INT PRIMARY KEY,
    order_id INT,
    partner_id INT,
    pickup_time TIME,
    delivery_time TIME,
    distance_km DECIMAL(10,2),
    actual_delivery_minutes INT,
    promised_delivery_minutes INT,
    was_on_time BOOLEAN
);

CREATE TABLE reviews (
    review_id INT PRIMARY KEY,
    order_id INT,
    customer_id INT,
    restaurant_id INT,
    partner_id INT,
    food_rating DECIMAL(3,1),
    delivery_rating DECIMAL(3,1),
    overall_rating DECIMAL(3,1),
    review_date DATE,
    has_text_review BOOLEAN
);

# Add FOREIGN KEY (FK) is a column in one table that refers to a Primary Key (PK) in another table.
# if order_id = 5001, customer_id = 102 => is valid because customer 102 exists.
# But if order_id = 5002, customer_id = 999 => would be invalid if customer 999 doesn't exist.
# So Foreign Keys help maintain Data Integrity.#

# Connect orders → customers : Every order belongs to a customer.
ALTER TABLE orders
ADD Constraint fk_orders_customers # # We are going to change/modify the existing orders table.
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id); 

# Connect orders → swiggy_restaurants : Every order is placed with a restaurant.
ALTER TABLE orders
ADD constraint fk_orders_swiggy_restaurants  
FOREIGN KEY (restaurant_id)
REFERENCES swiggy_restaurants(restaurant_id);

# Connect orders → delivery_partners : An order can be assigned to a delivery partner.

ALTER TABLE orders
ADD CONSTRAINT fk_orders_delivery_partners 
FOREIGN KEY (partner_id)
REFERENCES delivery_partners(partner_id);

# Connect orders → promotions 
ALTER TABLE orders
ADD CONSTRAINT fk_orders_promotions
FOREIGN KEY (promo_id)
REFERENCES promotions(promo_id);

# Connect order_items → orders: One order can contain multiple food items.
ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_orders
FOREIGN KEY (order_id)
REFERENCES orders(order_id);

# Connect delivery_tracking → orders : Delivery tracking belongs to a particular order
ALTER TABLE delivery_tracking
ADD CONSTRAINT fk_delivery_tracking_orders
FOREIGN KEY (order_id)
REFERENCES orders(order_id);

# Connect delivery_tracking → delivery_partners
ALTER TABLE delivery_tracking
ADD CONSTRAINT fk_tracking_partner
FOREIGN KEY (partner_id)
REFERENCES delivery_partners(partner_id);

# Connect reviews → orders: A review is associated with an order.
ALTER TABLE reviews
ADD CONSTRAINT fk_reviews_order
FOREIGN KEY (order_id)
REFERENCES orders(order_id);

# Connect reviews → customers : A customer submits a review.
ALTER TABLE reviews
ADD CONSTRAINT fk_reviews_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

# Connect reviews → swiggy_restaurants: The review is associated with a restaurant.
ALTER TABLE reviews
ADD CONSTRAINT fk_reviews_restaurant
FOREIGN KEY (restaurant_id)
REFERENCES swiggy_restaurants(restaurant_id);

# Connect reviews → delivery_partners: The customer can rate the delivery experience/partner
ALTER TABLE reviews
ADD CONSTRAINT fk_reviews_partner
FOREIGN KEY (partner_id)
REFERENCES delivery_partners(partner_id);

# Connect Menu -> restaurants : One restaurant can have many menu items.
ALTER TABLE menu
ADD CONSTRAINT fk_menu_restaurant
FOREIGN KEY (restaurant_id)
REFERENCES swiggy_restaurants(restaurant_id);

# Verify All Foreign Keys : let's check whether the relationships were actually created.
SELECT
    TABLE_NAME,
    CONSTRAINT_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'food_delivery_db'
AND REFERENCED_TABLE_NAME IS NOT NULL;

SHOW TABLES;
# Check Customers Table Data
SELECT COUNT(*) AS TOTAL_Customers FROM customers;
SELECT * From Customers limit 10;

# Check Null Value in Customers table
SELECT SUM(customer_id IS NULL) AS Missing_id,
SUM(name IS NULL) AS Missing_Name,
SUM(city IS NULL) AS Missing_City,
SUM(area IS NULL) AS Missing_Area,
SUM(phone IS NULL) AS Missing_phone,
SUM(email IS NULL) AS Missing_Email,
SUM(registration_date IS NULL) AS Missing_RegDate,
SUM(age IS NULL) AS Missing_age,
SUM(gender IS NULL) AS Missing_gender,
SUM(loyalty_tier IS NULL) AS Missing_tire
FROM customers;

# Check Date Column
SELECT 
MIN(registration_date) AS First_Registration_Date,
MAX(registration_date) AS Last_Registration_Date
FROM customers;

# Check restaurant table data
SELECT Count(*) As Total_restaurant from swiggy_restaurants;
SELECT * FROM swiggy_restaurants limit 10;

# Check Missing Restaurant id
SELECT COUNT(*) AS Missing_Restaurant_id
FROM swiggy_restaurants WHERE restaurant_id IS NULL ;

# Check Duplicate Restaurant id
SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT restaurant_id) AS Unique_Restaurant_IDs
FROM swiggy_restaurants;

#Verify Menu Table
SELECT COUNT(*) AS Total_Menu_Items
From menu;
SELECT * FROM menu limit 10;

# Check Restaurant IDs: This is important because every restaurant_id in menu should exist in swiggy_restaurants.
SELECT COUNT(*) As Invalid_Restaurant_id
from menu m
Left Join swiggy_restaurants r
ON m.restaurant_id = r.restaurant_id
where  r.restaurant_id IS NULL;
# Ans: 0 means every menu item is connected to a valid restaurant.


#Verify the Promotion Table
Select count(*) As Total_promotions from promotions;
SELECT * From promotions limit 10;

#Check Is NULL Promo ID !
Select count(*) As Missing_Promo_ID
from promotions 
Where promo_id IS NULL;

#Verify Delivery Partners table

#Fixed Error arrived in data during import file 
SELECT COUNT(*) AS Imported_Rows FROM delivery_partners;

ALTER TABLE delivery_partners
MODIFY COLUMN is_active VARCHAR(10);

#Now Data is displayed
SELECT COUNT(*) AS Total_Delivery_Partners
FROM delivery_partners;

SELECT * from delivery_partners limit 10;
SELECT * from delivery_partners where is_active = 'True'; # Active Partners displayed

# Check Orders Table : Fixed error, arrived during import orders
SELECT COUNT(*) AS Current_Orders
FROM orders;
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE orders;
SET FOREIGN_KEY_CHECKS = 1;
SELECT COUNT(*) AS Current_Orders
FROM orders;

#Enable local file loading
SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'D:\H Drive Data\Himanshu (H)\Data Analytics\Capston Project\Food Delivery App\orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    order_id,
    customer_id,
    restaurant_id,
    partner_id,
    @promo_id,
    order_date,
    order_time,
    order_status,
    subtotal,
    discount_amount,
    delivery_fee,
    total_amount,
    payment_method,
    city
)
SET promo_id = NULLIF(@promo_id, '');

SHOW VARIABLES LIKE 'local_infile';
#Now Check Current order status
SELECT COUNT(*) AS Current_Orders FROM orders;

LOAD DATA LOCAL INFILE 'D:/H Drive Data/Himanshu (H)/Data Analytics/Capston Project/Food Delivery App/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    order_id,
    customer_id,
    restaurant_id,
    partner_id,
    @promo_id,
    order_date,
    order_time,
    order_status,
    subtotal,
    discount_amount,
    delivery_fee,
    total_amount,
    payment_method,
    city
)
SET promo_id = NULLIF(@promo_id, ''); # issue Fixed

SELECT COUNT(*) AS Current_Orders FROM orders; # Check Orders data 500000
Select * From orders limit 10;

# Check orders result without promotion
Select count(*) As Orders_without_Promo
from orders where promo_id IS NULL;

# Check invalid Customer IDs with Orders to Customer
SELECT count(*) AS Invalid_customer_ids
from orders o Left Join customers c 
ON o.customer_id = c.customer_id
where c.customer_id IS NULL;

#Result 0 means:No invalid Customer IDs were found.Every customer_id present in the orders table exists in the customers table.
# All customer IDs match.

# Check Invalid Restaurant ID with Orders
SELECT count(*) AS Invalid_Restaurant_IDs
from orders o Left Join swiggy_restaurants r 
ON o.restaurant_id = r.restaurant_id
Where r.restaurant_id IS NULL;
#Result: 0 means -> There are no invalid restaurant IDs in the orders table.
#Every restaurant_id in the orders table exists in the swiggy_restaurants table.

# Check invalid Partner IDs
SELECT count(*) As Invalid_Partners_id
from orders o Left Join delivery_partners d
ON o.partner_id = d.partner_id
Where d.partner_id IS NULL;
#Result 0 : No invalid Partner IDs were found: Every partner_id in the orders table exists in the delivery_partners table.

#Check invalid Promotion IDs
SELECT count(*) AS Invalid_Promo_ID
From orders o Left Join promotions p 
ON o.promo_id = p.promo_id
Where p.promo_id IS NULL 
AND o.promo_id IS NOT NULL;

#Check with order items table
Select count(*) As Current_Order_items
from order_items;

LOAD DATA LOCAL INFILE 'D:/H Drive Data/Himanshu (H)/Data Analytics/Capston Project/Food Delivery App/order_items.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    item_id,
    order_id,
    menu_item_name,
    quantity,
    unit_price,
    total_price
);

SELECT count(*) AS Total_Order_item
from Order_items;

Select * From order_items limit 10;

#Check for NULL values
SELECT
sum(item_id IS NULL) AS NULL_Item_ID,
sum(order_id IS NULL) AS Null_Order_id,
sum(menu_item_name IS NULL) AS NUll_Name,
sum(unit_price IS NULL) AS Null_UnitPrice,
sum(total_price IS NULL) AS Null_TotalPrice
from order_items;

# Check duplicate item_id 
SELECT item_id, count(*) AS count_duplicate_id
from order_items 
group by item_id
having count(*) > 1; #  Result As there are no duplicate item_id values

# Check whether all order_id values exist in orders
SELECT oi.order_id
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;            

Select Count(*) As Total_Order_items
from order_items;          

#Check Invalid order_id
SELECT oi.order_id
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL
LIMIT 20;

#Check duplicate item_id
SELECT item_id,count(*) As Duplicate_count
from order_items
group by item_id
Having count(*) > 1;

#Price Calculation
SELECT
    item_id,
    quantity,
    unit_price,
    total_price,
    (quantity * unit_price) AS calculated_total
FROM order_items
WHERE ROUND(quantity * unit_price, 2) <> ROUND(total_price, 2)
LIMIT 20;

#Check with Delivery Tracking table
LOAD DATA LOCAL INFILE 'D:/H Drive Data/Himanshu (H)/Data Analytics/Capston Project/Food Delivery App/delivery_tracking.csv'
INTO TABLE delivery_tracking
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

Select * from delivery_tracking limit 10;
Select Count(*) As Total_count
From delivery_tracking;

DESCRIBE delivery_tracking;

#Validate delivery_tracking against orders
Select dt.order_id
from delivery_tracking dt
Left Join orders o
ON dt.order_id = o.order_id
Where o.order_id IS NULL; # Result: all order_id values in delivery_tracking exist in the orders table.

#Check duplicate tracking records
SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM delivery_tracking
GROUP BY order_id
HAVING COUNT(*) > 1;

#Check for NULL tracking dates: pickup_time is missing, or delivery_time is missing.
SELECT * FROM delivery_tracking
WHERE pickup_time IS NULL
   OR delivery_time IS NULL; # there are no missing pickup or delivery times.
   
#Check Invalid Delivery Time
SELECT
    order_id,
    pickup_time,
    delivery_time
FROM delivery_tracking
WHERE delivery_time < pickup_time
limit 10;

#Calculate delivery duration: calculate how long each delivery took using pickup_time and delivery_time.
SELECT
    order_id, pickup_time, delivery_time,
    TIMESTAMPDIFF(
        MINUTE,
        pickup_time,
        delivery_time
    ) AS delivery_duration_minutes
FROM delivery_tracking;

#Check Average Delivery Duration
SELECT
    ROUND(
        AVG(
            TIMESTAMPDIFF(
                MINUTE,
                pickup_time,
                delivery_time
            )
        ), 2
    ) AS average_delivery_duration_minutes
FROM delivery_tracking;

# Check Minimum, Maximum & Average Delivery Time
SELECT
    MIN(TIMESTAMPDIFF(MINUTE, pickup_time, delivery_time)) AS min_delivery_minutes,
    MAX(TIMESTAMPDIFF(MINUTE, pickup_time, delivery_time)) AS max_delivery_minutes,
    ROUND(
        AVG(TIMESTAMPDIFF(MINUTE, pickup_time, delivery_time)), 2
    ) AS avg_delivery_minutes
FROM delivery_tracking; # Result Min Time is wrong displayed as: -1428 Lets Find

#Find the negative durations
SELECT
    order_id,
    pickup_time,
    delivery_time,
    TIMESTAMPDIFF(
        MINUTE,
        pickup_time,
        delivery_time
    ) AS delivery_duration_minutes
FROM delivery_tracking
WHERE delivery_time < pickup_time
ORDER BY delivery_duration_minutes;

SELECT
    order_id,
    pickup_time,
    delivery_time,
    TIMESTAMPDIFF(
        MINUTE,
        pickup_time,
        delivery_time
    ) AS delivery_duration_minutes
FROM delivery_tracking
WHERE TIMESTAMPDIFF(
        MINUTE,
        pickup_time,
        delivery_time
    ) = -1428;
    #Identify ALL Invalid(-1428) Delivery Durations
    SELECT
    COUNT(*) AS invalid_delivery_records
FROM delivery_tracking
WHERE delivery_time < pickup_time;

DESCRIBE delivery_tracking;

# Now Calculate duration correctly
SELECT
    order_id,
    pickup_time,
    delivery_time,
    CASE
        WHEN delivery_time >= pickup_time
            THEN TIMESTAMPDIFF(MINUTE, pickup_time, delivery_time)
        ELSE
            TIMESTAMPDIFF(MINUTE, pickup_time, delivery_time)
            + 1440
    END AS delivery_duration_minutes
FROM delivery_tracking
LIMIT 20;

SELECT
    MIN(
        CASE
            WHEN delivery_time >= pickup_time
                THEN TIMESTAMPDIFF(MINUTE, pickup_time, delivery_time)
            ELSE TIMESTAMPDIFF(MINUTE, pickup_time, delivery_time) + 1440
        END
    ) AS min_delivery_minutes,

    MAX(
        CASE
            WHEN delivery_time >= pickup_time
                THEN TIMESTAMPDIFF(MINUTE, pickup_time, delivery_time)
            ELSE TIMESTAMPDIFF(MINUTE, pickup_time, delivery_time) + 1440
        END
    ) AS max_delivery_minutes,

    ROUND(
        AVG(
            CASE
                WHEN delivery_time >= pickup_time
                    THEN TIMESTAMPDIFF(MINUTE, pickup_time, delivery_time)
                ELSE TIMESTAMPDIFF(MINUTE, pickup_time, delivery_time) + 1440
            END
        ), 2
    ) AS avg_delivery_minutes

FROM delivery_tracking
WHERE pickup_time IS NOT NULL
  AND delivery_time IS NOT NULL;

#Check the Corrected Delivery Duration
SELECT
    order_id,
    pickup_time,
    delivery_time,
    CASE
        WHEN delivery_time >= pickup_time
            THEN TIMESTAMPDIFF(MINUTE, pickup_time, delivery_time)
        ELSE
            TIMESTAMPDIFF(MINUTE, pickup_time, delivery_time) + 1440
    END AS delivery_duration_minutes
FROM delivery_tracking
WHERE pickup_time IS NOT NULL
  AND delivery_time IS NOT NULL
ORDER BY delivery_duration_minutes DESC
LIMIT 10;

#Check Orders Without Delivery Tracking
SELECT o.order_id
from orders o
Left Join delivery_tracking dt
ON o.order_id = dt.order_id
Where dt.order_id IS NULL
limit 10;

#Check the status of these orders
SELECT
    o.order_status,
    COUNT(*) AS order_count
FROM orders o
LEFT JOIN delivery_tracking dt
    ON o.order_id = dt.order_id
WHERE dt.order_id IS NULL
GROUP BY o.order_status
ORDER BY order_count DESC;

#Check Delivered orders without tracking
SELECT
    o.order_id,
    o.order_status
FROM orders o
LEFT JOIN delivery_tracking dt
    ON o.order_id = dt.order_id
WHERE dt.order_id IS NULL
  AND o.order_status = 'Delivered'
LIMIT 10; # Result: There are no Delivered orders without tracking records.

# Check Cancelled/Returned/Failed orders with tracking
Select o.order_status, count(*) As Track_Record_status
From orders o Inner Join delivery_tracking dt
ON o.order_id = dt.order_id
Where o.order_id IN ('Cancelled','Returne','Failed')
group by o.order_status; #Result: Empty Set means there are no Cancelled, Returned, or Failed orders with a matching delivery-tracking record.

#Verify The Actual values
SELECT Count(*) As Total_Records,
Sum(was_on_time = 1) As On_Time,
Sum(was_on_time = 0) As late_record,
sum(was_on_time  IS NULL) As Null_Record
from delivery_tracking;

describe delivery_tracking;
# Check the actual vs promised delivery times
SELECT 
actual_delivery_minutes,
promised_delivery_minutes,
was_on_time
from delivery_tracking
limit 20;

SELECT COUNT(*) AS current_records
FROM delivery_tracking;

# Create Backup Table
CREATE TABLE delivery_tracking_backup AS
SELECT * FROM delivery_tracking;

SELECT COUNT(*) AS backup_records FROM delivery_tracking_backup;

TRUNCATE TABLE delivery_tracking;

SELECT COUNT(*) AS remaining_records FROM delivery_tracking; # check record 0 in table after truncat

LOAD DATA LOCAL INFILE 'D:/H Drive Data/Himanshu (H)/Data Analytics/Capston Project/Food Delivery App/delivery_tracking.csv'
INTO TABLE delivery_tracking
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    tracking_id,
    order_id,
    partner_id,
    pickup_time,
    delivery_time,
    distance_km,
    actual_delivery_minutes,
    promised_delivery_minutes,
    was_on_time
);

SELECT COUNT(*) AS total_records FROM delivery_tracking;

# Now Check Was on Time
SELECT was_on_time, count(*) As order_count
from delivery_tracking
group by was_on_time
order by was_on_time;

#Calculate On-Time Delivery %
SELECT
    COUNT(*) AS total_delivered_orders,
    SUM(dt.was_on_time = 1) AS on_time_orders,
    SUM(dt.was_on_time = 0) AS late_orders,
    ROUND(
        SUM(dt.was_on_time = 1) / COUNT(*) * 100,
        2
    ) AS on_time_delivery_percentage
FROM orders o
INNER JOIN delivery_tracking dt
    ON o.order_id = dt.order_id
WHERE o.order_status = 'Delivered';

# let's identify which delivery partners are performing well and which need improvement.
SELECT
    dt.partner_id,
    COUNT(*) AS total_deliveries,
    SUM(dt.was_on_time = 1) AS on_time_deliveries,
    SUM(dt.was_on_time = 0) AS late_deliveries,
    ROUND(
        SUM(dt.was_on_time = 1) / COUNT(*) * 100,
        2
    ) AS on_time_percentage
FROM orders o
INNER JOIN delivery_tracking dt
    ON o.order_id = dt.order_id
WHERE o.order_status = 'Delivered'
GROUP BY dt.partner_id
ORDER BY on_time_percentage DESC;

#Analysis Swiggy Restaurants
describe swiggy_restaurants;

# Restaurant-wise Order Performance
SELECT
    r.restaurant_id,
    r.restaurant_name,
    COUNT(o.order_id) AS total_orders,
    SUM(CASE WHEN o.order_status = 'Delivered' THEN 1 ELSE 0 END) AS delivered_orders,
    SUM(CASE WHEN o.order_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders
FROM swiggy_restaurants r
LEFT JOIN orders o
    ON r.restaurant_id = o.restaurant_id
GROUP BY
    r.restaurant_id,
    r.restaurant_name
ORDER BY total_orders DESC;

# Restaurant Revenue Performance
SELECT
    r.restaurant_id,
    r.restaurant_name,
    COUNT(o.order_id) AS total_orders,
    SUM(CASE 
        WHEN o.order_status = 'Delivered' 
        THEN o.total_amount 
        ELSE 0 
    END) AS total_revenue,
    AVG(CASE 
        WHEN o.order_status = 'Delivered' 
        THEN o.total_amount 
    END) AS average_order_value
FROM swiggy_restaurants r
LEFT JOIN orders o
    ON r.restaurant_id = o.restaurant_id
GROUP BY
    r.restaurant_id,
    r.restaurant_name
ORDER BY total_revenue DESC;

#Restaurant-wise Cancellation Rate
SELECT
    r.restaurant_id,
    r.restaurant_name,
    COUNT(o.order_id) AS total_orders,

    SUM(
        CASE
            WHEN o.order_status = 'Cancelled'
            THEN 1
            ELSE 0
        END
    ) AS cancelled_orders,

    ROUND(
        SUM(
            CASE
                WHEN o.order_status = 'Cancelled'
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(o.order_id),
        2
    ) AS cancellation_rate
FROM swiggy_restaurants r
LEFT JOIN orders o
    ON r.restaurant_id = o.restaurant_id
GROUP BY
    r.restaurant_id,
    r.restaurant_name
ORDER BY cancellation_rate DESC;

# Restaurant Delivery Performance : We will calculate Delivered Orders + On-Time Orders + Late Orders + On-Time Delivery % for each restaurant.
SELECT
    r.restaurant_id,
    r.restaurant_name,
    COUNT(o.order_id) AS delivered_orders,
    SUM(
        CASE
            WHEN dt.was_on_time = 1 THEN 1
            ELSE 0
        END
    ) AS on_time_orders,
    SUM(
        CASE
            WHEN dt.was_on_time = 0 THEN 1
            ELSE 0
        END
    ) AS late_orders,
    ROUND(
        SUM(
            CASE
                WHEN dt.was_on_time = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(o.order_id),
        2
    ) AS on_time_delivery_percentage
FROM orders o
INNER JOIN swiggy_restaurants r
    ON o.restaurant_id = r.restaurant_id
INNER JOIN delivery_tracking dt
    ON o.order_id = dt.order_id
WHERE o.order_status = 'Delivered'
GROUP BY
    r.restaurant_id,
    r.restaurant_name
ORDER BY on_time_delivery_percentage DESC;

# Analyze Orders by Hour
SELECT
    HOUR(order_time) AS order_hour,
    COUNT(*) AS total_orders
FROM orders
WHERE order_time IS NOT NULL
GROUP BY HOUR(order_time)
ORDER BY total_orders DESC;

# Analyze Order Status
SELECT order_status,
count(*) AS Total_order
from orders
group by order_status 
order by Total_order DESC;

# Calculate Order Status Percentage

SELECT order_status,
COUNT(*) AS total_orders,
ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders),2) AS order_percentage
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

# Analyze Revenue by Order Status
SELECT o.order_status,
COUNT(*) AS total_items,
SUM(oi.total_price) AS total_revenue
FROM orders o
INNER JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY o.order_status;

# Calculate Delivered Revenue Percentage
SELECT ROUND(SUM(oi.total_price) * 100.0 /
 (SELECT SUM(total_price) FROM order_items),2) AS delivered_value_percentage
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered';

# Let's identify which months have the highest number of orders.
SELECT
MONTH(order_date) AS Order_Month,
COUNT(*) AS Total_Orders
FROM orders
GROUP BY MONTH(order_date)
ORDER BY Order_Month DESC;

# Monthly Revenue Analysis
SELECT
MONTH(o.order_date) AS Order_Month,
ROUND(SUM(oi.total_price), 2) AS Monthly_Revenue
FROM orders o
INNER JOIN order_items oi
ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered'
GROUP BY MONTH(o.order_date)
ORDER BY Order_Month;

# Analyze Orders by Day of the Week
SELECT
dayname(order_date) AS Order_Day,
count(*) AS Total_order
from orders
group by dayname(order_date)
order by Total_order DESC;

describe orders;

# Analyze Average Order Value
Select ROUND(AVG(total_amount),2) AS Average_Order_Value
from orders 
where order_status = 'Delivered';

# Top 10 Restaurants by Delivered Orders
SELECT r.restaurant_name,
count(o.order_id) AS delivered_orders
from orders o
JOIN swiggy_restaurants r
ON o.restaurant_id = r.restaurant_id
WHERE o.order_status = 'Delivered'
group by r.restaurant_name
order by delivered_orders DESC Limit 10;

# Top 10 Restaurants by Revenue
SELECT
r.restaurant_name,
ROUND(SUM(oi.total_price), 2) AS total_revenue
FROM orders o
JOIN swiggy_restaurants r
ON o.restaurant_id = r.restaurant_id
JOIN order_items oi
ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered'
GROUP BY r.restaurant_name
ORDER BY total_revenue DESC
LIMIT 10;

# Top 10 Customers by Orders
SELECT c.customer_id,
count(o.order_id) AS Total_orders
from orders o 
INNER Join customers c 
ON o.customer_id = c.customer_id
Where o.order_status = 'Delivered'
Group by c.customer_id
order by Total_orders DESC limit 10;

# Order Status Distribution
SELECT order_status,
count(*) As Total_order
from orders 
group by order_status
order by Total_order DESC;

# Payment Method Analysis: Objective: Find out which payment methods customers use most frequently to place orders.
SELECT payment_method,
count(*) As Total_orders
from orders
group by payment_method
order by Total_orders DESC;

# Promotion and Coupon Analysis
SELECT promo_id,
count(*) As Total_orders
from orders
Where promo_id IS NOT NULL
group by promo_id
order by Total_orders DESC;

# Delivery Performance Analysis: Average Delivery Time by Delivery Partner.
SELECT
partner_id,
ROUND(AVG(actual_delivery_minutes), 2)
AS avg_delivery_minutes
FROM delivery_tracking
WHERE actual_delivery_minutes > 0
GROUP BY partner_id
ORDER BY avg_delivery_minutes ASC
LIMIT 10;

# On-Time Delivery by Partner: let's find how many deliveries each partner completed on time and calculate their on-time delivery percentage.
SELECT
    partner_id,
    COUNT(*) AS total_deliveries,
    SUM(was_on_time = 1) AS on_time_deliveries,
    ROUND(
        SUM(was_on_time = 1) * 100.0 / COUNT(*),
        2
    ) AS on_time_percentage
FROM delivery_tracking
WHERE actual_delivery_minutes > 0
GROUP BY partner_id
HAVING COUNT(*) >= 5
ORDER BY on_time_percentage DESC
LIMIT 10;

# Delivery Performance by Distance
SELECT
    CASE
        WHEN distance_km <= 2 THEN '0-2 KM'
        WHEN distance_km <= 5 THEN '2-5 KM'
        WHEN distance_km <= 10 THEN '5-10 KM'
        ELSE 'Above 10 KM'
    END AS distance_range,
    COUNT(*) AS total_deliveries,
    ROUND(AVG(actual_delivery_minutes), 2)
        AS avg_delivery_minutes,
    ROUND(
        SUM(was_on_time = 1) * 100.0 / COUNT(*),
        2
    ) AS on_time_percentage
FROM delivery_tracking
WHERE actual_delivery_minutes > 0
  AND distance_km IS NOT NULL
  AND distance_km >= 0
GROUP BY distance_range
ORDER BY MIN(distance_km);

# Customer Order Frequency Analysis
SELECT customer_id,
COUNT(*) AS total_orders,
ROUND(SUM(total_amount), 2) AS total_spent
FROM orders
WHERE order_status = 'Delivered'
GROUP BY customer_id
ORDER BY total_orders DESC
LIMIT 10;

# Customer Segmentation
SELECT
    customer_segment,
    COUNT(*) AS total_customers
FROM (
    SELECT
        customer_id,
        CASE
            WHEN COUNT(*) = 1 THEN 'One-Time'
            WHEN COUNT(*) BETWEEN 2 AND 5 THEN 'Occasional'
            ELSE 'Frequent'
        END AS customer_segment
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
) AS customer_groups
GROUP BY customer_segment
ORDER BY total_customers DESC;

# Monthly Customer Trend Analysis: Find how many unique customers
# placed delivered orders each month and identify which months attracted the most customers.
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(*) AS total_delivered_orders
FROM orders
WHERE order_status = 'Delivered'
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY order_month;

# Monthly Repeat-Customer Analysis
WITH customer_months AS (
    SELECT DISTINCT
        customer_id,
        DATE_FORMAT(order_date, '%Y-%m') AS order_month
    FROM orders
    WHERE order_status = 'Delivered'
),
monthly_repeat AS (
    SELECT
        current_month.order_month,
        COUNT(*) AS repeat_customers
    FROM customer_months current_month
    WHERE EXISTS (
        SELECT 1
        FROM customer_months previous_month
        WHERE previous_month.customer_id =
              current_month.customer_id
          AND previous_month.order_month <
              current_month.order_month
    )
    GROUP BY current_month.order_month
),
monthly_customers AS (
    SELECT
        order_month,
        COUNT(*) AS total_customers
    FROM customer_months
    GROUP BY order_month
)
SELECT
    m.order_month,
    m.total_customers,
    COALESCE(r.repeat_customers, 0) AS repeat_customers,
    ROUND(
        COALESCE(r.repeat_customers, 0) * 100.0 /
        m.total_customers,
        2
    ) AS repeat_customer_percentage
FROM monthly_customers m
LEFT JOIN monthly_repeat r
    ON m.order_month = r.order_month
ORDER BY m.order_month;

# Month-over-Month (MoM) Revenue Growth Analysis
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
        SUM(oi.total_price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
),
revenue_comparison AS (
    SELECT
        order_month,
        revenue,
        LAG(revenue) OVER (
            ORDER BY order_month
        ) AS previous_month_revenue
    FROM monthly_revenue
)
SELECT
    order_month,
    ROUND(revenue, 2) AS monthly_revenue,
    ROUND(previous_month_revenue, 2)
        AS previous_month_revenue,
    ROUND(
        (revenue - previous_month_revenue)
        * 100.0 / NULLIF(previous_month_revenue, 0),
        2
    ) AS mom_growth_percentage
FROM revenue_comparison
ORDER BY order_month;

# Rank the Top 5 Restaurants by Revenue
WITH restaurant_revenue AS (
    SELECT
        r.restaurant_id,
        r.restaurant_name,
        SUM(oi.total_price) AS total_revenue
    FROM orders o
    JOIN swiggy_restaurants r
        ON o.restaurant_id = r.restaurant_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY
        r.restaurant_id,
        r.restaurant_name
),
restaurant_ranking AS (
    SELECT
        restaurant_id,
        restaurant_name,
        total_revenue,
        DENSE_RANK() OVER (
            ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM restaurant_revenue
)
SELECT
    revenue_rank,
    restaurant_id,
    restaurant_name,
    ROUND(total_revenue, 2) AS total_revenue
FROM restaurant_ranking
WHERE revenue_rank <= 5
ORDER BY revenue_rank;

# Create a Monthly Revenue View
CREATE OR REPLACE VIEW vw_monthly_revenue AS
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.total_price), 2) AS total_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m');
SELECT * FROM vw_monthly_revenue ORDER BY order_month;

# Create a Restaurant Performance View
CREATE OR REPLACE VIEW vw_restaurant_performance AS
SELECT
    r.restaurant_id,
    r.restaurant_name,
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    ROUND(SUM(oi.total_price), 2) AS total_revenue
FROM orders o
JOIN swiggy_restaurants r
    ON o.restaurant_id = r.restaurant_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered'
GROUP BY
    r.restaurant_id,
    r.restaurant_name;
    
SELECT * FROM vw_restaurant_performance ORDER BY total_revenue DESC LIMIT 10;

# Create a Delivery Performance SQL View
CREATE OR REPLACE VIEW vw_delivery_performance AS
SELECT
    COUNT(*) AS total_deliveries,
    SUM(was_on_time = 1) AS on_time_deliveries,
    SUM(was_on_time = 0) AS late_deliveries,
    ROUND(
        AVG(actual_delivery_minutes), 2
    ) AS avg_delivery_minutes,
    ROUND(
        SUM(was_on_time = 1) * 100.0 / COUNT(*),
        2
    ) AS on_time_percentage
FROM delivery_tracking
WHERE actual_delivery_minutes > 0;

SELECT * FROM vw_delivery_performance;