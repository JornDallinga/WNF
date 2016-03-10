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






# Load source scripts
source("R/Download_FTP.R")
source("R/Hansen.R")
source("R/WWF.R")
source("R/Extent.R")
source("R/Confusion_matrix.R")
source("R/Poly_looping.R")
source("R/accuracy.R")
source("R/buf.R")

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

## set variables
threshold <- 60
BufferDistance <- 500 # translates to 1k by 1k polygons
year <- 2005

# read excel file
df <- read.xlsx("FC_test.xlsx", sheet = 1, startRow = 1, colNames = TRUE)

xy <- df[,c(2,3)]

# create SpatialPointsDataFrame
spdf <- SpatialPointsDataFrame(coords = xy, data = df,
                               proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))

# select ecoregion WWF data
ras <- raster('data/cerrado_af_2010_forest_WGS.tif')

# crop ecoregion
t <- crop(x = spdf, y = ras)

# subset by date
subsettest <- subset(t, substr(t$Google.image.date, 0, 4) == c('2004', '2005', '2006'))

# subset by confidence level
subt <- subset(subsettest, subsettest$HI.Confidence <= 30)

# copy dataset
mydata <- subt

# replace values based on threshold
mydata$Ref[(subt$LC1 == 1 & subt$LC1_Perc >= threshold) | (subt$LC2 == 1 & subt$LC2_Perc >= threshold) | (subt$LC3 == 1 & subt$LC3_Perc >= threshold) ] <- 1
mydata$Ref[is.na(mydata$Ref)] <- 0

#
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

final <- accuracy(output = mydata, threshold = threshold)

Confusion_table <- as.data.frame.matrix(final$table)
Confusion_overall <- as.matrix(final$overall)
Confusion_byClass <- as.matrix(final$byClass)

# Write to excel sheets
write.xlsx.xlsx(Confusion_table, file = sprintf("data/output/Amazone_WWF_%s.xlsx",year), sheetName = "Confusion_Matrix")
write.xlsx.xlsx(Confusion_overall, file = sprintf("data/output/Amazone_WWF_%s.xlsx",year), sheetName = "Confusion_overall", append = T)
write.xlsx.xlsx(Confusion_byClass, file = sprintf("data/output/Amazone_WWF_%s.xlsx",year), sheetName = "Confusion_byClass", append = T)
