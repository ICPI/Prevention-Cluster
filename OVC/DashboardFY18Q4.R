#Title: Working code
#Date updated: 11/07/2018
#Purpose: To subset PSNU X IM Genie Extract for OVC FY18Q4 clean dashboard


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
genie <- read_msd("GenieOUxIM20181102.txt")

#list column names and numbers
colnames(genie)

#drop any unnecessary columns for OVC dashboard
genie1 <- genie %>% 
  select(operatingunit, countryname:snu1, psnu, snuprioritization:typemilitary, primepartner:implementingmechanismname, indicator:standardizeddisaggregate,
         categoryoptioncomboname:coarsedisaggregate, fy2017_targets, fy2017q2, fy2017q4:fy2017apr, fy2018_targets, fy2018q2, fy2018q4:fy2019_targets)
        
#check the structure of dataset
str(genie1)
names(genie1)
unique(genie1$standardizeddisaggregate)

#remove age/sex/service  
genie2 <- genie1[ which(genie1$standardizeddisaggregate !='Age/Sex/Service'), ]
names(genie2)
unique(genie2$standardizeddisaggregate)

#does the dataset contain any NAs?
any(is.na(genie2))

#how many NAs are there?
sum(is.na(genie2))

#which columns have NAs and how many?
colSums(is.na(genie2))

#check the struture and stats for a specific set of columns
genie2 %>% 
  select(25:33) %>% 
  skim()

#new dataset to filter out NAs & zeroes
genie3 <- genie2

# look at how many records would be left without NAs and zeroes across FY columns
genie3 %>% 
  filter_at(vars(starts_with("FY")), any_vars(!is.na(.) & .!=0)) %>% 
  nrow()

#  filter out the NAs & zeroes
genie4 <- genie3 %>% 
  filter_at(vars(starts_with("FY")), any_vars(!is.na(.) & .!=0))

#how many records remain after removing NAs and zeroes
nrow(genie3) - nrow(genie4)

#check the struture and stats for a specific set of columns
genie4 %>% 
  select(standardizeddisaggregate) %>% 
  skim()


#move "exited without graduated" from program status StandardizedDisaggregate to Transferexit  
genie5 <- genie4 %>%
  mutate(standardizeddisaggregate = case_when(
    otherdisaggregate %in% c('Exited without Graduation', 'Transferred')~ 'TransferExit',
    TRUE~standardizeddisaggregate))


#reshape from wide to long, putting all results/targets into one column; removes rows with missing values too
genie6 <- gather(genie5, key = "period", "value", fy2017_targets:fy2019_targets, na.rm = TRUE)
 

#export wide  to csv/txt for dashboard
write.csv(genie5,"GeniePSNUxIM_OVC_20181106.csv", row.names = FALSE)

#export long to csv for dashboard
write.csv(genie6,"GeniePSNUxIM_OVC_20181106_long.csv", row.names = FALSE)

