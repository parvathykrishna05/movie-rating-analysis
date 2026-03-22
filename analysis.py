import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import os

def main():
    print("========================================")
    print("      MOVIE RATING ANALYSIS STARTED     ")
    print("========================================\n")
    
    # 1. Load Data
    print("[1] Loading datasets...")
    try:
        ratings = pd.read_csv('ratings.csv')
        movies = pd.read_csv('movies.csv')
    except FileNotFoundError as e:
        print(f"Error: {e}")
        print("Please make sure 'ratings.csv' and 'movies.csv' are in the project folder.")
        return

    # 2. Preprocess Data
    print("[2] Preprocessing data...")
    ratings.dropna(inplace=True)
    movies.dropna(inplace=True)
    # Merge datasets on 'movieId'
    movie_data = pd.merge(ratings, movies, on='movieId')

    # Create Features (Popularity and Average Rating)
    movie_stats = movie_data.groupby('title').agg({'rating': ['count', 'mean']})
    movie_stats.columns = ['rating_count', 'average_rating']
    movie_stats.reset_index(inplace=True)

    # Setup output directories
    if not os.path.exists('plots'):
        os.makedirs('plots')
        print("    -> Created 'plots' folder for saving visualizations.")

    # 3. Exploratory Data Analysis & Visualizations
    print("[3] Generating visualizations and exporting results...\n")

    # A. Rating Distribution
    print("    -> Plotting: Rating Distribution...")
    plt.figure(figsize=(8, 5))
    sns.histplot(movie_data['rating'], bins=10, kde=True, color='skyblue')
    plt.title('Distribution of Movie Ratings')
    plt.xlabel('Rating (0.5 to 5.0)')
    plt.ylabel('Count')
    plt.tight_layout()
    plt.savefig('plots/1_rating_distribution.png')
    plt.close()

    # B. Top Rated Movies (Min 50 Ratings)
    print("    -> Extracting: Top Rated Movies...")
    top_movies = movie_stats[movie_stats['rating_count'] >= 50].sort_values(by='average_rating', ascending=False)
    
    print("\n--- Top 10 Movies (Minimum 50 Ratings) ---")
    print(top_movies[['title', 'rating_count', 'average_rating']].head(10).to_string(index=False))
    print("------------------------------------------\n")
    
    # Exporting the full sorted list to CSV
    top_movies.to_csv('top_rated_movies_report.csv', index=False)
    print("    -> Saved 'top_rated_movies_report.csv'.")

    # C. Popularity vs Rating
    print("    -> Plotting: Popularity vs Average Rating...")
    plt.figure(figsize=(8, 5))
    sns.scatterplot(x='rating_count', y='average_rating', data=movie_stats, alpha=0.5, color='coral')
    plt.title('Popularity vs Average Rating')
    plt.xlabel('Number of Ratings (Popularity)')
    plt.ylabel('Average Rating')
    plt.tight_layout()
    plt.savefig('plots/2_popularity_vs_rating.png')
    plt.close()

    # D. Genre Analysis
    print("    -> Plotting: Genre Analysis...")
    # Splitting the pipe separated genre strings efficiently
    movie_genres = movie_data.assign(genres=movie_data['genres'].str.split('|')).explode('genres')
    genre_stats = movie_genres.groupby('genres').agg({'rating': ['count', 'mean']})
    genre_stats.columns = ['rating_count', 'average_rating']
    # Filtering genres with substantial representation
    genre_stats = genre_stats[genre_stats['rating_count'] > 1000].sort_values(by='average_rating', ascending=False)

    plt.figure(figsize=(12, 6))
    sns.barplot(x=genre_stats.index, y='average_rating', data=genre_stats, hue=genre_stats.index, palette='viridis', legend=False)
    plt.xticks(rotation=45)
    plt.title('Average Rating by Genre (Min 1000 Ratings)')
    plt.ylabel('Average Rating')
    plt.tight_layout()
    plt.savefig('plots/3_genre_analysis.png')
    plt.close()

    # E. User Behavior Analysis
    print("    -> Plotting: User Behavior Analysis...")
    user_stats = movie_data.groupby('userId').agg({'rating': ['count', 'mean']})
    user_stats.columns = ['rating_count', 'average_rating']

    plt.figure(figsize=(8, 5))
    sns.histplot(user_stats['average_rating'], bins=20, kde=True, color='purple')
    plt.title('Distribution of User Average Ratings')
    plt.xlabel('Average Rating given by User')
    plt.ylabel('Count of Users')
    plt.tight_layout()
    plt.savefig('plots/4_user_behavior.png')
    plt.close()

    print("\n========================================")
    print("          ANALYSIS COMPLETELY FINISHED        ")
    print("========================================")
    print("All visualizations have been cleanly saved in the 'plots/' directory.")
    print("Ready for your presentation/review!")

if __name__ == "__main__":
    main()
