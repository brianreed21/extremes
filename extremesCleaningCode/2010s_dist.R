library(tidyr);library(tidyverse);library(rgdal); library(dplyr); library(ncdf4); library(readr)
library(prism);library(raster);library(ggplot2);library(dplyr);library(raster);library(sp); library(data.table)

mergeScenarios = list()

s = 1
years = "20100101-20141231"

for (s in seq(1,10)){
  print(s)
  sampleData <- readRDS(paste0("../../../../../../../Volumes/backup2/dissData/cmip6Data/hqAllData_",s,"_",years,".RDS"))
  allData <- plyr::ldply(sampleData, data.frame) %>% relocate(s,variable)
  mergeScenarios[[s]] = allData
}

allData <- plyr::ldply(mergeScenarios, data.frame)
rm(mergeScenarios)

saveRDS(allData[allData$variable == 'tasmax_hist',],paste0("../../../../../../../Volumes/backup2/dissData/cmip6Data/tasmaxhist_2010s",".RDS"))
saveRDS(allData[allData$variable == 'pr_hist',],paste0("../../../../../../../Volumes/backup2/dissData/cmip6Data/pr_hist_2014",".RDS"))

saveRDS(allData[allData$variable == 'tasmax_histNat',],paste0("../../../../../../../Volumes/backup2/dissData/cmip6Data/tasmax_histNat_2014",".RDS"))
saveRDS(allData[allData$variable == 'pr_histNat',],paste0("../../../../../../../Volumes/backup2/dissData/cmip6Data/pr_histNat_2014",".RDS"))

saveRDS()

###########
tasmax_histNat = readRDS(paste0("../../../../../../../Volumes/backup2/dissData/cmip6Data/tasmax_histNat_2014",".RDS"))
tasmax_hist = readRDS(paste0("../../../../../../../Volumes/backup2/dissData/cmip6Data/tasmaxhist_2010s",".RDS")) 

tHN = unlist(tasmax_histNat[,6:1800]) - 273
tH  = unlist(tasmax_hist[,6:1800]) - 273

sum(tH > 34)/length(tH)
sum(tHN > 34)/length(tHN)


plot(density(tHN), main = "Distribution of Daily Max Temperature in MIROC6, 2010-2015",
     xlab = "Daily Max Temp at Company HQs (C)",
     ylab = "Density")
lines(density(tH),col = "red")
legend(-30, 0.03, legend=c("Realized Climate", "Pre-Industrial CO2"),
       col=c("black", "red"), lty=1:2, cex=0.8)


## 
pr_histNat = readRDS(paste0("../../../../../../../Volumes/backup2/dissData/cmip6Data/pr_histNat_2014",".RDS"))
pr_hist = readRDS(paste0("../../../../../../../Volumes/backup2/dissData/cmip6Data/pr_hist_2014",".RDS")) 

pHN = unlist(pr_histNat[,6:1800])
pH  = unlist(pr_hist[,6:1800])

( sum(tH > 34)/length(tH) - sum(tHN > 34)/length(tHN))*365*5


plot(density(pHN))
lines(density(pH),col = "red")
