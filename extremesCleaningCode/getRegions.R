library(rgdal)
library(sp)
library(raster)
setwd("~/Documents/supplyChain/data/companyData/")


stateBase = readOGR("cb_2021_us_state_20m/cb_2021_us_state_20m.shp")
hqs = read.csv("supplierCustomerHQs.csv")
head(hqs)



suppliers <- hqs[,c('supplier_longitude','supplier_latitude')]
suppliersSP <- SpatialPoints(coords = suppliers, proj4string = crs(stateBase))

customers <- hqs[,c('customer_longitude','customer_latitude')]
customersSP <- SpatialPoints(coords = customers, proj4string = crs(stateBase))

statesCust <- over(customersSP, stateBase)$NAME
statesSupp <- over(suppliersSP, stateBase)$NAME


hqs$custState <- statesCust
hqs$suppState <- statesSupp

write.csv(hqs, "hqsWithStates.csv")