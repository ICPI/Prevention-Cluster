*********************************************
Date updated: 7/02/2018
Analyst: Katya Noykhovich
Purpose: To subset PSNU X IM factview for OVC FY18Q2 clean dashboard
Software: Stata
**********************************************

*import dataset, edit file name/location as needed
import delimited filename.txt

*keep only specific OVC indicators (another option would be to use inlist)
keep if indicator == "OVC_HIVSTAT" | indicator == "OVC_HIVSTAT_NEG" | indicator == "OVC_HIVSTAT_POS" | indicator == "OVC_SERV" | indicator == "OVC_SERV_OVER_18" | indicator == "OVC_SERV_UNDER_18"

*drop any unnecessary columns for OVC dashboard
drop ïregion regionuid operatingunituid snu1uid psnuuid mechanismuid modality ismcad fy2017q1 fy2017q3 fy2018q1

**change values to numeric instead of strings (if needed)
destring fy2017_targets fy2017q2 fy2017q4 fy2017apr fy2018_targets fy2018q2 fy2019_targets, replace ignore(NULL)

*move exited without graduation under TransferExit  and move "Transferred" targets under "transfer non-PEPFAR partner" per MER Guidance for FY18

replace standardizeddisaggregate = "TransferExit" if otherdisaggregate == "Exited without Graduation"
replace standardizeddisaggregate = "TransferExit" if otherdisaggregate == "Transferred"
replace standardizeddisaggregate = "TransferExit" if otherdisaggregate == "Transferred out - non PEPFAR Support Partner"
replace standardizeddisaggregate = "TransferExit" if otherdisaggregate == "Transferred out - PEPFAR Support Partner"

