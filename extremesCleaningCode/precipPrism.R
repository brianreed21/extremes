library(tidyr);library(tidyverse);library(rgdal); library(dplyr); library(prism);library(raster);library(ggplot2);library(dplyr);library(raster);library(sp)

##########################
# get the hq data and make it a spatial points dataframe

# this one is compustat
hq = read.csv("~/Documents/supplyChain/data/companyHQZips.csv")

hq = hq %>% dplyr::select(year,gvkey,latitude,longitude) %>% unique()
# infogroup version: %>% select(archive_version_year,TICKER,company,state,latitude,longitude)
hq.spdf = SpatialPointsDataFrame(coords=hq[,c('longitude','latitude')], 
                                 data=hq, proj4string = CRS("+proj=longlat +ellps=WGS84 +no_defs"))

#####
prism_set_dl_dir("~/Documents/supplyChain/data/prism/prism_precip")


getData <- function(month) {
  print(paste0(year,"_",month))

  prism_set_dl_dir("../../../../../../../Volumes/backup2/dissData/prism/prism_precip/")
  precip = prism_archive_ls()[grepl(paste0("_",year,month),prism_archive_ls())]
  
  start = proc.time()
  # get a raster stack of all the climate data
  RS              <- pd_stack(precip) ##raster file of data
  proj4string(RS) <- CRS("+proj=longlat +ellps=WGS84 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs") ##assign projection info
  
  
  # slice the raster stack to get the climate data around the hq
  geoHQ.precip <- raster::extract(RS, hq.spdf,  fun=mean, na.rm=TRUE, sp=TRUE)
  proc.time() - start
  # grab the precipitation data and reformat it so that we have values, for each year for the hq in a given row
  hqWeather = geoHQ.precip@data %>% gather(month,precipitation,5:ncol(geoHQ.precip@data)) %>%
    separate(month, c(NA,'variable',NA,NA,'date',NA), "_") %>% mutate(weatherYear = substr(date,0,4),
                                                                      weatherMonth = substr(date,5,6)) %>% filter(weatherYear == year)


  filename = paste0("~/Documents/supplyChain/data/weatherData/hqCompustatPrecip",year,month,".csv")
  write.csv(hqWeather,filename)

}

months = c("01","02","03","04","05","06",
           "07","08","09","10","11","12")

library(parallel); library(MASS)
numCores <- detectCores()

year = 2001
system.time(
  mclapply(months,getData,mc.cores = numCores)
)
mclapply(months,getData,mc.cores = numCores)

#####################
# now get the precip and temperature data for each hq
