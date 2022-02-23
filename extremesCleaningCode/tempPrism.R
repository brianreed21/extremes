library(tidyr);library(tidyverse);library(rgdal); library(dplyr)
library(prism);library(raster);library(ggplot2);library(dplyr);library(raster);library(sp)

##########################
# get the hq data and make it a spatial points dataframe

# this one is compustat
hq = read.csv("~/Documents/supplyChain/data/companyHQZips.csv")

hq = hq %>% dplyr::select(year,gvkey,latitude,longitude) %>% unique()
# infogroup version: %>% select(archive_version_year,TICKER,company,state,latitude,longitude)
hq.spdf = SpatialPointsDataFrame(coords=hq[,c('longitude','latitude')], 
                                 data=hq, proj4string = CRS("+proj=longlat +ellps=WGS84 +no_defs"))

prism_set_dl_dir("~/Documents/supplyChain/data/prism/prism_precip")

#####################
# now get the precip and temperature data for each hq
for (year in seq(1981,2019)){
  
 
  # first do this for precipitation data
  print(year)
  # setwd("../../../../../../../Volumes/backup2")
 
  ######
  # next for temperature data
  print("and temperature")
  start = proc.time()
  
  prism_set_dl_dir("../../../../../../../Volumes/backup2/dissData/prism/prism_temp")
  temp = prism_archive_ls()[grepl(paste0("_",year),prism_archive_ls())]
  
  
  # get a raster stack of all the climate data
  RS_temp              <- pd_stack(temp) ## raster file of data
  proj4string(RS_temp) <- CRS("+proj=longlat +ellps=WGS84 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs") ##assign projection info
  
  
  # slice the raster stack to get the climate data around the hq
  geoHQ.temp <- raster::extract(RS_temp, hq.spdf,  fun=mean, na.rm=TRUE, sp=TRUE)
  print("After extracting")
  proc.time() - start
  
  
  hqWeather = geoHQ.temp@data %>% gather(month,temperature,5:ncol(geoHQ.temp@data)) %>%
    separate(month, c(NA,'variable',NA,NA,'date',NA), "_") %>% mutate(weatherYear = substr(date,0,4),
                                                                      weatherMonth = substr(date,5,6)) %>% filter(weatherYear == archive_version_year)

  
  
  print("After gathering")
  proc.time() - start
  
  
  filename = paste0("~/Documents/supplyChain/data/hqCompustatTmax",year,".csv")
  write.csv(hqWeather,filename)
  print("After saving")
  proc.time() - start
  
  
}
