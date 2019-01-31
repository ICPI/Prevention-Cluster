#Date updated: 01/31/2019
#Purpose: To explore CURRENT format of PSNU X IM MSD  format for OVC Trends Analysis
#Software: R

#A.inrcease memory and check working directory
memory.limit(size = 90000)
getwd()

#B.Installation directory - please change username to your username. This will direct R libraries/packages to install and run smoothly with RStudio.
.libPaths(c("C:/Users/knoykhovich/R", .libPaths()))

#C. install & load packages 
install.packages('tidyverse')
install.packages('dplyr')
install.packages("devtools")
devtools::install_github("ICPI/ICPIutilities")
install.packages("skimr")
library(skimr)
library(tidyverse)
library(ICPIutilities)

#1 read df file
df1 <- read_msd("MER_Structured_Dataset_PSNU_IM_FY17-18_20181221_v2_1.txt")

#2 list column names and numbers
colnames(df1)

#3 drop any unnecessary columns for OVC dashboard
df1b <- df1 %>% 
  select(operatingunit, snu1, psnu, snuprioritization:typemilitary, primepartner:coarsedisaggregate, fy2017_targets, fy2017q2, fy2017q4, fy2017apr, fy2018_targets, fy2018q2,fy2018q4:fy2019_targets)

#4 drop all indicators but OVC SERV, OVC_HIVSTAT
unique(df1b$indicator)
df2 <- filter(df1b, indicator == "OVC_HIVSTAT" | indicator == "OVC_SERV" | indicator == "OVC_SERV_OVER_18"| indicator == "OVC_SERV_UNDER_18" | indicator == "OVC_HIVSTAT_NEG" | indicator == "OVC_HIVSTAT_POS")
colnames(df2)
unique(df2$indicator)

#5 remove age/sex/service disaggregate as that is DREAMS only 
df3 <- df2[ which(df2$standardizeddisaggregate !='Age/Sex/Service'), ]
unique(df3$standardizeddisaggregate)

#6 filter out the NAs & zeroes
df4 <- df3 %>% 
  filter_at(vars(starts_with("fy")), any_vars(!is.na(.) & .!=0))

#check structure of dataset
str(df4)

#7 export to csv
write.csv(df4,"PSNUxIM_OVCTrends_20181221CURRENTformat.csv", row.names = FALSE)
