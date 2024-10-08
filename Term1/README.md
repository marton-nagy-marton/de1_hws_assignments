# Documentation for Term Project 1
Course: Data Engineering 1

Program: Business Analytics MS

Author: Márton Nagy

## Introduction

Spotify holds a vast array of quantitative data on all the tracks, albums and artists uploaded there (e.g. valence of every song, that is their overall positiveness score). These variables can help as draw useful insights on the determinants of e.g. the popularity of a song or an album, the number of followers of an artist, or we can even determine trending genres.

### Analytical questions

Having taken a look at the dataset, I would like to answer the following questions in this project:
1. 
2. 


### Submitted project artifacts and their description

[`spotify_raw_data.zip`](/Term1/spotify_raw_data.zip): The original source CSV files as downloaded from Kaggle. The compressed folder contains the following files: 
* `spotify_artist_data_2023.csv`,
* `spotify_features_data_2023.csv`,
* `spotify_albums_data_2023.csv`,
* `spotify_tracks_data_2023.csv`.

[`normalized_data_dump.zip`](/Term1/normalized_data_dump.zip): Contains a the `normalized_data_dump.sql` dump file. When executed, it creates the structure of the normalized database (see in [Figure 2](#figure-2) and populates it with data. It is recommended to run this script rather than to import all data from the raw files.

[`MartonNagy_term1_from_scratch.sql`](/Term1/MartonNagy_term1_from_scratch.sql): This SQL-script initializes the database structure, populates the original tables with data imported from local CSV files, and then performs some normalization tasks to alter the database structure.
> [!Important]
> If you decide to run this script, please make sure to change the path to the imported files according to your local setup! However, I recommend simply loading the database through the provided SQL dump file for performance purposes.


## Data
### Sources

The database has a single source: a Kaggle dataset repository by the name _Spotify Dataset 2023_. The dataset has been compiled on 2023-12-20 using the Spotify API. It contains data on 438,938 tracks and their respective artists and albums.
The raw CSVs can be downloaded directly from Kaggle: https://www.kaggle.com/datasets/tonygordonjr/spotify-dataset-2023
I have downloaded the files on 2024-10-07.

### Variable description

Variable descriptions were taken directly from Kaggle.

> [!Note]
> The fields and tables listed here correspond to the original dataset structure, as downloaded from the source. I have performed some normalization on these tables, which will be described in detail in the [_Database structure_](#database-structure) chapter. There, I will give a brief description of all the new tables and fields and the rationale.

`albums`:

- `track_name`: Name of the track.

- `track_id`: The Spotify ID for the track.

- `track_number`: The number of the track. If an album has several discs, the track number refers to the number on the specified disc.

- `duration_ms`: The track length in milliseconds.

- `album_type`: The type of the album. Allowed values include: `album`, `single`, `compilation`.

- `artists`: The artists who performed the track.

- `total_tracks`: The number of tracks in the album.

- `album_name`: The name of the album. In case of an album takedown, the value may be an empty string.

- `release_date`: The date the album was first released.

- `label`: The label associated with the album.

- `album_popularity`: The popularity of the album, ranging between 0 and 100, with 100 being the most popular.

- `album_id`: The Spotify ID for the album.

- `artist_id`: The Spotify ID for the artist.

- `artist_0`: Main artist.

- `artist_1`: Featuring artist.

- `artist_2`: Featuring artist.

- `artist_3`: Featuring artist.

- `artist_4`: Featuring artist.

- `artist_5`: Featuring artist.

- `artist_6`: Featuring artist.

- `artist_7`: Featuring artist.

- `artist_8`: Featuring artist.

- `artist_9`: Featuring artist.

- `artist_10`: Featuring artist.

- `artist_11`: Featuring artist.

- `duration_sec`: Track length in seconds.

`artist`:

- `id`: The Spotify ID of the artist.

- `name`: Name of the artist.

- `artist_popularity`: The popularity of the artist, ranging between 0 and 100, with 100 being the most popular. The artist's popularity is calculated based on the popularity of all the artist's tracks.

- `artist_genres`: A list of the genres the artist is associated with. If the artist is not yet classified, this array will be empty.

- `followers`: The total number of followers.

- `genre_0`: Main genre.

- `genre_1`: Sub-genre.

- `genre_2`: Sub-genre.

- `genre_3`: Sub-genre.

- `genre_4`: Sub-genre.

- `genre_5`: Sub-genre.

- `genre_6`: Sub-genre.

`tracks`:

- `id`: The Spotify ID for the track.

- `track_popularity`: The popularity of a track, ranging between 0 and 100, with 100 being the most popular. The popularity is calculated by an algorithm based on the total number of plays and how recent those plays are. Duplicate tracks (e.g., the same track from a single and an album) are rated independently. Artist and album popularity are derived from track popularity.

- `explicit`: Whether the track contains explicit lyrics (`true` = yes, `false` = no or unknown).

`features`:

- `danceability`: Danceability describes how suitable a track is for dancing based on a combination of musical elements including tempo, rhythm stability, beat strength, and overall regularity. A value of 0.0 is least danceable and 1.0 is most danceable.

- `energy`: Energy is a measure from 0.0 to 1.0 and represents a perceptual measure of intensity and activity. Typically, energetic tracks feel fast, loud, and noisy. For example, death metal has high energy, while a Bach prelude scores low on the scale. Perceptual features contributing to this attribute include dynamic range, perceived loudness, timbre, onset rate, and general entropy.

- `key`: The key the track is in. Integers map to pitches using standard Pitch Class notation. E.g., 0 = C, 1 = C♯/D♭, 2 = D, and so on. If no key was detected, the value is -1.

- `loudness`: The overall loudness of a track in decibels (dB). Loudness values are averaged across the entire track and are useful for comparing relative loudness of tracks. Values typically range between -60 and 0 dB.

- `mode`: Mode indicates the modality (major or minor) of a track. Major is represented by 1 and minor by 0.

- `speechiness`: Speechiness detects the presence of spoken words in a track. The more exclusively speech-like the recording (e.g., talk show, audiobook, poetry), the closer to 1.0 the attribute value. Values above 0.66 describe tracks made entirely of spoken words, values between 0.33 and 0.66 describe tracks that may contain both music and speech (e.g., rap music), and values below 0.33 likely represent music or non-speech-like tracks.

- `acousticness`: A confidence measure from 0.0 to 1.0 of whether the track is acoustic. A value of 1.0 represents high confidence that the track is acoustic.

- `instrumentalness`: Predicts whether a track contains no vocals. "Ooh" and "aah" sounds are treated as instrumental. Rap or spoken word tracks are clearly vocal. The closer the value is to 1.0, the greater the likelihood the track contains no vocal content. Values above 0.5 are intended to represent instrumental tracks, with higher confidence as the value approaches 1.0.

- `liveness`: Detects the presence of an audience in the recording. Higher liveness values represent an increased probability that the track was performed live. A value above 0.8 indicates a strong likelihood the track is live.

- `valence`: A measure from 0.0 to 1.0 describing the musical positiveness conveyed by a track. High valence indicates positive tracks (e.g., happy, cheerful, euphoric), while low valence indicates negative tracks (e.g., sad, depressed, angry).

- `tempo`: The overall estimated tempo of a track in beats per minute (BPM). In musical terms, tempo is the speed or pace of a given piece and derives directly from the average beat duration.

- `type`: The object type.

- `id`: The Spotify ID for the track.

- `uri`: The Spotify URI for the track.

- `track_href`: A link to the Web API endpoint providing full details of the track.

- `analysis_url`: A URL to access the full audio analysis of this track (an access token is required to retrieve data).

- `duration_ms`: The duration of the track in milliseconds.

- `time_signature`: An estimated time signature. The time signature ranges from 3 to 7, corresponding to time signatures from 3/4 to 7/4.


## OLTP layer
### Database structure
The initial database (that is, the OLTP layer) has 4 tables with structure presented in Figure 1.

<a name="figure-1"></a>
***Figure 1: The initial structure of the `spotify` database***

![The initial structure of the spotify database, EER graph](/Term1/assets/OLTP_structure.png)

Note, that the database is clearly not in a normal form because:

* Genres could be better represented in a separate table connected to `artist` by a junction table (currently they are represented in 8 different fields of `artist`, which makes it hard to work with).
* `albums` is currently very redundant: it holds information on every album as many times as there are tracks in the album. So, `albums` should be splitted into 2 separate tables: one describing only album-related info, and one junction table connecting albums to tracks.
* Information on tracks is scattered around in 3 different tables: `tracks`, `features` and `albums`. These fields should be merged into one table containing all track-specific fields (for the next point, note that artists performing a track is also a track-specific information, though an album should have a main artist as well).
* Performing artists of a track could be better represented by a junction table connecting `artist` and the `tracks` (now containing all track-specific fields) tables.

So, I performed some normalization tasks on the original tables, and the resulting structure is presented in Figure 2. I will perform all future tasks of Term Project 1 on this normalized database rather than on the original.

<a name="figure-2"></a>
***Figure 2: The normalized structure of the `spotify` database***

![The normalized structure of the spotify database, EER graph](/Term1/assets/OLTP_structure_normalized.png)

> [!Note]
> During the process of normalization, I have encountered a small number of duplicate entries in the database (this was possible, as I was performing the load data statements with `unique_checks` set to 0 for performance reasons). Only one instance of a duplicate has been kept. Thus, the normalized database has 438,102 tracks, 78,172 albums, 37,012 artists and 3,959 genres in it.

## Data warehouses

## Data marts
