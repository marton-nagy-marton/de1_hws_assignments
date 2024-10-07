/*
Term Project 1
Author: Márton Nagy
Course: Data Engineering 1
Program: Business Analytics MS
*/

-- CREATE SCHEMA
-- create schema for database
drop schema if exists spotify;
create schema if not exists spotify
-- charset is set to this to allow for a wide range of characters from practically all languages
default character set utf8mb4
collate utf8mb4_unicode_ci;

-- use created database
use spotify;


-- CREATE TABLES
-- Table: tracks
drop table tracks;
create table tracks (
    id varchar(255) primary key,
    track_popularity int,
    is_explicit tinyint(1)           -- Changed `explicit` to `is_explicit` to not collide with SQL keyword
) default character set = utf8mb4 collate = utf8mb4_unicode_ci;

-- Table: artist
create table artist (
    id varchar(255) primary key,
    name varchar(255),
    artist_popularity int,
    artist_genres varchar(255),
    followers int,
    genre_0 varchar(255),
    genre_1 varchar(255),
    genre_2 varchar(255),
    genre_3 varchar(255),
    genre_4 varchar(255),
    genre_5 varchar(255),
    genre_6 varchar(255)
) default character set = utf8mb4 collate = utf8mb4_unicode_ci;

-- Table: features
create table features (
    id varchar(255) primary key,
    danceability decimal(20,10),
    energy decimal(20,10),
    key_signature int,          -- Changed `key` to `key_signature` to not collide with SQL keyword
    loudness decimal(20,10),
    mode int,
    speechiness decimal(20,10),
    acousticness decimal(20,10),
    instrumentalness decimal(20,10),
    liveness decimal(20,10),
    valence decimal(20,10),
    tempo decimal(20,10),
    feature_type varchar(255),  -- Changed `type` to `feature_type` to not collide with SQL keyword
    uri varchar(255),
    track_href varchar(255),
    analysis_url varchar(255),
    duration_ms int,
    time_signature int,
	foreign key (id) references tracks(id)
        on delete no action
        on update no action
)
default character set = utf8mb4 collate = utf8mb4_unicode_ci;

-- Table: albums
create table albums (
    track_name text,
    track_id varchar(255),
    track_number int,
    duration_ms int,
    album_type varchar(255),
    artists varchar(255),
    total_tracks int,
    album_name text,
    release_date datetime,
    label varchar(255),
    album_popularity int,
    album_id varchar(255),
    artist_id varchar(255),
    artist_0 varchar(255),
    artist_1 varchar(255),
    artist_2 varchar(255),
    artist_3 varchar(255),
    artist_4 varchar(255),
    artist_5 varchar(255),
    artist_6 varchar(255),
    artist_7 varchar(255),
    artist_8 varchar(255),
    artist_9 varchar(255),
    artist_10 varchar(255),
    artist_11 varchar(255),
    duration_sec float,
    primary key (album_id, track_id),
    foreign key (artist_id) references artist(id)
        on delete no action
        on update no action,
    foreign key (track_id) references tracks(id)
        on delete no action
        on update no action
) default character set = utf8mb4 collate = utf8mb4_unicode_ci;

-- LOAD DATA INTO TABLES
-- NOTE: when using the load statements, do not forget to set the file paths to your local ones!

-- disable these temporarily to allow for faster load data statements
set foreign_key_checks = 0;
set unique_checks = 0;

-- Load data into artist table
load data infile 'D:/EGYETEM/CEU/DE/Uploads/spotify_artist_data_2023.csv'
into table artist
fields terminated by ',' enclosed by '"'
lines terminated by '\n'
ignore 1 lines
(id, name, @artist_popularity, artist_genres, @followers, @genre_0, @genre_1, @genre_2, @genre_3, @genre_4, @genre_5, @genre_6)
set
	-- using regexp to test for numeric values
    artist_popularity = if(@artist_popularity regexp '^[0-9]+$', cast(@artist_popularity as signed), null),
    followers = if(@followers regexp '^[0-9]+$', cast(@followers as signed), null),
    -- setting empty strings to null
    genre_0 = if(@genre_0 = '', null, @genre_0),
	genre_1 = if(@genre_1 = '', null, @genre_1),
	genre_2 = if(@genre_2 = '', null, @genre_2),
    genre_3 = if(@genre_3 = '', null, @genre_3),
    genre_4 = if(@genre_4 = '', null, @genre_4),
    genre_5 = if(@genre_5 = '', null, @genre_5),
    genre_6 = if(@genre_6 = '', null, @genre_6);

-- Load data into features table
load data infile 'D:/EGYETEM/CEU/DE/Uploads/spotify_features_data_2023.csv'
into table features
fields terminated by ','
lines terminated by '\n'
ignore 1 lines
(@danceability, @energy, @key_signature, @loudness, @mode, @speechiness, @acousticness, @instrumentalness, @liveness, @valence, @tempo, feature_type, id, uri, track_href, analysis_url, @duration_ms, @time_signature)
set
	-- checking decimals for correct format, allow for negatives and scientific notation
    danceability = if(@danceability regexp '^-?[0-9]+(\.[0-9]+)?([eE][-+]?[0-9]+)?$', cast(@danceability as decimal(20,10)), null),
    energy = if(@energy regexp '^-?[0-9]+(\.[0-9]+)?([eE][-+]?[0-9]+)?$', cast(@energy as decimal(20,10)), null),
    key_signature = if(@key_signature regexp '^-?[0-9]+$', cast(@key_signature as signed), null),
    loudness = if(@loudness regexp '^-?[0-9]+(\.[0-9]+)?([eE][-+]?[0-9]+)?$', cast(@loudness as decimal(20,10)), null),
    -- mode can either be 1 or 0
    mode = if(@mode regexp '^[0-1]$', cast(@mode as signed), null),
    speechiness = if(@speechiness regexp '^-?[0-9]+(\.[0-9]+)?([eE][-+]?[0-9]+)?$', cast(@speechiness as decimal(20,10)), null),
    acousticness = if(@acousticness regexp '^-?[0-9]+(\.[0-9]+)?([eE][-+]?[0-9]+)?$', cast(@acousticness as decimal(20,10)), null),
    instrumentalness = if(@instrumentalness regexp '^-?[0-9]+(\.[0-9]+)?([eE][-+]?[0-9]+)?$', cast(@instrumentalness as decimal(20,10)), null),
    liveness = if(@liveness regexp '^-?[0-9]+(\.[0-9]+)?([eE][-+]?[0-9]+)?$', cast(@liveness as decimal(20,10)), null),
    valence = if(@valence regexp '^-?[0-9]+(\.[0-9]+)?([eE][-+]?[0-9]+)?$', cast(@valence as decimal(20,10)), null),
    tempo = if(@tempo regexp '^-?[0-9]+(\.[0-9]+)?([eE][-+]?[0-9]+)?$', cast(@tempo as decimal(20,10)), null),
    duration_ms = if(@duration_ms regexp '^[0-9]+$', cast(@duration_ms as signed), null),
    time_signature = if(@time_signature regexp '^[0-9]+$', cast(@time_signature as signed), null);

-- Load data into tracks table
load data infile 'D:/EGYETEM/CEU/DE/Uploads/spotify_tracks_data_2023.csv'
into table tracks
fields terminated by ',' 
lines terminated by '\n'
ignore 1 lines
(id, @track_popularity, @is_explicit)
set
    track_popularity = if(@track_popularity regexp '^[0-9]+$', cast(@track_popularity as signed), null),
    -- casting true and false strings to tinyint(1)
    is_explicit = if(@is_explicit regexp '^(true|false)$', if(@is_explicit = "true", 1, 0), null);

-- Load data into albums table
truncate albums;
load data infile 'D:/EGYETEM/CEU/DE/Uploads/spotify-albums_data_2023.csv'
into table albums
fields terminated by ',' enclosed by '"'
lines terminated by '\n'
ignore 1 lines
(track_name, track_id, @track_number, @duration_ms, album_type, artists, @total_tracks, album_name, @release_date, label, @album_popularity, album_id, artist_id, @artist_0, @artist_1, @artist_2, @artist_3, @artist_4, @artist_5, @artist_6, @artist_7, @artist_8, @artist_9, @artist_10, @artist_11, @duration_sec)
set
    track_number = if(@track_number regexp '^[0-9]+$', cast(@track_number as signed), null),
    duration_ms = if(@duration_ms regexp '^[0-9]+$', cast(@duration_ms as signed), null),
    total_tracks = if(@total_tracks regexp '^[0-9]+$', cast(@total_tracks as signed), null),
    -- checking for assumed datetime format, trimming UTC from the end
	release_date = if(@release_date regexp '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} UTC$', str_to_date(trim(trailing ' UTC' from @release_date), '%Y-%m-%d %H:%i:%s'), null),
    album_popularity = if(@album_popularity regexp '^[0-9]+$', cast(@album_popularity as signed), null),
    duration_sec = if(@duration_sec regexp '^[0-9]+(\.[0-9]+)?$', cast(@duration_sec as decimal(10,5)), null),
    -- setting empty strings to null
    artist_0 = if(@artist_0 = '', null, @artist_0),
    artist_1 = if(@artist_1 = '', null, @artist_1),
    artist_2 = if(@artist_2 = '', null, @artist_2),
    artist_3 = if(@artist_3 = '', null, @artist_3),
    artist_4 = if(@artist_4 = '', null, @artist_4),
    artist_5 = if(@artist_5 = '', null, @artist_5),
    artist_6 = if(@artist_6 = '', null, @artist_6),
    artist_7 = if(@artist_7 = '', null, @artist_7),
    artist_8 = if(@artist_8 = '', null, @artist_8),
    artist_9 = if(@artist_9 = '', null, @artist_9),
    artist_10 = if(@artist_10 = '', null, @artist_10),
    artist_11 = if(@artist_11 = '', null, @artist_11);
    
-- turning these options back on
set foreign_key_checks = 1;
set unique_checks = 1;

-- NORMALIZE TABLE STRUCTURE

-- create a table to collect all the different genres listed in artist table last 7 fields
create table genres_temp(
genre VARCHAR(255));

insert into genres_temp select distinct genre_0 from artist where genre_0 is not null;
insert into genres_temp select distinct genre_1 from artist where genre_1 is not null;
insert into genres_temp select distinct genre_2 from artist where genre_2 is not null;
insert into genres_temp select distinct genre_3 from artist where genre_3 is not null;
insert into genres_temp select distinct genre_4 from artist where genre_4 is not null;
insert into genres_temp select distinct genre_5 from artist where genre_5 is not null;
insert into genres_temp select distinct genre_6 from artist where genre_6 is not null;

-- insert unique values into table with id
create table genres(
id int auto_increment not null primary key,
genre varchar(255));

insert into genres (genre) select distinct genre from genres_temp;

-- drop temporary table
drop table genres_temp;

-- create junction table matching artists to genres
create table artist_to_genre(
artist_id varchar(22),
genre_id int,
is_main_genre tinyint(1),
primary key (artist_id, genre_id));

-- if an artist has a genre in genre_0, it is main genre
insert into artist_to_genre
select artist.id, genres.id, 1 as is_main from
artist inner join genres
on genre_0 = genre;
-- if an artist has a genre in any other genre column, it is not a main genre
insert into artist_to_genre
select artist.id, genres.id, 0 as is_main from
artist inner join genres
on genre_1 = genre
where genre_1 is not null;

insert into artist_to_genre
select artist.id, genres.id, 0 as is_main from
artist inner join genres
on genre_2 = genre
where genre_2 is not null;

insert into artist_to_genre
select artist.id, genres.id, 0 as is_main from
artist inner join genres
on genre_3 = genre
where genre_3 is not null;

insert into artist_to_genre
select artist.id, genres.id, 0 as is_main from
artist inner join genres
on genre_4 = genre
where genre_4 is not null;

insert into artist_to_genre
select artist.id, genres.id, 0 as is_main from
artist inner join genres
on genre_5 = genre
where genre_5 is not null;

insert into artist_to_genre
select artist.id, genres.id, 0 as is_main from
artist inner join genres
on genre_6 = genre
where genre_6 is not null;

-- create relations with artist and genres tables
CREATE UNIQUE INDEX `idx_artist_id`  ON `spotify`.`artist` (id) COMMENT '' ALGORITHM DEFAULT LOCK DEFAULT;
CREATE UNIQUE INDEX `idx_genres_id`  ON `spotify`.`genres` (id) COMMENT '' ALGORITHM DEFAULT LOCK DEFAULT;

alter table artist_to_genre
add constraint `fk_artist`
foreign key (artist_id)
references artist(id)
on delete no action
on update no action;

alter table artist_to_genre
add constraint `fk_genres`
foreign key (genre_id)
references genres(id)
on delete no action
on update no action;

-- drop the columns from artist table which are now represented in a better form
alter table artist
drop column artist_genres,
drop column genre_0,
drop column genre_1,
drop column genre_2,
drop column genre_3,
drop column genre_4,
drop column genre_5,
drop column genre_6;

-- create a new table to collect all the fields that are related to tracks
create table tracks_revised(
    id varchar(255) primary key,
    track_popularity int,
    is_explicit tinyint(1),
	danceability decimal(20,10),
    energy decimal(20,10),
    key_signature int,
    loudness decimal(20,10),
    mode int,
    speechiness decimal(20,10),
    acousticness decimal(20,10),
    instrumentalness decimal(20,10),
    liveness decimal(20,10),
    valence decimal(20,10),
    tempo decimal(20,10),
    feature_type varchar(255),
    uri varchar(255),
    track_href varchar(255),
    analysis_url varchar(255),
    duration_ms int,
    time_signature int,
    track_name text,
    artists varchar(255),
    artist_id varchar(255),
    artist_0 varchar(255),
    artist_1 varchar(255),
    artist_2 varchar(255),
    artist_3 varchar(255),
    artist_4 varchar(255),
    artist_5 varchar(255),
    artist_6 varchar(255),
    artist_7 varchar(255),
    artist_8 varchar(255),
    artist_9 varchar(255),
    artist_10 varchar(255),
    artist_11 varchar(255));
    
-- populate this new table by joining existing ones
insert ignore into tracks_revised 
select tracks.id, track_popularity, is_explicit, danceability, energy, key_signature, loudness, mode, speechiness, acousticness,
instrumentalness, liveness, valence, tempo, feature_type, uri, track_href, analysis_url, features.duration_ms, time_signature, track_name,
artists, artist_id, artist_0, artist_1, artist_2, artist_3, artist_4, artist_5, artist_6, artist_7, artist_8, artist_9, artist_10, artist_11
from tracks inner join albums on tracks.id = albums.track_id inner join features on tracks.id = features.id;


-- drop tables and fields now in tracks_revised
set foreign_key_checks = 0;
drop table features;
drop table tracks;
alter table albums
drop column track_name,
drop column artists,
drop column artist_0,
drop column artist_1,
drop column artist_2,
drop column artist_3,
drop column artist_4,
drop column artist_5,
drop column artist_6,
drop column artist_7,
drop column artist_8,
drop column artist_9,
drop column artist_10,
drop column artist_11,
drop column duration_ms,
drop column duration_sec;  -- dropping this too, as it can be easily calculated from duration ms if needed

-- create junction table to match artist to tracks
create table artist_to_tracks(
artist_id varchar(255),
track_id varchar(255),
is_main_artist tinyint(1), -- an artist is the main one if it is located in the artist_0 column
primary key(artist_id, track_id)
);

-- populate junction table by joining tracks_revised's artist fields on artis.name
-- we have to do this for all the 12 artist fields
insert into artist_to_tracks
select distinct artist.id, tracks_revised.id, 1 as is_main from
artist inner join tracks_revised on artist.name = tracks_revised.artist_0
where tracks_revised.artist_0 is not null;

insert ignore into artist_to_tracks
select distinct artist.id, tracks_revised.id, 0 as is_main from
artist inner join tracks_revised on artist.name = tracks_revised.artist_1
where tracks_revised.artist_1 is not null;

insert ignore into artist_to_tracks
select distinct artist.id, tracks_revised.id, 0 as is_main from
artist inner join tracks_revised on artist.name = tracks_revised.artist_2
where tracks_revised.artist_2 is not null;

insert ignore into artist_to_tracks
select distinct artist.id, tracks_revised.id, 0 as is_main from
artist inner join tracks_revised on artist.name = tracks_revised.artist_3
where tracks_revised.artist_3 is not null;

insert ignore into artist_to_tracks
select distinct artist.id, tracks_revised.id, 0 as is_main from
artist inner join tracks_revised on artist.name = tracks_revised.artist_4
where tracks_revised.artist_4 is not null;

insert ignore into artist_to_tracks
select distinct artist.id, tracks_revised.id, 0 as is_main from
artist inner join tracks_revised on artist.name = tracks_revised.artist_5
where tracks_revised.artist_5 is not null;

insert ignore into artist_to_tracks
select distinct artist.id, tracks_revised.id, 0 as is_main from
artist inner join tracks_revised on artist.name = tracks_revised.artist_6
where tracks_revised.artist_6 is not null;

insert ignore into artist_to_tracks
select distinct artist.id, tracks_revised.id, 0 as is_main from
artist inner join tracks_revised on artist.name = tracks_revised.artist_7
where tracks_revised.artist_7 is not null;

insert ignore into artist_to_tracks
select distinct artist.id, tracks_revised.id, 0 as is_main from
artist inner join tracks_revised on artist.name = tracks_revised.artist_8
where tracks_revised.artist_8 is not null;

insert ignore into artist_to_tracks
select distinct artist.id, tracks_revised.id, 0 as is_main from
artist inner join tracks_revised on artist.name = tracks_revised.artist_9
where tracks_revised.artist_9 is not null;

insert ignore into artist_to_tracks
select distinct artist.id, tracks_revised.id, 0 as is_main from
artist inner join tracks_revised on artist.name = tracks_revised.artist_10
where tracks_revised.artist_10 is not null;

insert ignore into artist_to_tracks
select distinct artist.id, tracks_revised.id, 0 as is_main from
artist inner join tracks_revised on artist.name = tracks_revised.artist_11
where tracks_revised.artist_11 is not null;

-- drop those fields that are now represented in the junction table
alter table tracks_revised
drop column artists,
drop column artist_id,
drop column artist_0,
drop column artist_1,
drop column artist_2,
drop column artist_3,
drop column artist_4,
drop column artist_5,
drop column artist_6,
drop column artist_7,
drop column artist_8,
drop column artist_9,
drop column artist_10,
drop column artist_11;

-- rename table to more intuitive one
alter table tracks_revised rename to tracks;

-- add relation to artist table
alter table artist_to_tracks
add constraint `fk_artist_to_tracks_artist`
foreign key (artist_id)
references artist(id)
on delete no action
on update no action;

-- MySQL manual said it is good practice to create indexes on referenced fields before referencing, so I did that
CREATE INDEX `idx_tracks_id`  ON `spotify`.`tracks` (id) COMMENT '' ALGORITHM DEFAULT LOCK DEFAULT;

-- add relation to tracks table
alter table artist_to_tracks
add constraint `fk_artist_to_tracks_tracks`
foreign key (track_id)
references tracks(id)
on delete no action
on update no action;

-- create junction table to match tracks to albums
create table tracks_to_albums(
track_id varchar(255),
album_id varchar(255),
track_number int,
primary key(track_id, album_id));

-- the data is already in the albums table in correct format, so we just insert it
insert into tracks_to_albums
select track_id, album_id, track_number from albums;

-- create new albums table to hold album specific data
create table albums_revised(
    album_type varchar(255),
    total_tracks int,
    album_name text,
    release_date datetime,
    label varchar(255),
    album_popularity int,
    album_id varchar(255),
    artist_id varchar(255),
    primary key (album_id));
    
-- populate this table by selecting distinct album-specific fields from albums 
insert ignore into albums_revised
select distinct album_type, total_tracks, album_name, release_date, label, album_popularity, album_id, artist_id
from albums;

set foreign_key_checks = 0;
-- drop the original albums table
drop table albums;
-- rename new albums table to simply albums
alter table albums_revised rename to albums;

-- add reference to tracks
alter table tracks_to_albums
add constraint `fk_tracks_to_albums_tracks`
foreign key (track_id)
references tracks(id)
on delete no action
on update no action;

CREATE UNIQUE INDEX `idx_albums_album_id`  ON `spotify`.`albums` (album_id) COMMENT '' ALGORITHM DEFAULT LOCK DEFAULT;

-- add reference to albums
alter table tracks_to_albums
add constraint `fk_tracks_to_albums_albums`
foreign key (album_id)
references albums(album_id)
on delete no action
on update no action;

-- add reference to artist for the albums table
alter table albums
add constraint `fk_albums_artists`
foreign key (artist_id)
references artist(id)
on delete no action
on update no action;

-- tunr these variables back on
set foreign_key_checks = 1;
set unique_checks = 1;

-- NORMALIZING TABLES IS NOW DONE!
