library(reshape);library(gridExtra);library(stargazer);library(ggplot2);library(gdata);library(polyclip);library(maptools);library(plyr);library(ggmap);library(sp);library(raster);library(rgdal);library(maps);library(rworldmap);library(scales);library(ggplot2);library(ggrepel);library(xtable);library(plm);library(lmtest)
library(lfe);library(R.utils);library(dplyr);library(caTools);library(tidyr);library(DescTools)
########################################################################################################################


setwd("~/Documents/supplyChain")
data <- read.csv("data/companyData/allCompaniesWithWeather.csv") %>% select(-X) 
data <- read.csv("data/companyData/suppliersWithWeather.csv") %>% select(-X) 
data <- read.csv("data/companyData/customersWithWeather.csv") %>% select(-X) 
data <- read.csv("data/companyData/largestSuppliersWithWeather.csv") %>% select(-X)  
data <- read.csv("data/companyData/wtdAvgSuppliers.csv") %>% select(-X)  

dim(data)
head(data)


########################################################################################################################
# clean the data and remove any financial firms
data = data[complete.cases(data$revenueChange)  & complete.cases(data$costChange) & complete.cases(data$inventoryChange),] # & complete.cases(data$incomeChange)

data = data %>% mutate(revenueChange = Winsorize(revenueChange, probs = c(0.01, 0.99)),
                             # incomeChange  = Winsorize(incomeChange, probs = c(0.01, 0.99)),
                             costChange    = Winsorize(costChange, probs = c(0.01, 0.99)),
                             inventoryChange = Winsorize(inventoryChange, probs = c(0.01, 0.98)),
                       yearQtr = paste0(year,"_",qtr),
                       naics2 = substr(naics,1,2), zip2 = substr(zipcode,1,2)) %>% filter(naics2 %in% c('11','21','22','23','31','32','33','42','44','45','48','49')) #  %>% filter(naics2 != "52")      #  



#######################################################################################################################
revChange <- 
summary(lm(revenueChange ~ precip_quant_1.0  +  tmax_quant_1.0 + factor(naics2) + factor(gvkey) + factor(zipcode) + factor(yearQtr), data = data))




grep("*_quant_*", capture.output(revChange), value = TRUE)




########################################################################################################################
# all variables: 
# tmax_quant_0.05 + tmax_quant_0.1 + tmax_quant_0.15 + tmax_quant_0.2 + tmax_quant_0.25 + tmax_quant_0.30 + 
#   tmax_quant_0.35 + tmax_quant_0.4 + tmax_quant_0.45 + tmax_quant_0.5 + tmax_quant_0.55 + tmax_quant_0.60 + 
#   tmax_quant_0.65 + tmax_quant_0.70 + tmax_quant_0.75 + tmax_quant_0.8 + tmax_quant_0.85 + tmax_quant_0.9 + 
#   tmax_quant_0.95 + tmax_quant_1.0 + precip_quant_0.65 + precip_quant_0.70 + precip_quant_0.75 + 
#   precip_quant_0.8 + precip_quant_0.85 + precip_quant_0.9 + precip_quant_0.95 + precip_quant_1.0


revChange <- summary(lm(revenueChange   ~ precip_quant_1.0  +  tmax_quant_1.0 + supplier_precip_quant_1.0 + supplier_tmax_quant_1.0  + factor(zipcode) + factor(yearQtr) + factor(naics2), data = data))
grep("*_quant_*", capture.output(revChange), value = TRUE)

# incomeChange <- summary(lm(incomeChange    ~ precip_quant_1.0  +  tmax_quant_1.0  + supplier_precip_quant_1.0 + supplier_tmax_quant_1.0 + factor(yearQtr)*factor(naics2), data = data))
# grep("*_quant_*", capture.output(incomeChange), value = TRUE)

costChange <- summary(lm(costChange      ~ precip_quant_1.0  +  tmax_quant_1.0  + supplier_precip_quant_1.0 + supplier_tmax_quant_1.0 + factor(yearQtr)*factor(naics2), data = data))
grep("*_quant_*", capture.output(costChange), value = TRUE)

inventoryChange <- summary(lm(inventoryChange ~ precip_quant_1.0  +  tmax_quant_1.0  + supplier_precip_quant_1.0 + supplier_tmax_quant_1.0 + factor(yearQtr)*factor(naics2), data = data))
grep("*_quant_*", capture.output(inventoryChange), value = TRUE)

########################################################################################################################
# look at baseline profit changes as well



########################################################################################################################
# regress on industry subgroups


# list the industries first
data %>% pull(naics2) %>% unique() %>% sort()


# regress by industries
for (ind in data %>% pull(naics2) %>% unique() %>% sort()){
  
  if (ind != '61'){
    print("******************")
    print(ind)
    coeffPrecip <- summary(lm(costChange ~ precipQuartOverall + factor(year), data = data %>% filter(naics2 == ind)))$coefficients[2, 1]
    pvalPrecip  <- summary(lm(costChange ~ precipQuartOverall + factor(year), data = data %>% filter(naics2 == ind)))$coefficients[2, 4]
    print(paste0("precip: ", coeffPrecip," | p: ", pvalPrecip))
    
    
    coeffTmax <- summary(lm(costChange ~ tmaxQuartOverall + factor(year), data = data %>% filter(naics2 == ind)))$coefficients[2, 1]
    pvalTmax  <- summary(lm(costChange ~ tmaxQuartOverall + factor(year), data = data %>% filter(naics2 == ind)))$coefficients[2, 4]
    print(paste0("tmax: ", coeffTmax," | p: ", pvalTmax))
  }
  
}
  

