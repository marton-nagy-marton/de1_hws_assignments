-- The below script (until line 234) is a copy-paste of the MySQL generated forward engineering statements

-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema movies
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `movies` ;

-- -----------------------------------------------------
-- Schema movies
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `movies` DEFAULT CHARACTER SET utf8mb3 ;
USE `movies` ;

-- -----------------------------------------------------
-- Table `movies`.`name_basics`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `movies`.`name_basics` ;

CREATE TABLE IF NOT EXISTS `movies`.`name_basics` (
  `nconst` VARCHAR(45) NOT NULL,
  `primary_name` VARCHAR(255) NULL DEFAULT NULL,
  `birth_year` INT NULL DEFAULT NULL,
  `death_year` INT NULL DEFAULT NULL,
  `primary_profession` TEXT NULL DEFAULT NULL,
  `known_for_titles` TEXT NULL DEFAULT NULL,
  PRIMARY KEY (`nconst`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- Table `movies`.`the_numbers`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `movies`.`the_numbers` ;

CREATE TABLE IF NOT EXISTS `movies`.`the_numbers` (
  `id` INT NOT NULL,
  `release_date` DATE NULL DEFAULT NULL,
  `movie` VARCHAR(255) NULL DEFAULT NULL,
  `budget` BIGINT NULL DEFAULT NULL,
  `dom_gross` BIGINT NULL DEFAULT NULL,
  `worldw_gross` BIGINT NULL DEFAULT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `movies`.`title_basics`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `movies`.`title_basics` ;

CREATE TABLE IF NOT EXISTS `movies`.`title_basics` (
  `tconst` VARCHAR(45) NOT NULL,
  `title_type` VARCHAR(45) NULL DEFAULT NULL,
  `primary_title` VARCHAR(500) NULL DEFAULT NULL,
  `original_title` VARCHAR(500) NULL DEFAULT NULL,
  `is_adult` TINYINT(1) NULL DEFAULT NULL,
  `start_year` INT NULL DEFAULT NULL,
  `end_year` INT NULL DEFAULT NULL,
  `runtime_minutes` INT NULL DEFAULT NULL,
  `genres` VARCHAR(500) NULL DEFAULT NULL,
  PRIMARY KEY (`tconst`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- Table `movies`.`title_akas`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `movies`.`title_akas` ;

CREATE TABLE IF NOT EXISTS `movies`.`title_akas` (
  `tconst` VARCHAR(45) NOT NULL,
  `ordering` INT NOT NULL,
  `title` VARCHAR(1000) NULL DEFAULT NULL,
  `region` VARCHAR(45) NULL DEFAULT NULL,
  `language` VARCHAR(45) NULL DEFAULT NULL,
  `types` VARCHAR(255) NULL DEFAULT NULL,
  `attributes` VARCHAR(500) NULL DEFAULT NULL,
  `is_original_title` TINYINT(1) NULL DEFAULT NULL,
  PRIMARY KEY (`tconst`, `ordering`),
  INDEX `fk_title_akas_title_basics_idx` (`tconst` ASC) VISIBLE,
  CONSTRAINT `fk_title_akas_title_basics`
    FOREIGN KEY (`tconst`)
    REFERENCES `movies`.`title_basics` (`tconst`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- Table `movies`.`title_crew`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `movies`.`title_crew` ;

CREATE TABLE IF NOT EXISTS `movies`.`title_crew` (
  `tconst` VARCHAR(45) NOT NULL,
  `directors` TEXT NULL DEFAULT NULL,
  `writers` TEXT NULL DEFAULT NULL,
  PRIMARY KEY (`tconst`),
  INDEX `fk_title_crew_title_basics1_idx` (`tconst` ASC) VISIBLE,
  CONSTRAINT `fk_title_crew_title_basics1`
    FOREIGN KEY (`tconst`)
    REFERENCES `movies`.`title_basics` (`tconst`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- Table `movies`.`title_episodes`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `movies`.`title_episodes` ;

CREATE TABLE IF NOT EXISTS `movies`.`title_episodes` (
  `tconst` VARCHAR(45) NOT NULL,
  `parent_tconst` VARCHAR(45) NOT NULL,
  `season_number` INT NULL DEFAULT NULL,
  `episode_number` INT NULL DEFAULT NULL,
  PRIMARY KEY (`tconst`),
  INDEX `fk_title_episodes_title_basics1_idx` (`tconst` ASC) VISIBLE,
  INDEX `fk_title_episodes_title_episodes1_idx` (`parent_tconst` ASC) VISIBLE,
  CONSTRAINT `fk_title_episodes_parent_tconst`
    FOREIGN KEY (`parent_tconst`)
    REFERENCES `movies`.`title_basics` (`tconst`),
  CONSTRAINT `fk_title_episodes_title_basics1`
    FOREIGN KEY (`tconst`)
    REFERENCES `movies`.`title_basics` (`tconst`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- Table `movies`.`title_principals`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `movies`.`title_principals` ;

CREATE TABLE IF NOT EXISTS `movies`.`title_principals` (
  `tconst` VARCHAR(45) NOT NULL,
  `ordering` INT NOT NULL,
  `nconst` VARCHAR(45) NOT NULL,
  `category` VARCHAR(255) NULL DEFAULT NULL,
  `job` TEXT NULL DEFAULT NULL,
  `characters` TEXT NULL DEFAULT NULL,
  PRIMARY KEY (`tconst`, `ordering`),
  INDEX `fk_title_principals_title_basics1_idx` (`tconst` ASC) VISIBLE,
  INDEX `fk_title_principals_name_basics1_idx` (`nconst` ASC) VISIBLE,
  CONSTRAINT `fk_title_principals_name_basics1`
    FOREIGN KEY (`nconst`)
    REFERENCES `movies`.`name_basics` (`nconst`),
  CONSTRAINT `fk_title_principals_title_basics1`
    FOREIGN KEY (`tconst`)
    REFERENCES `movies`.`title_basics` (`tconst`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- Table `movies`.`title_ratings`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `movies`.`title_ratings` ;

CREATE TABLE IF NOT EXISTS `movies`.`title_ratings` (
  `tconst` VARCHAR(45) NOT NULL,
  `average_rating` FLOAT NULL DEFAULT NULL,
  `num_votes` INT NULL DEFAULT NULL,
  PRIMARY KEY (`tconst`),
  INDEX `fk_title_ratings_title_basics1_idx` (`tconst` ASC) VISIBLE,
  CONSTRAINT `fk_title_ratings_title_basics1`
    FOREIGN KEY (`tconst`)
    REFERENCES `movies`.`title_basics` (`tconst`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- Table `movies`.`tmdb`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `movies`.`tmdb` ;

CREATE TABLE IF NOT EXISTS `movies`.`tmdb` (
  `id` INT NOT NULL,
  `title` VARCHAR(500) NULL DEFAULT NULL,
  `vote_average` FLOAT NULL DEFAULT NULL,
  `vote_count` INT NULL DEFAULT NULL,
  `status` VARCHAR(45) NULL DEFAULT NULL,
  `release_date` DATE NULL DEFAULT NULL,
  `revenue` BIGINT NULL DEFAULT NULL,
  `runtime` INT NULL DEFAULT NULL,
  `adult` TINYINT(1) NULL DEFAULT NULL,
  `backdrop_path` MEDIUMTEXT NULL DEFAULT NULL,
  `budget` BIGINT NULL DEFAULT NULL,
  `homepage` MEDIUMTEXT NULL DEFAULT NULL,
  `imdb_id` VARCHAR(45) NULL DEFAULT NULL,
  `original_language` VARCHAR(45) NULL DEFAULT NULL,
  `original_title` VARCHAR(255) CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_unicode_ci' NULL DEFAULT NULL,
  `overview` MEDIUMTEXT NULL DEFAULT NULL,
  `popularity` FLOAT NULL DEFAULT NULL,
  `poster_path` MEDIUMTEXT NULL DEFAULT NULL,
  `tagline` MEDIUMTEXT NULL DEFAULT NULL,
  `genres` MEDIUMTEXT NULL DEFAULT NULL,
  `production_companies` MEDIUMTEXT NULL DEFAULT NULL,
  `production_countries` MEDIUMTEXT NULL DEFAULT NULL,
  `spoken_languages` MEDIUMTEXT NULL DEFAULT NULL,
  `keywords` MEDIUMTEXT NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_tmdb_title_basics1_idx` (`imdb_id` ASC) VISIBLE,
  CONSTRAINT `fk_tmdb_title_basics1`
    FOREIGN KEY (`imdb_id`)
    REFERENCES `movies`.`title_basics` (`tconst`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

/*
The below script imports all files to the pre-made schema. It converts all values to corresponding types, thus some checks are built in
to ensure that inputs are in the correct format. If an input does not match the required type, it is generally set to null.
The folder where MySQL can safely import local files on my computer is: D:/EGYETEM/CEU/DE/Uploads/
(When running this script on another computer, this path must be changed to the locally appropriate one.)
*/
-- use the movies schema
use movies;
-- turning off foreign key checks as this would cause problems if we are not importing the tables in the correct order
set foreign_key_checks = 0;

-- DONE
-- load data into the_numbers table from local csv file
-- delete content, if any
truncate the_numbers;
-- load the data
load data infile 'D:/EGYETEM/CEU/DE/Uploads/movie_budgets.csv'
into table the_numbers
fields enclosed by '"' terminated by ','
lines terminated by "\r\n"
ignore 1 lines
(@id, @d, movie, @budget, @dom_gross, @worldw_gross)
-- ids have 1000s seperators, they need to be removed
set id = cast(replace(@id, ',', '') as signed),
-- release date can be unknown, replace it with null
    release_date = if(@d = 'Unknown',
		null,
        -- if a comma is the 4th char, it means that there is no day for the data -> adding 1 for day before parsing date
		if(locate(',', @d) = 4, 
			str_to_date(concat(@d, ' 1'), '%b, %Y %e'),
            -- if there is no comma, the date only has a year -> adding Jan, 1 before parsing the date
			if (locate(',', @d) = 0,
				str_to_date(concat(@d, ' Jan, 1'), '%Y %b, %e'),
                -- the usual format for most records
				str_to_date(@d, '%b %e, %Y')
                )
			)
		),
	-- replacing 1000s separator commas and $ signs to get integers
	budget = cast(replace(replace(@budget, ',', ''), '$', '') as signed),
	dom_gross = cast(replace(replace(@dom_gross, ',', ''), '$', '') as signed),
	worldw_gross = cast(replace(replace(@worldw_gross, ',', ''), '$', '') as signed);

-- DONE
-- import data to tmdb table from local csv file
-- the source data is multilingual, so only the below charset can properly encode it
alter table tmdb convert to character set utf8mb4 collate utf8mb4_unicode_ci;
alter table tmdb modify column original_title varchar(255) character set utf8mb4 collate utf8mb4_unicode_ci;
set names 'utf8mb4';

-- there are duplicate entries in the source file, so we have to load it first to a temporary table with no primary key checks
-- this table has the same structure as the original table
CREATE TABLE IF NOT EXISTS movies.tmdb_temp (
  `id` INT NOT NULL,
  `title` VARCHAR(500) NULL,
  `vote_average` FLOAT NULL,
  `vote_count` INT NULL,
  `status` VARCHAR(45) NULL,
  `release_date` DATE NULL,
  `revenue` BIGINT(10) NULL,
  `runtime` INT NULL,
  `adult` TINYINT(1) NULL,
  `backdrop_path` TEXT NULL,
  `budget` BIGINT(10) NULL,
  `homepage` TEXT NULL,
  `imdb_id` VARCHAR(45) NULL,
  `original_language` VARCHAR(45) NULL,
  `original_title` VARCHAR(500) NULL,
  `overview` TEXT NULL,
  `popularity` FLOAT NULL,
  `poster_path` TEXT NULL,
  `tagline` TEXT NULL,
  `genres` TEXT NULL,
  `production_companies` TEXT NULL,
  `production_countries` TEXT NULL,
  `spoken_languages` TEXT NULL,
  `keywords` TEXT NULL);
  
-- we need the correct char set for this as well
alter table tmdb_temp convert to character set utf8mb4 collate utf8mb4_unicode_ci;
alter table tmdb_temp modify column original_title varchar(255) character set utf8mb4 collate utf8mb4_unicode_ci;
set names 'utf8mb4';

-- delete contents if any
truncate tmdb_temp;
-- loading in the data
load data infile 'D:/EGYETEM/CEU/DE/Uploads/TMDB_movie_dataset_v11.csv'
into table tmdb_temp
character set utf8mb4
fields enclosed by '"' terminated by ','
lines terminated by "\n"
ignore 1 lines
(id, @title, @vote_average, @vote_count, @status, @rel_date, @revenue, @runtime, @adult, @backdrop_path, @budget, @homepage, @imdb_id,
@original_language, @original_title, @overview, @popularity, @poster_path, @tagline, @genres,
@production_companies, @production_countries, @spoken_languages, @keywords)
-- empty strings are assigned null when loading
set title = if(@title = '', null, @title),
	-- checking with regex that the source data is indeed a float - if not, we assign null
    vote_average = if(@vote_average = '' or @vote_average not regexp '^[0-9]*\.?[0-9]+$', null, cast(@vote_average as decimal)),
    -- checking with regex that the source data is indeed an integer
    vote_count = if(@vote_count = '' or @vote_count not regexp '^[0-9]+$', null, cast(@vote_count as signed)),
    status = if(@status = '', null, @status),
    -- for some records, release data was empty or 0, we set those to null
    release_date = IF(@rel_date = '' OR @rel_date = '0', NULL, STR_TO_DATE(@rel_date, '%Y-%m-%d')),
    -- checking with regex that the source data is indeed an integer
    revenue = if(@revenue = '' or @revenue not regexp '^[0-9]+$', null, cast(replace(@revenue, ',', '') as signed)),
    -- checking with regex that the source data is indeed an integer
    runtime = if(@runtime = '' or @runtime not regexp '^[0-9]+$', null, cast(@runtime as signed)),
    -- checking with regex that the source data is True or False
    adult = if(@adult = '' or @adult not in ('True', 'False'), null, if(@adult = 'True', 1, 0)),
    backdrop_path = if(@backdrop_path = '', null, @backdrop_path),
    -- checking with regex that the source data is indeed an integer
    budget = if(@budget = '' or @budget not regexp '^[0-9]+$', null, cast(replace(@budget, ',', '') as signed)),
    homepage = if(@homepage = '', null, @homepage),
    imdb_id = if(@imdb_id = '', null, @imdb_id),
    -- this field ended up containing another data for a few entries, so had to check length
    original_language = if(@original_language = '', null, IF(LENGTH(@original_language) > 45, LEFT(@original_language, 45), @original_language)),
    original_title = if(@original_title = '', null, @original_title),
    overview = if(@overview = '', null, @overview),
    -- checking with regex that the source data is indeed a float - if not, we assign null
    popularity = if(@popularity = '' or @popularity not regexp '^[0-9]*\.?[0-9]+$', null, cast(@popularity as decimal)),
    poster_path = if(@poster_path = '', null, @poster_path),
    tagline = if(@tagline = '', null, @tagline),
    genres = if(@genres = '', null, @genres),
    production_companies = if(@production_companies = '', null, @production_companies),
    production_countries = if(@production_countries = '', null, @production_countries),
    spoken_languages = if(@spoken_languages = '', null, @spoken_languages),
    keywords = if(@keywords = '', null, @keywords);

-- delete contents if any
-- truncate tmdb;
-- adding the temp table to the original table to remove duplicates
insert ignore into tmdb
select * from tmdb_temp;

-- drop temporary table
drop table tmdb_temp;

-- Convert the character set to the correct for one for all tables from IMDb (just to make sure)
alter table name_basics convert to character set utf8mb4 collate utf8mb4_unicode_ci;
alter table title_akas convert to character set utf8mb4 collate utf8mb4_unicode_ci;
alter table title_basics convert to character set utf8mb4 collate utf8mb4_unicode_ci;
alter table title_crew convert to character set utf8mb4 collate utf8mb4_unicode_ci;
alter table title_episodes convert to character set utf8mb4 collate utf8mb4_unicode_ci;
alter table title_principals convert to character set utf8mb4 collate utf8mb4_unicode_ci;
alter table title_ratings convert to character set utf8mb4 collate utf8mb4_unicode_ci;


-- turning off unique checks now as the IMDB tables are well maintained so there are no unique id issues
set unique_checks = 0;


-- DONE
-- import data to title_basics from local tsv
-- delete contents, if any
truncate title_basics;
-- increase size of string fields (255 was causing problems)
alter table title_basics modify column primary_title varchar(500);
alter table title_basics modify column original_title varchar(500);
alter table title_basics modify column genres varchar(500);

load data infile 'D:/EGYETEM/CEU/DE/Uploads/title.basics.tsv'
into table title_basics
character set utf8mb4
fields terminated by '\t'
lines terminated by "\n"
ignore 1 lines
(tconst, @title_type, @primary_title, @original_title, @is_adult, @start_year, @end_year, @runtime_minutes, @genres)
set
    title_type = if(@title_type = '\N', null, @title_type),
    primary_title = if(@primary_title = '\N', null, @primary_title),
    original_title = if(@original_title = '\N', null, @original_title),
    is_adult = if(@is_adult = '\N' or @is_adult not regexp '^[01]$', null, cast(@is_adult as signed)),
    start_year = if(@start_year = '\N' or @start_year not regexp '^[0-9]+$', null, cast(@start_year as signed)),
    end_year = if(@end_year = '\N' or @end_year not regexp '^[0-9]+$', null, cast(@end_year as signed)),
    runtime_minutes = if(@runtime_minutes = '\N' or @runtime_minutes not regexp '^[0-9]+$', null, cast(@runtime_minutes as signed)),
    genres = if(@genres = '\N', null, @genres);


-- DONE
-- import data to title_akas from local tsv
-- increase size of string fields (255 was causing problems)
alter table title_akas modify column title varchar(1000);
alter table title_akas modify column attributes varchar(500);
alter table title_akas change tpyes types varchar(255);

-- delete contents, if any
truncate title_akas;

-- import data to title_akas from local tsv
load data infile 'D:/EGYETEM/CEU/DE/Uploads/title.akas.tsv'
into table title_akas
character set utf8mb4
fields terminated by '\t'
lines terminated by '\n'
ignore 1 lines
(tconst, @ordering, @title, @region, @language, @types, @attributes, @is_original_title)
set
    ordering = if(@ordering = '\N' or @ordering not regexp '^[0-9]+$', null, cast(@ordering as signed)),
    title = if(@title = '\N', null, @title),
    region = if(@region = '\N', null, @region),
    language = if(@language = '\N', null, @language),
    types = if(@types = '\N', null, @types),
    attributes = if(@attributes = '\N', null, @attributes),
    is_original_title = if(@is_original_title = '\N' or @is_original_title not regexp '^[01]$', null, cast(@is_original_title as signed));


-- DONE
-- impport title.crew.tsv
-- increase size of string fields (255 was causing problems)
alter table title_crew modify column directors text;
alter table title_crew modify column writers text;
-- delete contents, if any
truncate title_crew;
load data infile 'D:/EGYETEM/CEU/DE/Uploads/title.crew.tsv'
into table title_crew
character set utf8mb4
fields terminated by '\t'
lines terminated by '\n'
ignore 1 lines
(tconst, @directors, @writers)
set
    directors = if(@directors = '\N', NULL, @directors),
    writers = if(@writers = '\N', NULL, @writers);
    

-- NOT DONE
-- import title.principals.tsv
-- increase size of string fields (255 was causing problems)
alter table title_principals modify column job TEXT;
alter table title_principals modify column characters TEXT;
-- delete contents, if any
truncate title_principals;

-- loading directly to the table with composite PK was too slow, loading to temp table instead without PKs
create table temp_princip like title_principals;
alter table temp_princip drop primary key;

load data infile 'D:/EGYETEM/CEU/DE/Uploads/title.principals.tsv'
into table temp_princip
character set utf8mb4
fields terminated by '\t'
lines terminated by '\n'
ignore 1 lines
(tconst, ordering, nconst, @category, @job, @characters)
set
    category = if(@category = '\N', null, @category),
    job = if(@job = '\N', null, @job),
    characters = if(@characters = '\N', null, replace(replace(@characters, '["', ''), '"]', ''));  -- remove enclosing brackets

-- inserting temp table contents into original table;
insert into title_principals select * from temp_princip;

-- DONE
-- import title.episode.tsv
-- delete contents, if any
truncate title_episodes;
load data infile 'D:/EGYETEM/CEU/DE/Uploads/title.episode.tsv'
into table title_episodes
character set utf8mb4
fields terminated by '\t'
lines terminated by '\n'
ignore 1 lines
(tconst, @parent_tconst, @season_number, @episode_number)
set
    parent_tconst = if(@parent_tconst = '\N', null, @parent_tconst),
    season_number = if(@season_number = '\N' or @season_number not regexp '^[0-9]+$', null, cast(@season_number as signed)),  -- check for valid integers
    episode_number = if(@episode_number = '\N' or @episode_number not regexp '^[0-9]+$', null, cast(@episode_number as signed));  -- check for valid integers

-- DONE
-- import title.ratings.tsv
-- delete contents, if any
truncate title_ratings;
load data infile 'D:/EGYETEM/CEU/DE/Uploads/title.ratings.tsv'
into table title_ratings
character set utf8mb4
fields terminated by '\t'
lines terminated by '\n'
ignore 1 lines
(tconst, @average_rating, @num_votes)
set
    average_rating = if(@average_rating = '\N' or @average_rating not regexp '^[0-9]*\.?[0-9]+$', NULL, cast(@average_rating as decimal)),  -- Check for valid float
    num_votes = if(@num_votes = '\N' or @num_votes not regexp '^[0-9]+$', NULL, cast(@num_votes as signed));  -- Check for valid integers

-- DONE
-- import name.basics.tsv
-- increase size of string fields (255 was causing problems)
alter table name_basics modify column primary_profession TEXT;
alter table name_basics modify column known_for_titles TEXT;
-- delete contents, if any
truncate name_basics;

load data infile 'D:/EGYETEM/CEU/DE/Uploads/name.basics.tsv'
into table name_basics
character set utf8mb4
fields terminated by '\t'
lines terminated by '\n'
ignore 1 lines
(nconst, @primary_name, @birth_year, @death_year, @primary_profession, @known_for_titles)
set
    primary_name = if(@primary_name = '\N', NULL, @primary_name),
    birth_year = if(@birth_year = '\N' or @birth_year not regexp '^[0-9]{4}$', NULL, cast(@birth_year as signed)),  -- Check for valid YYYY format
    death_year = if(@death_year = '\N' or @death_year not regexp '^[0-9]{4}$', NULL, cast(@death_year as signed)),  -- Check for valid YYYY format
    primary_profession = if(@primary_profession = '\N', NULL, @primary_profession),
    known_for_titles = if(@known_for_titles = '\N', NULL, @known_for_titles);


-- turning foreign key checks and unique checks back on after all importing is done
set foreign_key_checks = 1;
set unique_checks = 1;