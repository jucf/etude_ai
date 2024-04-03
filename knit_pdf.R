# clear environnement
rm(list = ls())

library(tidyverse)
library(rmarkdown)
library(data.table)

# load data
data <- read_csv("knit_data.csv") 

# Loop through each nom and render R Markdown report
for (i in unique(data$nom)) {
  print(paste("Nom:", i))
  
  # load data
  data <- read_csv("knit_data.csv") 
  
  # Filter data for the current nom
  nom_data <- data %>%
    filter(nom == i)
  
  # Print the number of rows in the filtered data
  print(paste("Number of rows:", nrow(nom_data)))
  
  # Get the first and last response dates for the current nom
  selection_debut <- "2024-03-06"
  selection_fin <- "2024-04-03"
  # selection_debut <- min(nom_data$first_response_date)
  # selection_fin <- max(nom_data$last_response_date)
  
  # Print the calculated selection_debut and selection_fin
  print(paste("Selection debut:", selection_debut))
  print(paste("Selection fin:", selection_fin))
  
  # Render R Markdown report
  rmarkdown::render(
    "rapport.Rmd",
    params = list(
      athlete_selected = i,
      selection_debut = as.character(selection_debut),
      selection_fin = as.character(selection_fin)
    ),
    output_file = paste0(gsub(" ", "-", i), ".pdf")
  )
}
