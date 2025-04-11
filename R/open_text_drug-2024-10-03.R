#-----------------------------------------------------------
# Program: .R
# Author:  Ziyu Huang and Miao Yu
# Date:    
# Purpose: 
#-----------------------------------------------------------

# Summary
# This is a script to tabulate the open-text fields in forms in the MS database

rm(list=ls())
# load the necessary libraries
# library(DBI)
library(odbc)
library(glue)
library(janitor)
library(writexl)
library(tidyverse)

# Data Management

## Load data from EDC
### Connect to the database
myserver <- "10.0.1.83"
myconn <- odbc::dbConnect(odbc::odbc(),
                          Driver = "SQL Server",
                          Server = myserver,
                          Database = "RCC_MS700",
                          uid = "zhuang",pwd = "MonMar76%391")
### load data
df.drug <- dbGetQuery(
  myconn,
  glue("SELECT* FROM [RCC_MS700].[drug].[drugDosages]")
)
df.taediseasmodifyingtherapy <- dbGetQuery(
  myconn,
  glue("SELECT* FROM [RCC_MS700].[staging].[taediseasemodifyingtherapy]")
)
df.dm_drug_eventLog <- dbGetQuery(
  myconn,
  glue("SELECT* FROM [RCC].[dmMS700drug].[eventLog]")
)

### close the connection
dbDisconnect(myconn)

## load look up table from sharepoint
path = "../../../Corrona LLC/Biostat Data Files - MS/documentation/Open text field drug/drug_freetext_clean_MS_2023_08_01.xlsx"
df.lookup.ms <- readxl::read_xlsx(path, sheet = 1) %>% 
  filter(!is.na(as.numeric(freq)))
df.lookup.nonms <- readxl::read_xlsx(path, sheet = 2)
  
## Save the data as csv files in sharepoint
write_csv(df.drug, "../../../Corrona LLC/Biostat Data Files - MS/documentation/Open text field drug/drugDosages.csv")
write_csv(df.dm_drug_eventLog, "../../../Corrona LLC/Biostat Data Files - MS/documentation/Open text field drug/eventLog.csv")
write.csv(df.taediseasmodifyingtherapy, "../../../Corrona LLC/Biostat Data Files - MS/documentation/Open text field drug/taediseasemodifyingtherapy.csv")
# Analysis

# get the tabulation for df.drug
# and save it as a data frame
temp.df.drug <- df.drug %>% 
  select(otherDrugName) %>%
  pull() %>% 
  tabyl() %>% 
  select(1:2) %>% 
  rename("otherDrugName" = 1, "Count" = 2)

# do the same using df.dm_drug_eventLog
temp.df.dm_drug_eventLog <- df.dm_drug_eventLog %>% 
  select(otherDrugName) %>%
  pull() %>% 
  tabyl() %>% 
  select(1:2) %>% 
  rename("otherDrugName" = 1, "Count" = 2)

# we now combine these two data frames
# when otherDrugName is the same, add up the counts
df.combined <- full_join(temp.df.drug, temp.df.dm_drug_eventLog, by = "otherDrugName") %>% 
  mutate(Count = coalesce(Count.x, 0) + coalesce(Count.y, 0)) %>% 
  select(otherDrugName, Count)


# now, we need to add drugkey and othms from df.lookup.ms to df.combined
df.combined <- df.combined %>% 
  left_join(df.lookup.ms, by = c("otherDrugName" = "drugtxt")) %>% 
  select(drugkey, otherDrugName, othms, Count)

# using the information from df.lookup.nonms
# if otherDrugName is in df.lookup.nonms$drugtxt, then drugkey is "nonms"
df.combined <- df.combined %>% 
  mutate(drugkey = ifelse(otherDrugName %in% df.lookup.nonms$drugtxt, "nonms", drugkey))

# subset the data to df.nonms,where drugkey is "nonms",
# rename othms to nonms
# use df.lookup.nonms to get nonms values
df.nonms <- df.combined %>% 
  filter(drugkey == "nonms") %>%
  select(drugkey, otherDrugName, Count) %>%
  left_join(df.lookup.nonms %>% 
              select(drugtxt,nonms), 
            by = c("otherDrugName" = "drugtxt")) %>% 
  select(drugkey, nonms, otherDrugName, Count)

# update df.combined to exclude df.nonms
df.combined <- df.combined %>% 
  filter(drugkey != "nonms")

# Now save df.combined as renamed_MSdrug in an excel file
# And save df.nonms as renamed_nonMSdrug in the same file.

path = glue("./output/drug_freetext_clean-{Sys.Date()}.xlsx")
write_xlsx(list(renamed_MSdrug = df.combined, renamed_nonMSdrug = df.nonms), path)

# Now move this file to the sharepoint folder
file.rename(from = path, to = path %>% str_replace("output", "../../../Corrona LLC/Biostat Data Files - MS/documentation/Open text field drug"))

