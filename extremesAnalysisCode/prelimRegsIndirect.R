library(reshape);library(gridExtra);library(stargazer);library(ggplot2);library(gdata);library(polyclip);library(maptools);library(plyr);library(ggmap);library(sp);library(raster);library(rgdal);library(maps);library(rworldmap);library(scales);library(ggplot2);library(ggrepel);library(xtable);library(plm);library(lmtest)
library(lfe);library(R.utils);library(dplyr);library(caTools);library(tidyr);library(DescTools)

setwd("~/Documents/supplyChain")
data <- read.csv("data/compustat_supplierWeather.csv")
naics <- read.csv("data/compustatNAICS.csv") %>% select(gvkey, naics) %>% unique()
data  <- data %>% merge(naics,method = "outer")

dim(data)


########################################################################################################################
# clean the data and remove any financial firms
data = data[complete.cases(data$revenueChange) & complete.cases(data$incomeChange) & complete.cases(data$costChange) & complete.cases(data$inventoryChange),]

data = data %>% mutate(revenueChange = Winsorize(revenueChange, probs = c(0.01, 0.99)),
                       incomeChange  = Winsorize(incomeChange, probs = c(0.01, 0.99)),
                       costChange    = Winsorize(costChange, probs = c(0.01, 0.99)),
                       inventoryChange = Winsorize(inventoryChange, probs = c(0.01, 0.98)),
                       naics2 = substr(naics,0,2)) %>% filter(naics2 != "52")


########################################################################################################################

summary(lm(revenueChange ~ precipQuartOverall + supplier_precipQuartOverall + tmaxQuartOverall   + supplier_tmaxQuartOverall +  factor(fquarter)  +  factor(naics), data = data))
summary(lm(revenueChange ~ tmaxQuartOverall   + supplier_tmaxQuartOverall    +  factor(fquarter)  +  factor(naics), data = data))

summary(lm(costChange ~ precipQuartOverall + supplier_precipQuartOverall  +  factor(fquarter)  +  factor(naics), data = data))
summary(lm(costChange ~ tmaxQuartOverall + supplier_tmaxQuartOverall    +  factor(fquarter)  +  factor(naics), data = data))

summary(lm(inventoryChange ~ precipQuartOverall + supplier_precipQuartOverall +  factor(fquarter)  +  factor(naics), data = data))
summary(lm(inventoryChange ~ tmaxQuartOverall + supplier_tmaxQuartOverall  +  factor(fquarter)  +  factor(naics), data = data))


summarise(precipQuartOverall    = sum(precipQuartOverall),
          precipQuartState      = sum(precipQuartState),
          precipQuartStateMonth = sum(precipQuartStateMonth),
          tmaxQuartOverall      = sum(tmaxQuartOverall),
          tmaxQuartState        = sum(tmaxQuartState),
          tmaxQuartStateMonth   = sum(tmaxQuartStateMonth))


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


