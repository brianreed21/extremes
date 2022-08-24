library(reshape);library(gridExtra);library(stargazer);library(ggplot2);library(gdata);library(polyclip);library(maptools);library(plyr);library(ggmap);library(sp);library(raster);library(rgdal);library(maps);library(rworldmap);library(scales);library(ggplot2);library(ggrepel);library(xtable);library(plm);library(lmtest)
library(lfe);library(R.utils);library(dplyr);library(caTools);library(tidyr);library(DescTools)
library(plm); library(sandwich); library(lmtest); library(fastDummies);  library(margins); library(marginaleffects)

########################################################################################################################
# load the data first

setwd("~/Documents/supplyChain")

# load: ig data
data   <- read.csv("data/companyData/goodsData_igData.csv") %>% select(-X) 





########################################################################################################################
start = Sys.time()
mod <- lm('lnRevNormd ~ factor(indGroup)*(precip_zipQuarterquant_0.95 + lag1_precip_zipQuarterquant_0.95 + lag2_precip_zipQuarterquant_0.95 + lag3_precip_zipQuarterquant_0.95) +
          factor(gvkey) + factor(indGroup)*factor(qtr) + factor(yearQtr) + factor(ageTercile) + factor(profitTercile) + factor(sizeTercile)', data = data)
         
# end   = Sys.time()


print(Sys.time() - start)

cmp <- comparisons(mod, variables = "precip_zipQuarterquant_0.95")


plot_cap(mod, condition = c('precip_zipQuarterquant_0.95','indGroup'))

# https://vincentarelbundock.github.io/marginaleffects/articles/contrasts.html
# plot_cco(mod,
#   effect = list(indGroup = 'all'),
#   condition = "precip_zipQuarterquant_0.95")




plot_cap(mod, condition = 'precip_zipQuarterquant_0.95') + facet_wrap(~indGroup)


plot_cap(mod,
  type = "probs",
  condition = "mpg") +
  facet_wrap(~group)


#########################################################################################################################
# the following took 2.6 days, so...not this one
# mfx <- margins(mod,variables = c("precip_zipQuarterquant_0.95","lag1_precip_zipQuarterquant_0.95","lag2_precip_zipQuarterquant_0.95","lag3_precip_zipQuarterquant_0.95"),
#                at = list(indGroup = c("manu","wholesale","transportUtilities","mining","construction","agForFish","retail")))
# all = data.frame(summary(mfx))
# all

# potential 
# 


print(Sys.time() - start)