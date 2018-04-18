*********************************************
Date updated: 12/13/2017
Analyst: Katya Noykhovich
Purpose: To subset PSNU X IM factview for OVC FY17Q4 dashboard
**********************************************

*import dataset
import delimited C:\Users\knoykhovich\Desktop\ICPI_FactView_PSNU_IM_20171115_v1_1\ICPI_FactView_PSNU_IM_20171115_v1_1.txt

*keep only specific OVC indicators
keep if indicator == "OVC_HIVSTAT" | indicator == "OVC_HIVSTAT_NEG" | indicator == "OVC_HIVSTAT_POS" | indicator == "OVC_SERV" | indicator == "OVC_SERV_OVER_18" | indicator == "OVC_SERV_UNDER_18"

*drop any unnecessary columns for OVC dashboard
drop dataelementuid categoryoptioncombouid fy2015q3 fy2016q1 fy2016q3 fy2017q1 fy2017q3

*Keep all indicators that have OVC in title. this will include the OVC MER ESI data. if need MER ESI data then follow this code below:
keep if strmatch(indicator, "OVC*")
drop dataelementuid categoryoptioncombouid
