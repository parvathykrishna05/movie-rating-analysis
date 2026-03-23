# Movie Rating Analysis Project (R Version)
*A Case Study using the MovieLens Dataset built entirely in R*

This folder contains the complete project source code for the movie rating analysis. It has been successfully ported to R for native data science analytics and interactive dashboarding using Shiny.

## Project Structure
- `analysis.R`: The main R script that processes the data, calculates the top movies, and generates visualizations identical to the Python version using `dplyr` & `ggplot2`.
- `app.R`: A stunning `Shiny` Dashboard (with `bslib`) matching the aesthetics of the original Streamlit application, providing interactive EDA, dynamic top movie filtering, and an integrated Content-Based Recommender System.
- `install.R`: A setup script to rapidly install all required R packages (`shiny`, `dplyr`, `ggplot2`, `bslib`, etc.).
- `ratings.csv` & `movies.csv` & `tags.csv` & `links.csv`: The MovieLens dataset files.

## Instructions to Run

1. **Install Dependencies**:
   Ensure you have R installed and added to your system PATH. Open your **Terminal/PowerShell** in this folder and run:
   ```powershell
   Rscript install.R
   ```

2. **Run the Static Analysis**:
   Execute the analysis script by running the following command in terminal:
   ```bash
   Rscript analysis.R
   ```
   **Output:** High-quality visualization plots will be extracted to `plots/` and the ranked CSV exported as `top_rated_movies_report.csv`.

3. **Launch the Interactive Shiny Engine (Dashboard & Recommender)**:
   You can easily launch the full web application from the terminal by running:
   ```powershell
   Rscript -e "shiny::runApp('app.R', launch.browser=TRUE)"
   ```
   *Note: This will safely boot a local web server and pop open your browser to interact with the Movie Dashboard!*
