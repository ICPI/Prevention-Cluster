#Date updated: 02/05/2019
#Purpose: To subset PSNU X IM MSD for OVC Trends Analysis
#Software: R

#A.inrcease memory and check working directory
memory.limit(size = 90000)
getwd()

#B.Installation directory - please change username to your username. This will direct R libraries/packages to install and run smoothly with RStudio.
.libPaths(c("C:/Users/knoykhovich/R", .libPaths()))

#C. install & load packages 
install.packages('tidyverse')
install.packages('dplyr')
install.packages("devtools")
devtools::install_github("ICPI/ICPIutilities")
install.packages("skimr")
library(skimr)
library(tidyverse)
library(ICPIutilities)
library(dplyr)


#1 read df file
df1 <- read_msd("MER_Structured_Dataset_PSNU_IM_FY17-18_20181221_v2_1.txt")

#2 list column names and numbers
colnames(df1)

#3 drop any unnecessary columns
df1b <- df1 %>% 
  select(operatingunit, snu1, psnu, snuprioritization:typemilitary, primepartner:coarsedisaggregate, fy2017_targets, fy2017q2, fy2017q4, fy2017apr, fy2018_targets, fy2018q2, fy2018q4:fy2019_targets)

#4 drop all indicators but OVC SERV, OVC_HIVSTAT
unique(df1b$indicator)
df2 <- filter(df1b, indicator == "OVC_HIVSTAT" | indicator == "OVC_SERV" | indicator == "OVC_SERV_OVER_18"| indicator == "OVC_SERV_UNDER_18" | indicator == "OVC_HIVSTAT_NEG" | indicator == "OVC_HIVSTAT_POS")
colnames(df2)
unique(df2$indicator)

##EXPLORATION: what are the unique disaggregates under OVC_SERV?
testdisaggs <- data.frame(df2$indicator, df2$standardizeddisaggregate, df2$otherdisaggregate)
unique(testdisaggs[which(testdisaggs$df2.indicator == "OVC_SERV"), ])


#5 remove age/sex/service disaggregate as that is DREAMS only 
df3 <- df2[ which(df2$standardizeddisaggregate !='Age/Sex/Service'), ]
unique(df3$standardizeddisaggregate)


#6 remove exit without graduation from program status
df4 <- filter(df3, standardizeddisaggregate != "ProgramStatus" | categoryoptioncomboname != "Exited without Graduation")

#7 remove "Transferred" from program status
df5 <- filter(df4, standardizeddisaggregate != "ProgramStatus" | otherdisaggregate != "Transferred")

#8 does the dataset contain any NAs?
any(is.na(df5))

#9 how many NAs are there?
sum(is.na(df5))

#10 which columns have NAs and how many?
colSums(is.na(df5))

#11 look at how many records would be left without NAs and zeroes across FY columns
df5 %>% 
  filter_at(vars(starts_with("fy")), any_vars(!is.na(.) & .!=0)) %>% 
  nrow()

#12 filter out the NAs & zeroes
df6 <- df5 %>% 
  filter_at(vars(starts_with("fy")), any_vars(!is.na(.) & .!=0))

#13 how many records remain after removing NAs and zeroes
nrow(df6) - nrow(df5)

#14 reshape to long
longdf <- gather(df6, key = "period", "value", fy2017_targets:fy2019_targets, na.rm=TRUE)
write.csv(longdf,"PSNUxIM_OVC_20181221_Feb5.csv", row.names = FALSE)


### WORKING DRAFT CODE BELOW 
###Create new column called "calcfy17apr" to pull Q4 values from Total Num, all other values take from fy17apr and put into new "calcfy17apr" column. 
#df7 <- mutate(df6, calcfy17apr = if_else(indicator == "OVC_SERV" & standardizeddisaggregate == "Total Numerator", fy2017q4, fy2017apr))
# fix OVC SERV total numerator FY17apr = active fy17apr + grad fy17 apr

# add fy2017apr active + graduated to equal Total Numerator for fy2017apr
#df8 <- mutate(df7, calcfyapr = ifelse((otherdisaggregate == "Active" & otherdisaggregate == "Graduated", fy2017apr + fy2017apr ,fy2017apr)

# df8 <- df7 %>% 
#   group_by(indicator == "OVC_SERV", otherdisaggregate) %>% 
#   mutate_if(calcfy17apr = ifelse((otherdisaggregate == "Active"), fy2017apr + if(otherdisaggregate == "Graduated", fy2017apr,fy2017apr),fy2017apr))
# 
# df8 <- df7 %>% 
#  group_by(indicator == "OVC_SERV", otherdisaggregate) %>% 
#   filter(otherdisaggregate == "Active" | "Graduated") %>% 
#   mutate(calcfy17apr = fy2017apr + fy2017apr)
# 

#export wide  to csv/txt for dashboard (testing age/sex and transferexit APR calculation)
#write.csv(df7,"PSNUxIM_OVC_20181221_Feb5.csv", row.names = FALSE)
