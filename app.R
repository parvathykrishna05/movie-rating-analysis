library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(readr)
library(stringr)
library(tidyr)
library(DT)

# Attempt to load and preprocess data globally so it's cached for all sessions
if (file.exists('ratings.csv') && file.exists('movies.csv')) {
  ratings <- read_csv('ratings.csv', show_col_types = FALSE) %>% drop_na()
  movies <- read_csv('movies.csv', show_col_types = FALSE) %>% drop_na()
  
  movie_data <- inner_join(ratings, movies, by = 'movieId')
  
  movie_stats <- movie_data %>%
    group_by(title) %>%
    summarise(
      rating_count = n(),
      average_rating = mean(rating)
    ) %>%
    ungroup()
  
  # Merge genres into movie_stats for the recommendation engine
  genres_info <- movies %>% select(title, genres) %>% distinct(title, .keep_all = TRUE)
  movie_stats <- left_join(movie_stats, genres_info, by = 'title')
  
  raw_movies <- movies
  data_loaded <- TRUE
} else {
  data_loaded <- FALSE
}

# Custom CSS matching the Streamlit app's Glassmorphism & UI Styling
custom_css <- HTML("
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&display=swap');
  
  body, .container-fluid {
    font-family: 'Inter', sans-serif !important;
    background-color: #0e1117;
    color: white;
  }
  
  h1.main-title {
    background: -webkit-linear-gradient(45deg, #ff4b4b, #ff8f00);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    font-weight: 800;
    margin-top: 20px;
  }
  
  .metric-box {
    padding: 15px;
    border-left: 4px solid #00d4ff;
    background-color: rgba(255, 255, 255, 0.05);
    border-radius: 8px;
    margin-bottom: 20px;
  }
  .metric-title { font-size: 1rem; color: rgba(255,255,255,0.7); margin-bottom: 5px; }
  .metric-value { font-size: 2rem; font-weight: bold; color: white; margin-bottom: 0px; line-height: 1; }
  .metric-delta { font-size: 0.9rem; color: #4CAF50; margin-top: 5px; }
  
  /* Movie Recommendation Cards */
  .movie-card {
    background: linear-gradient(145deg, #2b2b3a, #1a1a24);
    padding: 24px;
    border-radius: 16px;
    box-shadow: 0px 10px 20px rgba(0,0,0,0.3);
    margin-bottom: 24px;
    border: 1px solid rgba(255,255,255,0.05);
    transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
  }
  .movie-card:hover {
    transform: translateY(-8px);
    box-shadow: 0px 15px 30px rgba(255, 75, 75, 0.2);
    border-color: rgba(255, 75, 75, 0.5);
  }
  .m-title { color: #ffffff; font-size: 1.5rem; font-weight: 800; margin-bottom: 8px; }
  .m-genres { color: #ff4b4b; font-size: 0.95rem; font-weight: 600; margin-bottom: 20px; text-transform: uppercase; letter-spacing: 1px; }
  .m-stats { display: flex; justify-content: space-between; color: #b0b0c0; font-size: 1rem; align-items: center; }
  .stat-val { color: #4CAF50; font-weight: 800; font-size: 1.2rem; }
  
  hr { border-top: 1px solid rgba(255,255,255,0.1); }
  
  .nav-tabs .nav-link { color: #fff; font-size: 1.1rem; font-weight: 600; margin-right: 15px; border: none; }
  .nav-tabs .nav-link.active { background-color: transparent !important; color: #ff4b4b !important; border-bottom: 3px solid #ff4b4b !important; }
")

# Custom ggplot theme
theme_dark_custom <- function() {
  theme_minimal(base_family = "Inter") +
    theme(
      plot.background = element_rect(fill = "#0e1117", color = NA),
      panel.background = element_rect(fill = "#0e1117", color = NA),
      text = element_text(color = "white"),
      axis.text = element_text(color = "white"),
      panel.grid.major = element_line(color = "#FFFFFF1A"),
      panel.grid.minor = element_blank(),
      plot.title = element_text(face = "bold", size = 14)
    )
}

# Helper function
v_n_distinct <- function(x) length(unique(x))

ui <- tagList(
  tags$head(tags$style(custom_css)),
  page_navbar(
    id = "main_navbar",
    title = HTML("<h1 class='main-title' style='margin:0; font-size: 1.8rem;'>🎬 Master Movie Rating Analysis Engine</h1>"),
    theme = bs_theme(version = 5, bg = "#0e1117", fg = "#ffffff", primary = "#ff4b4b"),
    
    header = div(
      style = "padding: 15px;",
      p("A Premium B.Tech Analytics Case Study on the MovieLens Dataset.")
    ),
    
    # ---------------- TAB 1: EDA ----------------
    nav_panel("📊 Global Data Analytics",
      if (!data_loaded) {
        h3("Dataset Error: Could not find 'ratings.csv' or 'movies.csv'. Please make sure they are in the same folder.", style = "color: red;")
      } else {
        div(
          h3("Global Network Overview", style="margin-top:20px;"),
          br(),
          fluidRow(
            column(4, div(class = "metric-box",
                          div(class = "metric-title", "Films Catalogued"),
                          div(class = "metric-value", format(v_n_distinct(raw_movies$movieId), big.mark=",")),
                          div(class = "metric-delta", "+15 Genres"))),
            column(4, div(class = "metric-box",
                          div(class = "metric-title", "Total User Ratings"),
                          div(class = "metric-value", format(nrow(movie_data), big.mark=",")),
                          div(class = "metric-delta", "Verified"))),
            column(4, div(class = "metric-box",
                          div(class = "metric-title", "Global Users"),
                          div(class = "metric-value", format(v_n_distinct(movie_data$userId), big.mark=",")),
                          div(class = "metric-delta", "Active")))
          ),
          hr(),
          h3("📈 Exploratory Visualizations", style="margin-bottom:20px;"),
          fluidRow(
            column(6,
                   h5("1. Community Rating Distribution Overview", style="font-weight:bold;"),
                   plotOutput("plot1", height = "400px"),
                   br(),
                   h5("3. Average Critical Reception by Primary Genre", style="font-weight:bold;"),
                   plotOutput("plot3", height = "400px")
            ),
            column(6,
                   h5("2. Cultural Popularity vs Base Rating", style="font-weight:bold;"),
                   plotOutput("plot2", height = "400px"),
                   br(),
                   h5("4. User Psychological Bias Check", style="font-weight:bold;"),
                   plotOutput("plot4", height = "400px")
            )
          )
        )
      }
    ),
    
    # ---------------- TAB 2: TOP MOVIES ----------------
    nav_panel("🏆 The Leaderboard",
      div(style = "padding: 20px 0;",
          h3("🏆 The Global Top 50 Leaderboard"),
          p("Dynamic filtering system to ensure obscure films don't pollute the leaderboard."),
          
          sliderInput("min_ratings", "Quality Assurance Filter (Minimum Views Required):",
                      min = 10, max = 500, value = 75, step = 5, width = "100%"),
          br(),
          DTOutput("top_movies_table")
      )
    ),
    
    # ---------------- TAB 3: RECOMMENDER ----------------
    nav_panel("🤖 AI Recommendations",
      div(style = "padding: 20px 0;",
          h3("🤖 Algorithmic Recommender System"),
          p("Our custom heuristic algorithm analyzes genre overlap networks and community sentiment to find perfect matches."),
          br(),
          
          if(data_loaded) {
            # Note: Select input is updated in server.R to handle many options
            selectizeInput("selected_movie", "Search for a catalyst movie in the database:", 
                           choices = NULL, width = "100%", options = list(placeholder = 'Type a movie name...'))
          },
          
          uiOutput("recommender_results")
      )
    )
  )
)

server <- function(input, output, session) {
  
  if (!data_loaded) return()
  
  # Valid movies for recommender (>= 50 ratings)
  valid_movies <- movie_stats %>%
    filter(rating_count >= 50) %>%
    arrange(title)
  
  updateSelectizeInput(session, "selected_movie", choices = valid_movies$title, server = TRUE)
  
  # TAB 1 Plots
  output$plot1 <- renderPlot({
    ggplot(movie_data, aes(x = rating)) +
      geom_histogram(bins = 10, fill = '#00d4ff', color = '#00d4ff', alpha = 0.8) +
      labs(x = 'Score', y = 'Volume') +
      theme_dark_custom()
  }, bg="transparent")
  
  output$plot2 <- renderPlot({
    ggplot(movie_stats, aes(x = rating_count, y = average_rating)) +
      geom_point(alpha = 0.3, color = '#ff4b4b') +
      labs(x = 'Popularity (Number of Ratings)', y = 'Average Rating') +
      theme_dark_custom()
  }, bg="transparent")
  
  output$plot3 <- renderPlot({
    genre_stats <- movie_data %>%
      separate_rows(genres, sep = "\\|") %>%
      group_by(genres) %>%
      summarise(rating_count = n(), average_rating = mean(rating)) %>%
      filter(rating_count > 1000) %>%
      arrange(desc(average_rating))
    
    genre_stats$genres <- factor(genre_stats$genres, levels = genre_stats$genres)
    
    ggplot(genre_stats, aes(x = genres, y = average_rating, fill = genres)) +
      geom_col() +
      scale_fill_viridis_d(option = "magma") +
      theme_dark_custom() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "none") +
      labs(x = '', y = 'Average Rating')
  }, bg="transparent")
  
  output$plot4 <- renderPlot({
    user_stats <- movie_data %>%
      group_by(userId) %>%
      summarise(average_rating = mean(rating))
    
    ggplot(user_stats, aes(x = average_rating)) +
      geom_histogram(bins = 20, fill = '#9b59b6', color = '#9b59b6', alpha = 0.8) +
      labs(x = 'Average Personal Voting Bias', y = 'Total Individual Users') +
      theme_dark_custom()
  }, bg="transparent")
  
  # TAB 2 Table
  output$top_movies_table <- renderDT({
    req(input$min_ratings)
    
    top_50 <- movie_stats %>%
      filter(rating_count >= input$min_ratings) %>%
      arrange(desc(average_rating)) %>%
      head(50) %>%
      select(title, genres, average_rating, rating_count) %>%
      mutate(average_rating = round(average_rating, 2))
    
    datatable(top_50, 
              options = list(pageLength = 10, scrollX = TRUE),
              rownames = FALSE,
              colnames = c("Title", "Genres", "Average Rating", "Rating Count")) %>%
      formatStyle('average_rating',
                  background = styleColorBar(range(top_50$average_rating), 'lightgreen'),
                  backgroundSize = '98% 88%',
                  backgroundRepeat = 'no-repeat',
                  backgroundPosition = 'center')
  })
  
  # TAB 3 Recommender Logic
  output$recommender_results <- renderUI({
    req(input$selected_movie)
    
    movie_info <- valid_movies %>% filter(title == input$selected_movie)
    if (nrow(movie_info) == 0) return(NULL)
    
    genres_str <- movie_info$genres
    
    if (is.na(genres_str) || genres_str == "nan" || genres_str == "(no genres listed)") {
      tagList(
        p(paste0("'", input$selected_movie, "' has no labeled genres in the dataset, making it hard to find similar matches!"), 
          style = "color: #ff9800; font-weight: bold;")
      )
    } else {
      target_genres <- str_split(genres_str, "\\|")[[1]]
      
      info_msg <- tags$div(
        style = "background-color: rgba(0, 212, 255, 0.1); border-left: 4px solid #00d4ff; padding: 10px; margin-bottom: 20px; border-radius: 4px;",
        tags$b("Target Catalyst Genres Identified: "), paste(target_genres, collapse = ", ")
      )
      
      if (length(target_genres) > 0) {
        # Calculate overlap
        recs <- valid_movies %>%
          filter(title != input$selected_movie) %>%
          rowwise() %>%
          mutate(
            sim_score = {
              g_str <- genres
              if (is.na(g_str) || g_str == "nan") {
                0
              } else {
                g_set <- str_split(g_str, "\\|")[[1]]
                length(intersect(target_genres, g_set))
              }
            }
          ) %>%
          ungroup() %>%
          filter(sim_score > 0) %>%
          arrange(desc(sim_score), desc(average_rating), desc(rating_count))
        
        if (nrow(recs) == 0) {
          tagList(info_msg, p("No similar movies found based on genres!", style = "color: #ff9800; font-weight: bold;"))
        } else {
          final_df <- head(recs, 4)
          
          cards <- lapply(1:nrow(final_df), function(i) {
            row <- final_df[i, ]
            clean_genres <- str_replace_all(row$genres, "\\|", " • ")
            
            card_html <- HTML(paste0('
              <div class="col-md-6">
                <div class="movie-card">
                    <div class="m-title">', row$title, '</div>
                    <div class="m-genres">', clean_genres, '</div>
                    <div class="m-stats">
                        <span>⭐ <span class="stat-val">', sprintf("%.2f", row$average_rating), '</span> / 5.0</span>
                        <span>👥 <span class="stat-val">', format(row$rating_count, big.mark=","), '</span> votes</span>
                    </div>
                </div>
              </div>
            '))
            return(card_html)
          })
          
          tagList(
            info_msg,
            h4("🌟 Suggested Masterpieces", style="margin-top: 20px; font-weight: bold;"),
            hr(),
            div(class = "row", cards)
          )
        }
      }
    }
  })
}

shinyApp(ui = ui, server = server)
