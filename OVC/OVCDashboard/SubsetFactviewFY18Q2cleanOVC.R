*********************************************
  Date updated: 7/09/2018
Analyst: Katya Noykhovich
Purpose: To subset PSNU X IM factview for OVC FY18Q2 clean dashboard
Software: R
**********************************************

memory.limit(size = 90000)

getwd()

install.packages('tidyverse')
install.packages('dplyr')
library(tidyverse)

#import dataset, edit file name/location as needed
data <- readr::read_tsv("filename.txt", col_names = TRUE)

#subset for indicators of interest
sub1 <- subset(data, indicator == 'OVC_SERV' | indicator == 'OVC_SERV_OVER_18' | indicator == 'OVC_SERV_UNDER_18' | indicator == 'OVC_HIVSTAT'| indicator == 'OVC_HIVSTAT_NEG' | indicator == 'OVC_HIVSTAT_POS')

#drop any unnecessary columns for OVC dashboard
sub2 <- sub1[c(-(1:2),-(4), -(7), -(9), -(12), -(31:32), -(34), -(36), -(40))]

#check the structure of dataset
str(sub2)
names(sub2)

#remove rows where  Standardized Disaggregate = NA(this includes duplicated values for exited without graduated and transferred)
sub3 <- sub2 %>%
  mutate(standardizedDisaggregate = case_when(
    otherDisaggregate %in% c('Exited without Graduation', 'Transferred', 'Transferred out - non PEPFAR Support Partner')~ 'TransferExit',
    TRUE~standardizedDisaggregate))

#remove age/sex/service  
sub4 <- sub3[ which(sub2$standardizedDisaggregate !='Age/Sex/Service'), ]

#export dataset to csv/txt for dashboard
write.csv(sub4,"OVC_MSD_PSNUxIM_20180622.csv", row.names = FALSE)
