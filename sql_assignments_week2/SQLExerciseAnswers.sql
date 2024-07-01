--#E1.1
USE assingment1;

CREATE TABLE users (
	user_id INT IDENTITY PRIMARY KEY,
    user_first_name VARCHAR(30) NOT NULL,
    user_last_name VARCHAR(30) NOT NULL,
    user_email_id VARCHAR(50) NOT NULL,
    user_email_validated BIT DEFAULT 0,
    user_password VARCHAR(200),
    user_role VARCHAR(1) NOT NULL DEFAULT 'U', --U and A
    is_active BIT DEFAULT 0,
    created_dt DATE DEFAULT GETDATE()
);
GO

--#E2.1
USE assingment1;
CREATE TABLE courses(
	course_id INT IDENTITY PRIMARY KEY,
	course_name VARCHAR(60),
	course_author VARCHAR(40),
	course_status VARCHAR(9) CHECK (course_status IN ('published', 'draft', 'inactive')),
	course_published_dt DATE
);
GO

--#E2.2
INSERT INTO courses
	(course_name, course_author, course_status, course_published_dt)
VALUES
	('Programming using Python', 'Bob Dillon', 'published', '2020-09-30'),
	('Data Engineering using Python', 'Bob Dillon', 'published', '2020-07-15'),
	('Data Engineering using Scala', 'Elvis Presley', 'draft', NULL),
	('Programming using Scala', 'Elvis Presley', 'published', '2020-05-12'),
	('Programming using Java', 'Mike Jack', 'inactive', '2020-08-10'),
	('Web Applications - Python Flask', 'Bob Dillon', 'inactive', '2020-07-20'),
	('Web Applications - Java Spring', 'Mike Jack', 'draft', NULL),
	('Pipeline Orchestration - Python', 'Bob Dillon', 'draft', NULL),
	('Streaming Pipelines - Python', 'Bob Dillon', 'published', '2020-10-05'),
	('Web Applications - Scala Play', 'Elvis Presley', 'inactive', '2020-09-30'),
	('Web Applications - Python Django', 'Bob Dillon', 'published', '2020-06-23'),
	('Server Automation - Ansible', 'Uncle Sam', 'published', '2020-07-05');

SELECT * FROM courses;
GO

--#E2.3
UPDATE courses
SET
	course_status = 'published',
	course_published_dt = GETDATE()
WHERE ((course_status = 'draft') AND 
((CHARINDEX('Python', course_name) !=  0) OR 
(CHARINDEX('Scala', course_name) != 0)));

SELECT * FROM courses;
GO

--#2.4
DELETE FROM courses WHERE ((course_status != 'published') AND (course_status != 'draft'));

SELECT * FROM courses;
GO

--#2.4...cont? Come look at this when you understand it better
SELECT course_author, count(1) AS course_count
FROM courses
WHERE course_status = 'published'
GROUP BY course_author;


--#E3.0

use retail_db;
SELECT TOP 1000 * FROM order_items;
SELECT TOP 20 * FROM orders;
SELECT TOP 20 * FROM customers;
SELECT * FROM products;--product id 502?
SELECT * FROM categories;
SELECT TOP 20 * FROM departments;

--#E3.1 START HERE
SELECT order_customer_id AS customer_id, 
	customer_fname AS customer_first_name, 
	customer_lname AS customer_last_name, 
	count(1) AS customer_order_count
FROM orders 
	RIGHT JOIN customers ON
	orders.order_customer_id = customers.customer_id
WHERE ((order_date >= '20140101') AND (order_date < '20140201'))
GROUP BY customers.customer_fname, order_customer_id, customers.customer_lname
ORDER BY customer_order_count DESC, customer_id ASC;


--#E3.2
SELECT * FROM customers
WHERE customers.customer_id NOT IN (SELECT orders.order_customer_id FROM orders
WHERE ((orders.order_date >= '20140101') AND (orders.order_date < '20140201')))
ORDER BY customers.customer_id ASC;

--#E3.3 Not 100% confiednt
SELECT
	customer_rev_table.customer_id,
	customer_rev_table.customer_first_name,
	customer_rev_table.customer_last_name,
	ISNULL(customer_rev_table.customer_revenue, 0) 
FROM(
	SELECT customers.customer_id, 
		customers.customer_fname AS customer_first_name,
		customers.customer_lname AS customer_last_name,
		sum(c_or_c_orders.item_revenue) AS customer_revenue
	FROM customers LEFT JOIN
		(SELECT sum(order_items.order_item_subtotal) AS item_revenue, 
		orders.order_customer_id,
		orders.order_id,
		orders.order_date
		FROM
			orders LEFT JOIN order_items
			ON orders.order_id = order_items.order_item_order_id
			WHERE (((orders.order_status LIKE 'COMPLETE%') OR (orders.order_status LIKE 'CLOSED%'))
			AND ((orders.order_date >= '20140101') AND (orders.order_date < '20140201')))
			GROUP BY
				orders.order_id,
				orders.order_customer_id,
				orders.order_date
		) AS c_or_c_orders
	ON customers.customer_id = c_or_c_orders.order_customer_id
	GROUP BY customers.customer_id, 
		customers.customer_fname,
		customers.customer_lname
	) AS customer_rev_table
ORDER BY customer_revenue DESC, customer_id ASC;



--#E3.4 FIX MISSING 0 orders placed for categories
SELECT oi_cp.category_id, 
	oi_cp.category_department_id,
	oi_cp.category_name,
	CAST(SUM(oi_cp.order_item_subtotal) AS DECIMAL(18,2)) as category_revenue
FROM orders o RIGHT JOIN(
	SELECT * FROM
		order_items oi RIGHT JOIN
		(SELECT * FROM
			categories c LEFT JOIN products p ON c.category_id = p.product_category_id
		) AS cp
		ON oi.order_item_product_id = cp.product_id
	) AS oi_cp
	ON o.order_id = oi_cp.order_item_order_id
WHERE (((o.order_status LIKE 'COMPLETE%') OR (o.order_status LIKE 'CLOSED%'))
			AND ((o.order_date >= '20140101') AND (o.order_date < '20140201')))
GROUP BY oi_cp.category_id, 
	oi_cp.category_department_id,
	oi_cp.category_name
ORDER BY oi_cp.category_id ASC;


--#E3.5
SELECT cd.department_id,
	cd.department_name,
	COUNT(1) AS product_count
FROM products p RIGHT JOIN (
	SELECT * FROM departments d LEFT JOIN
		categories c 
		ON d.department_id = c.category_department_id
	) AS cd
	ON p.product_category_id = cd.category_id
GROUP BY cd.department_id,
	cd.department_name
ORDER BY cd.department_id ASC;


--#E4.1
SELECT TOP 10 * FROM categories;
SELECT TOP 10 * FROM customers;
SELECT TOP 10 * FROM departments;
SELECT TOP 10 * FROM order_items;
SELECT TOP 10 * FROM orders;
SELECT TOP 10 * FROM products;
GO

SELECT MAX(category_id) FROM categories;
SELECT MAX(customer_id) FROM customers;
SELECT MAX(department_id) FROM departments;
SELECT MAX(order_item_id) FROM order_items;
SELECT MAX(order_id) FROM orders;
SELECT MAX(product_id) FROM products;
GO

CREATE SCHEMA Add_Row;
GO

CREATE SEQUENCE Add_Row.add_categ
	START WITH 58
	INCREMENT BY 1;
GO

CREATE SEQUENCE Add_Row.add_cust
	START WITH 12435
	INCREMENT BY 1;
GO

CREATE SEQUENCE Add_Row.add_dept
	START WITH 6
	INCREMENT BY 1;
GO

CREATE SEQUENCE Add_Row.add_order_item
	START WITH 172198
	INCREMENT BY 1;
GO

CREATE SEQUENCE Add_Row.add_order
	START WITH 68883
	INCREMENT BY 1;
GO

CREATE SEQUENCE Add_Row.add_prod
	START WITH 1345
	INCREMENT BY 1;
GO

CREATE PROCEDURE Add_Row.create_row_categ
	@cat_id INTEGER,
	@cat_dept_id INTEGER,
	@cat_name VARCHAR(45)
AS
	SET IDENTITY_INSERT categories ON;

	INSERT categories(category_id, category_department_id, category_name)
		VALUES(@cat_id, @cat_dept_id, @cat_name);

	SET IDENTITY_INSERT categories OFF;
GO

CREATE PROCEDURE Add_Row.create_row_cust
	@cust_id INTEGER,
	@cust_fname VARCHAR(45),
	@cust_lname VARCHAR(45),
	@cust_email VARCHAR(45),
	@cust_password VARCHAR(45),
	@cust_street VARCHAR(255),
	@cust_city VARCHAR(45),
	@cust_state VARCHAR(45),
	@cust_zipcode VARCHAR(45)
AS
	SET IDENTITY_INSERT customers ON;

	INSERT customers(customer_id, customer_fname, customer_lname, customer_email, 
			customer_password, customer_street, customer_city, customer_state,
			customer_zipcode)
		VALUES(@cust_id, @cust_fname, @cust_lname, @cust_email,
			@cust_password, @cust_street, @cust_city, @cust_state, @cust_zipcode);

	SET IDENTITY_INSERT customers OFF;
GO

CREATE PROCEDURE Add_Row.create_row_dept
	@department_id INTEGER,
	@department_name VARCHAR(45)
AS
	SET IDENTITY_INSERT departments ON;

	INSERT departments(department_id, department_name)
		VALUES(@department_id, @department_name);

	SET IDENTITY_INSERT departments OFF;
GO

CREATE PROCEDURE Add_Row.create_row_order_item
	@ord_item_id INTEGER,
	@ord_item_ord_id INTEGER,
	@ord_item_prod_id INTEGER,
	@ord_item_quant INTEGER,
	@ord_item_subtot FLOAT,
	@ord_item_prod_price FLOAT
AS
	SET IDENTITY_INSERT order_items ON;

	INSERT order_items(order_item_id, order_item_order_id, order_item_product_id,
			order_item_quantity, order_item_subtotal, order_item_product_price)
		VALUES(@ord_item_id, @ord_item_ord_id, @ord_item_prod_id,
				@ord_item_quant, @ord_item_subtot, @ord_item_prod_price);

	SET IDENTITY_INSERT order_items OFF;
GO

CREATE PROCEDURE Add_Row.create_row_order
	@order_id INTEGER,
	@order_date DATETIME,
	@order_cust_id INTEGER,
	@order_stat VARCHAR
AS
	SET IDENTITY_INSERT orders ON;

	INSERT orders(order_id, order_date, order_customer_id, order_status)
		VALUES(@order_id, @order_date, @order_cust_id,
						@order_stat);

	SET IDENTITY_INSERT orders ON;
GO

CREATE PROCEDURE Add_Row.create_row_prod
	@prod_id INTEGER,
	@prod_cat_id INTEGER,
	@prod_name VARCHAR(45),
	@prod_desc VARCHAR(255),
	@prod_price FLOAT,
	@prod_img VARCHAR(255)
AS
	SET IDENTITY_INSERT products ON;

	INSERT products(product_id, product_category_id, product_name, product_description,
				product_price, product_image)
			VALUES(@prod_id, @prod_cat_id, @prod_name, @prod_desc,
					@prod_price, @prod_img);

	SET IDENTITY_INSERT products ON;
GO

--VALIDATE
DECLARE @next_dept_id INTEGER;
SET @next_dept_id = NEXT VALUE FOR Add_Row.add_dept;
EXEC Add_Row.create_row_dept @next_dept_id , 'Booty Buys';
GO

SELECT * FROM departments;
DELETE FROM departments WHERE department_id = 7;
--#E4.2
--No violation
SELECT * FROM customers c RIGHT JOIN orders o
	ON o.order_customer_id = c.customer_id;

--No Violation
SELECT * FROM orders o RIGHT JOIN order_items oi
	ON o.order_id = oi.order_item_order_id;

--NO violation
SELECT * FROM order_items oi LEFT JOIN products p
	ON oi.order_item_product_id = p.product_id;

--Violation, no category 59 in categories
SELECT * FROM products p LEFT JOIN categories c
	ON c.category_id = p.product_category_id;

--Violaiton, no department 7 or 8 in departments
SELECT * FROM departments RIGHT JOIN categories
	ON categories.category_department_id = departments.department_id;

--SOLN
ALTER TABLE orders 
ADD CONSTRAINT FK_OrderCustomer
FOREIGN KEY (order_customer_id) REFERENCES customers(customer_id);

ALTER TABLE order_items
ADD CONSTRAINT FK_Order_itemOrder
FOREIGN KEY (order_item_order_id) REFERENCES orders(order_id);

ALTER TABLE order_items
ADD CONSTRAINT FK_Order_itemProduct
FOREIGN KEY (order_item_product_id) REFERENCES products(product_id);

ALTER TABLE products
ALTER COLUMN product_category_id INTEGER;

--Foriegn keys can be null, but can't exist if they don't exist in the table they point to
UPDATE products
SET product_category_id = NULL
WHERE product_category_id = 59;

ALTER TABLE products
ADD CONSTRAINT FK_ProductsCategories
FOREIGN KEY (product_category_id) REFERENCES categories(category_id);

ALTER TABLE categories 
ALTER COLUMN category_department_id INTEGER;

UPDATE categories
SET category_department_id = NULL
WHERE category_department_id in (7,8);

ALTER TABLE categories
ADD CONSTRAINT FK_CategoriesDepartments
FOREIGN KEY (category_department_id) REFERENCES departments(department_id);

SELECT * FROM categories;

--#E4.3
SELECT CONSTRAINT_NAME, CONSTRAINT_TYPE FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'categories';

SELECT CONSTRAINT_NAME, CONSTRAINT_TYPE FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'customers';

SELECT CONSTRAINT_NAME, CONSTRAINT_TYPE FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'departments';

SELECT CONSTRAINT_NAME, CONSTRAINT_TYPE FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'order_items';

SELECT CONSTRAINT_NAME, CONSTRAINT_TYPE FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'orders';

SELECT CONSTRAINT_NAME, CONSTRAINT_TYPE FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'products';


--#E5.1
DROP TABLE orders_part;

CREATE TABLE orders_part(
	order_id INTEGER ,
	order_date DATETIME NOT NULL,
	order_customer_id INTEGER NOT NULL,
	order_status VARCHAR(45) NOT NULL
);

CREATE PARTITION FUNCTION monthRangePF(DATETIME)
	AS RANGE RIGHT FOR VALUES(
		'2013-08-01 00:00:00.000',
		'2013-09-01 00:00:00.000',
		'2013-10-01 00:00:00.000',
		'2013-11-01 00:00:00.000',
		'2013-12-01 00:00:00.000',
		'2014-01-01 00:00:00.000',
		'2014-02-01 00:00:00.000',
		'2014-03-01 00:00:00.000',
		'2014-04-01 00:00:00.000',
		'2014-05-01 00:00:00.000',
		'2014-06-01 00:00:00.000',
		'2014-07-01 00:00:00.000')
GO

CREATE PARTITION SCHEME monthRangePS
	AS PARTITION monthRANGEPF
	ALL TO ('PRIMARY');
GO

CREATE TABLE orders_part(
	order_id INTEGER NOT NULL, --what am I supposed to do here? Like I can't use this as primary key
	order_date DATETIME NOT NULL,
	order_customer_id INTEGER NOT NULL,
	order_status VARCHAR(45) NOT NULL
)
ON monthRangePS(order_date);

INSERT INTO orders_part
SELECT * FROM orders;

--#E5.2
SELECT 
	COUNT(1)
FROM orders_part;

SELECT count(1)
FROM orders_part
WHERE order_date < '2013-08-01';

SELECT count(1)
FROM orders_part
WHERE (order_date < '2013-09-01') AND (order_date >= '2013-08-01');

SELECT count(1)
FROM orders_part
WHERE (order_date < '2013-10-01') AND (order_date >= '2013-09-01');

SELECT count(1)
FROM orders_part
WHERE (order_date < '2013-11-01') AND (order_date >= '2013-10-01');

SELECT count(1)
FROM orders_part
WHERE (order_date < '2013-12-01') AND (order_date >= '2013-11-01');

SELECT count(1)
FROM orders_part
WHERE (order_date < '2014-01-01') AND (order_date >= '2013-12-01');

SELECT count(1)
FROM orders_part
WHERE (order_date < '2014-02-01') AND (order_date >= '2014-01-01');

SELECT count(1)
FROM orders_part
WHERE (order_date < '2014-03-01') AND (order_date >= '2014-02-01');

SELECT count(1)
FROM orders_part
WHERE (order_date < '2014-04-01') AND (order_date >= '2014-03-01');

SELECT count(1)
FROM orders_part
WHERE (order_date < '2014-05-01') AND (order_date >= '2014-04-01');

SELECT count(1)
FROM orders_part
WHERE (order_date < '2014-06-01') AND (order_date >= '2014-05-01');

SELECT count(1)
FROM orders_part
WHERE (order_date < '2014-07-01') AND (order_date >= '2014-06-01');

--#E6.1
CREATE TABLE users (
    user_id int PRIMARY KEY IDENTITY,
    user_first_name VARCHAR(30),
    user_last_name VARCHAR(30),
    user_email_id VARCHAR(50),
    user_gender VARCHAR(1),
    user_unique_id VARCHAR(15),
    user_phone_no VARCHAR(20),
    user_dob DATE,
    created_ts DATETIME
);

insert into users (
    user_first_name, user_last_name, user_email_id, user_gender, 
    user_unique_id, user_phone_no, user_dob, created_ts
) VALUES
    ('Giuseppe', 'Bode', 'gbode0@imgur.com', 'M', '88833-8759', 
     '+86 (764) 443-1967', '1973-05-31', '2018-04-15 12:13:38'),
    ('Lexy', 'Gisbey', 'lgisbey1@mail.ru', 'N', '262501-029', 
     '+86 (751) 160-3742', '2003-05-31', '2020-12-29 06:44:09'),
    ('Karel', 'Claringbold', 'kclaringbold2@yale.edu', 'F', '391-33-2823', 
     '+62 (445) 471-2682', '1985-11-28', '2018-11-19 00:04:08'),
    ('Marv', 'Tanswill', 'mtanswill3@dedecms.com', 'F', '1195413-80', 
     '+62 (497) 736-6802', '1998-05-24', '2018-11-19 16:29:43'),
    ('Gertie', 'Espinoza', 'gespinoza4@nationalgeographic.com', 'M', '471-24-6869', 
     '+249 (687) 506-2960', '1997-10-30', '2020-01-25 21:31:10'),
    ('Saleem', 'Danneil', 'sdanneil5@guardian.co.uk', 'F', '192374-933', 
     '+63 (810) 321-0331', '1992-03-08', '2020-11-07 19:01:14'),
    ('Rickert', 'O''Shiels', 'roshiels6@wikispaces.com', 'M', '749-27-47-52', 
     '+86 (184) 759-3933', '1972-11-01', '2018-03-20 10:53:24'),
    ('Cybil', 'Lissimore', 'clissimore7@pinterest.com', 'M', '461-75-4198', 
     '+54 (613) 939-6976', '1978-03-03', '2019-12-09 14:08:30'),
    ('Melita', 'Rimington', 'mrimington8@mozilla.org', 'F', '892-36-676-2', 
     '+48 (322) 829-8638', '1995-12-15', '2018-04-03 04:21:33'),
    ('Benetta', 'Nana', 'bnana9@google.com', 'N', '197-54-1646', 
     '+420 (934) 611-0020', '1971-12-07', '2018-10-17 21:02:51'),
    ('Gregorius', 'Gullane', 'ggullanea@prnewswire.com', 'F', '232-55-52-58', 
     '+62 (780) 859-1578', '1973-09-18', '2020-01-14 23:38:53'),
    ('Una', 'Glayzer', 'uglayzerb@pinterest.com', 'M', '898-84-336-6', 
     '+380 (840) 437-3981', '1983-05-26', '2019-09-17 03:24:21'),
    ('Jamie', 'Vosper', 'jvosperc@umich.edu', 'M', '247-95-68-44', 
     '+81 (205) 723-1942', '1972-03-18', '2020-07-23 16:39:33'),
    ('Calley', 'Tilson', 'ctilsond@issuu.com', 'F', '415-48-894-3', 
     '+229 (698) 777-4904', '1987-06-12', '2020-06-05 12:10:50'),
    ('Peadar', 'Gregorowicz', 'pgregorowicze@omniture.com', 'M', '403-39-5-869', 
     '+7 (267) 853-3262', '1996-09-21', '2018-05-29 23:51:31'),
    ('Jeanie', 'Webling', 'jweblingf@booking.com', 'F', '399-83-05-03', 
     '+351 (684) 413-0550', '1994-12-27', '2018-02-09 01:31:11'),
    ('Yankee', 'Jelf', 'yjelfg@wufoo.com', 'F', '607-99-0411', 
     '+1 (864) 112-7432', '1988-11-13', '2019-09-16 16:09:12'),
    ('Blair', 'Aumerle', 'baumerleh@toplist.cz', 'F', '430-01-578-5', 
     '+7 (393) 232-1860', '1979-11-09', '2018-10-28 19:25:35'),
    ('Pavlov', 'Steljes', 'psteljesi@macromedia.com', 'F', '571-09-6181', 
     '+598 (877) 881-3236', '1991-06-24', '2020-09-18 05:34:31'),
    ('Darn', 'Hadeke', 'dhadekej@last.fm', 'M', '478-32-02-87', 
     '+370 (347) 110-4270', '1984-09-04', '2018-02-10 12:56:00'),
    ('Wendell', 'Spanton', 'wspantonk@de.vu', 'F', null, 
     '+84 (301) 762-1316', '1973-07-24', '2018-01-30 01:20:11'),
    ('Carlo', 'Yearby', 'cyearbyl@comcast.net', 'F', null, 
     '+55 (288) 623-4067', '1974-11-11', '2018-06-24 03:18:40'),
    ('Sheila', 'Evitts', 'sevittsm@webmd.com', null, '830-40-5287',
     null, '1977-03-01', '2020-07-20 09:59:41'),
    ('Sianna', 'Lowdham', 'slowdhamn@stanford.edu', null, '778-0845', 
     null, '1985-12-23', '2018-06-29 02:42:49'),
    ('Phylys', 'Aslie', 'paslieo@qq.com', 'M', '368-44-4478', 
     '+86 (765) 152-8654', '1984-03-22', '2019-10-01 01:34:28');

SELECT * FROM users;

SELECT FORMAT(created_ts, 'yyyy') AS created_year,
	COUNT(1) AS user_count
FROM users 
GROUP BY FORMAT(created_ts, 'yyyy')
ORDER BY FORMAT(created_ts, 'yyyy') ASC;


--#E6.2
SELECT user_id,
	user_dob,
	user_email_id,
	DATENAME(dw, user_dob) as user_day_of_birth
FROM users
WHERE FORMAT(user_dob, 'MM') = '05'
ORDER BY FORMAT(user_dob, 'dd') ASC;


--#6.3
SELECT user_id,
	UPPER(CONCAT_WS(' ', user_first_name, user_last_name)) as user_name,
	user_email_id,
	created_ts,
	CAST(FORMAT(created_ts, 'yyyy') AS DECIMAL(5,1)) AS created_year
FROM users
WHERE FORMAT(created_ts, 'yyyy') = 2019
ORDER BY UPPER(CONCAT_WS(' ', user_first_name, user_last_name));


--#E6.4
SELECT user_gender = CASE user_gender
			WHEN 'M' THEN 'Male'
			WHEN 'F' THEN 'Female'
			WHEN 'N' THEN 'Non-Binary'
			ELSE 'Not Specified'
		END,
		COUNT(1) AS user_count
FROM users
GROUP BY user_gender
ORDER BY COUNT(1) DESC;


--#E6.5
--case checking for NULL forgo CASE <col> and do like below
--cant just let else catch since SELECT LEN(REPLACE(NULL, '-', '')) returns NULL
--and can't be compared to 9
SELECT 
	user_id,
	ISNULL(user_unique_id, '') AS user_unique_id,
	user_unique_id_last4 = CASE
		WHEN user_unique_id IS NULL THEN 'Not Specified'
		ELSE IIF((LEN(REPLACE(user_unique_id, '-', '')) < 9), 
			'Invalid Unique Id', RIGHT(REPLACE(user_unique_id, '-', ''), 4))
	END
FROM users
ORDER BY user_id;


--#E6.6
--Perhaps the most jank way possible, only works for this format
	--Get first 4
	--RTRIM '(', for if it is only a one digit code
	--Then LTRIM '+' for all cases
	--Then TRIM to get rid of any space that will be on the right from one or two digit codes
	--then cast final product to int so we can order by it later(could probaly order in current 
			--state, but casting it to int makes the behavior of ORDER BY more predictable
SELECT
	CAST(TRIM(LTRIM(RTRIM(LEFT(user_phone_no, 4), '('), '+')) AS INT) AS country_code,
	COUNT(1) AS user_count
FROM users
WHERE user_phone_no IS NOT NULL
GROUP BY TRIM(LTRIM(RTRIM(LEFT(user_phone_no, 4), '('), '+'))
ORDER BY CAST(TRIM(LTRIM(RTRIM(LEFT(user_phone_no, 4), '('), '+')) AS INT);


--#E6.7
SELECT COUNT(1) as count
FROM order_items
WHERE ROUND((order_item_quantity * order_item_product_price), 2) !=
order_item_subtotal;

--#E6.8
SELECT day_type = CASE DATENAME(dw, order_date)
		WHEN 'Saturday' THEN 'Weekend days'
		WHEN 'Sunday' THEN 'Weekend days'
		ELSE 'Week days'
		END,
	COUNT(1) AS order_count
FROM orders
WHERE ((order_date >= '20140101') AND (order_date < '20140201'))
GROUP BY CASE DATENAME(dw, order_date)
		WHEN 'Saturday' THEN 'Weekend days'
		WHEN 'Sunday' THEN 'Weekend days'
		ELSE 'Week days'
		END
ORDER BY COUNT(1) ASC;


--#E7.1
SELECT cp.category_name FROM
	(SELECT category_name,
		COUNT(1) as name_count
	FROM products LEFT JOIN categories ON
	products.product_category_id = categories.category_id
	WHERE category_name IS NOT NULL
	GROUP BY category_name) AS cp
WHERE cp.name_count > 5;

--#E7.2
SELECT order_customer_id, order_id FROM orders
WHERE orders.order_customer_id IN 
	(SELECT order_customer_id
	FROM orders 
	GROUP BY order_customer_id
	HAVING COUNT(1) >= 10)
ORDER BY order_customer_id;

--#E7.3
--THE point of this is circumventing taking the average product price for each 
--product, which is enforced by group by???
SELECT (SELECT AVG(oi.order_item_product_price) FROM
			order_items oi RIGHT JOIN orders o
			ON o.order_id = oi.order_item_order_id
			WHERE FORMAT(o.order_date, 'yyyy-MM') = '2013-10') AS avg_price,
		product_name
FROM products RIGHT JOIN 
	(SELECT * FROM orders INNER JOIN order_items
		ON orders.order_id = order_items.order_item_order_id) AS ooi
ON products.product_id = ooi.order_item_product_id
WHERE FORMAT(ooi.order_date, 'yyyy-MM') = '2013-10'
GROUP BY product_name;

--takes individual product_price average
SELECT AVG(product_price) AS avg_price,
		product_name
FROM products RIGHT JOIN 
	(SELECT * FROM orders INNER JOIN order_items
		ON orders.order_id = order_items.order_item_order_id
		WHERE FORMAT(orders.order_date, 'yyyy-MM') = '2013-10') AS ooi
ON products.product_id = ooi.order_item_product_id
GROUP BY product_name;


--#E7.4
--could be way eaiser wiht names subquery :(
SELECT order_id FROM 
	(SELECT SUM(order_items.order_item_subtotal) order_sums,
			order_id
		FROM orders inner join order_items
		ON orders.order_id = order_items.order_item_order_id
		GROUP BY orders.order_id) as orders_avg
WHERE orders_avg.order_sums > 
		(SELECT AVG(order_sums) FROM 
			(SELECT SUM(order_items.order_item_subtotal) order_sums
			FROM orders inner join order_items
			ON orders.order_id = order_items.order_item_order_id
			GROUP BY orders.order_id) AS or_sum)
ORDER BY order_id;

--#E7.5
WITH category_products_counts AS(
	SELECT 
		count(1) product_counts,
			category_id
		FROM categories INNER JOIN products
			ON products.product_category_id = categories.category_id
		GROUP BY category_id)
SELECT TOP 3 * FROM category_products_counts
ORDER BY product_counts DESC;


--#E7.6
WITH december_customers AS(
	SELECT SUM(order_item_subtotal) sub_sum,
		customers.customer_id,
		customers.customer_fname,
		customers.customer_lname
		FROM customers INNER JOIN (SELECT *
			FROM
			orders INNER JOIN order_items
			ON orders.order_id = order_items.order_item_order_id
			WHERE FORMAT(orders.order_date, 'MM') = '12') AS ooi
		ON ooi.order_customer_id = customers.customer_id
		GROUP BY customers.customer_id,
		customers.customer_fname,
		customers.customer_lname
),
above_december_avg AS(
	SELECT * FROM december_customers
	WHERE sub_sum > (SELECT AVG(sub_sum) FROM
						december_customers)
)
SELECT * FROM above_december_avg;


--#E8.1
USE hr_db;

SELECT employee_id,
	department_name,
	salary,
	avg_salary_expense
FROM( SELECT employee_id,
			department_name,
			departments.department_id,
			salary,
			CAST(AVG(salary) OVER 
				(PARTITION BY department_name) 
				AS DECIMAL(18,2)) avg_salary_expense
		FROM employees INNER JOIN departments 
		ON departments.department_id = employees.department_id
	 ) AS emp_vs_sal
WHERE salary > avg_salary_expense
ORDER BY department_id ASC, salary DESC;
GO

--#E8.2
SELECT employee_id,
	department_name,
	salary,
	CAST(SUM(salary) OVER (PARTITION BY department_name 
		 ORDER BY e.employee_id DESC)--NEED DESC here to get data to look how should
		 AS DECIMAL(18,2)) AS sal_sum
FROM employees e INNER JOIN departments d
ON e.department_id = d.department_id
WHERE department_name in ('Finance', 'IT')
ORDER BY department_name ASC, salary ASC;
GO

--#E8.3
SELECT employee_id,
	department_id,
	department_name,
	salary,
	RANK() OVER (PARTITION BY department_name 
				ORDER BY salary DESC) AS employee_rank
FROM(
	SELECT employee_id,
		d.department_id,
		department_name,
		salary,
		ROW_NUMBER() OVER(PARTITION BY department_name
			ORDER BY salary DESC) AS ranking
	FROM employees e INNER JOIN departments d
	ON e.department_id = d.department_id) AS all_ranked
WHERE ranking <=3
ORDER BY department_id ASC, salary DESC;

SELECT employee_id,
	department_id,
	department_name,
	salary,
	RANK() OVER (PARTITION BY department_name 
				ORDER BY salary DESC) AS employee_rank
FROM(
	SELECT employee_id,
		d.department_id,
		department_name,
		salary,
		ROW_NUMBER() OVER(PARTITION BY department_name
			ORDER BY salary DESC) AS ranking
	FROM employees e INNER JOIN departments d
	ON e.department_id = d.department_id) AS all_ranked
WHERE ranking <=3
ORDER BY department_id ASC, salary DESC;


--#E8.4
USE retail_db;
UPDATE orders
SET order_status = REPLACE(order_status, CHAR(13), '')
GO

SELECT TOP 3 *,
	RANK() OVER (ORDER BY revenue DESC) AS product_rank
FROM (SELECT product_id,
		product_name,
		CAST(SUM(order_item_subtotal) AS DECIMAL(18,2)) revenue
	FROM orders o INNER JOIN 
		(SELECT * FROM order_items oi
			INNER JOIN products p
		ON p.product_id = oi.order_item_product_id) AS oip
	ON o.order_id = oip.order_item_order_id
	WHERE ((o.order_status IN ('COMPLETE', 'CLOSED')) AND
	(FORMAT(o.order_date, 'yyyy-MM') = '2014-01'))
	GROUP BY product_name, product_id) AS revenue_jan_14
ORDER BY revenue DESC;


--#E8.5
UPDATE categories
SET category_name = REPLACE(category_name, CHAR(13), '');
GO


WITH prod_in_cardio_and_str AS(
	SELECT * FROM products p INNER JOIN
		categories c
	ON c.category_id = p.product_category_id
	WHERE category_name IN ('Cardio Equipment', 'Strength Training')
),
jan_14_comp_closed AS(
	SELECT * FROM orders o
		INNER JOIN order_items oi
	ON o.order_id = oi.order_item_order_id
	WHERE ((o.order_status IN ('COMPLETE', 'CLOSED')) AND
	(FORMAT(o.order_date, 'yyyy-MM') = '2014-01'))
),
car_and_str_revenue_jan_14 AS(
	SELECT category_id,
		category_name,
		product_id,
		product_name,
		CAST(SUM(order_item_subtotal) AS DECIMAL(18,2)) revenue
	FROM jan_14_comp_closed j INNER JOIN
		prod_in_cardio_and_str p
	ON j.order_item_product_id = p.product_id
	GROUP BY category_id,
		category_name,
		product_id,
		product_name
),
products_ranked AS(
	SELECT *,
		RANK() OVER (PARTITION BY category_id ORDER BY revenue DESC) product_rank
	FROM car_and_str_revenue_jan_14
)
SELECT * FROM products_ranked
ORDER BY category_id ASC, revenue DESC;


USE AdventureWorks2022;
--#E9.1.1
SELECT * FROM Production.Product;
--#E9.1.2
SELECT * FROM HumanResources.Employee;
--#E9.1.3
SELECT * FROM Sales.Customer cust INNER JOIN
		Sales.SalesOrderHeader soh
	ON cust.CustomerID = soh.CustomerID
WHERE cust.CustomerID = 11000;

--#E9.1.4 
SELECT cust.CustomerID,
	SUM(soh.TotalDue) total_due
FROM Sales.Customer cust INNER JOIN
		Sales.SalesOrderHeader soh
	ON cust.CustomerID = soh.CustomerID
GROUP BY cust.CustomerID
ORDER BY cust.CustomerID;


--#E9.1.5
--Not sure what to do here for finiding contact info, found address for some
SELECT * FROM Person.Address a INNER JOIN(
	SELECT v.BusinessEntityID, v.Name,
		bec.AddressID 
	FROM Purchasing.Vendor v INNER JOIN Person.BusinessEntityAddress bec
		ON v.BusinessEntityID = bec.BusinessEntityID) becv
	ON becv.AddressID = a.AddressID;


--#E9.1.6
SELECT pc.Name AS category,
	ps.Name AS subcategory
FROM Production.ProductCategory pc INNER JOIN Production.ProductSubcategory ps
	ON ps.ProductCategoryID = pc.ProductCategoryID;

--#E9.1.7
--No products currently discontiued
SELECT * FROM Production.Product p
WHERE p.DiscontinuedDate IS NOT NULL;

--#E9.1.8
SELECT p.ProductID, 
	p.Name,
	SUM(sod.OrderQty) AS total_qty
FROM Production.Product p INNER JOIN 
	Sales.SalesOrderDetail sod
ON p.ProductID = sod.ProductID
GROUP BY p.ProductID,
		p.Name
ORDER BY p.ProductID;

--#E9.1.9
--Would this work if had multiple addresses for one customer?
SELECT sohc.CustomerID,
	AddressLine1, AddressLine2,
	City, PostalCode
FROM Person.Address a INNER JOIN (
		SELECT c.CustomerID, soh.BillToAddressID
		FROM Sales.SalesOrderHeader soh
			INNER JOIN Sales.Customer c
		ON c.CustomerID = soh.CustomerID) AS sohc
	ON sohc.BillToAddressID = a.AddressID
WHERE CustomerID = 11000
GROUP BY sohc.CustomerID,
	AddressLine1, AddressLine2,
	City, PostalCode;

--#E9.1.10
--712,870,711,715,708
SELECT TOP 5 p.ProductID, 
	p.Name,
	SUM(sod.OrderQty) AS total_qty
FROM Production.Product p INNER JOIN 
	Sales.SalesOrderDetail sod
ON p.ProductID = sod.ProductID
GROUP BY p.ProductID,
		p.Name
ORDER BY total_qty DESC;


--#E9.3.1
SELECT * FROM (
SELECT COUNT(1) OVER(ORDER BY SalesOrderID) AS row_number,
	* 
FROM Sales.SalesOrderHeader) as row_count_soh
WHERE FORMAT(OrderDate, 'yyyy-MM') = '2011-06';

--#E9.3.2
SELECT TotalDue,
CAST(SUM(TotalDue) OVER (PARTITION BY OrderDate) AS DECIMAL(18,2)) DailyTotalDue,
* FROM Sales.SalesOrderHeader;

--#E9.3.3
SELECT CAST(AVG(DailyTotalDue) OVER 
		(ORDER BY OrderDate
		ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
		AS DECIMAL(18,2)) AS three_day_avg,
		*
FROM (SELECT CAST(SUM(TotalDue) AS DECIMAL(18,2)) DailyTotalDue,
			OrderDate 
		FROM Sales.SalesOrderHeader
		GROUP BY OrderDate) AS totDueDaily;

--#E9.3.4
SELECT RANK() OVER(PARTITION BY ProductID
				ORDER BY OrderQty DESC) AS [rank],
		*
FROM Sales.SalesOrderDetail
ORDER BY ProductID;

--#E9.3.5
SELECT LAG(OrderDate) OVER(
		PARTITION BY CustomerID
		ORDER BY OrderDate ASC) last_order_date,
		LEAD(OrderDate) OVER(PARTITION BY CustomerID
		ORDER BY OrderDate ASC) next_order_date,
* FROM Sales.SalesOrderHeader
ORDER BY CustomerID, OrderDate;