library(tidyr);library(tidyverse)
library(prism);library(raster);library(ggplot2);library(dplyr);library(raster);library(sp)
##########################
# This file uses the prism data 

##########################
# get the hq data and make it a spatial points dataframe
hq = read.csv("~/Documents/supplyChain/data/geoHQ.csv") %>% select(archive_version_year,TICKER,company,state,latitude,longitude)
hq.spdf = SpatialPointsDataFrame(coords=hq[,c('longitude','latitude')], 
                                 data=hq, proj4string = CRS("+proj=longlat +ellps=WGS84 +no_defs"))

geoHQ.temp <- raster::extract(RS, hq.spdf,  fun=mean, na.rm=TRUE, sp=TRUE)



##########################
# now get the preciptation and temperature data for the time period of interest. this takes >1hr to run.
prism_set_dl_dir("~/Documents/supplyChain/data/prism/prism_precip")

get_prism_dailys(
  type = "ppt", 
  minDate = "2000-01-01", 
  maxDate = "2019-12-31", 
  keepZip = FALSE
)

prism_set_dl_dir("~/Documents/supplyChain/data/prism/prism_temp")

get_prism_dailys(
  type = "tmax", 
  minDate = "2000-01-01", 
  maxDate = "2009-12-31", 
  keepZip = FALSE
)

# we got some warning messages here but generally okay
# 1: In utils::download.file(url = uri, destfile = outFile, mode = "wb",  :
#                              URL 'http://services.nacse.org/prism/data/public/4km/tmax/20130613': Timeout of 60 seconds was reached
#                            2: In utils::download.file(url = uri, destfile = outFile, mode = "wb",  :
#                                                         URL 'http://services.nacse.org/prism/data/public/4km/tmax/20180923': Timeout of 60 seconds was reached
#                                                       3: In utils::download.file(url = uri, destfile = outFile, mode = "wb",  :
#                                                                                    URL 'http://services.nacse.org/prism/data/public/4km/tmax/20180928': Timeout of 60 seconds was reached


#####################
# now get the precip and temperature data for each hq
for (year in seq(2010,2019)){
  
  # first do this for precipitation data
  print(year)
  
  prism_set_dl_dir("~/Documents/supplyChain/data/prism/prism_precip")
  precip = prism_archive_ls()[grepl(paste0("_",year),prism_archive_ls())]
  
  
  # get a raster stack of all the climate data
  RS              <- pd_stack(precip) ##raster file of data
  proj4string(RS) <- CRS("+proj=longlat +ellps=WGS84 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs") ##assign projection info
  
  
  # slice the raster stack to get the climate data around the hq
  geoHQ.precip <- raster::extract(RS, hq.spdf,  fun=mean, na.rm=TRUE, sp=TRUE)
  
  # grab the precipitation data and reformat it so that we have values, for each year for the hq in a given row
  hqWeather = geoHQ.precip@data %>% gather(month,precipitation,7:ncol(geoHQ.precip@data)) %>%
    separate(month, c(NA,'variable',NA,NA,'date',NA), "_") %>% mutate(weatherYear = substr(date,0,4),
                                                                      weatherMonth = substr(date,5,6)) %>% filter(weatherYear == archive_version_year)
  
  
  filename = paste0("~/Documents/supplyChain/data/hqPrecip",year,".csv")
  write.csv(hqWeather,filename)
  
  
  ######
  # next for temperature data
  print("and temperature")
  prism_set_dl_dir("~/Documents/supplyChain/data/prism/prism_temp")
  temp = prism_archive_ls()[grepl(paste0("_",year),prism_archive_ls())]
  
  
  # get a raster stack of all the climate data
  RS_temp              <- pd_stack(temp) ##raster file of data
  proj4string(RS_temp) <- CRS("+proj=longlat +ellps=WGS84 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs") ##assign projection info
  
  
  # slice the raster stack to get the climate data around the hq
  geoHQ.temp <- raster::extract(RS_temp, hq.spdf,  fun=mean, na.rm=TRUE, sp=TRUE)
  
  
  hqWeather = geoHQ.temp@data %>% gather(month,temperature,7:ncol(geoHQ.temp@data)) %>%
    separate(month, c(NA,'variable',NA,NA,'date',NA), "_") %>% mutate(weatherYear = substr(date,0,4),
                                                                      weatherMonth = substr(date,5,6)) %>% filter(weatherYear == archive_version_year)
  
  
  filename = paste0("~/Documents/supplyChain/data/hqTmax",year,".csv")
  write.csv(hqWeather,filename)
  
  
}

######################################################################
allData = data.frame(matrix(ncol = 10, nrow = 0))


for (year in seq(2010,2019)){
  print(year)
  
  filenamePrecip = paste0("~/Documents/supplyChain/data/hqPrecip",year,".csv")
  precip = read.csv(filenamePrecip) %>% select(-c('variable','X'))
  
  filenameTemp = paste0("~/Documents/supplyChain/data/hqTmax",year,".csv")
  temp = read.csv(filenameTemp) %>% select(-c('variable','X'))
  
  
  allOneYear = merge(precip,temp) 
  
  allData = rbind(allData,allOneYear)
}


######################################################################
# add in some summary statistics for the weather
allDataQuartiles <- allData %>% mutate(month = substr(date,5,6)) %>% 
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

allData_byQuarter = allDataQuartiles %>% select(-c(archive_version_year,latitude,longitude)) %>% group_by(company,TICKER,fquarter) %>% 
  summarise(precipQuartOverall    = sum(precipQuartOverall),
            precipQuartState      = sum(precipQuartState),
            precipQuartStateMonth = sum(precipQuartStateMonth),
            tmaxQuartOverall      = sum(tmaxQuartOverall),
            tmaxQuartState        = sum(tmaxQuartState),
            tmaxQuartStateMonth   = sum(tmaxQuartStateMonth))

filename = paste0("~/Documents/supplyChain/data/allData_byQuarter.csv")
write.csv(allData_byQuarter,filename)
