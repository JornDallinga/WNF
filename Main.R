# Installing packages
if (!require(raster)) install.packages('raster')
if (!require(sp)) install.packages('sp')
if (!require(rgdal)) install.packages('rgdal')
if (!require(RCurl)) install.packages('RCurl')
if (!require(ff)) install.packages('ff')
if (!require(gfcanalysis)) install.packages('gfcanalysis')
if (!require(caret)) install.packages('caret', dependencies = T)
if (!require(parallel)) install.packages('parallel', dependencies = T)
if (!require(pryr)) install.packages('pryr', dependencies = T)
if (!require(plotKML)) install.packages('plotKML', dependencies = T)
if (!require(xlsx)) install.packages('xlsx', dependencies = T)
if (!require(openxlsx)) install.packages('openxlsx', dependencies = T)
if (!require(stringi)) install.packages('stringi', dependencies = T)
if (!require(cleangeo)) install.packages('cleangeo', dependencies = T)


# Loading packages
library(raster)
library(pryr)
library(parallel)
library(sp)
library(rgdal)
library(rgeos)
library(RCurl)
library(bitops)
library(gfcanalysis)
library(caret)
library(e1071)
library(plotKML)
library(maptools)
library(xlsx)
# prioritize a package function for writing excel files
write.xlsx.xlsx <- write.xlsx
library(openxlsx)
library(stringi)
library(cleangeo)







# Load source scripts
source("R/Download_FTP.R")
source("R/Hansen.R")
source("R/WWF.R")
source("R/Extent.R")
source("R/Confusion_matrix.R")
source("R/Poly_looping.R")
source("R/accuracy.R")
source("R/buf.R")
source("R/Forest_def.R")
source("R/TREES_III.R")
source("R/Conf_t.R")
source("R/combine_tab.R")

# set temp directory
#options(rasterTmpDir='d:/r/temp_dir/')

# install Rtools
# Set environemnt to the zip.exe in C:/INSTALLATIONFOLDER/Rtools/bin/zip
#Sys.setenv(R_ZIPCMD= "C:/Users/Gebruiker/Documents/R/win-library/3.1/Rtools/bin/zip") 

# Create folders
dir.create(file.path('data'), showWarnings = FALSE)
dir.create(file.path('data/output'), showWarnings = FALSE)
dir.create(file.path('data/Hansen'), showWarnings = FALSE)
dir.create(file.path('data/extract_hansen'), showWarnings = FALSE)


# Set function parameters
data <- 'Forest Cover'
year <- 2010
mydir <- 'data'
threshold <- 30
country <- NULL # or 
country <- NULL # http://en.wikipedia.org/wiki/ISO_3166-1
region <- NULL # Select state/province of country. Use NULL if you wish to use the whole country as extent

# Run functions

## Download WWF data
x <- Download_WWF(data = 'Forest Cover', year = year, mydir = 'data')

## Create extent from selected country
output <- Extent_func(year = year, mydir = mydir, country = country, region = region)

## Forest Cover WWF
s <- writeRaster(x, 'new.grd', datatype='INT2U', overwrite=TRUE)

WWF_FC <- WWF(x = x, output = output)

## Download and prepare Hansen Forest Cover data
hansen_FC <- Hansen(threshold = threshold, year = year, output = output)

## Confusion matrix for accuracy assessment
Confusion_Matrix(WNF = WWF_FC, Hansen = hansen_FC[1])


#----------------------------------------end of script---------------------------------------#



######################################################## GEO-WIKI #########################################################

## set variables
threshold <- 10
BufferDistance <- 500 # translates to 1km by 1km polygons
year <- 2010

# read excel file
df <- read.xlsx("FC_test.xlsx", sheet = 1, startRow = 1, colNames = TRUE)

xy <- df[,c(2,3)]

# create SpatialPointsDataFrame
spdf <- SpatialPointsDataFrame(coords = xy, data = df,
                               proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))

# select ecoregion WWF data
ras <- raster('data/cerrado_2010_forest_WGS.tif')

# crop ecoregion
t <- crop(x = spdf, y = ras)

# subset by date
subsettest <- subset(t, (as.numeric(substr(t$Google.image.date, 0, 4)) >= 2009) & (as.numeric(substr(t$Google.image.date, 0, 4)) <= 2011))

# subset by confidence level
subt <- subset(subsettest, subsettest$HI.Confidence <= 30)

# copy dataset
mydata <- subt

# replace values based on threshold
mydata$Ref[(subt$LC1 == 1 & subt$LC1_Perc >= threshold) | (subt$LC2 == 1 & subt$LC2_Perc >= threshold) | (subt$LC3 == 1 & subt$LC3_Perc >= threshold) ] <- 1
mydata$Ref[is.na(mydata$Ref)] <- 0

# run loop through each point in the dataframe, create a buffer, and calc accuracy.
for (i in 1:length(mydata)){
  
  # create progress bar
  pb <- winProgressBar(title = "progress bar", min = 0,
                       max = length(mydata), width = 300)
  Sys.sleep(0.1)
  setWinProgressBar(pb, i, title=paste(round(i/length(mydata)*100, 0),
                                       "% done"))
  # start functions
  buff <- buf(mydata = mydata, BufferDistance = BufferDistance)
  
  #rast <- Hansen(threshold = threshold, year = 2010, output = buff, UTM = F)
  rr <- Poly_looping(mydata = mydata, ras = ras, buff = buff)
  
  # add to dataframe
  mydata$non_forest[i] <- as.numeric(rr[1])
  mydata$forest[i] <- as.numeric(rr[2])
  
  print(i)
  # close
  if (i == length(mydata)){
    close(pb)
  }


}

# Calculate accuracy to table
final.table <- accuracy(output = mydata, threshold = threshold)

# Confusion matrix
final <- confusionMatrix(final.table)
# prop table
final.prop <- prop.table(final.table)

# Create confusion matrix
Confusion_table <- as.data.frame.matrix(final$table)
Confusion_table_prop <- as.data.frame.matrix(final.prop)
Confusion_overall <- as.matrix(final$overall)
Confusion_byClass <- as.matrix(final$byClass)

dataset <- 'GEO-Wiki'
Ecozone <- 'Amazon'
Name <- 'WWF'

# Write to excel sheets
write.xlsx.xlsx(Confusion_table, file = sprintf("data/output/%s/%s_%s_%s_%s.xlsx",dataset,Ecozone, Name, year, threshold), sheetName = "Confusion_Matrix")
write.xlsx.xlsx(Confusion_table_prop, file = sprintf("data/output/%s/%s_%s_%s_%s.xlsx",dataset,Ecozone, Name, year, threshold), sheetName = "Confusion_table_prop", append = T)
write.xlsx.xlsx(Confusion_overall, file = sprintf("data/output/%s/%s_%s_%s_%s.xlsx",dataset,Ecozone, Name, year, threshold), sheetName = "Confusion_overall", append = T)
write.xlsx.xlsx(Confusion_byClass, file = sprintf("data/output/%s/%s_%s_%s_%s.xlsx",dataset,Ecozone, Name,year, threshold), sheetName = "Confusion_byClass", append = T)



######################################################## TREES III #########################################################

# Error at 16


# Load WWF datasets
from <- raster('data/cerrado_2000_forest.tif')
to <- raster('data/cerrado2010merc.tif')

from <- setMinMax(from)
to <- setMinMax(to)

threshold <- 30

# List files of TREES III dataset
myfiles <- list.files('data/TREES_III/Amazon/Brazil_SHP/', pattern = '.shp', full.names = T)
myfiles_names <- list.files('data/TREES_III/Amazon/Brazil_SHP/', pattern = '.shp', full.names = F)

#Ignore .zip files (optional)
#myfiles <- myfiles[ !grepl(".zip",myfiles) ]

count <- 0

# Run loop through myfiles
for (i in 1:length(myfiles)){
  
  # create progress bar
  pb <- winProgressBar(title = "progress bar", min = 0,
                       max = length(myfiles), width = 300)
  Sys.sleep(0.1)
  setWinProgressBar(pb, i, title=paste(round(i/length(myfiles)*100, 0),
                                       "% done"))
  
  # start functions
  ogr <- myfiles[i]
  ogr_layer <- stri_sub(myfiles_names[i], 0, -5)
  TREES <- readOGR(ogr, layer = ogr_layer)
  flag <- tryCatch(clgeo_Clean(TREES), error = function(x) NULL)
  if (is.null(flag)){
    next
  } else {
    TREES <- clgeo_Clean(TREES)
  }
  
  # Check if TREES and WWF intersect
  comb <- Check_Intersect(TREES,to)
  if (comb == F){
    next
  }
  
  #comb <- TREES_III(from = from, to = to, TREES = TREES, type = 'FCC', year = 2010, Mosaic = T, ogr_layer = ogr_layer, H = F)
  tab <- TREES_III_weights(TREES = TREES, from = from, to = to, year = year)

  
  if (is.null(tab) == F){
    #tab <- Conf_t(pred = subset(comb, 'Prediction'), ref = subset(comb, 'Reference'))
    #Spat <- Point_dataframe(tab = tab, comb = comb, count = count)

    if (count == 0){
      tab1 <- tab
      count <- count + 1
      #Spat2 <- Spat
    } else {
      tab1 <- combine_tab(tab1 = tab1, tab = tab)
      #Spat2 <- rbind.SpatialPointsDataFrame(Spat2, Spat)
    }
    
  }
  # close
  if (i == length(myfiles)){
    close(pb)
  }
}

# create confusion matrix
final <- confusionMatrix(tab1)
final

final.prop <- prop.table(tab1)

# read variables
# Create confusion matrix
Confusion_table <- as.data.frame.matrix(final$table)
Confusion_table_prop <- as.data.frame.matrix(final.prop)
Confusion_overall <- as.matrix(final$overall)
Confusion_byClass <- as.matrix(final$byClass)

dataset <- 'TREES_III'
Ecozone <- 'Cerrado'
Name <- 'WWF'
type <- 'FC'
Tree_type <- 'Mosaic_weight_5_5MMU_Majority'

# Write to excel sheets
write.xlsx.xlsx(Confusion_table, file = sprintf("data/output/%s/%s/%s_%s_%s_%s_%s.xlsx",dataset, type,Ecozone, Name, year, threshold, Tree_type), sheetName = "Confusion_Matrix")
write.xlsx.xlsx(Confusion_table_prop, file = sprintf("data/output/%s/%s/%s_%s_%s_%s_%s.xlsx",dataset,type,Ecozone, Name, year, threshold, Tree_type), sheetName = "Confusion_table_prop", append = T)
write.xlsx.xlsx(Confusion_overall, file = sprintf("data/output/%s/%s/%s_%s_%s_%s_%s.xlsx",dataset,type,Ecozone, Name, year, threshold, Tree_type), sheetName = "Confusion_overall", append = T)
write.xlsx.xlsx(Confusion_byClass, file = sprintf("data/output/%s/%s/%s_%s_%s_%s_%s.xlsx",dataset,type,Ecozone, Name,year, threshold, Tree_type), sheetName = "Confusion_byClass", append = T)

# write to ESRI shapefile
Spat2WGS <- spTransform(x = Spat2, CRSobj = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
writeOGR(Spat2WGS, dsn = 'C:/R_Projects/WNF', layer ='SpatialPoints2WGS', driver = 'ESRI Shapefile')
