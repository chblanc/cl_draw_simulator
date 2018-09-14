#' ---
#' title: "Data Scraper"
#' author: "Carlos Blancarte"
#' date: "December 11, 2016"
#' ---
  
#' packages
library(tidyverse)
library(rvest)

# set working directory
setwd("C:\\Users\\Chuck\\Documents\\GitHub\\cl_draw_simulator")

#' pull down champions league standings from the bbc website and
#' create a dataframe with them.
#' 

# link
dataLink <- "http://www.bbc.com/sport/football/champions-league/table"

# grab the html
bbDat <- read_html(dataLink)

#' Grab the team name, ending position, and group name. NOTE:
#' some of these strings will need to be cleaned up.

#' ### Team Names
bbDat %>%
  html_nodes(".team-name") %>%
  html_text() -> teamNames

#' remove 'TEAM' from the vector of team names
teamNames <- teamNames[!grepl('Team', teamNames)]
  
#' ### Ending Position
bbDat %>%
  html_nodes(".position") %>%
  html_text() -> endingPositions

# remove 'Position' from vector
endingPositions <- endingPositions[!grepl('Position', endingPositions)]

# extract the number
endingPositions <- parse_number(endingPositions)

#' ### Group Names 
bbDat %>%
  html_nodes(".table-header") %>%
  html_text() -> groupNames

#' Remove all the filler
groupNames <- gsub(".*\n", '', groupNames)

#' ## Put it all together now!
data <- data.frame(
  team_name = teamNames,
  position = endingPositions,
  group = rep(groupNames, 4),
  stringsAsFactors = FALSE
)

#' Merge this data with the federation data that Ravi put together
fedData <- read.csv("data\\Champions Leauge 1617 Round of 16.csv", stringsAsFactors = FALSE)
names(fedData) <- tolower(names(fedData))

endData <- data %>%
  left_join(., fedData, by = c('team_name' = 'team')) %>%
  select(-group.winner)
  