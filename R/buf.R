buf <- function(mydata, BufferDistance){
  
  # select point from mydata (in WGS 84)
  point <- mydata[i,]
  
  # Select UTM zone
  UTMLocation <- utm_zone(point@coords[1], point@coords[2], proj4string = FALSE)
  
  # Make location ready for projection change.
  Zone <- substr(UTMLocation, 1, 2)
  Hemisphere <- substr(UTMLocation, 3,3)
  
  # Hemisphere <- "N"
  # Hemisphere <- "S"
  
  # Assign String values for CRS input.
  if(Hemisphere == "N") {
    HemiText <- "+north"
  } else if (Hemisphere == "S") {
    HemiText <- "+south"
  } else stop("Not a correct Hemisphere given")
  ZoneText = paste("+zone=", Zone, sep = "")
  
  # Combine prepared strings for final input string.
  CRSText <- paste("+proj=utm", ZoneText, HemiText, sep = " ")
  
  # Transform WGS to UTM.
  PointsUTM <- spTransform(mydata[i,], CRS(CRSText))
  
  # Buffers the point
  BufferUTM <- gBuffer(PointsUTM, width=BufferDistance, capStyle="SQUARE")
  
  # Convert to WGS
  BufferWGS <- spTransform(BufferUTM, CRS("+proj=longlat +datum=WGS84")) 
  
  return(BufferWGS)
}
