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

# #change new data structure to old data structure 
#  #label rows
# Df4_rownumbers <- tibble::rowid_to_column(Play2)
# 
# unique(Df4_rownumbers$indicator) 
# colnames(Df4_rownumbers)
# 
# # take years from long to wide
# Df5_NewPeriod <- Df4_rownumbers %>% 
# gather("period","value",targets:cumulative) %>% 
# mutate(fiscalperiod = paste(fiscal_year,period)) %>%
# spread(fiscalperiod,value) 
# 
# Df6_RemoveCol <- Df5_NewPeriod %>% 
#   select(-c("fiscal_year", "period", "rowid"))
# 
# colnames(Df7_RemoveCol)
# 
# #Rename Columns
# Df7_NewHeader <- Df6_RemoveCol %>% rename(
#   "FY2017Q1" = "2017 qtr1",
#   "FY2017Q2" = "2017 qtr2",
#   "FY2017Q3" = "2017 qtr3",
#   "FY2017Q4" = "2017 qtr4",
#   "FY2017APR" = "2017 cumulative",
#   "FY2017_TARGETS" = "2017 targets",
#   "FY2018Q1" = "2018 qtr1",
#   "FY2018Q2" = "2018 qtr2",
#   "FY2018Q3" = "2018 qtr3",
#   "FY2018Q4" = "2018 qtr4",
#   "FY2018_TARGETS" = "2018 targets",
#   "FY2018APR" = "2018 cumulative",
#   "FY2019Q1" = "2019 qtr1",
#   "FY2019Q2" = "2019 qtr2",
#   "FY2019Q3" = "2019 qtr3",
#   "FY2019Q4" = "2019 qtr4",
#   "FY2019_TARGETS" = "2019 targets",
#   "FY2019APR" = "2019 cumulative",
#   "AgeFine" = "trendsfine",
#   "AgeSemiFine" = "trendssemifine",
#   "AgeCoarse" = "trendscoarse")

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
