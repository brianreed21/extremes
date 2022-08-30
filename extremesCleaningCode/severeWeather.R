library(noaastormevents)
library(tidyverse)
library(stringr)
library(zoo)

########################
# go through the 
events_2015 <- create_storm_data(date_range = c("2009-01-01", "2015-12-31"))
slice(events_2015, 1:3)

colnames(events_2015)

# look at events by TYPE
events_2015 %>%
  group_by(EVENT_TYPE) %>%
  summarize(N = n()) %>%
  arrange(desc(N)) %>%
  mutate(N = prettyNum(N, big.mark = ",")) %>%
  knitr::kable(col.names = c("Event type", "Number of events in 2015"))


# next look at events by EVENTS TYPE & COUNTY VS FIPS
events_2015 %>%
  group_by(CZ_TYPE, EVENT_TYPE) %>%
  summarize(n_events = n()) %>%
  ungroup() %>%
  spread(key = CZ_TYPE, value = n_events, fill = 0) %>%
  mutate(total = C + Z,
         perc_county = 100 * C / total) %>%
  arrange(desc(perc_county), desc(total)) %>%
  mutate(C = prettyNum(C, big.mark = ","),
         Z = prettyNum(Z, big.mark = ","),
         total = prettyNum(total, big.mark = ","),
         perc_county = paste0(round(perc_county), "%")) %>%
  knitr::kable(col.names = c("Event type", "County", "Forecast Zone", "Total", "% county"),
               align = "lcccc")


# other potential data
# https://www.kaggle.com/datasets/noaa/noaa-severe-weather-data-inventory

#########################
# merge with the fips - zip ladder
setwd("~/Documents/supplyChain")
ladder <- read.csv("data/companyData/zipFIPS_ladder.csv") %>% select(ZIP,STCOUNTYFP) %>% 
  rename(zipcode = ZIP) # before depreciation, things seem a bit more scarce


# focus on winds
events_2000s     <- create_storm_data(date_range = c("2000-01-01", "2019-12-31"))

thunderstormWinds = events_2000s %>% filter(EVENT_TYPE == 'Thunderstorm Wind')

thunderstormWinds$propScale = str_sub(thunderstormWinds$DAMAGE_PROPERTY,-1)
thunderstormWinds$propDam   = as.numeric(str_sub(thunderstormWinds$DAMAGE_PROPERTY,end = -2))

# get a sense of scale here 
thunderstormWinds %>%
  summarise(enframe(quantile(INJURIES_DIRECT,   c(0.5,0.9,0.95,0.9999)), "quantile", "INURIES_DIRECT"),
            enframe(quantile(INJURIES_INDIRECT, c(0.5,0.9,0.95,0.9999)), "quantile", "INURIES_INDIRECT"),
            enframe(quantile(DEATHS_DIRECT,     c(0.5,0.9,0.95,0.9999)), "quantile", "DEATHS_DIRECT"),
            enframe(quantile(DEATHS_INDIRECT,   c(0.5,0.9,0.95,0.9999)), "quantile", "DEATHS_INDIRECT"),
            enframe(quantile(propDamageScaled,   c(0.5,0.9,0.95,0.9999)), "quantile", "propDamageScaled"))

# now summarize by quarter
thunderstormWindsQtr = thunderstormWinds %>% transform(CZ_FIPS = as.character(CZ_FIPS)) %>%
                                mutate(propDam = ifelse(is.na(propDam),0 , propDam),
                                 propertyScaleNumeric = case_when(propScale  == 'M'   ~ 1000000, 
                                                              propScale  == 'K'   ~ 1000,
                                                              (propScale != 'K') & (propScale  != 'M') ~ 0),
                                 propDamageScaled = propDam*propertyScaleNumeric,
                                 date = as.Date(paste0(END_YEARMONTH,END_DAY), "%Y%m%d"),
                                 qtr = as.yearqtr(as.POSIXct(date, format="%Y-%m-%d")),
                                 yearQtr = str_replace(qtr," Q","q"),
                                 propAboveTenThou     = 1*(propDamageScaled > 10000),
                                 propAboveHundredThou = 1*(propDamageScaled > 100000),
                                 propAboveMilli       = 1*(propDamageScaled > 1000000),
                                 CZ_FIPS = str_pad(CZ_FIPS,3,pad = "0",side = "left"),
                                 STCOUNTYFP = paste0(STATE_FIPS,CZ_FIPS)) %>%
  select(STCOUNTYFP,yearQtr,propAboveTenThou,propAboveHundredThou,propAboveMilli) 

thunderstormsByZIP = thunderstormWindsQtr %>% merge(ladder)

  

setwd("~/Documents/supplyChain")
filename = paste0('data/companyData/thunderstormWinds','.csv')
write.csv(thunderstormsByZIP,filename)


# %>% 
#   group_by(STCOUNTYFP,yearQtr) %>% summarise(propAboveTenThou     = (sum(propAboveTenThou) > 0)*1,
#                                              propAboveHundredThou = (sum(propAboveHundredThou) > 0)*1,
#                                              propAboveMilli       = (sum(propAboveMilli) > 0)*1)


