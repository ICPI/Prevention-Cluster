#Date updated: 11/16/2018
#Purpose: To subset PSNU X IM Genie Extract for OVC FY18Q4 clean dashboard
#Software: R

#increase memory
memory.limit(size = 90000)

#install & load packages 
install.packages('tidyverse')
install.packages('dplyr')
install.packages("devtools")
devtools::install_github("ICPI/ICPIutilities")
install.packages("skimr")
library(skimr)
library(tidyverse)
library(ICPIutilities)

#read genie file using ICPI Utilities (read_msd)
genie <- read_msd("DHIS2_ef2d178f5bd340779acfcea01eb19bed.txt")

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

#remove age/sex/service from the standardized disaggregate column since that is only for DREAMS 
genie2 <- genie1[ which(genie1$standardizeddisaggregate !='Age/Sex/Service'), ]
names(genie2)
unique(genie2$standardizeddisaggregate)

#check if the dataset contains any NAs
any(is.na(genie2))

#how many NAs are there?
sum(is.na(genie2))

#which columns have NAs and how many?
colSums(is.na(genie2))

#check the struture and stats for a specific set of columns
genie2 %>% 
  select(25:33) %>% 
  skim()

#create a new dataset to filter out NAs & zeroes
genie3 <- genie2

#look at how many records would be left without NAs and zeroes across FY columns
genie3 %>% 
  filter_at(vars(starts_with("FY")), any_vars(!is.na(.) & .!=0)) %>% 
  nrow()

#filter out the NAs & zeroes
genie4 <- genie3 %>% 
  filter_at(vars(starts_with("FY")), any_vars(!is.na(.) & .!=0))

#how many records remain after removing NAs and zeroes
nrow(genie3) - nrow(genie4)

#check the struture and stats for a specific set of columns
genie4 %>% 
  select(standardizeddisaggregate) %>% 
  skim()


#move "exited without graduated" from program status StandardizedDisaggregate to Transferexit since it is duplicated in the ProgramStatus category
genie5 <- genie4 %>%
  mutate(standardizeddisaggregate = case_when(
    otherdisaggregate %in% c('Exited without Graduation', 'Transferred')~ 'TransferExit',
    TRUE~standardizeddisaggregate))

#check dataset
head(genie5)

# Create new column called "calcfy2018apr" to pull Q4 values from Age/Sex disaggs and TransferExit disaggs into new calcfy2018aapr column, all other values take from fy2018apr and put into new "calcfy2018apr" column. 
genie6 <- mutate(genie5, calcfy2018apr = if_else(indicator == "OVC_SERV" & standardizeddisaggregate == "Age/Sex", fy2018q4,
                                       if_else(indicator == "OVC_SERV" & standardizeddisaggregate == "TransferExit", fy2018q4, fy2018apr)))


#export wide  to csv/txt for dashboard (testing age/sex and transferexit APR calculation)
write.csv(genie6,"GeniePSNUxIM_OVC_20181116b.csv", row.names = FALSE)
