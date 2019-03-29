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


#Create new column called "calcfy17apr" to pull Q4 values from Total Num, all other values take from fy17apr and put into new "calcfy17apr" column.  
Play2 <- mutate(Play1, calcfy17apr = if_else(indicator == "OVC_SERV" & standardizeddisaggregate == "Total Numerator",fy2017q4, fy2017apr)) 
#fix OVC SERV total numerator FY17apr = active fy17apr + grad fy17 apr 
colnames(Play2)  


#get rid of unwanted columns for FY (anything thats not FY17 )
Drop <- select(Play2, -starts_with("fy2018"))
Drop2 <- select(Drop, -starts_with("fy2019"))
Drop3 <- select(Drop2, -c("fy2017_targets","fy2017q1","fy2017q2","fy2017q3"))



# to view if where indicator is OVC_SERV is where disagg is total numerator
# Check <- filter(Drop3, indicator == "OVC_SERV" & standardizeddisaggregate == "Total Numerator")


psnu_int <- Play2 %>% group_by("psnu","indicator") %>% filter((indicator == "OVC_SERV") & (categoryoptioncomboname == "Active" & categoryoptioncomboname == "Graduated"))
psnu <- unique(Play2$psnu)
for (n in psnu){
  active_value <- if_else(exists(Drop3[ which((Play2$psnu == n) & 
                                         (Drop3$indicator=="OVC_SERV") & 
                                         (Drop3$standardizeddisaggregate == "ProgramStatus") & 
                                         (Drop3$categoryoptioncomboname== "Active")), Drop3$calcfy17apr], 
                                 Drop3[ which((Play2$psnu == n) & 
                                         (Drop3$indicator=="OVC_SERV") & 
                                         (Drop3$standardizeddisaggregate == "ProgramStatus") & 
                                         (Drop3$categoryoptioncomboname== "Active")), Drop3$calcfy17apr], NA))
  print(active_value)
}

