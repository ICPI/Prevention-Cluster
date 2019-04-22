#To extract a site list by OU for GBV QA Tool
#DataSource: Genie extract
#Date 03/11/19 

memory.limit(size = 90000)

#set working directory and load libraries
setwd("C:/Users/Ksato/Prevention Tools/GEND_GBV")

library(tidyverse)
library(reshape2)

#read in datasets and remove NULL, N/A, and NA values

df1 <- read_tsv(file = "Uganda_Genie_Frozen_1436121d52004856a5aa36c1533d779e.txt", 
                col_types = cols(MechanismID        = "c"), na=c("NULL", "N/A", "NA"))

colnames(df1)

#keep only two necessary columns
longdf1 <- subset(df1, select = c(SiteName, PSNU))
colnames(longdf1)

#Export dataset to csv
write.csv(longdf1, file = "Uganda_Genie Extract_20190418.txt", row.names = FALSE)
