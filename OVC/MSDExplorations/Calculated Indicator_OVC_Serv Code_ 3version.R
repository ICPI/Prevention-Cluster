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


#import data
Play1 <- read_csv("C:/Users/ovu6/Desktop/Prevention Cluster/OVC/Calculated Indicator/OVC_MSD_PSNUxIM_Play.csv")

#creating new column pulling out the total numerator values for OVC_SERV indicator 
Play2 <- mutate(Play1, calcfy17apr = if_else(indicator == "OVC_SERV" & standardizeddisaggregate == "Total Numerator",fy2017q4, fy2017apr)) 


Play3 <- Play2 %>% 
  filter(indicator == "OVC_SERV" & categoryoptioncomboname %in% c("Active", "Graduated")) %>%
  group_by(psnu,standardizeddisaggregate,indicatortype) %>% 
  summarise(calcfy17apr = sum(calcfy17apr)) %>%
  mutate("Total Numerator")

colnames(Play3)





#*this part of the code is still a working progress
#reanme column 
Play4 <-Play3 %>%  rename("standardizeddisaggregate" = "\"Total Numerator\"")

drop1 <- Play4[, -2]

colnames(drop1)


#merge to original dataset. exclude calcfy17apr because it is the one being merged to the orginal dataset 

Play5 <- merge( Play1, drop1, by = c("psnu","standardizeddisaggregate", "indicatortype"))




