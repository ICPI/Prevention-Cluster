#To extract a site list by OU for GBV QA Tool
#DataSource: Genie extract
#Date 03/11/19 

memory.limit(size = 90000)

#set working directory and load libraries
setwd("C:/Users/Ksato/Prevention Tools/GEND_GBV")

library(tidyverse)
library(reshape2)

#read in datasets and remove NULL, N/A, and NA values

df1 <- read_tsv(file = "Nigeria_Genie_Daily_ec313ad3e290496e91050f312af386ad.txt", 
                col_types = cols(MechanismID        = "c"), na=c("NULL", "N/A", "NA"))

colnames(df1)

#keep only two necessary columns
longdf1 <- subset(df1, select = c(SiteName, PSNU))
colnames(longdf1)

# "subject" and "sex" are columns we want to keep the same
# "condition" is the column that contains the names of the new column to put things in
# "measurement" holds the measurements

df_wide <- spread(data = longdf1, 
             key = PSNU,
             value = SiteName)


#reshape datasets from wide to long, putting all results/targets into one column; removes rows with missing values
finaldf <- gather(mergedf, key= "period", "value", FY2015Q2:FY2019_TARGETS, na.rm=TRUE)
colnames(finaldf)
count(finaldf, "period")

#Export dataset to csv
write.csv(finaldf, file = "Genie Extract_OUxIM_FY18Q4_Clean_20190107.txt", row.names = FALSE)
