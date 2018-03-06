*********************************************
Date: 01/16/2018
Analyst: Katya Noykhovich STATA
Purpose: To subset Tanz site factview for Tanz DREAMS AFHS dashboard


*Import TZ Site by IM dataset
import delimited [filepath]

*drop unnecessary variables
drop ïorgunituid region regionuid countryname fy2015q2 fy2015q3 fy2015q4 fy2015apr categoryoptioncombouid categoryoptioncomboname dataelementuid
*keep only necessary indicators
keep if strmatch(indicator, "OVC*") | strmatch(indicator, "PMTCT_STAT*") | strmatch(indicator, "PP_PREV*")| strmatch(indicator, "TX_*")| strmatch(indicator, "VMMC_*") | strmatch(indicator, "GEND_*")| strmatch(indicator, "KP_*") | strmatch(indicator, "HTS_*")
keep if indicator == "PMTCT_STAT" |  indicator == "PMTCT_STAT_POS" | indicator == "PMTCT_STAT_KnownatEntry_POSITIVE" | indicator == "PMTCT_STAT_NewlyIdentified_Negative" | indicator == "PMTCT_STAT_NewlyIdentified_POSITIVE" | indicator == "VMMC_CIRC" | indicator == "TX_NEW" | indicator == "PP_PREV" | indicator == "TX_CURR" | indicator == "OVC_SERV"| indicator == "OVC_SERV_OVER_18" | indicator == "OVC_SERV_UNDER_18" | indicator == "KP_PREV" | indicator == "GEND_GBV" | indicator == "GEND_NORM"
*keep if disaggregate == "Total Numerator"| disaggregate == "Age/Sex/Service"| disaggregate == "AgeAboveTen/Sex"| disaggregate == "AgeLessThanTen"| disaggregate == "Age/Sex"| disaggregate == "KeyPop" |disaggregate == "Age"

*keep only relevant PSNUs where AFHS sites exist
keep if psnu == "Kahama TC" | psnu == "Kyela DC" | psnu == "Mbeya CC" | psnu == "Msalala DC" | psnu == "Shinyanga MC" | psnu == "Temeke MC" | psnu == "Ushetu DC"

save [file name]


*import AFHS sites and merge on FacilityUID
import excel "U:\My Documents\ICPI\DREAMS\Requests\Copy of DREAMS Facilities Selection_Nov_09.xlsx", sheet("Compiled list for data_en") firstrow clear
merge 1:m facilityuid using "C:\Temp\DREAMS\ICPI_FactView_Site_IM_Tanzania_20171222_v1_1_subset_2018.01.16.dta"

*order variables to match what is in Excel tool
order TYPE operatingunit snu1 psnu currentsnuprioritization typemilitary primepartner fundingagency mechanismid implementingmechanismname community fy16communityprioritization currentcommunityprioritization typecommunity facilityuid facility currentfacilityprioritization typefacility indicator numeratordenom indicatortype disaggregate standardizeddisaggregate age sex resultstatus otherdisaggregate coarsedisaggregate modality tieredsitecounts typetieredsupport ismcad fy2016_targets fy2016q1 fy2016q2 fy2016q3 fy2016q4 fy2016apr fy2017_targets fy2017q1 fy2017q2 fy2017q3 fy2017q4 fy2017apr fy2018_targets _merge

*Excel formulas:
*ISAFHSSite =IF([@[_merge]]="matched (3)",1,0)
*AFHSsite =IF([@isAFHSsite]=1, "AFHS site", "Other site")
