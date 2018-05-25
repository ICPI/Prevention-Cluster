
*********************************************
Date updated: 5/25/2018
Analyst: Katya Noykhovich
Purpose: To subset PSNU X IM factview for Prevention Reference Tables
**********************************************

*import dataset, edit file location as needed
import delimited C:\Users\knoykhovich\Desktop\datasets\ICPI_MER_Structured_Dataset_PSNU_IM_FY17-18_20180515_v1_1.txt

*drop unnecessary fields
drop ïregion regionuid operatingunituid snu1uid psnuuid mechanismuid dataelementuid categoryoptioncombouid modality ismcad

keep if indicator == "PP_PREV" | indicator == "KP_PREV" | indicator == "KP_PREV_MSMTGSW" | indicator == "GEND_GBV" | indicator == "VMMC_CIRC" | indicator == "PrEP_NEW"

*change values to numeric instead of strings
destring fy2017_targets fy2017q1 fy2017q2 fy2017q3 fy2017q4 fy2017apr fy2018_targets fy2018q1 fy2018q2, replace ignore(NULL)


