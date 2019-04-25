#OVC_SERV Calculated Indicator for FY17 APR Total Nuemrator 
 #Version 5 for Kenya 
#Updated 4/22/2019 

memory.limit(size = 90000)

library(skimr) 
library(tidyverse) 
library(ICPIutilities) 
library(rlang) 
library(devtools) 
library(readr) 
library(openxlsx) 

#import data 
Play1 <- read_msd("C:/Users/ovu6/Desktop/Prevention Cluster/OVC/Calculated Indicator/Calculated Indicator_OVC_Serve/Txt Files/MER_Structured_Dataset_PSNU_IM_FY17-19_20190322_v2_1") 

Play2 <- filter(Play1, indicator == 'OVC_SERV' | indicator == 'OVC_SERV_OVER_18' | indicator == 'OVC_SERV_UNDER_18' | 
                indicator == 'OVC_HIVSTAT'| indicator == 'OVC_HIVSTAT_NEG' | indicator == 'OVC_HIVSTAT_POS')

#change new data structure to old data structure 
# #label rows
# Df4_rownumbers <- tibble::rowid_to_column(Df2_filterindicator)
# 
# #take years from long to wide
# Df5_NewPeriod <- Df4_rownumbers %>% 
#   gather("period","value",targets:cumulative) %>% 
#   mutate(fiscalperiod = paste(fiscal_year,period)) %>%
#   spread(fiscalperiod,value) 
# 
# colnames(Df4_rownumbers)
# unique(Df5_NewPeriod$`2018 Qtr4`)

# Pull out Active & Graduated values for OVC_Serv and use that to calculate Total Numerator 
Play3 <- Play2 %>%  
filter(indicator == "OVC_SERV" & otherdisaggregate %in% c("Active", "Graduated")) %>% 
group_by(psnuuid, psnu, mechanismuid, primepartner, fundingagency, mechanismid, implementingmechanismname,indicator,indicatortype,standardizeddisaggregate) %>%   
summarise(fy2017apr_new = sum(fy2017apr, na.rm = TRUE)) %>%  
ungroup() %>% 
mutate( standardizeddisaggregate = "Total Numerator") 

#view coloumn names
colnames(Play1) 


#sum up calcfy17apr column to make sure it matches the MSD  
Play4 <- sum(as.numeric(Play3$fy2017apr_new), na.rm = TRUE) 

#join data sets  
Play5 <-left_join( Play2, Play3) 

# check if all the data is added for ovc-serv & tot numerator 
Tab1 <- Play5 %>% filter(indicator == "OVC_SERV", standardizeddisaggregate== 'Total Numerator') 

# replace data in fy2017apr with new values in fy2017apr_new 
Play6 <- Play5 %>%  
mutate(fy2017apr=case_when( 
indicator == "OVC_SERV" & standardizeddisaggregate =='Total Numerator' ~ fy2017apr_new, 
TRUE ~ as.numeric(fy2017apr) 
  )) %>%  
select(-fy2017apr_new) 

#export data  
write.csv(Play6, 'OVC7.csv') 
