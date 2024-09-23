/*
Data Engineering 1 course, 2nd homework
Author: Marton Nagy
Note: if applicable, answers to the exercises are provided after the corresponding SQL statement.
*/

use birdstrikes;

-- Exercise1:
-- Based on the previous chapter, create a table called “employee” with two columns: “id” and “employee_name”. NULL values should not be accepted for these 2 columns.
create table employee
(id integer not null,
employee_name varchar(255) not null,
primary key(id)
);
-- (no output solution value, only a table is created)

-- Exercise2:
-- What state figures in the 145th line of our database?
select state from birdstrikes limit 144,1;
-- Tennessee

-- Exercise3:
-- What is flight_date of the latest birstrike in this database?
select flight_date from birdstrikes order by flight_date desc limit 1;
-- 2000-04-18

-- Exercise4:
-- What was the cost of the 50th most expensive damage?
select distinct cost from birdstrikes order by cost desc limit 49,1;
-- 5345

-- Exercise5:
-- What state figures in the 2nd record, if you filter out all records which have no state and no bird_size specified?
select state from birdstrikes where state is not null and bird_size is not null limit 1,1;
-- <empty record>

-- Exercise6:
-- How many days elapsed between the current date and the flights happening in week 7, for incidents from Colorado?
select datediff(now(),(select flight_date from birdstrikes where weekofyear(flight_date) = 7 and state = 'Colorado'));
-- 8987