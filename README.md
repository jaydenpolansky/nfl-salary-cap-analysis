# NFL Salary Cap & Team Performance Analysis (2011-2024)

An analysis of how NFL teams allocate their salary cap and whether spending strategies correlate with winning. This project examines salary distribution inequality using the Gini coefficient and explores the relationship between cap management and team success.

## Key Questions

- Does how a team *distributes* salary matter more than how much they spend?
- Do "star-heavy" rosters (high Gini) outperform "depth-focused" rosters (low Gini)?
- Can we predict win percentage based on salary cap metrics?

## Methodology

### Data Sources
- **Salary Cap Data**: Scraped from [Spotrac](https://www.spotrac.com/nfl/cap/) (2011-2024)
- **Team Performance Data**: NFL standings and point differentials (2011-2024)
- **Contract Data**: Player contracts via the [`nflreadr`](https://nflreadr.nflverse.com/) package

### Key Metrics
- **Gini Coefficient**: Measures inequality in salary distribution (0 = perfectly equal, 1 = one player gets everything)
- **Max Contract %**: Percentage of salary cap allocated to the highest-paid player
- **Cap Space**: Available spending room under the salary cap

### Analysis Approach
1. Calculated Gini coefficients for each team-year based on new contract APY (average per year) as a percentage of the cap
2. Built a linear regression model predicting win percentage from cap metrics
3. Categorized teams into spending strategies: Star-Heavy, Balanced, and Depth-Spending
4. Examined relationships between salary inequality and offensive/defensive performance

## Project Structure

```
nfl-salary-cap-analysis/
├── README.md
├── NFL_Salary_Cap_Analysis.Rmd    # Main analysis (R Markdown)
├── scripts/
│   └── scrape_spotrac.R           # Web scraper for Spotrac cap data
├── data/
│   ├── team_cap_2011_2024.csv     # Salary cap data by team/year
│   └── team_data_2011_2024.csv    # Team performance data
└── outputs/                        # Generated plots and reports
```

## Requirements

### R Packages
```r
install.packages(c("nflreadr", "dplyr", "tidyr", "stringr", 
                   "tibble", "ineq", "ggplot2", "rvest", "httr"))
```

## Usage

### Running the Analysis
1. Clone this repository
2. Place data files in the `data/` folder (or run the scraper to generate them)
3. Open `NFL_Salary_Cap_Analysis.Rmd` in RStudio
4. Knit the document to generate the full report

### Regenerating Salary Cap Data
```r
source("scripts/scrape_spotrac.R")
```
*Note: Please be respectful of Spotrac's servers - the script includes a 1-second delay between requests.*

## Key Findings

The analysis explores several relationships:

- **Gini vs. Win %**: Examines whether concentrating salary in fewer players (star-heavy approach) correlates with winning
- **Spending Strategy Comparison**: Compares average win percentages across Star-Heavy, Balanced, and Depth-Spending teams
- **Predictive Model**: Tests whether cap metrics can meaningfully predict team success when controlling for previous season performance

## Visualizations

The analysis generates several plots:
- Predicted vs. Actual Win Percentage (model validation)
- Gini Coefficient vs. Win Percentage
- Max Contract % vs. Win Percentage  
- Salary Inequality vs. Points Scored/Allowed
- Win Percentage by Spending Strategy (box plots)

## Limitations

- Contract data reflects *new* contracts signed each year, not total roster salary
- Gini calculations may be affected by teams with few new contracts in a given year
- The model doesn't account for factors like coaching, injuries, or draft capital

## Author

Jayden Polansky

## License

This project is for educational and portfolio purposes. Data sourced from Spotrac and nflverse.
