library(data.table)
library(tidyverse)
library(ICPIutilities)

# load files (you need to change the name manually to the most recent MSD file, OU x IM).  Add cumulative period
ouxim <- ICPIutilities::read_msd("C:/Users/wvp3/Desktop/Large data files/MER_Structured_Dataset_OU_IM_FY17-18_20180622_v2_1.txt")
ouxim_cum <- ICPIutilities::add_cumulative(ouxim)

# keep only the indicators and disaggs relevant to the KP dashboard
kp.df.long <- ouxim_cum %>%
  filter(indicator %in% c("KP_PREV","HTS_TST_POS","TX_NEW","HTS_TST","HTS_TST_NEG","PrEP_NEW","KP_MAT")) %>%
  filter(indicator=="KP_PREV" | otherDisaggregate %in%
         c("MSM","TG","FSW","PWID","People in prisons and other enclosed settings", 
           "Other Key Populations") | 
           standardizedDisaggregate=="Total Numerator" |
           standardizedDisaggregate=="Total Denominator") %>%

  # transpose to long format, removing NA values
  gather("fiscalperiod","value",starts_with("FY20")) %>%
  filter(!is.na(value)) 

  write.csv(kp.df.long, file="kpdash_rawdata.csv")
  
