#To subset DREAMS MSD
#Date 8/27/2018 KS

memory.limit(size = 90000)

#set working directory and load libraries
# setwd("C:/Users/Ksato/DREAMS")

library(tidyverse)
library(plyr)
#library(ICPIutilities)

#             "c" = character 
#             "i" = integer 
#             "n" = number 
#             "d" = double (includes decimals)
#             "l" = logical 
#             "D" = date 
#             "T" = date time 
#             "t" = time 
#             "?" = guess


# Add customized variable types for accuracy and update text file name
df1 <- read_tsv(file = "MER_Structured_Dataset_PSNU_IM_DREAMS_FY17-18_20180815_v1_1.txt", 
                     col_types = cols(MechanismID        = "c",
                                      AgeAsEntered       = "c",            
                                      AgeFine            = "c",     
                                      AgeSemiFine        = "c",    
                                      AgeCoarse          = "c",      
                                      Sex                = "c",     
                                      resultStatus       = "c",     
                                      otherDisaggregate  = "c",     
                                      coarseDisaggregate = "c",     
                                      FY2017_TARGETS     = "d",
                                      FY2017Q1           = "d",      
                                      FY2017Q2           = "d",      
                                      FY2017Q3           = "d",      
                                      FY2017Q4           = "d",      
                                      FY2017APR          = "d",
                                      FY2018Q1           = "d",
                                      FY2018Q2           = "d",
                                      FY2018_TARGETS     = "d",
                                      FY2019_TARGETS     = "d"))
# Check data classes for all variables
spec(df1)

#subset for indicators of interest
subdf1 <- subset(df1, indicator == 'PP_PREV' | indicator == "KP_PREV" | indicator == "KP_PREV_MSMTGSW" | indicator == "GEND_GBV"| 
                   indicator == "VMMC_CIRC" |indicator ==  "PrEP_NEW" |indicator ==  "HTS_TST" |indicator ==  "HTS_TST_NEG" |indicator ==  "HTS_TST_POS" |
                   indicator ==  "OVC_SERV" |indicator ==  "PMTCT_STAT" |indicator ==  "PMTCT_STAT_POS" |indicator ==  "TX_CURR" |indicator ==  "TX_NEW" |indicator ==  "TX_RET")

#remove unnecessary disaggs
subdf2 <- filter(subdf1, standardizedDisaggregate !="ViolenceServiceType" & standardizedDisaggregate !="12mo/HIVStatus" & standardizedDisaggregate !="TB Diagnosis/HIVStatus" & 
                   standardizedDisaggregate !="Age Aggregated/Sex" & standardizedDisaggregate !="Known/New" & standardizedDisaggregate !="KeyPop/Result"
                 & standardizedDisaggregate !="FacilityDeliveryPoint" & standardizedDisaggregate !="Technique/Sex" & standardizedDisaggregate !="CommunityDeliveryPoint"
                 & standardizedDisaggregate !="36mo" & standardizedDisaggregate !="Results" & standardizedDisaggregate !="ServiceDeliveryPoint/Result"
                 & standardizedDisaggregate !="ProgramStatus" & standardizedDisaggregate !="MostCompleteAgeDisagg" & standardizedDisaggregate !="24mo"
                 & standardizedDisaggregate !="KeyPopAbr" & standardizedDisaggregate !="PregnantOrBreastfeeding/HIVStatus" & standardizedDisaggregate !="ServiceDeliveryPoint"
                 & standardizedDisaggregate !="Modality/Age Aggregated/Sex/Result" & standardizedDisaggregate !="Age Aggregated/Sex/HIVStatus" & standardizedDisaggregate !="Positive"
                 & standardizedDisaggregate !="TransferExit" & standardizedDisaggregate !="TechFollowUp/Sex" & standardizedDisaggregate !="PEP"
                 & standardizedDisaggregate !="Modality/MostCompleteAgeDisagg" & standardizedDisaggregate !="Status" & standardizedDisaggregate !="Age Aggregated/Sex/Result" 
                 & standardizedDisaggregate !="KeyPop/HIVStatus" & standardizedDisaggregate !="KeyPop/Status" & standardizedDisaggregate !="TechFollowUp>14days/Sex"
                 & standardizedDisaggregate !="TB Diagnosis" & standardizedDisaggregate !="Total Denominator" & standardizedDisaggregate !="12mo")

#Check for unique variables remaining in StandardizeDisaggregate
unique (subdf2$standardizedDisaggregate)

#Filter out Rwanda military DSNU (it shouldn't be listed as a DREAMS SNU)
subdf2 <- filter(subdf2, DSNU != "_Military Rwanda")
unique (subdf2$DSNU)

#Check for unique column names
colnames(subdf2)

#Drop unnecessary columns
subdf3 <- subset(subdf2, select = -c(Region, RegionUID, OperatingUnitUID, CountryName, SNU1Uid, PSNUuid, isMCAD, coarseDisaggregate, disaggregate,
                                     typeMilitary, MechanismUID, categoryOptionComboName, DSNUuid, AgeCoarse))

#Check for unique column names
colnames(subdf3)

#Check for N/A values
is.na(subdf3)

#Replace N/A values with blanks
subdf3 [is.na(subdf3)]=""
is.na(subdf3)

#NOTE- next quarter transform data into "Period" and "Value" columns

#Export dataset to csv or txt to load into Excel dashboard
write.csv(subdf3,"DREAMS_MSD_FY18Q3_initial.csv", row.names = FALSE)
