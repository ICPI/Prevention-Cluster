#Date updated: 02/06/2019
#Purpose: To combine with Factview and MSD to include FY15-FY16 data for OVC Trends Analysis
#Software: R

#A.increase memory and check working directory
memory.limit(size = 90000)
getwd()

#B.Installation directory - please change username to your username. This will direct R libraries/packages to install and run smoothly with RStudio.
.libPaths(c("C:/Users/knoykhovich/R", .libPaths()))

#C. install & load packages 
install.packages('tidyverse')
install.packages('dplyr')
install.packages("devtools")
devtools::install_github("ICPI/ICPIutilities")
install.packages("skimr")
library(skimr)
library(tidyverse)
library(ICPIutilities)
library(dplyr)

# read in MSD file
msd1 <- read_msd("MER_Structured_Dataset_PSNU_IM_FY17-18_20181221_v2_1.txt")

# read in Factvie file
f1 <- read_msd("ICPI_FactView_PSNU_IM_20170324_v2_1.txt")

# subset for indicators of interest: OVC SERV, OVC_HIVSTAT, OVC_HIVST (prior to FY17)
unique(msd1$indicator)
unique(f1$indicator)

msd2 <- filter(msd1, indicator == "OVC_HIVSTAT" | indicator == "OVC_SERV" | indicator == "OVC_SERV_OVER_18"| indicator == "OVC_SERV_UNDER_18" | indicator == "OVC_HIVSTAT_NEG" | indicator == "OVC_HIVSTAT_POS")

f2 <- filter(f1, indicator == "OVC_HIVST" | indicator == "OVC_SERV")

# list column names and numbers
colnames(msd2)
colnames(f2)
setdiff(msd1, f1)

# keep selected columns
msd3 <- msd2 %>% 
  select(operatingunit, snu1:snuprioritization, mechanismuid:coarsedisaggregate, fy2017_targets, fy2017q2, fy2017q4, fy2017apr:fy2018_targets, fy2018q2, fy2018q4:fy2019_targets)

f3 <- f2 %>% 
  select(operatingunit, snu1:fy17snuprioritization, mechanismuid:coarsedisaggregate, fy2015q2, fy2015q4:fy2016_targets, fy2016q2, fy2016q4:fy2016apr) 

# merge msd3 and f3
df <- bind_rows(msd3, f3)

# Check column names
colnames(df)

# reorder columns
df <- df[c(1,2,3, 4, 5, 35, 36, 6, 7, 8, 9, 10, 11, 12, 13,14,15,16,17,37,18, 19, 20, 21,22,23,24,25, 26, 27, 28, 29, 30, 31,32,33,34,38,39,40,41,42,43,44)]
colnames(df)

# rehapse dataset from wide to long, putting all results/targets in one column called value and the period into a column titled "period"
df2 <- gather(df, key = "period", "value", fy2017_targets:fy2016apr, na.rm = TRUE)

# EXPLORATION: what are the unique disaggregates under OVC_SERV?
testdisaggs <- data.frame(df2$indicator, df2$disaggregate, df2$otherdisaggregate)
unique(testdisaggs[which(testdisaggs$df2.indicator == "OVC_SERV"), ])

# remove age/sex/service disaggregate as that is DREAMS only 
df3 <- df2[ which(df2$disaggregate !='Age/Sex/Service'), ]
unique(df3$disaggregate)

# EXPLORATION: what are the unique disaggregates under OVC_SERV?
testdisaggs <- data.frame(df3$indicator, df3$standardizeddisaggregate, df3$disaggregate, df3$otherdisaggregate)
unique(testdisaggs[which(testdisaggs$df3.indicator == "OVC_SERV"), ])


# Replace Swaziland with Eswatini
unique(df3$operatingunit)
df4 <- df3
df4$operatingunit <- ifelse(df3$operatingunit=="Swaziland", "Eswatini", df3$operatingunit)
unique(df4$operatingunit)


# export dataset to csv/txt
write.csv(df4,"OVC_PSNUxIM_FY15toFY18.csv", row.names = FALSE)

