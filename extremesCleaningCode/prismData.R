library(tidyr);library(tidyverse);library(rgdal); library(dplyr)
library(prism);library(raster);library(ggplot2);library(dplyr);library(raster);library(sp)

##########################
# get the hq data and make it a spatial points dataframe

# this one is compustat
# hq = read.csv("~/Documents/supplyChain/data/companyHQZips.csv")


# hq = hq %>% dplyr::select(year,gvkey,latitude,longitude) %>% unique()
# infogroup version: %>% select(archive_version_year,TICKER,company,state,latitude,longitude)
hq = read.csv("~/Documents/supplyChain/data/igHQ.csv")
hq = hq %>% dplyr::select(year,TICKER,company,state,latitude,longitude)

hq.spdf = SpatialPointsDataFrame(coords=hq[,c('longitude','latitude')], 
                                 data=hq, proj4string = CRS("+proj=longlat +ellps=WGS84 +no_defs"))

prism_set_dl_dir("~/Documents/supplyChain/data/prism/prism_precip")

#####################
# now get the precip and temperature data for each hq
for (year in seq(1895,1925)){

  
  # first do this for precipitation data
  print(year)
  # setwd("../../../../../../../Volumes/backup2")
  
  prism_set_dl_dir("../../../../../../../Volumes/backup2/dissData/prism/prism_precip/")
  precip = prism_archive_ls()[grepl(paste0("_",year),prism_archive_ls())]
  
  # get a raster stack of all the climate data
  RS              <- pd_stack(precip) ##raster file of data
  proj4string(RS) <- CRS("+proj=longlat +ellps=WGS84 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs") ##assign projection info

  # slice the raster stack to get the climate data around the hq
  geoHQ.precip <- raster::extract(RS, hq.spdf,  fun=mean, na.rm=TRUE, sp=TRUE)

  # grab the precipitation data and reformat it so that we have values, for each year for the hq in a given row
   # hqWeather = geoHQ.precip@data %>% gather(month,precipitation,7:ncol(geoHQ.precip@data)) %>%
   #   separate(month, c(NA,'variable',NA,NA,'date',NA), "_") %>% mutate(weatherYear = substr(date,0,4),
   #                                                                     weatherMonth = substr(date,5,6)) %>% filter(weatherYear == year)
  
  
  filename = paste0("../../../../../../../Volumes/backup2/dissData/prism/hqInfogroupPrecip",year,".csv")
  write.csv(geoHQ.precip@data,filename)

  
  ######
  # next for temperature data
  print("and temperature")
  prism_set_dl_dir("../../../../../../../Volumes/backup2/dissData/prism/prism_temp")
  temp = prism_archive_ls()[grepl(paste0("_",year),prism_archive_ls())]
  
  
  # get a raster stack of all the climate data
  RS_temp              <- pd_stack(temp) ## raster file of data
  proj4string(RS_temp) <- CRS("+proj=longlat +ellps=WGS84 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs") ##assign projection info
  
  
  # slice the raster stack to get the climate data around the hq
  geoHQ.temp <- raster::extract(RS_temp, hq.spdf,  fun=mean, na.rm=TRUE, sp=TRUE)
  
  
  # hqWeather = geoHQ.temp@data %>% gather(month,temperature,7:ncol(geoHQ.temp@data)) %>%
  #   separate(month, c(NA,'variable',NA,NA,'date',NA), "_") %>% mutate(weatherYear = substr(date,0,4),
  #                                                                      weatherMonth = substr(date,5,6)) %>% filter(weatherYear == year)
  
  filename = paste0("../../../../../../../Volumes/backup2/dissData/prism/hqInfogroupTmax",year,".csv")
  write.csv(geoHQ.temp@data,filename)
  
  
}

######################################################################
allData = data.frame(matrix(ncol = 10, nrow = 0))


for (year in seq(1998,2019)){
  print(year)
  
  # filenamePrecip = paste0("~/Documents/supplyChain/data/hqPrecip",year,".csv")
  # precip = read.csv(filenamePrecip) %>% select(-c('variable','X'))
  # 
  # filenameTemp = paste0("~/Documents/supplyChain/data/hqTmax",year,".csv")
  # temp = read.csv(filenameTemp) %>% select(-c('variable','X'))
  
  
  # allOneYear = merge(precip,temp) 
  
  allData = rbind(allData,allOneYear)
}


######################################################################
allData = read.csv("../../../../../../../Volumes/backup2/dissData/prism/allWeather.csv")
quantile(allData$ppt, c(0.95),na.rm = TRUE) 
quantile(allData$tmax, c(0.95),na.rm = TRUE) 

# add in some summary statistics for the weather
allDataQuartiles <- allData %>% rename(precipitation = ppt, temperature = tmax) %>%
  # precipitation - overall, by state, and by state by month
  mutate(precipQuartOverall = as.numeric(ntile(precipitation,20) == 20)) %>% 
  group_by(state) %>% mutate(precipQuartState = as.numeric(ntile(precipitation,20) == 20)) %>% 
  group_by(state,month) %>% mutate(precipQuartStateMonth = as.numeric(ntile(precipitation,20) == 20)) %>%
  # temperature - overall, by state, and by state by month
  mutate(tmaxQuartOverall = as.numeric(ntile(temperature,20) == 20)) %>% 
  group_by(state) %>% mutate(tmaxQuartState = as.numeric(ntile(temperature,20) == 20)) %>% 
  group_by(state,month) %>% mutate(tmaxQuartStateMonth = as.numeric(ntile(temperature,20) == 20))
 

allDataQuartiles = allDataQuartiles %>% mutate(quarter = case_when(month %in% c("01","02","03") ~ "1",
                                                     month %in% c("04","05","06") ~ "2",
                                                     month %in% c("07","08","09") ~ "3",
                                                     month %in% c("10","11","12") ~ "4"),
                                               fquarter = paste0("q",quarter,"y",weatherYear)) 

colnames(allDataQuartiles)

allData_byQuarter = allDataQuartiles %>% dplyr::select(-c(X,year,month,day,weatherYear,latitude,longitude)) %>% group_by(company,TICKER,fquarter) %>% 
  summarise(precipQuartOverall    = sum(precipQuartOverall),
            precipQuartState      = sum(precipQuartState),
            precipQuartStateMonth = sum(precipQuartStateMonth),
            tmaxQuartOverall      = sum(tmaxQuartOverall),
            tmaxQuartState        = sum(tmaxQuartState),
            tmaxQuartStateMonth   = sum(tmaxQuartStateMonth))

# filename = paste0("~/Documents/supplyChain/data/allData_byQuarter.csv")
filename = paste0("~/Documents/supplyChain/data/allIGData_byQuarter.csv")
write.csv(allData_byQuarter,filename)
