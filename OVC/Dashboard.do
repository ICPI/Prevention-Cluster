*********************************************
Date updated: 5/24/2018
Analyst: Katya Noykhovich
Purpose: To subset PSNU X IM factview for OVC FY18Q2 dashboard
**********************************************

*import dataset, edit file location as needed
import delimited C:\Users\knoykhovich\Desktop\datasets\ICPI_MER_Structured_Dataset_PSNU_IM_FY17-18_20180515_v1_1.txt

*keep only specific OVC indicators (another option would be to use inlist)
keep if indicator == "OVC_HIVSTAT" | indicator == "OVC_HIVSTAT_NEG" | indicator == "OVC_HIVSTAT_POS" | indicator == "OVC_SERV" | indicator == "OVC_SERV_OVER_18" | indicator == "OVC_SERV_UNDER_18"

*drop any unnecessary columns for OVC dashboard
drop ïregion regionuid operatingunituid snu1uid psnuuid mechanismuid dataelementuid categoryoptioncombouid modality ismcad fy2017q1 fy2017q3 fy2018q1

*change values to numeric instead of strings
destring fy2017_targets fy2017q2 fy2017q4 fy2017apr fy2018_targets fy2018q2, replace ignore(NULL)

*move exited without graduation under TransferExit 

replace standardizeddisaggregate = "TransferExit" if otherdisaggregate == "Exited without Graduation"
replace standardizeddisaggregate = "TransferExit" if otherdisaggregate == "Transferred"
replace otherdisaggregate = "Transferred out - non PEPFAR Support Partner" if otherdisaggregate == "Transferred"
