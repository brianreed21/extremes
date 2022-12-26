library(tidyr);library(tidyverse);library(rgdal); library(dplyr); library(ncdf4); library(readr)
library(prism);library(raster);library(ggplot2);library(dplyr);library(raster);library(sp); library(data.table)


##################################################
# get the company information. take a rough centroid of lat and long by zipcode
hq = read.csv("~/Documents/supplyChain/data/companyData/justHQs.csv") %>%
   dplyr::select(-c('X', 'year')) %>% unique() %>% group_by(zipcode) %>% summarize(latitude = mean(latitude),
                                                                                      longitude = mean(longitude))


hq.spdf = SpatialPointsDataFrame(coords=hq[,c('longitude','latitude')], 
                                 data=hq, proj4string = CRS("+proj=longlat +ellps=WGS84 +no_defs"))


# go through the scenarios and find 95th percentile
index = 1
scenarios = seq(25,29)
# yearList = c("20150101-20241231", "20250101-20341231", "20350101-20441231")
yearList = c("19800101-19891231", "19900101-19991231")
allData = list()


for (years in yearList){
  
  
  print(years)
  
  
  for (s in scenarios){
    print("getting bricks")
    print(s)
    
    # pr
    filename_pr_hist = paste0("../../../../../../../Volumes/backup2/dissData/cmip6Data/hist/pr/pr_day_MIROC6_historical_r",s,"i1p1f1_gn_",years,".nc")
    # filename_pr_hist = paste0("../../../../../../../Volumes/backup2/dissData/cmip6Data/proj/pr/pr_day_MIROC6_ssp585_r",s,"i1p1f1_gn_",years,".nc")
    
    # tmax
    filename_tasmax_hist    = paste0("../../../../../../../Volumes/backup2/dissData/cmip6Data/hist/tasmax/tasmax_day_MIROC6_historical_r",s,"i1p1f1_gn_",years,".nc")
    # filename_tasmax_hist    = paste0("../../../../../../../Volumes/backup2/dissData/cmip6Data/proj/tasmax/tasmax_day_MIROC6_ssp585_r",s,"i1p1f1_gn_",years,".nc")

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
        
        allData[[index]] =  melt(setDT(data), id.vars = c("zipcode","latitude","longitude","s","variable"), variable.name = "date")
        
      }
    }
    
    index = index + 1
    
    

    
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
        
        allData[[index]] =  melt(setDT(data), id.vars = c("zipcode","latitude","longitude","s","variable"), variable.name = "date")
      }
    }
    
    index = index + 1
    
    
  }
}

rm(pr_hist, tasmax_hist)
rm(hq,hq.spdf,data,geoHQ_pr_hist,geoHQ_tasmax_hist)

# reformat the data 
allData_combined <- do.call(rbind.data.frame, allData) 
# %>%   dplyr::select(-c('latitude', 'longitude','s'))
rm(allData)



allData_combined$convDate <- as.Date(str_sub(allData_combined$date,2,11), '%Y.%m.%d')
allData_combined <- subset(allData_combined, select = -c(latitude,longitude,date))
allData_combined$year <- format(allData_combined$convDate,"%Y")

# filter to match the other time period
allData_combined <- allData_combined %>% filter(year >= 1981 & year <= 1999)

allData_combined$quarter <- quarters(allData_combined$convDate)
allData_combined <- subset(allData_combined, select = -c(convDate))
allData_combined$value <- as.numeric(allData_combined$value)
gc()



allData_combined = allData_combined[complete.cases(allData_combined$value) & (allData_combined$quarter != 'QNA'), ]
gc()



# change this so that it's by zipcode, but otherwise gtg
# quants = allData_combined %>% group_by(c(quarter,zipcode,variable)) %>% summarize(quant95 = quantile(value,0.95), na.rm = TRUE) 
# write.csv(allData_combined,"../../../../../../../Volumes/backup2/dissData/cmip6Data/proj/mirocHQs_202040.csv",
#           row.names = FALSE)

write.csv(allData_combined,"../../../../../../../Volumes/backup2/dissData/cmip6Data/hist/mirocHQs_198199.csv",
          row.names = FALSE)




gc()



library(data.table)
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

sampleData <- readRDS("../../../../../../../Volumes/backup2/dissData/cmip6Data/all_19000101-19091231_.RDS")



##################################################
s = 10
years = "18900101-18991231"
sampleData <- readRDS(paste0("../../../../../../../Volumes/backup2/dissData/cmip6Data/allHistBaseline_Processed/all_",years,"_",s,".RDS"))
allData <- plyr::ldply(sampleData, data.frame)
