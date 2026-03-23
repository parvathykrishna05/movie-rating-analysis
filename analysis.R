# Load required libraries
if(!require(dplyr)) install.packages("dplyr", repos = "http://cran.us.r-project.org")
if(!require(ggplot2)) install.packages("ggplot2", repos = "http://cran.us.r-project.org")
if(!require(readr)) install.packages("readr", repos = "http://cran.us.r-project.org")
if(!require(stringr)) install.packages("stringr", repos = "http://cran.us.r-project.org")
if(!require(tidyr)) install.packages("tidyr", repos = "http://cran.us.r-project.org")

library(dplyr)
library(ggplot2)
library(readr)
library(stringr)
library(tidyr)

main <- function() {
  cat("========================================\n")
  cat("      MOVIE RATING ANALYSIS STARTED     \n")
  cat("========================================\n\n")
  
  # 1. Load Data
  cat("[1] Loading datasets...\n")
  if (!file.exists('ratings.csv') || !file.exists('movies.csv')) {
    stop("Error: Please make sure 'ratings.csv' and 'movies.csv' are in the project folder.")
  }
  
  ratings <- read_csv('ratings.csv', show_col_types = FALSE)
  movies <- read_csv('movies.csv', show_col_types = FALSE)
  
  # 2. Preprocess Data
  cat("[2] Preprocessing data...\n")
  ratings <- drop_na(ratings)
  movies <- drop_na(movies)
  
  # Merge datasets on 'movieId'
  movie_data <- inner_join(ratings, movies, by = 'movieId')
  
  # Create Features (Popularity and Average Rating)
  movie_stats <- movie_data %>%
    group_by(title) %>%
    summarise(
      rating_count = n(),
      average_rating = mean(rating)
    ) %>%
    ungroup()
  
  # Setup output directories
  if (!dir.exists('plots')) {
    dir.create('plots')
    cat("    -> Created 'plots' folder for saving visualizations.\n")
  }
  
  # 3. Exploratory Data Analysis & Visualizations
  cat("[3] Generating visualizations and exporting results...\n\n")
  
  # A. Rating Distribution
  cat("    -> Plotting: Rating Distribution...\n")
  p1 <- ggplot(movie_data, aes(x = rating)) +
    geom_histogram(bins = 10, fill = 'skyblue', color = 'black', alpha = 0.8) +
    labs(title = 'Distribution of Movie Ratings', x = 'Rating (0.5 to 5.0)', y = 'Count') +
    theme_minimal()
  ggsave('plots/1_rating_distribution.png', plot = p1, width = 8, height = 5)
  
  # B. Top Rated Movies (Min 50 Ratings)
  cat("    -> Extracting: Top Rated Movies...\n")
  top_movies <- movie_stats %>%
    filter(rating_count >= 50) %>%
    arrange(desc(average_rating))
  
  cat("\n--- Top 10 Movies (Minimum 50 Ratings) ---\n")
  print(head(top_movies, 10))
  cat("------------------------------------------\n\n")
  
  # Exporting the full sorted list to CSV
  write_csv(top_movies, 'top_rated_movies_report.csv')
  cat("    -> Saved 'top_rated_movies_report.csv'.\n")
  
  # C. Popularity vs Rating
  cat("    -> Plotting: Popularity vs Average Rating...\n")
  p2 <- ggplot(movie_stats, aes(x = rating_count, y = average_rating)) +
    geom_point(alpha = 0.5, color = 'coral') +
    labs(title = 'Popularity vs Average Rating', x = 'Number of Ratings (Popularity)', y = 'Average Rating') +
    theme_minimal()
  ggsave('plots/2_popularity_vs_rating.png', plot = p2, width = 8, height = 5)
  
  # D. Genre Analysis
  cat("    -> Plotting: Genre Analysis...\n")
  # Splitting the pipe separated genre strings efficiently
  movie_genres <- movie_data %>%
    separate_rows(genres, sep = "\\|")
  
  genre_stats <- movie_genres %>%
    group_by(genres) %>%
    summarise(
      rating_count = n(),
      average_rating = mean(rating)
    ) %>%
    filter(rating_count > 1000) %>%
    arrange(desc(average_rating))
  
  # Ensure factors are sorted for plotting
  genre_stats$genres <- factor(genre_stats$genres, levels = genre_stats$genres)
  
  p3 <- ggplot(genre_stats, aes(x = genres, y = average_rating, fill = genres)) +
    geom_bar(stat = "identity") +
    scale_fill_viridis_d(option = "D") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "none") +
    labs(title = 'Average Rating by Genre (Min 1000 Ratings)', x = '', y = 'Average Rating')
  ggsave('plots/3_genre_analysis.png', plot = p3, width = 12, height = 6)
  
  # E. User Behavior Analysis
  cat("    -> Plotting: User Behavior Analysis...\n")
  user_stats <- movie_data %>%
    group_by(userId) %>%
    summarise(
      rating_count = n(),
      average_rating = mean(rating)
    )
  
  p4 <- ggplot(user_stats, aes(x = average_rating)) +
    geom_histogram(bins = 20, fill = 'purple', color = 'black', alpha = 0.8) +
    labs(title = 'Distribution of User Average Ratings', x = 'Average Rating given by User', y = 'Count of Users') +
    theme_minimal()
  ggsave('plots/4_user_behavior.png', plot = p4, width = 8, height = 5)
  
  cat("\n========================================\n")
  cat("          ANALYSIS COMPLETELY FINISHED        \n")
  cat("========================================\n")
  cat("All visualizations have been cleanly saved in the 'plots/' directory.\n")
  cat("Ready for your presentation/review!\n")
}

if (sys.nframe() == 0L) {
  main()
}
