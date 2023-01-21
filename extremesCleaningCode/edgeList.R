###################################################
# install devtools
install.packages("devtools")

# load devtools
library(devtools)

# install arcdiagram
install_github('gastonstat/arcdiagram')

# load arcdiagram
library(arcdiagram)

library(igraph)

# devtools::install_github("mattflor/chorddiag")
library(tidyverse)
library(viridis)
library(patchwork)
library(hrbrthemes)
library(circlize)
library(chorddiag)  #devtools::install_github("mattflor/chorddiag")

###################################################


setwd("~/Documents/supplyChain")
stateGraph <- read.csv("data/companyData/stateEdgeList.csv") %>% select(-c('X')) %>% as.matrix()
nodes <- read.csv("data/companyData/nodeList.csv") %>% pull('X0')
colnames(stateGraph) <- nodes
rownames(stateGraph) <- nodes
statesOrdered <- read.csv("data/companyData/statesByRelats.csv")  %>% select(-c('X')) %>% pull('supplier_state')
stateGraph <- stateGraph[statesOrdered, statesOrdered]



# cite things here: 
# https://jokergoo.github.io/circlize_book/book/the-chorddiagram-function.html
chordDiagram(x = stateGraph,
             directional = 1,
             direction.type = c("arrows", "diffHeight"), 
             diffHeight  = -0.04,
             link.arr.type = "big.arrow",
             link.lwd = .01,    # Line width
             link.lty = 1,    # Line type
             link.border = 1)



###################################################
precipGraph <- read.csv("data/companyData/precipGraph.csv") %>% select(-c('X')) %>% as.matrix()
colnames(precipGraph) = c('1','2','3','4','5','6','7','8','9','10')
rownames(precipGraph) = c('1','2','3','4','5','6','7','8','9','10')

# make the blue palette
getHEXcolors <- colorRampPalette(c("#FFFFFF", "#1F78B4"))
blues <- getHEXcolors(10)
# scales::show_col(getHEXcolors(10), labels = FALSE)
# https://datacornering.com/how-to-create-and-preview-hex-color-code-sequence-in-r/


chordDiagram(precipGraph, 
             grid.col = blues,
             directional = 1,
             direction.type = c("arrows", "diffHeight"), 
             diffHeight  = -0.04,
             link.arr.type = "big.arrow",
             link.lwd = .05,    # Line width
             link.lty = 1,    # Line type
             link.border = 1)


###################################################
tempGraph <- read.csv("data/companyData/tempGraph.csv") %>% select(-c('X')) %>% as.matrix()
colnames(tempGraph) = c('1','2','3','4','5','6','7','8','9','10')
rownames(tempGraph) = c('1','2','3','4','5','6','7','8','9','10')

reds = c()
for (i in seq(1,10)){
  reds <- append(reds,hsv(h=0, s=i/10, v=1))
}


chordDiagram(tempGraph, 
             grid.col = reds,
             directional = 1,
             direction.type = c("arrows", "diffHeight"), 
             diffHeight  = -0.04,
             link.arr.type = "big.arrow",
             link.lwd = .05,    # Line width
             link.lty = 1,    # Line type
             link.border = 1)

blues = c()
for (i in seq(1,10)){
  blues <- append(reds,rainbow(subrange = 0.5 + i/10))
}
blues <- c('blue1', 'blue2', 'blue3', 'blue4', 'blue5', 'blue6', 'blue7','blue8','blue9', 'blue10')
###################################################
# state edge list
scFile <- "data/companyData/precipGraph.txt" 

sc_graph = read.graph(scFile, format = "gml")#, format="gml")

edgelist = get.edgelist(sc_graph)
values   = get.edge.attribute(sc_graph, "relats")


arcplot(edgelist, 
        lwd.arcs  = 0.01*values, 
        col.arcs  = hsv(0, 0, 0.2, 0.25),
        sorted = TRUE)

