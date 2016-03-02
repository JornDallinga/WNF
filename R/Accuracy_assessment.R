cities <- readOGR(system.file("vectors", package = "rgdal")[1], "cities")
is.na(cities$POPULATION) <- cities$POPULATION == -99
summary(cities$POPULATION)
td <- tempdir()
writeOGR(cities, paste(td, "cities.kml", sep="/"), "cities", driver="KML")
xx <- readOGR(paste(td, "cities.kml", sep="/"), "cities")


readOGR("/data/Geo_Wiki.",layer.kml)
writeOGR("pathtooutput",driver="ESRI Shapefile",layer=output.shp)


library(maptools)
getKMLcoordinates(textConnection(system("unzip -p/data/Geo_Wiki1/test.kmz", intern = TRUE)))

kmlfile <- list.files('data/Geo_Wiki1/', full.names = T)[5]
kmlfile
kml.text <- readLines(kmlfile)  

OGRListLayers(dsn=kmlfile)

kml.text[3]

td <- 'data/Geo_Wiki1'
tt <- getKMLcoordinates(kmlfile, ignoreAltitude=T)

## reading kml files in R
read.kml <- function(file, layers) {
  read.layer <- function (layer_name) {
    spobj <- rgdal::readOGR(dsn=file, layer=layer_name)
    coords <- coordinates(spobj)
    colnames(coords) <- c('x', 'y', 'z')[1:ncol(coords)]
    df <- data.frame(coords, spobj@data)
    transform(df, layer=layer_name)
  }
  Reduce(rbind, lapply(layers, read.layer))
}

t <- read.kml(file = kmlfile, layers = 'validation.kml')

newmap <- readOGR(kmlfile, layer = 'validation.kml')[1]

###
#output path
output <- 'data/Geo_Wiki1/output'
######
importeddata <- readOGR(kmlfile, layer = 'testing.kml')
writeOGR(importeddata ,output,driver="ESRI Shapefile",layer= 'output.shp')
