#Date updated: 04/29/2019
#Purpose: To set up shell for OVC Dashboard FY19 Q2 using updated PSNU X IM Genie structure
#Software: R

#increase memory and check working directory
memory.limit(size = 90000)
getwd()

#installation directory - please change username to your username. This will direct R libraries/packages to install and run smoothly with RStudio.
.libPaths(c("C:/Users/knoykhovich/R", .libPaths()))

#install & load packages 
install.packages('tidyverse')
install.packages('dplyr')
install.packages("devtools")
devtools::install_github("ICPI/ICPIutilities")
install.packages("skimr")
library(skimr)
library(tidyverse)
library(ICPIutilities)

#set working directory to where the data is
setwd("C:/R/OVC/datasets")

#read PSNU x IM MSD
psnu1 <- read_msd("Genie_Daily_20190429.txt")

#list column names and numbers
colnames(psnu1)

#drop any unnecessary columns for OVC dashboard
psnu2 <- psnu1 %>% 
  select(operatingunit:statushiv, otherdisaggregate, fiscal_year:targets, qtr2, qtr4:cumulative)

# only run for MSD, not necessary for Genie if selected these indicators already. drop all indicators but OVC SERV, OVC_HIVSTAT
# unique(psnu2$indicator)
# psnu2 <- filter(psnu2, indicator == "OVC_HIVSTAT" | indicator == "OVC_SERV" | indicator == "OVC_SERV_OVER_18"| indicator == "OVC_SERV_UNDER_18" | indicator == "OVC_HIVSTAT_NEG" | indicator == "OVC_HIVSTAT_POS")

# remove age/sex/service disaggregate as that is DREAMS only 
unique(psnu2$standardizeddisaggregate)
psnu3 <- psnu2[ which(psnu2$standardizeddisaggregate !='Age/Sex/Service'), ]
unique(psnu3$standardizeddisaggregate)

#check structure of dataset
str(psnu3)

#convert values to numeric 
psnu4 <- (type_convert(psnu3))
str(psnu4)

#Replace N/A values with blanks
is.na(psnu4)
psnu4 [is.na(psnu4)] = ""
is.na(psnu4)

#remove exit without graduation from program status (duplicated in both program status and transferexit)
unique(psnu4$otherdisaggregate)
psnu5 <- filter(psnu4, standardizeddisaggregate != "ProgramStatus" | otherdisaggregate != "Exited without Graduation")

#remove Transferred from program status (duplicated in both program status and transferexit)
psnu6 <- filter(psnu5, standardizeddisaggregate != "ProgramStatus" | otherdisaggregate != "Transferred")

#export to csv
write.csv(psnu6,"PreliminaryGenie_OVCDash_psnuxIM_20190429.csv", row.names = FALSE)
