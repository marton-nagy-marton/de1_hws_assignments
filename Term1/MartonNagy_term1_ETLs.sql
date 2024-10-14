/*
Term Project 1
Author: Marton Nagy
Course: Data Engineering 1
Program: Business Analytics MS
--------------------------------------------------
Note: The below script ran without errors on my computer.
However, some statements require a few minutes (no more than 5) to run if you do not have a powerful setup.
If you encounter performance issues while running the script, please consider
cutting the sample size and running the scripts on a smaller sample.
*/
use spotify;
-- Creating the data warehouses and the OLTP to EDW ETLs, then the views based on the DWs

-- general log table for the project, used by stored procedure, triggers and events
drop table if exists messages;
create table messages(message varchar(500));

-- DATA WAREHOUSES
-- First let's create a DW for albums!
drop procedure if exists UpdateAlbumsDW;
delimiter //
create procedure UpdateAlbumsDW(in pr_mode int)
-- pr_mode only controls the log message (initialization (0) or scheduled update (1))
begin
drop table if exists albums_dw;
-- a unique ID is needed so that we can perform deletion with triggers later (same logic for all other DWs)
create table albums_dw (primary key(album_id)) ignore
select
-- album facts
albums.album_id,
album_name,
total_tracks,
album_popularity,
release_date,
album_type,
label,
total_duration_s, -- total duration of the album in sec
-- artist dimension
albums.artist_id,
artist.name,
artist.artist_popularity,
artist.followers,
avg_feat_artist_popularity, -- average of popularity of featuring artists on the album
avg_feat_artist_followers, -- average of followers of featuring artists on the album
count_feat_artist, -- count of featuring artists on the album
-- genre dimension
genres.genre as artist_main_genre,
-- tracks dimension
explicit_tracks_pct,
avg_danceability,
avg_energy,
avg_loudness,
avg_speechiness,
avg_acousticness,
avg_instrumentalness,
avg_liveness,
avg_valence
from (((((albums
left join artist on albums.artist_id = artist.id)
left join (select artist_id, genre_id from artist_to_genre where is_main_genre = 1) as ag on ag.artist_id = artist.id)
left join genres on ag.genre_id = genres.id)
left join (
    select
	feat_artists.album_id,
    avg(feat_artists.artist_popularity) as avg_feat_artist_popularity, 
	avg(feat_artists.followers) as avg_feat_artist_followers, 
	count(distinct feat_artists.artist_id) as count_feat_artist
from
	(select distinct artr.artist_id, a.artist_popularity, a.followers, tral.album_id
	from artist_to_tracks artr
	left join artist a on a.id = artr.artist_id
	left join tracks_to_albums tral on tral.track_id = artr.track_id
	where artr.is_main_artist = 0) as feat_artists
group by album_id
) as feats on albums.album_id = feats.album_id)
left join (
select ta.album_id, sum(t.duration_ms) / 1000 as total_duration_s
	from tracks_to_albums ta
	left join tracks t on ta.track_id = t.id
	group by ta.album_id) as td on albums.album_id = td.album_id)
left join (
select
	album_id,
	avg(is_explicit)*100 as explicit_tracks_pct,
	avg(danceability) as avg_danceability,
	avg(energy) as avg_energy,
    avg(loudness) as avg_loudness,
    avg(speechiness) as avg_speechiness,
    avg(acousticness) as avg_acousticness,
    avg(instrumentalness) as avg_instrumentalness,
    avg(liveness) as avg_liveness,
    avg(valence) as avg_valence
from
	tracks_to_albums
    left join tracks on tracks_to_albums.track_id = tracks.id
group by album_id
) as track_avgs on albums.album_id = track_avgs.album_id;

-- logging into messages
if pr_mode = 0 then -- initialization mode
	insert into messages
    select concat(now(), ': added ', (select count(*) from albums_dw), ' rows to abums_dw on initialization.');
else -- update mode
	insert into messages
    select concat(now(), ': re-initialized albums_dw on scheduled update, added ', (select count(*) from albums_dw), ' rows.');
end if;
end //
delimiter ;

-- now we can initialize the albums DW
-- takes around 90 secs with 1 GB RAM allocated to server
call UpdateAlbumsDW(0);
select * from messages;

-- Now we have a functioning DW on albums. Let's move on to tracks!
drop procedure if exists UpdateTracksDW;
delimiter //
create procedure UpdateTracksDW(in pr_mode int)
begin
drop table if exists tracks_dw;
create table tracks_dw (primary key (id)) ignore
select
-- tracks facts
	tracks.id as id,
    track_name,
    track_popularity,
    is_explicit,
    danceability,
    energy,
    key_signature,
    loudness,
    mode,
    speechiness,
    acousticness,
    instrumentalness,
    liveness,
    valence,
    tempo,
    duration_ms / 1000 as duration_s,
    time_signature,
-- albums dimension
    albums.album_name,
    albums.total_tracks,
    albums.release_date,
    albums.album_popularity,
    album_aggregates.album_duration_s,
    album_aggregates.albumtracks_avg_popularity,
-- artist dimension
    main_artist.name as main_artist_name,
    avg(if(artist_to_tracks.is_main_artist = 1, artist.artist_popularity, null)) as main_artist_popularity,
    avg(if(artist_to_tracks.is_main_artist = 1, artist.followers, null)) as main_artist_followers,
	avg(if(artist_to_tracks.is_main_artist = 0, artist.artist_popularity, null)) as feat_artist_avg_popularity,
    avg(if(artist_to_tracks.is_main_artist = 0, artist.followers, null)) as feat_artist_avg_followers,
    sum(if(artist_to_tracks.is_main_artist = 0, 1, 0)) as feat_artist_count,
-- genre dimension
    track_to_genre.genre as main_artist_genre
from (((((((tracks
	left join tracks_to_albums on tracks.id = tracks_to_albums.track_id)
		left join albums on tracks_to_albums.album_id = albums.album_id)
			left join
				(select ta.album_id, sum(t.duration_ms) / 1000 as album_duration_s, avg(t.track_popularity) as albumtracks_avg_popularity
				from tracks_to_albums ta
				inner join tracks t on ta.track_id = t.id
				group by ta.album_id)
				as album_aggregates on album_aggregates.album_id = tracks_to_albums.album_id)
					left join artist_to_tracks on artist_to_tracks.track_id = tracks.id)
						left join artist on artist_to_tracks.artist_id = artist.id)
							left join (
								select distinct tracks.id as track_id, genres.genre from tracks
									left join artist_to_tracks on tracks.id = artist_to_tracks.track_id
                                    left join artist_to_genre on artist_to_tracks.artist_id = artist_to_genre.artist_id
                                    left join genres on artist_to_genre.genre_id = genres.id
                                    where artist_to_tracks.is_main_artist = 1 and artist_to_genre.is_main_genre = 1)
								as track_to_genre on tracks.id = track_to_genre.track_id)
										left join (select tracks.id as track_id, artist.id as artist_id, artist.name from tracks
												left join artist_to_tracks on artist_to_tracks.track_id = tracks.id
												left join artist on artist_to_tracks.artist_id = artist.id
                                                where artist_to_tracks.is_main_artist = 1)
										as main_artist on tracks.id = main_artist.track_id)
group by tracks.id,
albums.album_name,
albums.total_tracks,
albums.release_date,
albums.album_popularity,
album_aggregates.album_duration_s,
album_aggregates.albumtracks_avg_popularity,
main_artist.name,
track_to_genre.genre;

-- logging into messages
if pr_mode = 0 then -- initialization mode
	insert into messages
    select concat(now(), ': added ', (select count(*) from tracks_dw), ' rows to tracks_dw on initialization.');
else -- update mode
	insert into messages
    select concat(now(), ': re-initialized tracks_dw on scheduled update, added ', (select count(*) from tracks_dw), ' rows.');
end if;
end //
delimiter ;

-- again, initialize the tracks DW
-- takes around 300 secs with 1 GB RAM allocated to server (tracks is by far tha largest table in my database)
call UpdateTracksDW(0);
select * from messages;

-- Let's move on to artists and the respective data warehouse! The logic is the same as previously.
drop procedure if exists UpdateArtistDW;
delimiter //
create procedure UpdateArtistDW(in pr_mode int)
begin
drop table if exists artist_dw;
create table artist_dw (primary key (artist_id)) ignore
select
	-- artist facts
	artist.id as artist_id,
    artist.name as artist_name,
    artist_popularity,
    followers,
    -- tracks dimension
    main_songs_popularity,
    feat_songs_popularity,
    main_songs_count,
    feat_songs_count,
	avg_popularity_no_feat, -- average popularity of songs where there is no featuring artist
    avg_popularity_with_feat, -- average popularity of songs where there are featuring artists
    avg_popularity_with_high_follower_feat, -- average popularity of songs where there is a highly followed featuring artists
											-- see definition below
    -- albums dimension
    albums_count,
    avg_albums_popularity, -- average popularity of artist's albums
    -- genres dimension
    sub_genres_count, -- artist's number of subgenres
    main_genre
from artist
left join (
-- aggregate artist's songs
select
	artist_id,
    avg(if(is_main_artist = 1, tracks.track_popularity, null)) as main_songs_popularity,
    avg(if(is_main_artist = 0, tracks.track_popularity, null)) as feat_songs_popularity,
	count(if(is_main_artist = 1, artist_to_tracks.track_id, null)) as main_songs_count,
    count(if(is_main_artist = 0, artist_to_tracks.track_id, null)) as feat_songs_count
from
	artist_to_tracks left join tracks on tracks.id = artist_to_tracks.track_id
group by artist_id
) as mf_agg on mf_agg.artist_id = artist.id
left join (
-- aggregate artist's albums
select
	artist.id,
    count(albums.album_id) as albums_count,
    avg(albums.album_popularity) as avg_albums_popularity
from artist left join albums on artist.id = albums.artist_id
group by artist.id
) as alb_agg on alb_agg.id = artist.id
left join (
-- aggregate artist's subgenres
select
	artist_id,
    count(if(is_main_genre = 0, genre_id, null)) as sub_genres_count
from artist_to_genre
group by artist_id
) as sg_c on sg_c.artist_id = artist.id
left join (
-- select artist's main genre
select
	artist_id,
	genres.genre as main_genre
from artist_to_genre left join genres on genre_id = genres.id
where is_main_genre = 1
) as mg on mg.artist_id = artist.id
left join (
-- aggregate song's popularity based on featuring artists
select 
	main_artist.id as artist_id, 
	main_artist.name as artist_name,
	avg(if(feat_artists.featuring = 0, t.track_popularity, null)) as avg_popularity_no_feat,
	avg(if(feat_artists.featuring > 0, t.track_popularity, null)) as avg_popularity_with_feat,  -- average popularity with any featuring artist
	avg(if(feat_artists.featuring > 0 and feat_artists.high_follower_feat = 1, t.track_popularity, null)) as avg_popularity_with_high_follower_feat -- high-follower artist (at least double)
	from 
		artist main_artist left join 
		artist_to_tracks main_artist_tracks on main_artist.id = main_artist_tracks.artist_id and main_artist_tracks.is_main_artist = 1 left join 
		tracks t on t.id = main_artist_tracks.track_id left join (
			select 
				artr.track_id, 
				count(if(artr.is_main_artist = 0, 1, null)) as featuring,
				max(if(a.followers >= 2 * main_artist.followers, 1, 0)) as high_follower_feat -- high follower defined as at least double the main artist's follower count
			from 
				artist_to_tracks artr inner join 
				artist a on a.id = artr.artist_id inner join 
				artist main_artist on main_artist.id = artr.artist_id -- to get the main artist's followers for comparison
			group by artr.track_id) as feat_artists on feat_artists.track_id = t.id
	group by main_artist.id, main_artist.name
) as feat_art_agg on feat_art_agg.artist_id = artist.id;

-- logging into messages
if pr_mode = 0 then -- initialization mode
	insert into messages
    select concat(now(), ': added ', (select count(*) from artist_dw), ' rows to artist_dw on initialization.');
else -- update mode
	insert into messages
    select concat(now(), ': re-initialized artist_dw on scheduled update, added ', (select count(*) from artist_dw), ' rows.');
end if;
end //
delimiter ;

-- initialize the artist DW
-- Takes around 120 secs with 1 GB RAM allocated to server.
call UpdateArtistDW(0);
select * from messages;

-- Lastly, let's create the data warehouse on genres!
drop procedure if exists UpdateGenresDW;
delimiter //
create procedure UpdateGenresDW(in pr_mode int)
begin
drop table if exists genres_dw;
create table genres_dw (primary key (genre_id)) ignore
select
	genres.id as genre_id,
    genre,
    -- album counts in main and subgenres, based on album's artist
    albums_in_genre_main,
    albums_in_genre_sub,
    -- album popularity averages in main and subgenres, based on albums's artist
    albums_in_genre_main_popularity_avg,
    albums_in_genre_sub_popularity_avg,
    -- artist count that have the genre as main genre / subgenre
    artist_in_genre_main,
    artist_in_genre_sub,
    -- average popularity of artists that have the genre as main genre / subgenre
    artist_in_genre_main_popularity_avg,
    artist_in_genre_sub_popularity_avg,
    -- total follower count of artists that have the genre as main genre / subgenre
    artist_in_genre_main_foll_sum,
    artist_in_genre_sub_foll_sum,
    -- tracks count in main and subgenres, based on track's artists
    tracks_in_genre_main,
    tracks_in_genre_sub,
    -- tracks average popularity in main and subgenres, based on track's artists
    tracks_in_genre_main_popularity_avg,
    tracks_in_genre_sub_popularity_avg,
    -- ratio of explicit tracks in main and subgenres, based on track's artists
    tracks_in_genre_main_explicit_pct,
    tracks_in_genre_sub_explicit_pct
from genres
left join (
-- aggregate on albums
select
	genre_id,
    count(if(is_main_genre = 1, 1, null)) as albums_in_genre_main,
    count(if(is_main_genre = 0, 1, null)) as albums_in_genre_sub,
	avg(if(is_main_genre = 1, album_popularity, null)) as albums_in_genre_main_popularity_avg,
    avg(if(is_main_genre = 0, album_popularity, null)) as albums_in_genre_sub_popularity_avg
from artist_to_genre
	left join albums on artist_to_genre.artist_id = albums.artist_id
group by genre_id
) as genre_album on genre_album.genre_id = genres.id
left join (
-- aggregate on artists
select
	genre_id,
    count(if(is_main_genre = 1, 1, null)) as artist_in_genre_main,
    count(if(is_main_genre = 0, 1, null)) as artist_in_genre_sub,
	avg(if(is_main_genre = 1, artist_popularity, null)) as artist_in_genre_main_popularity_avg,
    avg(if(is_main_genre = 0, artist_popularity, null)) as artist_in_genre_sub_popularity_avg,
	sum(if(is_main_genre = 1, followers, null)) as artist_in_genre_main_foll_sum,
    sum(if(is_main_genre = 0, followers, null)) as artist_in_genre_sub_foll_sum
from artist_to_genre
	left join artist on artist_to_genre.artist_id = artist.id
group by genre_id
) as genre_artist on genre_artist.genre_id = genres.id
left join (
-- aggregate on tracks
select
	genre_id,
    count(if(is_main_genre = 1, 1, null)) as tracks_in_genre_main,
    count(if(is_main_genre = 0, 1, null)) as tracks_in_genre_sub,
	avg(if(is_main_genre = 1, track_popularity, null)) as tracks_in_genre_main_popularity_avg,
    avg(if(is_main_genre = 0, track_popularity, null)) as tracks_in_genre_sub_popularity_avg,
	avg(if(is_main_genre = 1, is_explicit, null)) * 100 as tracks_in_genre_main_explicit_pct,
    avg(if(is_main_genre = 0, is_explicit, null)) * 100 as tracks_in_genre_sub_explicit_pct
from artist_to_genre
	left join artist_to_tracks on artist_to_genre.artist_id = artist_to_tracks.artist_id
    left join tracks on artist_to_tracks.track_id = tracks.id
group by genre_id
) as genre_tracks on genre_tracks.genre_id = genres.id;

-- logging into messages
if pr_mode = 0 then -- initialization mode
	insert into messages
    select concat(now(), ': added ', (select count(*) from genres_dw), ' rows to genres_dw on initialization.');
else -- update mode
	insert into messages
    select concat(now(), ': re-initialized genres_dw on scheduled update, added ', (select count(*) from genres_dw), ' rows.');
end if;
end //
delimiter ;

-- Takes around 30 secs with 1 GB RAM allocated to server.
call UpdateGenresDW(0);
select * from messages;

-- DELETION TRIGGERS
-- create trigger for deletion from albums
drop trigger if exists on_albums_delete;
delimiter //
create trigger on_albums_delete
after delete
on albums for each row
begin
	-- logging into messages
	insert into messages select concat(now(), ': deleted data on album ID ', old.album_id, ' from albums_dw.');
	-- deletion from albums_dw
    delete from albums_dw where album_id = old.album_id;
end //
delimiter ;

-- create trigger for deletion from artist
drop trigger if exists on_artist_delete;
delimiter //
create trigger on_artist_delete
after delete
on artist for each row
begin
	-- logging into messages
	insert into messages select concat(now(), ': deleted data on artist ID ', old.id, ' from artist_dw.');
	-- deletion from artist_dw
    delete from artist_dw where artist_id = old.id;
end //
delimiter ;

-- create trigger for deletion from tracks
drop trigger if exists on_tracks_delete;
delimiter //
create trigger on_tracks_delete
after delete
on tracks for each row
begin
	-- logging into messages
	insert into messages select concat(now(), ': deleted data on tracks ID ', old.id, ' from tracks_dw.');
	-- deletion from tracks_dw
    delete from tracks_dw where track_id = old.id;
end //
delimiter ;

-- create trigger for deletion from genres
drop trigger if exists on_genres_delete;
delimiter //
create trigger on_genres_delete
after delete
on genres for each row
begin
	-- logging into messages
	insert into messages select concat(now(), ': deleted data on genres ID ', old.id, ' from genres_dw.');
	-- deletion from genres_dw
    delete from genres_dw where genre_id = old.id;
end //
delimiter ;


-- UPDATE ALL DWs EVENT
set global event_scheduler = on;
drop event if exists UpdateAllDWEvent;
delimiter //
-- this event re-initializes all DWs once every day during lunch break to keep track of changes
-- it might have been better to use triggers and update all DWs on insertion, deletion, and update on every table
-- but that solution was a bit over my knowledge :)
create event UpdateAllDWEvent
on schedule every 24 hour
starts '2024-10-11 12:30:00'
ends '2024-10-11 12:30:00' + interval 2 month
do
	begin
		-- I want this to appear on the screen directly, that is why I am not inserting into messages.
        -- So that the user is aware what is happening.
		select 'Attention: Now re-initializing all DWs on scheduled update! Some tables may be locked during the update.';
        insert into messages select concat(now(), ': starting the scheduled UpdateAllDWEvent...');
        call UpdateAlbumsDW(1);
        call UpdateArtistDW(1);
        call UpdateTracksDW(1);
        call UpdateGenresDW(1);
        insert into messages select concat(now(), ': scheduled UpdateAllDWEvent happened successfully.');
        select 'Scheduled update finished!';
	end //
delimiter ;

-- DATA MARTS
-- Q1: What are the determinant factors of an album's popularity in the pop genres?
drop view if exists pop_albums;
create view pop_albums as
select
	album_id,
    album_name,
    total_tracks,
    album_popularity,
    year(release_date) as release_year,
    month(release_date) as release_month,
    day(release_date) as release_day,
    dayofweek(release_date) as release_dayofweek,
    time(release_date) as release_time,
    album_type,
    label,
	artist_id,
    name,
    artist_popularity,
    followers,
	avg_feat_artist_popularity, 
	avg_feat_artist_followers, 
	count_feat_artist,
    artist_main_genre,
	explicit_tracks_pct,
	avg_danceability,
	avg_energy,
    avg_loudness,
    avg_speechiness,
    avg_acousticness,
    avg_instrumentalness,
    avg_liveness,
    avg_valence,
    total_duration_s
from albums_dw
where artist_main_genre like '%pop%'
order by album_popularity desc;

select * from pop_albums;

-- Q2: How does albums' popularity differ between between songs from 2010 to 2015 and 2016 to 2023?
drop view if exists albums_popularity_date;
create view albums_popularity_date as
select
	if(year(release_date) >= 2010 and year(release_date) <= 2015, '2010-2015',
		if(year(release_date) >= 2016 and year(release_date) <= 2023,'2016-2013', null)) as release_year_category,
	avg(album_popularity) as avg_album_popularity,
    std(album_popularity) as std_album_popularity,
    min(album_popularity) as min_album_popularity,
    max(album_popularity) as max_album_popularity,
    count(album_popularity) as count_album_popularity
from albums_dw
group by release_year_category
having release_year_category is not null;

select * from albums_popularity_date;

-- Q3: What are the determinant factors of Taylor Swift's songs - that is
-- what kind of songs should she produce to maximize popularity?
drop view if exists taylor_swift_songs;
create view taylor_swift_songs as
select
	track_name,
    track_popularity,
    is_explicit,
    danceability,
    energy,
    key_signature,
    loudness,
    mode,
    speechiness,
    acousticness,
    instrumentalness,
    liveness,
    valence,
    tempo,
    duration_s,
    time_signature,
    album_duration_s,
    feat_artist_avg_popularity,
    feat_artist_avg_followers,
    feat_artist_count,
    year(release_date) as release_year,
    month(release_date) as release_month,
    day(release_date) as release_day,
    dayofweek(release_date) as release_dayofweek,
    time(release_date) as release_time
from tracks_dw
where main_artist_name = 'Taylor Swift'
order by track_popularity desc;

select * from taylor_swift_songs;

-- Q4: How did the average valence of songs evolve over time?
-- Is there a pattern, or at least some bumps that we might attribute to major world events?
drop view if exists valence_ts;
create view valence_ts as
select
    year(release_date) as release_year,
    month(release_date) as release_month,
    count(id) as count_songs,
	avg(valence)
from tracks_dw
where year(release_date) is not null and month(release_date) is not null
group by release_year, release_month
order by release_year, release_month;

select * from valence_ts;

-- Q5: Does an artist's follower count influence the popularity of their songs?
drop view if exists artist_followers_popularity;
create view artist_followers_popularity as
select
	artist_id,
    artist_name,
    artist_popularity,
    followers
from artist_dw
order by artist_popularity desc, followers desc;

select * from artist_followers_popularity;

-- Q6: Does having a high-follower count featuring artist increase the popularity of an artist's song
-- relative to where there is no featuring artist?
drop view if exists feat_effects;
create view feat_effects as
select
	artist_id,
    artist_name,
    avg_popularity_no_feat,
    avg_popularity_with_feat,
    avg_popularity_with_high_follower_feat
from artist_dw
order by avg_popularity_no_feat desc, avg_popularity_with_feat desc, avg_popularity_with_high_follower_feat desc;

select * from feat_effects;

-- Q7: What are the genres that are very popular but don't have many songs - that is,
-- what kind of genres should we produce if we want high popularity and low competition?
drop view if exists genre_niche;
create view genre_niche as
select
	genre_id,
    genre,
    tracks_in_genre_main,
    tracks_in_genre_sub,
    -- popularity is taken on song level (could be also artist or album)
    tracks_in_genre_main_popularity_avg,
    tracks_in_genre_sub_popularity_avg
from genres_dw
where tracks_in_genre_main + tracks_in_genre_sub
	-- not many songs is defines as above 50 but below the average songs per genre
	between 50 and (select avg(tracks_in_genre_main + tracks_in_genre_sub) as avg_total from genres_dw)
order by tracks_in_genre_main_popularity_avg desc, tracks_in_genre_sub_popularity_avg desc;

select * from genre_niche;

-- Q8: Are certain genres associated with more explicit language?
drop view if exists explicit_genres;
create view explicit_genres as
select
	genre_id,
    genre,
    tracks_in_genre_main_explicit_pct,
    tracks_in_genre_sub_explicit_pct
from genres_dw
order by (tracks_in_genre_main_explicit_pct * tracks_in_genre_main
			+ tracks_in_genre_sub_explicit_pct * tracks_in_genre_sub) /
            (tracks_in_genre_main + tracks_in_genre_sub) desc;

select * from explicit_genres;

-- EXTRA: Materialized views for first 2 questions
drop procedure if exists UpdateMVPopAlbums;
delimiter //
create procedure UpdateMVPopAlbums()
begin
	drop table if exists mv_pop_albums;
    create table mv_pop_albums as
		select
			album_id,
			album_name,
			total_tracks,
			album_popularity,
			year(release_date) as release_year,
			month(release_date) as release_month,
			day(release_date) as release_day,
			dayofweek(release_date) as release_dayofweek,
			time(release_date) as release_time,
			album_type,
			label,
			artist_id,
			name,
			artist_popularity,
			followers,
			avg_feat_artist_popularity, 
			avg_feat_artist_followers, 
			count_feat_artist,
			artist_main_genre,
			explicit_tracks_pct,
			avg_danceability,
			avg_energy,
			avg_loudness,
			avg_speechiness,
			avg_acousticness,
			avg_instrumentalness,
			avg_liveness,
			avg_valence,
			total_duration_s
	from albums_dw
	where artist_main_genre like '%pop%'
	order by album_popularity desc;
    
    insert into messages select concat(now(), ': updated the mv_pop_albums materialized view.');
end //
delimiter ;

call UpdateMVPopAlbums();

drop procedure if exists UpdateMVAlbumsPopularityDate;
delimiter //
create procedure UpdateMVAlbumsPopularityDate()
begin
drop table if exists mv_albums_popularity_date;
create table mv_albums_popularity_date as
select
	if(year(release_date) >= 2010 and year(release_date) <= 2015, '2010-2015',
		if(year(release_date) >= 2016 and year(release_date) <= 2023,'2016-2013', null)) as release_year_category,
	avg(album_popularity) as avg_album_popularity,
    std(album_popularity) as std_album_popularity,
    min(album_popularity) as min_album_popularity,
    max(album_popularity) as max_album_popularity,
    count(album_popularity) as count_album_popularity
from albums_dw
group by release_year_category
having release_year_category is not null;

insert into messages select concat(now(), ': updated the mv_albums_popularity_date materialized view.');
end //
delimiter ;

call UpdateMVAlbumsPopularityDate();

-- event to update the materialized views daily at midnight
drop event if exists UpdateMVs;
delimiter //
create event UpdateMVs
on schedule every 24 hour
starts '2024-10-11 00:00:00'
ends '2024-10-11 00:00:00' + interval 2 month
do
	begin
		select 'Updating materialized views, tables may be locked!';
        insert into messages select concat(now(), ': scheduled update of materialized views started.');
		call UpdateMVPopAlbums();
        call UpdateMVAlbumsPopularityDate();
        insert into messages select concat(now(), ': scheduled update of materialized views finished.');
        select 'Successfully updated materialized views.';
	end //
delimiter ;