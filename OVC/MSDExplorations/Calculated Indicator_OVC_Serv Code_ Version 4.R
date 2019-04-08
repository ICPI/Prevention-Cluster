#OVC Calculated Indicator 
#Version 4

memory.limit(size = 90000)

getwd()

#install & load packages 
install.packages('tidyverse')
install.packages('dplyr')
install.packages("devtools")
devtools::install_github("ICPI/ICPIutilities")
install.packages("skimr")
install.packages("rlang")
library(skimr)
library(tidyverse)
library(ICPIutilities)
library(dplyr) 
library(rlang)
library(devtools)

#import data
Play1 <- read_csv("C:/Users/ovu6/Desktop/Prevention Cluster/OVC/Calculated Indicator/OVC_MSD_PSNUxIM_Play.csv")

#creating new column pulling out the total numerator values for OVC_SERV indicator 
Play2 <- mutate(Play1, calcfy17apr = if_else(indicator == "OVC_SERV" & standardizeddisaggregate == "Total Numerator",fy2017q4, fy2017apr)) 

Play3 <- Play2 %>% 
filter(indicator == "OVC_SERV" & categoryoptioncomboname %in% c("Active", "Graduated")) %>%
group_by(psnu,standardizeddisaggregate,indicatortype) %>% 
summarise(calcfy17apr = sum(calcfy17apr)) %>%
mutate("Total Numerator") %>%
mutate("OVC_SERV")
#refer below, for step by step comment for each line of code 


# #filtering for active and graduated where indicator is equal to OVC_SERV 
# bd1 <-  filter(Play2, indicator == "OVC_SERV" & categoryoptioncomboname %in% c("Active", "Graduated"))
# #group by psnu,standardizeddisaggregate, and indicatortype
# bd2 <- group_by(bd1,psnu,standardizeddisaggregate,indicatortype) 
# #summing calcfy17apr
# bd3 <- summarise(bd2,calcfy17apr = sum(calcfy17apr))
# #creating new column 
# bd4 <- mutate(bd3,"Total Numerator")
# bd5 <- mutate(bd4,"OVC_SERV")

#view column names 
colnames(Play3)

#reanme columns 
Play4 <-Play3 %>%  rename("standardizeddisaggregate" = "\"Total Numerator\"",
                          "indicator" = "\"OVC_SERV\"")
#drop columns 
drop1 <- Play4[, -2]

#view column names 
colnames(drop1)

#merge to original dataset. exclude calcfy17apr because it is the one being merged to the orginal dataset 
Play5 <- merge( Play1, drop1, by = c("psnu","standardizeddisaggregate", "indicatortype", "indicator"), all.x = TRUE)

