library(tidyr);library(tidyverse);library(rgdal); library(dplyr); library(ncdf4); library(readr)
library(prism);library(raster);library(ggplot2);library(dplyr);library(raster);library(sp); library(data.table)

mergeScenarios = list()

s = 1


for (s in seq(1,10)){
  print(s)
  sampleData <- readRDS(paste0("../../../../../../../Volumes/backup2/dissData/cmip6Data/hqAllData_",s,"_",years,".RDS"))
  allData <- plyr::ldply(sampleData, data.frame) %>% relocate(s,variable)
  mergeScenarios[[s]] = allData
}

allData <- plyr::ldply(mergeScenarios, data.frame)


saveRDS(allData[allData$variable == 'tasmax_hist',],paste0("../../../../../../../Volumes/backup2/dissData/cmip6Data/tasmaxhist_2014",".RDS"))
saveRDS(allData[allData$variable == 'tasmax_hist',],paste0("../../../../../../../Volumes/backup2/dissData/cmip6Data/tasmaxhist_2014",".RDS"))

saveRDS(allData[allData$variable == 'tasmax_hist',],paste0("../../../../../../../Volumes/backup2/dissData/cmip6Data/tasmaxhist_2014",".RDS"))
saveRDS(allData[allData$variable == 'tasmax_hist',],paste0("../../../../../../../Volumes/backup2/dissData/cmip6Data/tasmaxhist_2014",".RDS"))

saveRDS()
tasmax_hist = allData[allData$variable == 'tasmax_hist',] %>% gather(month,temperature,5:1800)
tasmax_hist = allData[allData$variable == 'tasmax_hist',] %>% gather(month,temperature,5:1800)