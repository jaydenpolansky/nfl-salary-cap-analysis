# ============================================================================
# Spotrac NFL Salary Cap Data Scraper
# ============================================================================
# 
# Description: Scrapes historical NFL salary cap data from Spotrac.com
# Author: Jayden Polansky
# 
# This script collects team-level salary cap information including:
#   - Total cap allocations
#   - Available cap space  
#   - Active roster spending
#   - Reserve list allocations (IR/PUP/NFI/SUSP)
#   - Dead cap money
#
# Note: Please be respectful of Spotrac's servers. This script includes
# a 1-second delay between requests to avoid overwhelming their site.
# ============================================================================

# Required packages
library(rvest)
library(httr)
library(dplyr)
library(stringr)
library(readr)

# ============================================================================
# Configuration
# ============================================================================

YEARS <- 2011:2024                          # Years to scrape
OUTPUT_FILE <- "data/team_cap_2011_2024.csv"  # Output file path
REQUEST_DELAY <- 1                          # Seconds between requests (be polite!)

# ============================================================================
# Helper Functions
# ============================================================================

#' Clean currency strings to numeric values
#' 
#' Converts strings like "$10.5M" or "$1,234,567" to numeric values
#' 
#' @param x Character vector of currency strings
#' @return Numeric vector
clean_currency <- function(x) {
  x <- gsub("\\$", "", x)   # Remove dollar signs
  x <- gsub("M", "", x)     # Remove M suffix  
  x <- gsub(",", "", x)     # Remove commas
  as.numeric(x)
}

#' Scrape salary cap data for a single year
#' 
#' @param year Integer year to scrape
#' @return Data frame with cap data, or NULL if scraping fails
scrape_year <- function(year) {
  
  url <- paste0("https://www.spotrac.com/nfl/cap/_/year/", year)
  
  # Make request with browser user-agent to avoid blocking
  response <- GET(
    url, 
    user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
  )
  
  # Check for successful response
  if (http_error(response)) {
    warning(paste("HTTP error for year", year))
    return(NULL)
  }
  
  # Parse HTML and extract table
  html <- read_html(response)
  table_node <- html %>% html_node("table")
  
  if (is.null(table_node)) {
    warning(paste("No table found for year", year))
    return(NULL)
  }
  
  # Convert to data frame and add year column
  df <- table_node %>% 
    html_table(fill = TRUE) %>%
    mutate(Year = year)
  
  return(df)
}

# ============================================================================
# Main Scraping Loop
# ============================================================================

cat("Starting Spotrac scrape for years", min(YEARS), "-", max(YEARS), "\n")
cat("=" |> rep(50) |> paste(collapse = ""), "\n")

all_data <- list()

for (yr in YEARS) {
  cat("Scraping", yr, "... ")
  
  result <- scrape_year(yr)
  
  if (!is.null(result)) {
    all_data[[as.character(yr)]] <- result
    cat("Success!\n")
  } else {
    cat("Failed\n")
  }
  
  # Be polite - wait before next request
  Sys.sleep(REQUEST_DELAY)
}

cat("=" |> rep(50) |> paste(collapse = ""), "\n")
cat("Scraping complete. Processing data...\n")

# ============================================================================
# Data Cleaning
# ============================================================================

# Combine all years into single data frame
nfl_cap_data <- bind_rows(all_data)

# Clean column names (remove line breaks and extra whitespace)
nfl_cap_data <- nfl_cap_data %>%
  rename_with(~ gsub("\n", " ", .x)) %>%
  rename_with(~ gsub("\\s+", " ", .x)) %>%
  rename_with(trimws)

# Select and rename columns of interest
team_cap_data <- nfl_cap_data %>%
  select(
    Year,
    Team,
    Total_Cap = `Total Cap Allocations`,
    Cap_Space = `Cap Space All`,
    Active = `Active 53-Man`,
    Reserves = `Reserves IR/PUP/NFI/SUSP`,
    Dead = `Dead Cap`
  ) %>%
  # Remove aggregate rows
  filter(!Team %in% c("Totals", "Averages")) %>%
  # Clean numeric columns
mutate(
    across(
      c(Total_Cap, Cap_Space, Active, Reserves, Dead),
      ~ as.numeric(str_replace_all(., "[$,]", ""))
    )
  ) %>%
  # Extract team abbreviation from team name
  mutate(
    Team = str_trim(Team),
    Team = str_extract(Team, "^[A-Z]{2,3}")
  )

# ============================================================================
# Export
# ============================================================================

# Ensure output directory exists
dir.create(dirname(OUTPUT_FILE), showWarnings = FALSE, recursive = TRUE)

# Write to CSV
write_csv(team_cap_data, OUTPUT_FILE)

cat("\nData exported to:", OUTPUT_FILE, "\n")
cat("Total rows:", nrow(team_cap_data), "\n")
cat("Years covered:", min(team_cap_data$Year), "-", max(team_cap_data$Year), "\n")
cat("Teams per year:", team_cap_data %>% count(Year) %>% pull(n) %>% unique(), "\n")
