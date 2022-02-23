library(tidyr);library(tidyverse);library(rgdal); library(dplyr); library(ncdf4); library(readr)
library(prism);library(raster);library(ggplot2);library(dplyr);library(raster);library(sp); library(data.table)


##################################################
# get the company information
hq = read.csv("~/Documents/supplyChain/data/igHQ.csv")
hq = hq %>% dplyr::select(TICKER,latitude,longitude) %>% unique()
 
hq.spdf = SpatialPointsDataFrame(coords=hq[,c('longitude','latitude')], 
                                 data=hq, proj4string = CRS("+proj=longlat +ellps=WGS84 +no_defs"))

scenarios = seq(1,10)
yearList = c("19000101-19091231","19100101-19191231", "19200101-19291231")

allVars = list()

for (years in yearList){
  
  
  print(years)
  
  
  for (s in scenarios[1:10]){
    allData = list()
    print("getting bricks")
    print(s)
    
    # pr
    filename_pr_hist = paste0("../../../../../../../Volumes/backup2/dissData/cmip6Data/hist/pr/pr_day_MIROC6_historical_r",s,"i1p1f1_gn_",years,".nc")
    filename_pr_histNat = paste0("../../../../../../../Volumes/backup2/dissData/cmip6Data/histNat/pr/pr_day_MIROC6_hist-nat_r",s,"i1p1f1_gn_",years,".nc")
    
    # tmax
    filename_tasmax_hist    = paste0("../../../../../../../Volumes/backup2/dissData/cmip6Data/hist/tasmax/tasmax_day_MIROC6_historical_r",s,"i1p1f1_gn_",years,".nc")
    filename_tasmax_histNat = paste0("../../../../../../../Volumes/backup2/dissData/cmip6Data/histNat/tasmax/tasmax_day_MIROC6_hist-nat_r",s,"i1p1f1_gn_",years,".nc")
    
    # extract and save all these
    
    ################
    if (!is.na(file.info(filename_pr_hist)$size)){
      if (file.info(filename_pr_hist)$size > 0){
        print("pr_hist")
        pr_hist        <- brick(filename_pr_hist,  varname = "pr")
        proj4string(pr_hist)=CRS("+init=EPSG:4326")
        pr_hist <- rotate(pr_hist)
        
        geoHQ_pr_hist <- raster::extract(pr_hist, hq.spdf,  fun=mean, na.rm=TRUE, sp=TRUE)
        data = geoHQ_pr_hist@data
        
        data$s = s
        data$variable = "pr_hist"
        
        allData[[1]] = data
      }
    }
    
    
    #################
    
    if (!is.na(file.info(filename_pr_histNat)$size)){
      if (file.info(filename_pr_histNat)$size > 0){
        print("pr_histNat")
        pr_histNat     <- brick(filename_pr_histNat,  varname = "pr")
        proj4string(pr_histNat)=CRS("+init=EPSG:4326")
        pr_histNat <- rotate(pr_histNat)
        
        geoHQ_pr_histNat <- raster::extract(pr_histNat, hq.spdf,  fun=mean, na.rm=TRUE, sp=TRUE)
        data = geoHQ_pr_histNat@data
        
        data$s = s
        data$variable = "pr_histNat"
        
        
        allData[[2]] = data
        
      }
    }
    

    #################
    if (!is.na(file.info(filename_tasmax_hist)$size)){
      if (file.info(filename_tasmax_hist)$size > 0){
        print("tasmax_hist")
        tasmax_hist    <- brick(filename_tasmax_hist,  varname = "tasmax")
        proj4string(tasmax_hist)=CRS("+init=EPSG:4326")
        tasmax_hist <- rotate(tasmax_hist)
        
        geoHQ_tasmax_hist <- raster::extract(tasmax_hist, hq.spdf,  fun=mean, na.rm=TRUE, sp=TRUE)
        data = geoHQ_tasmax_hist@data
        
        data$s = s
        data$variable = "tasmax_hist"
        
        allData[[3]] = data
      }
    }
    
    
    #################
    if (!is.na(file.info(filename_tasmax_histNat)$size)){
      if (file.info(filename_tasmax_histNat)$size > 0){
        print("tasmax_histNat")
        tasmax_histNat <- brick(filename_tasmax_histNat,  varname = "tasmax")
        proj4string(tasmax_histNat)=CRS("+init=EPSG:4326")
        tasmax_histNat <- rotate(tasmax_histNat)
        
        geoHQ_tasmax_histNat <- raster::extract(tasmax_histNat, hq.spdf,  fun=mean, na.rm=TRUE, sp=TRUE)
        data = geoHQ_tasmax_histNat@data
        
        
        data$s = s
        data$variable = "tasmax_histNat"
        
        allData[[4]] = data
      }
    }
    
    ############################################
    # now process the averages for each of these
    preAvg = plyr::ldply(allData, data.frame)  %>% relocate(s,variable)
    allVars[[s]] = preAvg
    
    
    if (s %% 10 == 0){
      # save the list and reset it
      print("all vars - dump")
      toSave <- plyr::ldply(allVars, data.frame)
      fwrite(toSave,paste0("../../../../../../../Volumes/backup2/dissData/cmip6Data/all_",years,".csv"))
  
    }
  }
}
  
sampleData <- readRDS("../../../../../../../Volumes/backup2/dissData/cmip6Data/all_19000101-19091231_.RDS")



##################################################
s = 10
years = "18900101-18991231"
sampleData <- readRDS(paste0("../../../../../../../Volumes/backup2/dissData/cmip6Data/allHistBaseline_Processed/all_",years,"_",s,".RDS"))
allData <- plyr::ldply(sampleData, data.frame)
