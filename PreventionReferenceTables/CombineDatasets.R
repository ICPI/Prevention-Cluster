#To combine FY15-FY16 and FY17-FY18 datasets for Prevention Reference Tables
#Date 7/3/2018 KS

memory.limit(size = 90000)

#set working directory and load libraries
setwd("Insert working directory")

install.packages('tidyverse')
install.packages('plyr')
library(tidyverse)
library(plyr)

#read in datasets

df1 <- readr::read_tsv("ICPI_MER_Structured_Dataset_PSNU_IM_FY15-16_20180515_v1_1.txt", col_names = TRUE)
df2 <- readr::read_tsv("MER_Structured_Dataset_PSNU_IM_FY17-18_20180622_v2_1.txt", col_names = TRUE)

#subset for indicators of interest
subdf1 <- subset(df1, indicator == 'PP_PREV' | indicator == "KP_PREV" | indicator == "KP_PREV_MSMTGSW" | indicator == "GEND_GBV"| indicator == "VMMC_CIRC" |indicator ==  "PrEP_NEW")
subdf2 <- subset(df2, indicator == 'PP_PREV' | indicator == "KP_PREV" | indicator == "KP_PREV_MSMTGSW" | indicator == "GEND_GBV"| indicator == "VMMC_CIRC" |indicator ==  "PrEP_NEW")

#reshape datasets from wide to long, putting all results/targets into one column; removes rows with missing values
longdf1 <- gather(subdf1, key= "period", "value", FY2015Q2:FY2016APR, na.rm=TRUE)
longdf2 <- gather(subdf2, key= "period", "value", FY2017_TARGETS:FY2019_TARGETS, na.rm=TRUE)

#remove unnecessary columns
longsubdf1 <- subset(longdf1, select = -c(dataElementUID,categoryOptionComboUID))

#Check # of columns match
ncol(longsubdf1)
ncol(longdf2)

#merge longdf1 and longdf2
mergedf <- rbind(longsubdf1, longdf2)

#subset data without NULL values
finaldf <- select(filter(finaldf, value != "NULL"),c(Region:value))

#Export dataset to csv or txt or xls for reading into Tableau
write.csv(finaldf,"MSDmergedFY15toFY18.csv", row.names = FALSE)

