# Installing packages
if (!require(raster)) install.packages('raster')
if (!require(sp)) install.packages('sp')
if (!require(rgdal)) install.packages('rgdal')
if (!require(RCurl)) install.packages('RCurl')
if (!require(ff)) install.packages('ff')
if (!require(gfcanalysis)) install.packages('gfcanalysis')

# Loading packages
library(raster)
library(sp)
library(rgdal)
library(RCurl)
library(bitops)
library(gfcanalysis)


# Load source scripts
source("R/Download_FTP.R")

# Create folders
dir.create(file.path('data'), showWarnings = FALSE)
dir.create(file.path('data/Hansen'), showWarnings = FALSE)
dir.create(file.path('data/extract_hansen'), showWarnings = FALSE)
data/extract_hansen

# Set function parameters
data <- 'Forest Cover'
year <- 2000
mydir <- 'data'
threshold <- 30


# Run functions

## Download WWF data
Download_WWF(data = 'Forest Cover', year = 2000, mydir = 'data')
# Download_WWF(data = 'MODIS Mosaic.overviews', year = 'MODIS2005.Overviews', mydir = 'data/MODIS_MOSAIC')


