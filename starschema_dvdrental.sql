
# Create Dimension tables in database

CREATE TABLE dimdate
(
 	date_key 	integer 	NOT NULL PRIMARY KEY,
	date 		date 		NOT NULL,
	year 		smallint 	NOT NULL,
	quarter 	smallint 	NOT NULL,
	month 		smallint 	NOT NULL,
	day 		smallint 	NOT NULL,
	week 		smallint 	NOT NULL,
	is_weekend 	boolean
);

CREATE TABLE dimcustomer
(
	customer_key 		SERIAL 	PRIMARY KEY,
	customer_id 		smallint    	NOT NULL,
	first_name 		varchar(45) 	NOT NULL,
	last_name 		varchar(45) 	NOT NULL,
	email 			varchar(50),
	address 		varchar(50)	NOT NULL,
	address2 		varchar(50),  
	district 			varchar(20) 	NOT NULL,
	city			varchar(50) 	NOT NULL,
	country		varchar(50) 	NOT NULL,
	postal_code 		varchar(10),
	phone			varchar(20) 	NOT NULL,
	active			smallint 	NOT NULL,
	create_date 		timestamp	NOT NULL,
	start_date  		date		NOT NULL,
	end_date    		date		NOT NULL
);

CREATE TABLE dimmovie
(
	movie_key		  SERIAL 	PRIMARY KEY,
	film_id			  smallint 	NOT NULL,
	title			  varchar(255) 	NOT NULL,
	description		  text,
	release_year	 	  year,
	language		  varchar(20) 	NOT NULL,
	original_language 	  varchar(20),
	rental_duration   	  smallint 	NOT NULL,
	length			  smallint 	NOT NULL,
	rating			  varchar(5) 	NOT NULL,
	special_features  	varchar(60) 	NOT NULL
);

CREATE TABLE dimstore
(
	store_key 		   SERIAL 	PRIMARY KEY,
	store_id		   smallint 	NOT NULL,
	address 		   varchar(50) 	NOT NULL,
	address2 		   varchar(50),
	district 		  	   varchar(20) 	NOT NULL,
	city 			   varchar(50) 	NOT NULL,
	country 		   varchar(50) 	NOT NULL,
	postal_code 	   	   varchar(10),
	manager_first_name     varchar(45) 	NOT NULL,
	manager_last_name     varchar(45) 	NOT NULL,
	start_date 		   date 		NOT NULL,
	end_date 		   date 		NOT NULL
);

# Create Fact table in database

CREATE TABLE factSales
(
	sales_key 	SERIAL  PRIMARY KEY,
	date_key	integer REFERENCES dimdate (date_key),
	customer_key integer REFERENCES dimcustomer (customer_key),
	movie_key	integer REFERENCES dimmovie (movie_key),
	store_key	integer REFERENCES dimstore (store_key),
	sales_amount numeric	
);

# Insert database data into dimension tables

INSERT INTO dimdate (date_key, date, year, quarter, month,
					 day, week, is_weekend)
SELECT
		DISTINCT(TO_CHAR(payment_date :: DATE, 'yyyMMDD')::integer) as date_key,
		date(payment_date) as date,
		EXTRACT(year from payment_date) AS year,
		EXTRACT(quarter FROM payment_date) AS quarter,
		EXTRACT(month FROM payment_date) AS month,
		EXTRACT(week FROM payment_date) AS week,
		EXTRACT(day FROM payment_date) AS day,
		CASE WHEN EXTRACT(ISODOW FROM payment_date) IN (6,7) THEN true ELSE false END
FROM payment;

# Insert database data into fact table

INSERT INTO factSales (date_key, customer_key, movie_key,
					  store_key, sales_amount)
SELECT
		TO_CHAR(payment_date :: DATE, 'yyyyMMDD')::integer AS date_key,
		p.customer_id AS customer_key,
		i.film_id AS movie_key,
		i.store_id AS store_key,
		p.amount AS sales_amount
FROM payment AS p
JOIN rental AS r ON (p.rental_id = r.rental_id)
JOIN inventory AS i ON (r.inventory_id = i.inventory_id);
