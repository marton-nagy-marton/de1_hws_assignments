-- creating own db and table for the project
create schema ninjadb;
use ninjadb;
-- could not figure out what each field was for, so went simply with col1, col2 etc.
create table ninjatable
(col1 integer not null,
col2 varchar(63) not null,
col3 varchar(63) not null,
col4 float not null);
-- loading the txt file into the table
load data infile 'D:/EGYETEM/CEU/DE/Uploads/ninja.txt' 
into table ninjatable 
-- removing quot. marks and field separator is a comma
fields enclosed by '"' terminated by ','
-- only importing lines starting with Data:; and line break is simply \n in this file
lines starting by 'Data:' terminated by '\n'
-- storing the 4th column in a seperate variable, and than setting the real col4 field to that, divided by a 1000
(col1, col2, col3, @col4)
set col4 = @col4 / 1000;