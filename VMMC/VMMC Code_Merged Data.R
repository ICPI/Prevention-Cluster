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

#----------------------------------------------------------------
# Step 2: Bring in & filter the MER Structured PSNU-IM .txt files
#----------------------------------------------------------------

#create list for filtering to VMMC OUs
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

#create list for filtering to VMMC indicators
indlist <- c("VMMC_CIRC", "VMMC_CIRC_FollowUp")

#create list for filtering to VMMC disaggs
disagglist <- c("Total Numerator", "Age/Sex", "HIVStatus/Sex", "Technique/Sex", "Total FollowUp")

#create list to name vmmc dataframes
vmmclist <- c("vmmc_prev", "vmmc_curr") #dependent on order of files in the project folder

#create list of charatcter variables needed
varlist <- c("CountryName",
             "SNU1",
             "PSNU",
             "SNUPrioritization",
             "PrimePartner",
             "FundingAgency",
             "MechanismID",
             "ImplementingMechanismName",
             "indicator",
             "numeratorDenom",
             "indicatorType",
             "disaggregate",
             "standardizedDisaggregate",
             "categoryOptionComboName",
             "Age",
             "resultStatus",
             "otherDisaggregate",
             "coarseDisaggregate")

#creates a list of the .txt file names
MSDnames <- list.files(pattern="*.txt")

#function to read in and filter the files
ReadVMMC <- function(file) {
  vmmc <- read_tsv(file, col_types = 
                     cols(MechanismID =        "c",
                          coarseDisaggregate = "c",
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
                          FY2018Q3 =           "d"))
  vmmc %>%
    filter(OperatingUnit %in% oulist & indicator %in% indlist
           & standardizedDisaggregate %in% disagglist)
}

for (i in 1:length(MSDnames)){
  assign(vmmclist[i], ReadVMMC(MSDnames[i]))
}

#---------------------------------
#Step 3: Join the VMMC data frames
#---------------------------------

#function that allows you differentiate 0 values from NA values
sum.na <- function(df){
  if (all(is.na(df))){
        suma <- NA
  }  
  else {    
    suma <- sum(df, na.rm = TRUE)
  }
    return(suma)
}

#clean up the two datasets, keep only needed columns
#summarizing and filter functions are needed for the older MSD to remove duplicative rows
#as well as all rows containing only NA values
vmmc_prev1 <- vmmc_prev %>% 
  rename(SNUPrioritization = CurrentSNUPrioritization) %>%
  select(varlist, starts_with("FY2015"), starts_with("FY2016")) %>%
  group_by_if(is.character) %>% 
  summarize_at(vars(contains("FY20")), funs(sum.na)) %>% 
  filter_at(vars(contains("FY20")), any_vars(!is.na(.))) %>% 
  ungroup()

vmmc_curr1 <- vmmc_curr %>%
  rename(Age = AgeAsEntered) %>%
  select(varlist, starts_with("FY20")) %>% 
  group_by_if(is.character) %>% 
  summarize_at(vars(contains("FY20")), funs(sum.na)) %>% 
  filter_at(vars(contains("FY20")), any_vars(!is.na(.))) %>% 
  ungroup()


vmmc_all <- full_join(vmmc_prev1, vmmc_curr1, by = varlist)

#Check to confirm the join worked properly, output should be true
all.equal(
  checkall <-
    vmmc_all %>%
    filter(standardizedDisaggregate == "Total Numerator") %>% 
    group_by(CountryName) %>% 
    summarize_at(vars(contains("FY20")), funs(sum), na.rm = TRUE) %>%
    ungroup(),
  
  checkold <-
    full_join(
      vmmc_curr1 %>%
        filter(standardizedDisaggregate == "Total Numerator") %>%
        group_by(CountryName) %>%
        summarize_at(vars(contains("FY20")), funs(sum), na.rm = TRUE) %>%
        ungroup(),
      
      vmmc_prev1 %>%
        filter(standardizedDisaggregate == "Total Numerator") %>% 
        group_by(CountryName) %>% 
        summarize_at(vars(contains("FY20")), funs(sum), na.rm = TRUE) %>% 
        ungroup()))

#-------------------------------------------------------------------------------------
#Step 4: Recode age variables, create cumulative, special and disaggcatcombo variables
#-------------------------------------------------------------------------------------

vmmc_data <- vmmc_all %>%
  
  #recode age from the MSD to VMMC age bands 
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
             Age == "50+"                  ~"50+"
             )) %>%
  
  #create new variable with priority age bands
  mutate(Age_Priority =
           case_when(
             Age_MER2 == "<2 months"          ~ "<15", 
             Age_MER2 == "2 months - 9 years" ~"<15",
             Age_MER2 == "10-14"              ~ "<15",
             Age_MER2 == "15-19"              ~ "15 - 29",
             Age_MER2 == "20-24"              ~ "15 - 29",
             Age_MER2 == "25-29"              ~ "15 - 29",
             Age_MER2 == "30-49"              ~ "30+",
             Age_MER2 == "50+"                ~ "30+")) %>% 
  
  #clean up the standardizedDisaggregate variable a bit
  mutate(standardizedDisaggregate = 
           recode(standardizedDisaggregate, "Age/Sex" = "Age", "HIVStatus/Sex" = "HIV Status", "Technique/Sex" = "Technique",
                  "Total FollowUp" = "Total Follow-Up")) %>% 
  
  #remove ", Male" from categoryOptionCombo
  separate(categoryOptionComboName, "categoryOptionComboName", sep = ",", extra = "drop") %>% 
  
  #disagg_catcomboname is used to create the disagg pivots for SNU/IM tabs
  mutate(disagg_catcomboname = 
           ifelse(standardizedDisaggregate %in% "Age", Age_Priority,
                  ifelse(standardizedDisaggregate %in% "Total Numerator",
                         standardizedDisaggregate, categoryOptionComboName))) %>% 
  
  rowwise() %>% 
  
  #this needs to be updated each quarter as this sums up to current quarter vs. previous quarters
  mutate(FY_Cum_current = 
           ifelse(is.na(FY2018Q1) & is.na(FY2018Q2) & is.na(FY2018Q3), NA, sum(FY2018Q1, FY2018Q2, FY2018Q3, na.rm=T))) %>%
  
  mutate(FY_Cum_previous = 
           ifelse(is.na(FY2017Q1) & is.na(FY2017Q2) & is.na(FY2017Q3), NA, sum(FY2017Q1, FY2017Q2, FY2017Q3, na.rm=T))) %>%
  
  #the special variable is used in as a filter in the tool so pivots only show rows with data
  mutate(special =
           ifelse(sum(FY_Cum_current, FY2018_TARGETS, na.rm = T) == 0 | is.na(sum(FY_Cum_current, FY2018_TARGETS, na.rm = T)),
                  "Blank", "Data")) %>%
  
  ungroup()

#Check to confirm age recodes worked properly
agetable <- table(vmmc_data$Age, vmmc_data$Age_MER2, vmmc_data$Age_Priority)
agetable

#Check to confirm disagg_catcombo variable worked
disaggtable <- table(vmmc_data$standardizedDisaggregate, vmmc_data$disagg_catcomboname)
disaggtable

#Check to confirm special variable worked
vmmc_data %>%
  filter(special %in% "Blank") %>%
  select(special, FY_Cum_current, FY2018_TARGETS) %>%
  head()

vmmc_data %>%
  filter(special %in% "Data")%>%
  select(special, FY_Cum_current, FY2018_TARGETS) %>%
  head()

#--------------------------------------------
# Step 5: Create and Export the Final Dataset
#--------------------------------------------

final <- vmmc_data %>%
   select(varlist, Age_MER2, Age_Priority, special, disagg_catcomboname, FY_Cum_previous, FY_Cum_current,
        contains("FY20")) 
  
write_tsv(final, "Final Data/VMMC Tool Data_FY18Q3i_09072018.txt", na="")


  
