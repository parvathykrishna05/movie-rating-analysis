import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Set page styling for the Streamlit dashboard
st.set_page_config(page_title="Movie Rating Analysis", page_icon="🎬", layout="wide", initial_sidebar_state="collapsed")

# Inject Custom CSS for Premium Glassmorphism & UI Styling
st.markdown("""
<style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&display=swap');
    
    html, body, [class*="st-"] {
        font-family: 'Inter', sans-serif;
    /* Simple Metric Layout */
    div[data-testid="stMetric"] {
        padding: 10px;
        border-left: 3px solid #00d4ff;
        background-color: rgba(255, 255, 255, 0.05);
        border-radius: 5px;
    }
    
    /* Main H1 Title Gradient */
    h1 {
        background: -webkit-linear-gradient(45deg, #ff4b4b, #ff8f00);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        font-weight: 800;
    }
    
    hr {
        border-top: 1px solid rgba(255,255,255,0.1);
    }
    
    /* Tabs Customization */
    .stTabs [data-baseweb="tab-list"] {
        gap: 30px;
        background-color: transparent;
    }
    .stTabs [data-baseweb="tab"] {
        height: 55px;
        font-size: 1.1rem;
        font-weight: 600;
        transition: color 0.3s;
    }
    
    /* Movie Recommendation Cards */
    .movie-card {
        background: linear-gradient(145deg, #2b2b3a, #1a1a24);
        padding: 24px;
        border-radius: 16px;
        box-shadow: 0px 10px 20px rgba(0,0,0,0.3);
        margin-bottom: 24px;
        border: 1px solid rgba(255,255,255,0.05);
        transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
        text-align: left;
    }
    .movie-card:hover {
        transform: translateY(-8px);
        box-shadow: 0px 15px 30px rgba(255, 75, 75, 0.2);
        border-color: rgba(255, 75, 75, 0.5);
    }
    .m-title {
        color: #ffffff;
        font-size: 1.5rem;
        font-weight: 800;
        margin-bottom: 8px;
    }
    .m-genres {
        color: #ff4b4b;
        font-size: 0.95rem;
        font-weight: 600;
        margin-bottom: 20px;
        text-transform: uppercase;
        letter-spacing: 1px;
    }
    .m-stats {
        display: flex;
        justify-content: space-between;
        color: #b0b0c0;
        font-size: 1rem;
        align-items: center;
    }
    .stat-val {
        color: #4CAF50;
        font-weight: 800;
        font-size: 1.2rem;
    }
</style>
""", unsafe_allow_html=True)

st.title("🎬 Master Movie Rating Analysis Engine")
st.markdown("A Premium B.Tech Analytics Case Study on the MovieLens Dataset.")
st.markdown("<br>", unsafe_allow_html=True)

# Setting up caching so the data only loads once (saves immense time on reruns)
@st.cache_data
def load_and_preprocess_data():
    ratings = pd.read_csv('ratings.csv')
    movies = pd.read_csv('movies.csv')

    # Dropping missing values
    ratings.dropna(inplace=True)
    movies.dropna(inplace=True)
    
    # Merging Datasets
    movie_data = pd.merge(ratings, movies, on='movieId')
    
    # Feature Creation
    movie_stats = movie_data.groupby('title').agg({'rating': ['count', 'mean']})
    movie_stats.columns = ['rating_count', 'average_rating']
    movie_stats.reset_index(inplace=True)
    
    # Merge genres into movie_stats for the recommendation engine
    movie_stats = pd.merge(movie_stats, movies[['title', 'genres']], on='title', how='left')
    movie_stats.drop_duplicates(subset=['title'], inplace=True)
    
    return movie_data, movie_stats, movies

try:
    with st.spinner('Powering up predictive engine...'):
        movie_data, movie_stats, raw_movies = load_and_preprocess_data()
        
    # Introduce a modern Tabs layout
    tab1, tab2, tab3 = st.tabs(["📊 Global Data Analytics", "🏆 The Leaderboard", "🤖 AI Recommendations"])

    # ---------------- TAB 1: EDA ----------------
    with tab1:
        st.subheader("Global Network Overview")
        st.markdown("<br>", unsafe_allow_html=True)
        col1, col2, col3 = st.columns(3)
        col1.metric("Films Catalogued", f"{raw_movies['movieId'].nunique():,}", "+15 Genres")
        col2.metric("Total User Ratings", f"{len(movie_data):,}", "Verified")
        col3.metric("Global Users", f"{movie_data['userId'].nunique():,}", "Active")

        st.markdown("<br><hr><br>", unsafe_allow_html=True)
        st.subheader("📈 Exploratory Visualizations")
        col_left, col_right = st.columns(2)

        # Matplotlib global sleek dark settings
        plt.style.use("dark_background")

        with col_left:
            # 1. Rating Distribution
            st.markdown("**1. Community Rating Distribution Overview**")
            fig1, ax1 = plt.subplots(figsize=(8, 5))
            fig1.patch.set_facecolor('#0e1117')
            ax1.set_facecolor('#0e1117')
            sns.histplot(movie_data['rating'], bins=10, kde=True, color='#00d4ff', ax=ax1, edgecolor='none')
            ax1.set_xlabel('Score')
            ax1.set_ylabel('Volume')
            st.pyplot(fig1)

            st.markdown("<br>", unsafe_allow_html=True)

            # 3. Genre Analysis
            st.markdown("**3. Average Critical Reception by Primary Genre**")
            movie_genres = movie_data.assign(genres=movie_data['genres'].str.split('|')).explode('genres')
            genre_stats = movie_genres.groupby('genres').agg({'rating': ['count', 'mean']})
            genre_stats.columns = ['rating_count', 'average_rating']
            genre_stats = genre_stats[genre_stats['rating_count'] > 1000].sort_values(by='average_rating', ascending=False)
            
            fig3, ax3 = plt.subplots(figsize=(8, 5))
            fig3.patch.set_facecolor('#0e1117')
            ax3.set_facecolor('#0e1117')
            sns.barplot(x=genre_stats.index, y='average_rating', data=genre_stats, hue=genre_stats.index, palette='magma', legend=False, ax=ax3)
            ax3.set_xticklabels(ax3.get_xticklabels(), rotation=45, ha='right')
            ax3.set_ylabel('Average Rating')
            st.pyplot(fig3)

        with col_right:
            # 2. Popularity vs Rating
            st.markdown("**2. Cultural Popularity vs Base Rating**")
            fig2, ax2 = plt.subplots(figsize=(8, 5))
            fig2.patch.set_facecolor('#0e1117')
            ax2.set_facecolor('#0e1117')
            sns.scatterplot(x='rating_count', y='average_rating', data=movie_stats, alpha=0.3, color='#ff4b4b', ax=ax2)
            ax2.set_xlabel('Popularity (Number of Ratings)')
            ax2.set_ylabel('Average Rating')
            st.pyplot(fig2)
            
            st.markdown("<br>", unsafe_allow_html=True)

            # 4. User Behavior Analysis
            st.markdown("**4. User Psychological Bias Check**")
            user_stats = movie_data.groupby('userId').agg({'rating': ['count', 'mean']})
            user_stats.columns = ['rating_count', 'average_rating']
            
            fig4, ax4 = plt.subplots(figsize=(8, 5))
            fig4.patch.set_facecolor('#0e1117')
            ax4.set_facecolor('#0e1117')
            sns.histplot(user_stats['average_rating'], bins=20, kde=True, color='#9b59b6', ax=ax4, edgecolor='none')
            ax4.set_xlabel('Average Personal Voting Bias')
            ax4.set_ylabel('Total Individual Users')
            st.pyplot(fig4)

    # ---------------- TAB 2: TOP MOVIES ----------------
    with tab2:
        st.subheader("🏆 The Global Top 50 Leaderboard")
        st.markdown("Dynamic filtering system to ensure obscure films don't pollute the leaderboard.")
        
        min_ratings = st.slider("Quality Assurance Filter (Minimum Views Required):", min_value=10, max_value=500, value=75, step=5)
        top_movies = movie_stats[movie_stats['rating_count'] >= min_ratings].sort_values(by='average_rating', ascending=False)
        
        st.markdown("<br>", unsafe_allow_html=True)
        st.dataframe(
            top_movies[['title', 'genres', 'average_rating', 'rating_count']].head(50).style
            .format({'average_rating': '{:.2f}'})
            .background_gradient(subset=['average_rating'], cmap='Greens'), 
            use_container_width=True,
            height=600
        )

    # ---------------- TAB 3: RECOMMENDER ----------------
    with tab3:
        st.subheader("🤖 Algorithmic Recommender System")
        st.markdown("Our custom heuristic algorithm analyzes genre overlap networks and community sentiment to find perfect matches.")
        st.markdown("<br>", unsafe_allow_html=True)
        
        # Valid pool for recommendations (avoid recommending movies with sparse ratings)
        valid_movies = movie_stats[movie_stats['rating_count'] >= 50].sort_values(by='title').copy()
        
        selected_movie = st.selectbox("Search for a catalyst movie in the database:", valid_movies['title'].unique())
        
        if selected_movie:
            movie_info = valid_movies[valid_movies['title'] == selected_movie].iloc[0]
            movie_genres_str = str(movie_info['genres'])
            
            if pd.isna(movie_genres_str) or movie_genres_str == 'nan' or movie_genres_str == '(no genres listed)':
                st.warning(f"'{selected_movie}' has no labeled genres in the dataset, making it hard to find similar matches!")
                target_genres = set()
            else:
                target_genres = set(movie_genres_str.split('|'))
                st.info(f"**Target Catalyst Genres Identified:** {', '.join(target_genres)}")
            
            if len(target_genres) > 0:
                # Simple content based recommendation logic
                def calculate_similarity(row):
                    genres_str = str(row['genres'])
                    if pd.isna(genres_str) or genres_str == 'nan':
                        return 0
                    genres_set = set(genres_str.split('|'))
                    
                    # Calculate similarity weighted by overlap
                    overlap = len(target_genres.intersection(genres_set))
                    return overlap
                
                # Apply the similarity check ONLY on remaining movies
                recommendations = valid_movies[valid_movies['title'] != selected_movie].copy()
                recommendations['similarity_score'] = recommendations.apply(calculate_similarity, axis=1)
                
                # Filter to movies that share at least 1 genre
                recommendations = recommendations[recommendations['similarity_score'] > 0]
                
                if recommendations.empty:
                    st.warning("No similar movies found based on genres!")
                else:
                    # Sort heavily by similarity score FIRST, then by quality (average_rating), then popularity
                    recommendations = recommendations.sort_values(
                        by=['similarity_score', 'average_rating', 'rating_count'], 
                        ascending=[False, False, False]
                    )
                    
                    st.markdown("<br>### 🌟 Suggested Masterpieces", unsafe_allow_html=True)
                    st.markdown("---")
                    
                    display_cols = ['title', 'genres', 'similarity_score', 'average_rating', 'rating_count']
                    final_df = recommendations[display_cols].head(4).copy()
                    
                    # Displaying as beautiful CSS cards in 2 columns
                    card_cols = st.columns(2)
                    for i, (index, row) in enumerate(final_df.iterrows()):
                        clean_genres = row['genres'].replace('|', ' • ')
                        card_html = f"""
                        <div class="movie-card">
                            <div class="m-title">{row['title']}</div>
                            <div class="m-genres">{clean_genres}</div>
                            <div class="m-stats">
                                <span>⭐ <span class="stat-val">{row['average_rating']:.2f}</span> / 5.0</span>
                                <span>👥 <span class="stat-val">{row['rating_count']:,.0f}</span> votes</span>
                            </div>
                        </div>
                        """
                        card_cols[i % 2].markdown(card_html, unsafe_allow_html=True)

except FileNotFoundError:
    st.error("Dataset Error: Could not find 'ratings.csv' or 'movies.csv'. Please make sure they are in the same folder.")
