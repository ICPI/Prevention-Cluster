#To combine FY15-FY16 and FY17-FY18 datasets for Prevention Reference Tables
#Date 6/25/2018

memory.limit(size = 90000)

#set working directory and load libraries
setwd("C:/Users/knoykhovich/Desktop/datasets")
library(tidyr)
library(plyr)
library(stringr)
library(dplyr)

#read in datasets

df1 <- readr::read_tsv("ICPI_MER_Structured_Dataset_PSNU_IM_FY15-16_20180515_v1_1.txt", col_names = TRUE)
df2 <- readr::read_tsv("ICPI_MER_Structured_Dataset_PSNU_IM_FY17-18_20180515_v1_1.txt", col_names = TRUE)

#subset for indicators of interest
subdf1 <- subset(df1, indicator == 'PP_PREV' | indicator == "KP_PREV" | indicator == "KP_PREV_MSMTGSW" | indicator == "GEND_GBV"| indicator == "VMMC_CIRC" |indicator ==  "PrEP_NEW")
subdf2 <- subset(df2, indicator == 'PP_PREV' | indicator == "KP_PREV" | indicator == "KP_PREV_MSMTGSW" | indicator == "GEND_GBV"| indicator == "VMMC_CIRC" |indicator ==  "PrEP_NEW")


#reshape datasets from wide to long, putting all results/targets into one column 
longdf1 <- gather(subdf1, key= "period", "value", FY2015Q2:FY2016APR, na.rm=TRUE)
longdf2 <- gather(subdf2, key= "period", "value", FY2017_TARGETS:FY2018Q2, na.rm=TRUE)

#merge longdf1 and longdf2
finaldf <- rbind(longdf1, longdf2)

#subset data without NULL values
subfinaldf <- select(filter(finaldf, value != "NULL"),c(Region:value))

#Export dataset to csv or txt or xls for reading into Tableau
write.csv(subfinaldf,"MSDmergedFY15toFY18.csv", row.names = FALSE)
