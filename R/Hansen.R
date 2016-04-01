Hansen <- function(threshold = threshold, year = year, output = output, UTM = UTM, H = T){
  ## Create variable Area Of Interest (aio)
  #aoi <- readRDS(file = 'data/BufferWGS.rds', refhook = NULL)
  aoi <- output
  ## Calculate tiles needed to cover the AOI
  tiles <- calc_gfc_tiles(aoi)
  print(length(tiles))
  
  ## Download GFC data
  download_tiles(tiles, 'data/Hansen', data_year = 2015)
  
  ## Extract data from tiles
  Ex_data <- extract_gfc(aoi, data_folder = "data/Hansen", stack = 'change', data_year = 2015, to_UTM = UTM)

  
  ## Apply threshold to extracted data 
  thres <- threshold_gfc(Ex_data, forest_threshold = threshold)
  

  ## anual stack of years
  annual_Hansen <- annual_stack(stack(thres), data_year = 2015)
  
  # Select a year from the annual Hansen dataset
  select_y <- sprintf("y%s",year)
  subset_Year <- subset(annual_Hansen, subset = select_y)

  
  # Create binary forest cover map and figure output
  
  if (year == 2000){
    ## create forest cover mask year 2000

    mask_gfc <- mask_gfc$forest2000
    
  } else if (year >= 2001 & year <= 2014){
    ## create forest cover mask of years 2001 till 2014
    subset_Year[subset_Year == 1 ] <- 1   # Forest
    subset_Year[subset_Year == 2 ] <- 0   # Non forest
    subset_Year[subset_Year == 3 ] <- 0   # Forest loss
    subset_Year[subset_Year == 4 ] <- 1   # Forest gain
    subset_Year[subset_Year == 5 ] <- 1   # Forest loss and gain
    subset_Year[subset_Year == 6 ] <- 0   # Water
    mask_gfc <- subset_Year
  } else {
    warning("invalid year")
  }
  
  names(mask_gfc) <- "Hansen"
  
  return (mask_gfc)
}


# KML(mask_gfc, file = 'data/output/test.kml') 
