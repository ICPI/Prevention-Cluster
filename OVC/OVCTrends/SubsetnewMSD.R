#Date updated: 01/24/2019
#Purpose: To subset PSNU X IM MSD new format for OVC Trends Analysis
#Software: R

#A.inrcease memory and check working directory
memory.limit(size = 90000)
getwd()

#B.Installation directory - please change username to your username. This will direct R libraries/packages to install and run smoothly with RStudio.
.libPaths(c("C:/Users/USERNAME/R", .libPaths()))

#C. install & load packages 
install.packages('tidyverse')
install.packages('dplyr')
install.packages("devtools")
devtools::install_github("ICPI/ICPIutilities")
install.packages("skimr")
library(skimr)
library(tidyverse)
library(ICPIutilities)


#1 read df file
df1 <- read_msd("MER_Structured_Dataset_PSNU_IM_FY17-18_20181221_v2_1_new_format.txt")

#2 list column names and numbers
colnames(df1)

#3 drop any unnecessary columns for OVC dashboard
df1b <- df1 %>% 
  select(operatingunit, snu1, psnu, snuprioritization:typemilitary, primepartner:statushiv, otherdisaggregate, fiscal_year:targets, qtr2, qtr4:cumulative)

#4 drop all indicators but OVC SERV, OVC_HIVSTAT
unique(df1b$indicator)
df2 <- filter(df1b, indicator == "OVC_HIVSTAT" | indicator == "OVC_SERV" | indicator == "OVC_SERV_OVER_18"| indicator == "OVC_SERV_UNDER_18" | indicator == "OVC_HIVSTAT_NEG" | indicator == "OVC_HIVSTAT_POS")


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
  filter_at(vars(starts_with("qtr")), any_vars(!is.na(.) & .!=0)) %>% 
  nrow()

#12 filter out the NAs & zeroes
df6 <- df5 %>% 
  filter_at(vars(starts_with("qtr")), any_vars(!is.na(.) & .!=0))

#13 how many records remain after removing NAs and zeroes
nrow(df6) - nrow(df5)

#14 convert values to numeric 
str(df6)
type_convert(df6)

###HOLD pending test in new structure Create new column called "calcfy2018apr" to pull Q4 values from Age/Sex disaggs and TransferExit disaggs into new calcfy2018aapr column, all other values take from fy2018apr and put into new "calcfy2018apr" column. 
df6 <- mutate(df5, calcfy2018apr = if_else(indicator == "OVC_SERV" & standardizeddisaggregate == "Age/Sex", fy2018q4,
                                                 if_else(indicator == "OVC_SERV" & standardizeddisaggregate == "TransferExit", fy2018q4, 
                                                         if_else(indicator == "OVC_HIVSTAT" | indicator == "OVC_HIVSTAT_POS" | indicator == "OVC_HIVSTAT_NEG", fy2018q4, 
                                                                 if_else(indicator == "OVC_SERV", fy2018q4, fy2018apr)))))


#export wide  to csv/txt for dashboard (testing age/sex and transferexit APR calculation)
write.csv(df6,"PSNUxIM_OVCTrends_20181221newformat.csv", row.names = FALSE)


