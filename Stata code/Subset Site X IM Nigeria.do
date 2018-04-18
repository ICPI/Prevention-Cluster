*********************************************
Date: 03/08/2018
Analyst: Katya Noykhovich  STATA
Purpose: To subset Site x IM factview for KaeAnne Parris
Dataset: ICPI_FactView_Site_IM_Nigeria_20180215_v1_3
*********************************************
*Requirements
*FY17Q1, Q2, Q3, Q4, FY18 Q2
*Indicators: HTS_TST, HTS_TSTPOS, TX_NEW, OVC_SERV, OVC_HIVSTAT, TX_RET, TX_PVLS, TX_CURR

drop fy2015q2 fy2015q3 fy2015q4 fy2015apr fy2016_targets fy2016q1 fy2016q2 fy2016q3 fy2016q4 fy2016apr
keep if strmatch(indicator, "HTS_TST*") | strmatch(indicator, "TX_CURR") | strmatch(indicator, "TX_NEW") | strmatch(indicator, "OVC_SERV*")| strmatch(indicator, "OVC_HIVSTAT*") | strmatch(indicator, "TX_RET*") | strmatch(indicator, "TX_PVLS*")
