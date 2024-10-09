use spotify;
-- Creating the data warehouses and the OLTP to EDW ETLs
-- First, I focus on the albums and their dimensions.
-- Initialize the DW on the topic of albums (we first load existing data into a new table -> this is a one-time operation, so
-- no need to use a stored procedure)

drop procedure if exists CreateAlbumsDW;

delimiter //
create procedure CreateAlbumsDW(in update_albums tinyint(1))
begin
if update_albums = 0 then
drop table if exists albums_dw;
create table albums_dw as
select
	albums.album_id,
    album_name,
    total_tracks,
    album_popularity,
    release_date,
    album_type,
    label,
	albums.artist_id,
    artist.name,
    artist.artist_popularity,
    artist.followers,
	avg(feat_artists.artist_popularity) as avg_feat_artist_popularity, 
	avg(feat_artists.followers) as avg_feat_artist_followers, 
	count(distinct feat_artists.artist_id) as count_feat_artist,
    genres.genre as artist_main_genre,
	avg(is_explicit)*100 as explicit_tracks_pct,
	avg(danceability) as avg_danceability,
	avg(energy) as avg_energy,
    avg(loudness) as avg_loudness,
    avg(speechiness) as avg_speechiness,
    avg(acousticness) as avg_acousticness,
    avg(instrumentalness) as avg_instrumentalness,
    avg(liveness) as avg_liveness,
    avg(valence) as avg_valence,
    total_durations.total_duration_s
	from ((((((((albums
		left join artist on albums.artist_id = artist.id)
			left join (select artist_id, genre_id from artist_to_genre where is_main_genre = 1) as ag on ag.artist_id = artist.id)
				left join genres on ag.genre_id = genres.id)
					left join tracks_to_albums on tracks_to_albums.album_id = albums.album_id)
						left join tracks on tracks_to_albums.track_id = tracks.id)
							left join artist_to_tracks on artist_to_tracks.track_id = tracks.id)
								left join 
									(select ta.album_id, sum(t.duration_ms) / 1000 as total_duration_s
									from tracks_to_albums ta
									inner join tracks t on ta.track_id = t.id
									group by ta.album_id)
								as total_durations on total_durations.album_id = albums.album_id)
								left join (
									select distinct artr.artist_id, a.artist_popularity, a.followers, tral.album_id
									from artist_to_tracks artr
									inner join artist a on a.id = artr.artist_id
									inner join tracks_to_albums tral on tral.track_id = artr.track_id
									where artr.is_main_artist = 0)
								as feat_artists on feat_artists.album_id = albums.album_id)
	group by albums.album_id, artist_main_genre;
else
drop table if exists albums_dw;
create table albums_dw as
select
	albums.album_id,
    album_name,
    total_tracks,
    album_popularity,
    release_date,
    album_type,
    label,
	albums.artist_id,
    artist.name,
    artist.artist_popularity,
    artist.followers,
	avg(feat_artists.artist_popularity) as avg_feat_artist_popularity, 
	avg(feat_artists.followers) as avg_feat_artist_followers, 
	count(distinct feat_artists.artist_id) as count_feat_artist,
    genres.genre as artist_main_genre,
	avg(is_explicit)*100 as explicit_tracks_pct,
	avg(danceability) as avg_danceability,
	avg(energy) as avg_energy,
    avg(loudness) as avg_loudness,
    avg(speechiness) as avg_speechiness,
    avg(acousticness) as avg_acousticness,
    avg(instrumentalness) as avg_instrumentalness,
    avg(liveness) as avg_liveness,
    avg(valence) as avg_valence,
    total_durations.total_duration_s
	from ((((((((albums
		left join artist on albums.artist_id = artist.id)
			left join (select artist_id, genre_id from artist_to_genre where is_main_genre = 1) as ag on ag.artist_id = artist.id)
				left join genres on ag.genre_id = genres.id)
					left join tracks_to_albums on tracks_to_albums.album_id = albums.album_id)
						left join tracks on tracks_to_albums.track_id = tracks.id)
							left join artist_to_tracks on artist_to_tracks.track_id = tracks.id)
								left join 
									(select ta.album_id, sum(t.duration_ms) / 1000 as total_duration_s
									from tracks_to_albums ta
									inner join tracks t on ta.track_id = t.id
									group by ta.album_id)
								as total_durations on total_durations.album_id = albums.album_id)
								left join (
									select distinct artr.artist_id, a.artist_popularity, a.followers, tral.album_id
									from artist_to_tracks artr
									inner join artist a on a.id = artr.artist_id
									inner join tracks_to_albums tral on tral.track_id = artr.track_id
									where artr.is_main_artist = 0)
								as feat_artists on feat_artists.album_id = albums.album_id)
	where albums.album_id = new.album_id
    group by albums.album_id, artist_main_genre;
end if;
end //
delimiter ;
