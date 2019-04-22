#OVC Calculated Indicator 
#Version 4 for Kenya 


library(skimr)
library(tidyverse)
library(ICPIutilities)
library(rlang)
library(devtools)
library(readr)
library(openxlsx)

#import data
Play1 <- read_csv("C:/Users/ovu6/Desktop/Prevention Cluster/OVC/Calculated Indicator/OVC_MSD_PSNUxIM_Play.csv")

Play1_OU <- filter(Play1,operatingunit == "Kenya")

# Pull out Active & Graduated values for OVC_Serv and use that to calculate Total Numerator
Play3 <- Play1_OU %>% 
  filter(indicator == "OVC_SERV" & otherdisaggregate %in% c("Active", "Graduated")) %>%
  group_by(psnuuid, psnu, mechanismuid, primepartner, fundingagency, mechanismid, implementingmechanismname, indicator, indicatortype, 
           standardizeddisaggregate) %>% 
  summarise(fy2017apr_new = sum(fy2017apr, na.rm = TRUE)) %>% 
  ungroup() %>%
  mutate( standardizeddisaggregate = "Total Numerator")

colnames(Play3)

#sum up calcfy17apr column to make sure it matches the MSD 
Play5 <- sum(as.numeric(Play3$fy2017apr_new), na.rm = TRUE)



#join data sets 
play6 <-left_join( Play1_OU, Play3)

# check if all the data is added for ovc-serv & tot numerator
tab1 <- play7 %>% filter(indicator == "OVC_SERV", standardizeddisaggregate== 'Total Numerator')

# replace data in fy2017apr with new values in fy2017apr_new
play7 <- play6 %>% 
  mutate(fy2017apr=case_when(
    indicator == "OVC_SERV" & standardizeddisaggregate =='Total Numerator' ~ fy2017apr_new,
    TRUE ~ as.numeric(fy2017apr)
  )) %>% 
  select(-fy2017apr_new)

#export data 
write.xlsx(play7, 'kenyaplay7.xlsx')


