#To subset DREAMS MSD
#Date 7/5/2018 KS

memory.limit(size = 90000)

#set working directory and load libraries
setwd("C:/Users/Ksato/Documents/MSD")

library(tidyverse)
library(plyr)

#read in dataset
df1 <- readr::read_tsv("MER_Structured_Dataset_PSNU_IM_DREAMS_FY17-18_20180622_v2_2.txt", col_names = TRUE)

#subset for indicators of interest
subdf1 <- subset(df1, indicator == 'PP_PREV' | indicator == "KP_PREV" | indicator == "KP_PREV_MSMTGSW" | indicator == "GEND_GBV"| 
                   indicator == "VMMC_CIRC" |indicator ==  "PrEP_NEW" |indicator ==  "HTS_TST" |indicator ==  "HTS_TST_NEG" |indicator ==  "HTS_TST_POS" |
                   indicator ==  "OVC_SERV" |indicator ==  "PMTCT_STAT" |indicator ==  "PMTCT_STAT_POS" |indicator ==  "TX_CURR" |indicator ==  "TX_NEW" |indicator ==  "TX_RET")

#drop Rwanda for this round since DSNUs are incorrect
subdf2 <- filter(subdf1, OperatingUnit != 'Rwanda')
unique (subdf2$OperatingUnit)

#remove unnecessary disaggs
subdf3 <- filter(subdf2, standardizedDisaggregate !="ViolenceServiceType" & standardizedDisaggregate !="12mo/HIVStatus" & standardizedDisaggregate !="TB Diagnosis/HIVStatus" & 
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

#Check for unnique variables remaining in StandardizeDisaggregate
unique (subdf3$standardizedDisaggregate)

#Check for unique column names
colnames(subdf3)

#Drop unnecessary columns
subdf4 <- subset(subdf3, select = -c(Region, RegionUID, OperatingUnitUID, CountryName, SNU1Uid, PSNUuid, isMCAD, coarseDisaggregate, disaggregate,
                                     typeMilitary, MechanismUID, categoryOptionComboName, DSNUuid, AgeCoarse))

#Check for unique column names
colnames(subdf4)

#Check for N/A values
is.na(subdf4)

#Replace N/A values with blanks
subdf4 [is.na(subdf4)]=""
is.na(subdf4)

#NOTE- next quarter transform data into "Period" and "Value" columns

#Export dataset to csv or txt to load into Excel dashboard
write.csv(subdf4,"DREAMS_MSD_FY18Q2.csv", row.names = FALSE)
