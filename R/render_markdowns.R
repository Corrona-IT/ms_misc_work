rm(list=ls())
library(rmarkdown)
source("R/src/render2.R")
myfile = "R/check_lab_ranges-2024-05-23.Rmd"
myoutdir = "output/"
render2() # specify output location
