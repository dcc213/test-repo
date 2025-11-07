#---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
# runAll.R                       damianclarke              yyyy-mm-dd:2023-10-22
#
# This script runs required codes for the project SHORT DESCRIPTION HERE. To run
#the script, simply change directory locations on lines 29-31 to the correspond-
#ing locations on your machine.  If PREP is set to true data preparation scripts
#will be run.  If ANALYSIS is set to true, data analysis scripts will be run.  
#
#
#
#

rm(list=ls()) 

#pkgs=c("dplyr","ggplot2", "readxl", "haven", "tidyr") 
#lapply(pkgs, require, character.only = TRUE)  

## A MORE ROBUST VERSION: 
## Install if missing
to_install <- pkgs[!pkgs %in% rownames(installed.packages())]
if (length(to_install) > 0) {
  install.packages(to_install)
}
# Load all req's
invisible(lapply(pkgs, library, character.only = TRUE))

#-------------------------------------------------------------------------------   
#--- (1) Define switches for running certain areas of code and define locations  
#-------------------------------------------------------------------------------   
PREP     <- TRUE
SUMSTATS <- TRUE
ANALYSIS <- TRUE

source  <- "~/trabajo/Teaching/Exeter/ResearchMethods-I/structure/source"  
results <- "~/trabajo/Teaching/Exeter/ResearchMethods-I/structure/results"  
data    <- "~/trabajo/Teaching/Exeter/ResearchMethods-I/structure/data" 

#-------------------------------------------------------------------------------   
#--- (2) Run required codes 
#-------------------------------------------------------------------------------   
if(PREP) {  
  print("Running all data preparation code") 
  source(file.path(source,"dataPrep.R"))
}

if(SUMSTATS) {  
  print("Running all summary statistic code") 
  source(file.path(source,"descriptives.R"))
}

if(ANALYSIS) {  
  # print("Running all analysis code") 
  source(file.path(source,"analysis.R"))
}

