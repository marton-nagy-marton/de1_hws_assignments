/*
Author: Marton Nagy
Solution for Data Engineering 1 HW5
*/
use classicmodels;
-- create new table for US phone prefixes
create table usPhonePrefixes(
prefix varchar(10) not null,
city varchar(63) not null,
state varchar(63) not null);

-- load data into table
-- data downloaded from: https://github.com/ravisorg/Area-Code-Geolocation-Database/blob/master/us-area-code-cities.csv
load data infile 'D:/EGYETEM/CEU/DE/Uploads/us_area_codes.csv' 
into table usPhonePrefixes 
-- removing quot. marks and field separator is a comma
fields enclosed by '"' terminated by ','
-- line break is simply \n in this file
lines terminated by '\n'
(prefix, city, state, @field4, @field5, @field6);
/*
Sadly, this database does not include the city for the only domestic US phone number in the customers table (Brickhaven)
However, I found online that actually there is no US city called Brickhaven...
So, for the sake of the exercise, I add a new record with this city's data to my usPhonePrefixes table.
I inferred its prefix and state values from other records of Brickhaven from the customers table.
*/
insert into usPhonePrefixes(prefix, city, state) values('617','Brickhaven','Massachusetts');

-- below there is the stored procedure that:
-- 1) fixes domestic US numbers to be international
-- 2) adds the domestic area code for local numbers and also makes them international
-- most of this procedure was copied from the class materials
DROP PROCEDURE IF EXISTS FixDomUSPhones; 
DELIMITER //
CREATE PROCEDURE FixDomUSPhones ()
BEGIN
	DECLARE finished INTEGER DEFAULT 0;
	DECLARE phone varchar(50) DEFAULT "x";
	DECLARE customerNumber INT DEFAULT 0;
	DECLARE country varchar(50) DEFAULT "";
    -- c stands for city, wanted to avoid confusion by not naming it city
    DECLARE c varchar(50) default "";
    DECLARE areacode varchar(10) default "";
	-- declare cursor for customer, we also need the city
	DECLARE curPhone
		CURSOR FOR 
            		SELECT customers.customerNumber, customers.phone, customers.country , customers.city
				FROM classicmodels.customers;
	-- declare NOT FOUND handler
	DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET finished = 1;
	OPEN curPhone;
    	-- create a copy of the customer table 
	DROP TABLE IF EXISTS classicmodels.fixed_customers;
	CREATE TABLE classicmodels.fixed_customers LIKE classicmodels.customers;
	INSERT fixed_customers SELECT * FROM classicmodels.customers;
	-- truncate messages;
	fixPhone: LOOP
		FETCH curPhone INTO customerNumber, phone, country, c;
		IF finished = 1 THEN 
			LEAVE fixPhone;
		END IF;
		IF country = 'USA'  THEN
			IF phone NOT LIKE '+%' THEN
				-- if the phone already has an area code, we only have to add the +1
				IF LENGTH(phone) = 10 THEN 
					SET  phone = CONCAT('+1',phone);
					UPDATE classicmodels.fixed_customers 
						SET fixed_customers.phone=phone 
							WHERE fixed_customers.customerNumber = customerNumber;
				-- if the number is a domestic one, we have to look up the corresponding area code for the city
                ELSEIF LENGTH(phone) = 7 THEN
					-- insert into messages select concat('city is: ', c, ', phone is: ', phone);
                    -- must limit to 1 as otherwise we get as many records as there are customers from the specific city
					SET areacode = (SELECT prefix from usPhonePrefixes inner join customers using(city) where usPhonePrefixes.city = c limit 1);
                    insert into messages SELECT areacode;
					SET phone = CONCAT('+1', areacode, phone);
					UPDATE classicmodels.fixed_customers 
						SET fixed_customers.phone=phone 
							WHERE fixed_customers.customerNumber = customerNumber;
                END IF;    
			END IF;
		END IF;
	END LOOP fixPhone;
	CLOSE curPhone;
END //
DELIMITER ;
call FixDomUSPhones();
-- checking the results, we can see that the only local number has been correctly updated
select * from fixed_customers where country = 'USA';
