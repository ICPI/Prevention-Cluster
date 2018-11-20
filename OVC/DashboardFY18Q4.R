#Date updated: 11/20/2018
#Purpose: To subset PSNU X IM Genie Extract for OVC FY18Q4 clean dashboard
#Software: R

memory.limit(size = 90000)


getwd()

#install & load packages 
install.packages('tidyverse')
install.packages('dplyr')
install.packages("devtools")
devtools::install_github("ICPI/ICPIutilities")
install.packages("skimr")
library(skimr)
library(tidyverse)
library(ICPIutilities)

#read genie file
genie <- read_msd("Genie Download OVC_SERV OVCHIVSTAT_20181116.txt")

#list column names and numbers

colnames(genie)

#drop any unnecessary columns for OVC dashboard
genie1 <- genie %>% 
  select(operatingunit, countryname:snu1, psnu, snuprioritization:typemilitary, primepartner:implementingmechanismname, indicator:standardizeddisaggregate,
         categoryoptioncomboname:coarsedisaggregate, fy2018_targets, fy2018q2, fy2018q4:fy2019_targets)
        
#check the structure of dataset
str(genie1)
names(genie1)
unique(genie1$standardizeddisaggregate)

#remove age/sex/service  
genie2 <- genie1[ which(genie1$standardizeddisaggregate !='Age/Sex/Service'), ]
names(genie2)
unique(genie2$standardizeddisaggregate)

#remove exit without graduation from program status
genie3 <- filter(genie2, standardizeddisaggregate != "ProgramStatus" | categoryoptioncomboname != "Exited without Graduation")

names(genie3)
unique(genie3$standardizeddisaggregate)
unique(genie3$categoryoptioncomboname)

#does the dataset contain any NAs?
any(is.na(genie3))

#how many NAs are there?
sum(is.na(genie3))

#which columns have NAs and how many?
colSums(is.na(genie3))

#check the struture and stats for a specific set of columns
genie3 %>% 
  select(25:33) %>% 
  skim()

#new dataset to filter out NAs & zeroes
genie4 <- genie3

# look at how many records would be left without NAs and zeroes across FY columns
genie4 %>% 
  filter_at(vars(starts_with("FY")), any_vars(!is.na(.) & .!=0)) %>% 
  nrow()

#  filter out the NAs & zeroes
genie5 <- genie4 %>% 
  filter_at(vars(starts_with("FY")), any_vars(!is.na(.) & .!=0))

#how many records remain after removing NAs and zeroes
nrow(genie4) - nrow(genie5)

#check the struture and stats for a specific set of columns
genie5 %>% 
  select(standardizeddisaggregate) %>% 
  skim()


# Check indicators
unique(genie5$indicator)


# Create new column called "calcfy2018apr" to pull Q4 values from Age/Sex disaggs and TransferExit disaggs into new calcfy2018aapr column, all other values take from fy2018apr and put into new "calcfy2018apr" column. 
genie6 <- mutate(genie5, calcfy2018apr = if_else(indicator == "OVC_SERV" & standardizeddisaggregate == "Age/Sex", fy2018q4,
                                                 if_else(indicator == "OVC_SERV" & standardizeddisaggregate == "TransferExit", fy2018q4, 
                                                         if_else(indicator == "OVC_HIVSTAT" | indicator == "OVC_HIVSTAT_POS" | indicator == "OVC_HIVSTAT_NEG", fy2018q4, 
                                                                 if_else(indicator == "OVC_SERV", fy2018q4, fy2018apr)))))


#export wide  to csv/txt for dashboard (testing age/sex and transferexit APR calculation)
write.csv(genie6,"GeniePSNUxIM_OVC_20181120.csv", row.names = FALSE)

