# Documentation for Term Project 1
Course: Data Engineering 1

Program: Business Analytics MS

Author: Márton Nagy

## Introduction

### Submitted project artifacts and their description

## Data
### Sources

The database has a single source: a Kaggle dataset repository by the name _Spotify Dataset 2023_. The dataset has been compiled on 2023-12-20 using the Spotify API. It contains data on 438 938 tracks and their respective artists and albums.
The raw CSVs can be downloaded directly from Kaggle: https://www.kaggle.com/datasets/tonygordonjr/spotify-dataset-2023
I have downloaded the files on 2024-10-07.

### Variable description

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
The initial database (that is, the OLTP layer) has 4 tables with structure presented in Figure 1. Note, that the database is clearly not in a normal form (as genres and featuring artist could be better treated in separate tables connecting to the respective table, also there is no logical separation between the `albums` and the `tracks` table - that is, `albums` contain many pieces of information that would be better suited to be in `tracks`).

***Figure 1: The initial structure of the `spotify` database***

![The initial structure of the movies database, EER graph](/Term1/assets/OLTP_structure.png)

*Notes:*