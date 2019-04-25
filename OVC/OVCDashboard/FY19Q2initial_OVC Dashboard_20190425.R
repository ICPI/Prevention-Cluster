#Date updated: 04/25/2019
#Purpose: To set up shelle for OVC Dashboard FY19 Q2 using updated PSNU X IM MSD structure
#Software: R

#increase memory and check working directory
memory.limit(size = 9000)
getwd()

#istallation directory - please change username to your username. This will direct R libraries/packages to install and run smoothly with RStudio.
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

#read PSNU x IM MSD
psnu1 <- read_msd("MER_Structured_Dataset_PSNU_IM_FY17-19_PreQ2.txt")

#list column names and numbers
colnames(psnu1)

#drop any unnecessary columns for OVC dashboard
psnu2 <- psnu1 %>% 
  select(operatingunit:statushiv, otherdisaggregate, fiscal_year:targets, qtr2, qtr4:cumulative)

#drop all indicators but OVC SERV, OVC_HIVSTAT
unique(psnu2$indicator)
psnu3 <- filter(psnu2, indicator == "OVC_HIVSTAT" | indicator == "OVC_SERV" | indicator == "OVC_SERV_OVER_18"| indicator == "OVC_SERV_UNDER_18" | indicator == "OVC_HIVSTAT_NEG" | indicator == "OVC_HIVSTAT_POS")

# remove age/sex/service disaggregate as that is DREAMS only 
unique(psnu3$standardizeddisaggregate)
psnu4 <- psnu3[ which(psnu3$standardizeddisaggregate !='Age/Sex/Service'), ]
unique(psnu4$standardizeddisaggregate)

#check structure of dataset
str(psnu4)

#convert values to numeric 
psnu5 <- (type_convert(psnu4))
str(psnu5)

#Replace N/A values with blanks
psnu5 [is.na(psnu5)]=""
is.na(psnu5)

#export to csv
write.csv(psnu5,"PreliminaryMSD_OVCDash_psnuxIM_20190425.csv", row.names = FALSE)
