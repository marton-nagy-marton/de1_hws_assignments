import pymysql
import seaborn as sns
import matplotlib.pyplot as plt
from matplotlib.backends.backend_agg import FigureCanvasAgg as FigureCanvas
from mpl_toolkits.axes_grid1.inset_locator import inset_axes
import pandas as pd
import numpy as np
import warnings
warnings.filterwarnings('ignore')
import textwrap
import os

username = input('Please provide your MySQL username! ')
password = input('Please provide your MySQL password! ')

#connect to local MySQL server
spotify = pymysql.connect(
    host='localhost',
    user= username,    # your MySQL username
    password= password, # your MySQL password
    database='spotify'
)

#import views as dataframes
pop_albums = pd.read_sql('select * from pop_albums',spotify)
albums_popularity_date = pd.read_sql('select * from albums_popularity_date',spotify)
duration_determinants = pd.read_sql('select * from duration_determinants',spotify)
taylor_swift_songs = pd.read_sql('select * from taylor_swift_songs',spotify)
valence_ts = pd.read_sql('select * from valence_ts',spotify)
one_time_hits = pd.read_sql('select * from one_time_hits',spotify)
artist_followers_popularity = pd.read_sql('select * from artist_followers_popularity',spotify)
feat_effects = pd.read_sql('select * from feat_effects',spotify)
feature_spillovers = pd.read_sql('select * from feature_spillovers',spotify)
genre_niche = pd.read_sql('select * from genre_niche',spotify)
explicit_genres = pd.read_sql('select * from explicit_genres',spotify)
genre_aggregation = pd.read_sql('select * from genre_aggregation',spotify)

#Close connection
spotify.close()

os.mkdir('charts')

#Q1
# Function to wrap titles
def wrap_title(title, width=25):
    return "\n".join(textwrap.wrap(title, width))

numeric_columns = ["explicit_tracks_pct","avg_danceability", "avg_energy", "avg_loudness", "avg_speechiness", "avg_acousticness", "avg_instrumentalness", "avg_liveness","avg_valence",
                   "artist_popularity", "followers", "avg_feat_artist_popularity", "avg_feat_artist_followers", "count_feat_artist"]
# Create a grid of regplots
fig, axes = plt.subplots(nrows=5, ncols=3, figsize=(10, 20))
axes = axes.flatten()  # Flatten to easily iterate over the axes

for i, column in enumerate(numeric_columns[:]):
    sns.regplot(x=column, y='album_popularity', data=pop_albums, fit_reg = True, ax=axes[i], line_kws = {'color' : 'k'}, scatter_kws={'s': 1, 'color': 'green', 'alpha': 0.1})
    wrapped_title = wrap_title(f'Regression of {column} vs album_popularity', width=40)  # Wrap title text
    axes[i].set_title(wrapped_title, fontsize=10)
    
    # Set axis labels with font size
    axes[i].set_xlabel(column, fontsize=8)
    axes[i].set_ylabel('album_popularity', fontsize=8)

    # Set tick label font size
    axes[i].tick_params(axis='both', labelsize=8)

ts_popalbums = pop_albums[['album_popularity', 'release_year', 'release_month', 'release_day']]
ts_popalbums.release_year.dropna(inplace=True)
ts_popalbums.release_month.dropna(inplace=True)
ts_popalbums.release_day.dropna(inplace=True)
ts_popalbums['release_date'] = pd.to_datetime(
    dict(year=ts_popalbums['release_year'], 
         month=ts_popalbums['release_month'], 
         day=ts_popalbums['release_day']), 
    errors='coerce'
)

# Ensure that release_date is in numeric format for polynomial fitting
ts_popalbums['release_date_numeric'] = ts_popalbums['release_date'].astype(np.int64) // 10**9  # Convert to seconds since epoch

# Fit a linear regression model
slope, intercept = np.polyfit(ts_popalbums['release_date_numeric'], ts_popalbums['album_popularity'], 1)

# Create the trend line values
trend_line = slope * ts_popalbums['release_date_numeric'] + intercept

# Create the time series plot for release date vs album popularity
axes[14].plot(ts_popalbums['release_date'], trend_line, color='black', linewidth=1.5)
sns.scatterplot(data=ts_popalbums, x='release_date', y='album_popularity', ax=axes[14], color='green', alpha=0.1, s=1)
axes[14].set_title('Album Popularity Over Time', fontsize=10)
axes[14].set_xlabel('release_date', fontsize=8)
axes[14].set_ylabel('album_popularity', fontsize=8)
axes[14].tick_params(axis='both', labelsize=8)

# Remove empty subplots if there are any
#for j in range(len(numeric_columns), len(axes)):
#    fig.delaxes(axes[j])

plt.tight_layout()
plt.savefig('charts/q1.png', bbox_inches='tight')

#Q2
# Format float values to 2 decimal places
albums_popularity_date['avg_album_popularity'] = albums_popularity_date['avg_album_popularity'].map('{:.2f}'.format)
albums_popularity_date['std_album_popularity'] = albums_popularity_date['std_album_popularity'].map('{:.2f}'.format)

# Create a figure and axis for the table
fig, ax = plt.subplots(figsize=(10, 2))  # Adjust figure size as needed
ax.axis('tight')
ax.axis('off')

# Create a table from the DataFrame
table = ax.table(cellText=albums_popularity_date.values, colLabels=albums_popularity_date.columns, cellLoc='center', loc='center')

# Customize table style (academic formatting)
table.auto_set_font_size(False)
table.set_fontsize(10)
#table.scale(1.2, 1.2)  # Scale the table for better appearance

# Customize colors and line thickness for an academic style
table.auto_set_column_width(col=list(range(len(albums_popularity_date.columns))))  # Adjust column widths
for key, cell in table.get_celld().items():
    cell.set_linewidth(1.2)  # Set a thicker line for cell borders
    if key[0] == 0:  # Header row
        cell.set_text_props(weight='bold')  # Bold for the header
        cell.set_facecolor('#D3D3D3')  # Light gray background for header

plt.tight_layout()
plt.savefig('charts/q2.png', bbox_inches='tight')

#Q3
numeric_columns = ["avg_danceability", "avg_energy", "avg_loudness", "avg_speechiness", "avg_acousticness", "avg_instrumentalness", "avg_liveness","avg_valence"]
# Create a grid of regplots
fig, axes = plt.subplots(nrows=3, ncols=3, figsize=(10, 10))
axes = axes.flatten()  # Flatten to easily iterate over the axes

for i, column in enumerate(numeric_columns[:]):
    sns.regplot(x=column, y=np.log(duration_determinants['total_duration_s']), data=duration_determinants, fit_reg = True, ax=axes[i], line_kws = {'color' : 'k'}, scatter_kws={'s': 1, 'color': 'green', 'alpha': 0.1})
    wrapped_title = wrap_title(f'Regression of {column} vs ln(total_duration_s)', width=40)  # Wrap title text
    axes[i].set_title(wrapped_title, fontsize=10)
    
    # Set axis labels with font size
    axes[i].set_xlabel(column, fontsize=8)
    axes[i].set_ylabel('ln(total_duration_s)', fontsize=8)

    # Set tick label font size
    axes[i].tick_params(axis='both', labelsize=8)

for j in range(len(numeric_columns), len(axes)):
    fig.delaxes(axes[j])

plt.tight_layout()
plt.savefig('charts/q3.png', bbox_inches='tight')

#Q4
numeric_columns = ['danceability','energy', 'key_signature', 'loudness', 'speechiness', 'acousticness', 'instrumentalness', 'liveness', 'valence', 'tempo', 'duration_s',
                   'time_signature', 'album_duration_s', 'feat_artist_avg_popularity', 'feat_artist_avg_followers', 'feat_artist_count', 'release_dayofweek']
# Create a grid of regplots
fig, axes = plt.subplots(nrows=6, ncols=3, figsize=(10, 20))
axes = axes.flatten()  # Flatten to easily iterate over the axes

for i, column in enumerate(numeric_columns[:]):
    sns.regplot(x=column, y='track_popularity', data=taylor_swift_songs, fit_reg = True, ax=axes[i], line_kws = {'color' : 'k'}, scatter_kws={'s': 1, 'color': 'green', 'alpha': 0.1})
    wrapped_title = wrap_title(f'Regression of {column} vs track_popularity', width=40)  # Wrap title text
    axes[i].set_title(wrapped_title, fontsize=10)
    
    # Set axis labels with font size
    axes[i].set_xlabel(column, fontsize=8)
    axes[i].set_ylabel('track_popularity', fontsize=8)

    # Set tick label font size
    axes[i].tick_params(axis='both', labelsize=8)

ts_taylor = taylor_swift_songs[['track_popularity', 'release_year', 'release_month', 'release_day']]
ts_taylor.release_year.dropna(inplace=True)
ts_taylor.release_month.dropna(inplace=True)
ts_taylor.release_day.dropna(inplace=True)
ts_taylor['release_date'] = pd.to_datetime(
    dict(year=ts_taylor['release_year'], 
         month=ts_taylor['release_month'], 
         day=ts_taylor['release_day']), 
    errors='coerce'
)

# Ensure that release_date is in numeric format for polynomial fitting
ts_taylor['release_date_numeric'] = ts_taylor['release_date'].astype(np.int64) // 10**9  # Convert to seconds since epoch

# Fit a linear regression model
slope, intercept = np.polyfit(ts_taylor['release_date_numeric'], ts_taylor['track_popularity'], 1)

# Create the trend line values
trend_line = slope * ts_taylor['release_date_numeric'] + intercept

# Create the time series plot for release date vs album popularity
axes[17].plot(ts_taylor['release_date'], trend_line, color='black', linewidth=1.5)
sns.scatterplot(data=ts_taylor, x='release_date', y='track_popularity', ax=axes[17], color='green', alpha=0.1, s=1)
axes[17].set_title('Track Popularity Over Time', fontsize=10)
axes[17].set_xlabel('release_date', fontsize=8)
axes[17].set_ylabel('track_popularity', fontsize=8)
axes[17].tick_params(axis='both', labelsize=8)

# Remove empty subplots if there are any
#for j in range(len(numeric_columns), len(axes)):
#    fig.delaxes(axes[j])

plt.tight_layout()
plt.savefig('charts/q4.png', bbox_inches='tight')

#Q5
valence_ts['release_date'] = pd.to_datetime(
    dict(year=valence_ts['release_year'], 
         month=valence_ts['release_month'], 
         day=1))
valence_ts.set_index('release_date', inplace=True)

# Resample the data to ensure a continuous time series (monthly frequency)
valence_ts_resampled = valence_ts.resample('MS').mean()

# Calculate a 12-month moving average for avg(valence) and count_songs
valence_ts_resampled['12_month_MA_valence'] = valence_ts_resampled['avg(valence)'].rolling(window=12).mean()
valence_ts_resampled['12_month_MA_count'] = valence_ts_resampled['count_songs'].rolling(window=12).mean()

# Create the figure and axis objects
fig, ax1 = plt.subplots(figsize=(10, 5))  # Set the figure size

# Plot the avg(valence) data and the 12-month moving average on the first y-axis
sns.lineplot(data=valence_ts_resampled, x=valence_ts_resampled.index, y='avg(valence)', color='green', alpha=0.5, linewidth = 0.5, ax=ax1, label='Avg valence')
sns.lineplot(data=valence_ts_resampled, x=valence_ts_resampled.index, y='12_month_MA_valence', color='green', linewidth = 2, ax=ax1, label='12-month MA valence')

# Label the first y-axis
ax1.set_ylabel('Avg valence', fontsize=12)
ax1.set_xlabel('Release date', fontsize=12)

# Create the second y-axis for count_songs
ax2 = ax1.twinx()  # Create a twin Axes sharing the x-axis

# Plot the count_songs data and the 12-month moving average on the second y-axis
sns.lineplot(data=valence_ts_resampled, x=valence_ts_resampled.index, y='count_songs', color='orange', linewidth = 0.5, alpha=0.5, ax=ax2, label='Count of songs')
sns.lineplot(data=valence_ts_resampled, x=valence_ts_resampled.index, y='12_month_MA_count', color='orange', linewidth = 2, ax=ax2, label='12-month MA count')

# Label the second y-axis
ax2.set_ylabel('Count of songs', fontsize=12)

# Set the title for the plot
plt.title('Average valence and song count over time\n(with 12-month moving averages)', fontsize=12)

# Rotate x-axis labels for better readability
ax1.tick_params(axis='x', rotation=45, labelsize=10)
ax1.tick_params(axis='y', labelsize=10)
ax2.tick_params(axis='y', labelsize=10)

# Add legends to both axes (placing them outside the plot to avoid overlap)
ax1.legend(loc='upper left', bbox_to_anchor=(0, 1))
ax2.legend(loc='upper right', bbox_to_anchor=(1, 1))

# Show the plot
plt.tight_layout()
plt.savefig('charts/q5.png', bbox_inches='tight')

#Q6
one_time_hits
def label_point(x, y, val, ax):
    a = pd.concat({'x': x, 'y': y, 'val': val}, axis=1)
    for i, point in a.iterrows():
        ax.text(point['x'], point['y'], 
        str(point['val']) if len(str(point['val'])) < 10 else f'{str(point['val'])[0:10]}...', 
        fontsize=5, wrap=True, snap=True, horizontalalignment = 'right', in_layout =True, rotation = 0)

fig, ax = plt.subplots(figsize=(10,5))
sns.scatterplot(data=one_time_hits, 
            x = 'albumtracks_avg_popularity', y = 'track_popularity', s = 10, color = 'green', alpha = 1)
ax.set_xlim(left = 0, right = 1.5, auto = False)
ax.set_ylim(bottom = 0, top = 40, auto = False)
ax.set_title('Scatterplot of track_popularity and albumtracks_avg_popularity')

label_point(one_time_hits.albumtracks_avg_popularity,
            one_time_hits.track_popularity,
            one_time_hits.track_name, ax)

plt.tight_layout()
plt.savefig('charts/q6.png', bbox_inches='tight')

#Q7
fig, ax = plt.subplots(figsize=(10,5))
sns.regplot(data=artist_followers_popularity[(artist_followers_popularity['followers'] > 1000000)], 
            x = 'followers', y = 'artist_popularity', fit_reg = True, 
            line_kws = {'color' : 'k'}, scatter_kws={'s': 5, 'color': 'green', 'alpha': 0.5})
ax.set_ylim(top=100, bottom = 0, auto = False)
ax.set_xlim(left = 0)
ax.set_title('Regression of artist_popularity vs followers\n(limited to artists with more than 1M followers)')

# Show the plot
plt.tight_layout()
plt.savefig('charts/q7.png', bbox_inches='tight')

#Q8
fig, axes = plt.subplots(nrows = 1, ncols = 3, figsize=(10, 5))  # Set the figure size
sns.violinplot(data=feat_effects['avg_popularity_no_feat'], ax = axes[0], fill = False, cut = 2, inner = 'box',
               linewidth = 1, inner_kws = {'box_width' : 20, 'whis_width' : 1}, color = 'green')
sns.violinplot(data=feat_effects['avg_popularity_with_feat'], ax = axes[1], fill = False, cut = 2, inner = 'box',
               linewidth = 1, inner_kws = {'box_width' : 20, 'whis_width' : 1}, color = 'green')
sns.violinplot(data=feat_effects['avg_popularity_with_high_follower_feat'], ax = axes[2], fill = False, cut = 2, inner = 'box',
               linewidth = 1, inner_kws = {'box_width' : 20, 'whis_width' : 1}, color = 'green')
for i in range(0,3):
    axes[i].set_ylim(bottom = 0, top = 100, auto = False)
    axes[i].set_yticks(range(0,101,10))
    axes[i].set_xlabel(str(axes[i].get_ylabel).split("ylabel='")[-1][0:-3])
    axes[i].set_ylabel('')
plt.tight_layout()
plt.savefig('charts/q8.png', bbox_inches='tight')

#Q9
fig, ax = plt.subplots(figsize=(10,5))
sns.regplot(data=feature_spillovers, 
            x = 'feat_songs_popularity', y = 'main_songs_popularity', fit_reg = True, 
            line_kws = {'color' : 'k'}, scatter_kws={'s': 5, 'color': 'green', 'alpha': 0.5})
ax.set_ylim(top=100, bottom = 0, auto = False)
ax.set_xlim(left = 0, right = 100, auto = False)
ax.set_title('Regression of main_songs_popularity vs feat_songs_popularity')

# Show the plot
plt.tight_layout()
plt.savefig('charts/q9.png', bbox_inches='tight')

#Q10
def label_point(x, y, val, ax):
    a = pd.concat({'x': x, 'y': y, 'val': val}, axis=1)
    for i, point in a.iterrows():
        ax.text(point['x']+1, point['y']+1, str(point['val']), fontsize = 6, wrap = True, snap = True)

fig, axes = plt.subplots(nrows = 1, ncols = 2, figsize=(10,5))
sns.scatterplot(data=genre_niche, 
            x = 'tracks_in_genre_main_popularity_avg', y = 'tracks_in_genre_main', s = 10, color = 'green', alpha = 1, ax = axes[0])
axes[0].set_xlim(left = 0, right = 100, auto = False)
axes[0].set_ylim(bottom = 0, top = 160, auto = False)
axes[0].hlines(y = 80, xmin = 45, xmax = 100, linestyle = '--', color = 'orange')
axes[0].vlines(x = 45, ymin = 0, ymax = 80, linestyle = '--', color = 'orange')

(
label_point(genre_niche[(genre_niche['tracks_in_genre_main_popularity_avg'] > 45) & (genre_niche['tracks_in_genre_main'] < 80)].tracks_in_genre_main_popularity_avg,
            genre_niche[(genre_niche['tracks_in_genre_main_popularity_avg'] > 45) & (genre_niche['tracks_in_genre_main'] < 80)].tracks_in_genre_main,
            genre_niche[(genre_niche['tracks_in_genre_main_popularity_avg'] > 45) & (genre_niche['tracks_in_genre_main'] < 80)].genre, axes[0])
)

sns.scatterplot(data=genre_niche, 
            x = 'tracks_in_genre_sub_popularity_avg', y = 'tracks_in_genre_sub', s = 10, color = 'green', alpha = 1, ax = axes[1])
axes[1].set_xlim(left = 0, right = 100, auto = False)
axes[1].set_ylim(bottom = 0, top = 160, auto = False)
axes[1].hlines(y = 80, xmin = 45, xmax = 100, linestyle = '--', color = 'orange')
axes[1].vlines(x = 45, ymin = 0, ymax = 80, linestyle = '--', color = 'orange')

(
label_point(genre_niche[(genre_niche['tracks_in_genre_sub_popularity_avg'] > 45) & (genre_niche['tracks_in_genre_sub'] < 80)].tracks_in_genre_sub_popularity_avg,
            genre_niche[(genre_niche['tracks_in_genre_sub_popularity_avg'] > 45) & (genre_niche['tracks_in_genre_sub'] < 80)].tracks_in_genre_sub,
            genre_niche[(genre_niche['tracks_in_genre_sub_popularity_avg'] > 45) & (genre_niche['tracks_in_genre_sub'] < 80)].genre, axes[1])
)

fig.suptitle('Scatterplots of genre average popularaties vs tracks in the genre\n(for main and subgenres)')

# Show the plot
plt.tight_layout()
plt.savefig('charts/q10.png', bbox_inches='tight')

#Q11
def label_point(x, y, val, ax):
    a = pd.concat({'x': x, 'y': y, 'val': val}, axis=1)
    for i, point in a.iterrows():
        ax.text(point['x'] - .2, point['y'] - .2, str(point['val']), fontsize=5, wrap=True, snap=True, horizontalalignment = 'right', in_layout =True, rotation = 30)

fig, ax = plt.subplots(figsize=(10,5))
sns.scatterplot(data=explicit_genres, 
            x = 'tracks_in_genre_main_explicit_pct', y = 'tracks_in_genre_sub_explicit_pct', s = 10, color = 'green', alpha = 1)
ax.set_xlim(left = 0, right = 100, auto = False)
ax.set_ylim(bottom = 0, top = 100, auto = False)
ax.set_title('Pct of explicit tracks in main and subgenres')

# Zoomed-in plot with orange outer line, tick font size 5
zoom_ax = fig.add_axes([0.65, 0.40, 0.2, 0.2], xlim=(90, 100), ylim=(90, 100), facecolor='white')
sns.scatterplot(data=explicit_genres[(explicit_genres['tracks_in_genre_main_explicit_pct'] > 90) & (explicit_genres['tracks_in_genre_sub_explicit_pct'] > 90)],
                x='tracks_in_genre_main_explicit_pct', y='tracks_in_genre_sub_explicit_pct', s=10, color='green', alpha=1, ax=zoom_ax)

# Reapply the adjusted label function
label_point(explicit_genres[(explicit_genres['tracks_in_genre_main_explicit_pct'] > 90) & (explicit_genres['tracks_in_genre_sub_explicit_pct'] > 90)].tracks_in_genre_main_explicit_pct,
            explicit_genres[(explicit_genres['tracks_in_genre_main_explicit_pct'] > 90) & (explicit_genres['tracks_in_genre_sub_explicit_pct'] > 90)].tracks_in_genre_sub_explicit_pct,
            explicit_genres[(explicit_genres['tracks_in_genre_main_explicit_pct'] > 90) & (explicit_genres['tracks_in_genre_sub_explicit_pct'] > 90)].genre, zoom_ax)

# Customize the outer line color for the zoom-in
zoom_ax.spines['top'].set_color('orange')
zoom_ax.spines['right'].set_color('orange')
zoom_ax.spines['left'].set_color('orange')
zoom_ax.spines['bottom'].set_color('orange')
zoom_ax.spines['top'].set_linestyle('--')
zoom_ax.spines['right'].set_linestyle('--')
zoom_ax.spines['left'].set_linestyle('--')
zoom_ax.spines['bottom'].set_linestyle('--')

# Set tick font sizes for the zoomed-in plot
zoom_ax.tick_params(axis='both', labelsize=5)
zoom_ax.set_xlabel('')
zoom_ax.set_ylabel('')
zoom_ax.set_title('Zoomed view when explicit pct > 90', fontsize = 8)

# Add orange lines to indicate zoom area in the main plot
ax.plot([90, 100], [90, 90], color='orange', linestyle='--', linewidth=0.8)  # Top horizontal line
ax.plot([100, 100], [90, 100], color='orange', linestyle='--', linewidth=0.8)  # Right vertical line

# Lines connecting the zoomed-in plot to the main plot
ax.plot([90, zoom_ax.get_position().x0 * 100], [100, zoom_ax.get_position().y1 * 100], color='orange', linestyle='-', linewidth=0.8)
ax.plot([100, zoom_ax.get_position().x1 * 100], [90, zoom_ax.get_position().y0 * 100], color='orange', linestyle='-', linewidth=0.8)


ax.hlines(y = 90, xmin = 90, xmax = 100, linestyle = '--', color = 'orange')
ax.vlines(x = 90, ymin = 90, ymax = 100, linestyle = '--', color = 'orange')


# Show the plot
plt.tight_layout()
plt.savefig('charts/q11.png', bbox_inches='tight')

#Q12
fig, axes = plt.subplots(nrows = 1, ncols = 3, figsize=(10, 5))  # Set the figure size
sns.violinplot(data=genre_aggregation['tracks_in_genre_main_popularity_avg'], ax = axes[0], fill = False, cut = 2, inner = 'box',
               linewidth = 1, inner_kws = {'box_width' : 20, 'whis_width' : 1}, color = 'green')
sns.violinplot(data=genre_aggregation['albums_in_genre_main_popularity_avg'], ax = axes[1], fill = False, cut = 2, inner = 'box',
               linewidth = 1, inner_kws = {'box_width' : 20, 'whis_width' : 1}, color = 'green')
sns.violinplot(data=genre_aggregation['artist_in_genre_main_popularity_avg'], ax = axes[2], fill = False, cut = 2, inner = 'box',
               linewidth = 1, inner_kws = {'box_width' : 20, 'whis_width' : 1}, color = 'green')
for i in range(0,3):
    axes[i].set_ylim(bottom = 0, top = 100, auto = False)
    axes[i].set_yticks(range(0,101,10))
    axes[i].set_xlabel(str(axes[i].get_ylabel).split("ylabel='")[-1][0:-3])
    axes[i].set_ylabel('')
plt.tight_layout()
plt.savefig('charts/q12.png', bbox_inches='tight')


