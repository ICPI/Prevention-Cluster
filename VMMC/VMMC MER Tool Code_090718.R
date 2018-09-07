#-----------------------------------------------------------------------------
#                         VMMC MER Tool Script  
#                              9/7/2018
#                            Created by:
#                   Dustyn Palmer & Brittney Baack
#                           VMMC ICPI Team
#-----------------------------------------------------------------------------

#-------------------------------
# Step 1: Load required packages
#-------------------------------

if(!require(readr)){
  install.packages("readr")
}
library(readr)

if(!require(tidyverse)){
  install.packages("tidyverse")
}
library(tidyverse)

if(!require(eply)){
  install.packages("eply")
}
library(eply)


if(!require(knitr)){
  install.packages("knitr")
}
library(knitr)


#-----------------------------------------------------------------------
# Step 2: Bring in the MER Structured PSNU-IM .txt file
# Note: FY15-16 columns are to retain tool structure, will not have data
#-----------------------------------------------------------------------

#Add dataset to R project, then update file name here
FactView_name <-
  "MER_Structured_Dataset_PSNU_IM_FY17-18_20180815_v1_1.txt"

# Read the PSNU-IM FactView dataset 
fact <- read_tsv(file=FactView_name, 
                 col_types = cols(MechanismID =        "c",
                                  FY2015Q2 =           "d",      
                                  FY2015Q3 =           "d",      
                                  FY2015Q4 =           "d",      
                                  FY2015APR =          "d",     
                                  FY2016_TARGETS =     "d",
                                  FY2016Q1 =           "d",      
                                  FY2016Q2 =           "d",      
                                  FY2016Q3 =           "d",      
                                  FY2016Q4 =           "d",      
                                  FY2016APR =          "d",     
                                  FY2017_TARGETS =     "d",
                                  FY2017Q1 =           "d",      
                                  FY2017Q2 =           "d",      
                                  FY2017Q3 =           "d",      
                                  FY2017Q4 =           "d",      
                                  FY2017APR =          "d",
                                  FY2018_TARGETS =     "d",
                                  FY2018Q1 =           "d",
                                  FY2018Q2 =           "d",
                                  FY2018Q3 =           "d",
                                  coarseDisaggregate = "c"))


#--------------------------------------------------------------------------
# Step 3: Subset by Operating Unit, Indicators & Standardized Disaggregates
#--------------------------------------------------------------------------

#Create list for filtering to VMMC OUs
oulist <- c("Botswana",
            "Ethiopia",
            "Kenya",
            "Lesotho",
            "Malawi",
            "Mozambique",
            "Namibia",
            "Rwanda",
            "South Africa",
            "Swaziland",
            "Tanzania",
            "Uganda",
            "Zambia",
            "Zimbabwe" )

#Create list for filtering to VMMC Indicators
indlist <- c("VMMC_CIRC", "VMMC_CIRC_FollowUp")


#Filter to VMMC OUs, VMMC Indicators, and Required Standardized Disaggregates
#Note: Required Standardized Disaggregates may change with updates to dataset
vmmc <- fact %>%
  filter(OperatingUnit %in% oulist &
           indicator %in% indlist) %>%
  
  filter(standardizedDisaggregate %in% c("Total Numerator", "Age/Sex", "HIVStatus/Sex", 
                                         "Technique/Sex", "Total FollowUp"))
  
#Check to confirm dataset filtered properly
unique(vmmc$OperatingUnit)
unique(vmmc$indicator)
unique(vmmc$standardizedDisaggregate)


#----------------------------------------------------------------------------------------
# Step 4: Recode age variables; create cumulative, special, and disagg_catcombo variables 
#----------------------------------------------------------------------------------------

vmmc_data <- vmmc %>%

  rename(Age = AgeAsEntered) %>% 
  
  #recodes ages in MSD to VMMC specified age-bands, if these change in MSD need to be updated
  mutate(Age_MER2 =
           case_when(
             Age == "<02 Months"           ~"<2 months",
             Age == "<01"                  ~"<2 months",
             Age == "01-09"                ~"2 months - 9 years",
             Age == "02 Months - 09 Years" ~"2 months - 9 years",
             Age == "10-14"                ~"10-14",
             Age == "15-19"                ~"15-19",
             Age == "20-24"                ~"20-24",
             Age == "25-29"                ~"25-29",
             Age == "30-49"                ~"30-49",
             Age == "30-34"                ~"30-49",
             Age == "35-39"                ~"30-49",
             Age == "40-49"                ~"30-49",
             Age == "50+"                  ~"50+"      )) %>% 
  
  #creates priortiy age bands for VMMC, if these change in MSD need to be updated
  mutate(Age_priority =
           case_when(
             Age == "<02 Months"           ~ "<15", 
             Age == "<01"                  ~ "<15",
             Age == "01-09"                ~ "<15",
             Age == "02 Months - 09 Years" ~ "<15",
             Age == "10-14"                ~ "<15",
             Age == "15-19"                ~ "15 - 29",
             Age == "20-24"                ~ "15 - 29",
             Age == "25-29"                ~ "15 - 29",
             Age == "30-49"                ~ "30+",
             Age == "30-34"                ~ "30+",
             Age == "35-39"                ~ "30+",
             Age == "40-49"                ~ "30+",
             Age == "50+"                  ~ "30+")) %>% 
  

  rowwise()%>%
  
  #this needs to be updated each quarter as this sums up to current quarter vs. previous quarters
  mutate(FY_Cum_current = 
           ifelse(is.na(FY2018Q1) & is.na(FY2018Q2) & is.na(FY2018Q3), NA, sum(FY2018Q1, FY2018Q2, FY2018Q3, na.rm=T))) %>%
           
  mutate(FY_Cum_previous = 
           ifelse(is.na(FY2017Q1) & is.na(FY2017Q2) & is.na(FY2017Q3), NA, sum(FY2017Q1, FY2017Q2, FY2017Q3, na.rm=T))) %>%
  
  #the special variable is used in as a filter in the tool so pivots only show rows with data
  mutate(special =
           ifelse(sum(FY_Cum_current, FY2018_TARGETS, na.rm = T) == 0 | is.na(sum(FY_Cum_current, FY2018_TARGETS, na.rm = T)),
                  "Blank", "Data")) %>%
  
  ungroup()%>%
  
  #disagg_catcomboname is used to create the disagg pivots for SNU/IM tabs
  mutate(disagg_catcomboname = 
           ifelse(standardizedDisaggregate %in% "Age/Sex", Age_priority,
                  ifelse(standardizedDisaggregate %in% "Total Numerator",
                         standardizedDisaggregate, categoryOptionComboName))) 

#Check to confirm age recodes worked properly
agetable <- table(vmmc_data$Age, vmmc_data$Age_MER2, vmmc_data$Age_priority)
agetable

#Check to confirm special variable worked
vmmc_data %>%
  filter(special %in% "Blank") %>%
  select(special, FY_Cum_current, FY2018_TARGETS) %>%
  head()

vmmc_data %>%
  filter(special %in% "Data")%>%
  select(special, FY_Cum_current, FY2018_TARGETS) %>%
  head()

#Check to confirm disagg_catcombo variable worked
disaggtable <- table(vmmc_data$standardizedDisaggregate, vmmc_data$disagg_catcomboname)
disaggtable


#--------------------------------------------
# Step 5: Create and Export the Final Dataset
#--------------------------------------------

final <- vmmc_data %>%
  
  mutate(
    FY2015Q2 =       NA,
    FY2015Q3 =       NA,
    FY2015Q4 =       NA,
    FY2015APR =      NA,
    FY2016_TARGETS = NA,
    FY2016Q1 =       NA,
    FY2016Q2 =       NA,
    FY2016Q3 =       NA,
    FY2016Q4 =       NA,
    FY2016APR =      NA
  ) %>% 
  
  select(
    CountryName,
    SNU1,
    PSNU,
    SNUPrioritization,
    PrimePartner,
    FundingAgency,
    MechanismID,
    ImplementingMechanismName,
    indicator,
    numeratorDenom,
    indicatorType,
    disaggregate,
    standardizedDisaggregate,
    categoryOptionComboName,
    Age,
    resultStatus,
    otherDisaggregate,
    coarseDisaggregate,
    Age_MER2,
    Age_priority,
    special,
    disagg_catcomboname,
    FY_Cum_previous,
    FY_Cum_current,
    FY2015Q2,
    FY2015Q3,
    FY2015Q4,
    FY2015APR,
    FY2016_TARGETS,
    FY2016Q1,
    FY2016Q2,
    FY2016Q3,
    FY2016Q4,
    FY2016APR,
    FY2017_TARGETS,
    FY2017Q1,
    FY2017Q2,
    FY2017Q3,
    FY2017Q4,
    FY2017APR,
    FY2018_TARGETS,
    FY2018Q1,
    FY2018Q2,
    FY2018Q3
  )

write_tsv(final, "VMMC Tool Data_FY18Q3i_09072018.txt", na="")
