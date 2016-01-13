Download_WWF <- function(data,year,mydir){
  
  # get login information
  baseurl <- sprintf(("ftp://globil.panda.org/%s/%s/"), data, year)
  un = readline("Type the username:")
  pw = readline("Type the password:")
  upw = paste(un, pw, sep = ":")
  
  # list files on FTP server
  filenames <- getURL(baseurl, userpwd = upw,
                      ftp.use.epsv = FALSE, dirlistonly = TRUE)
  filenames <- strsplit(filenames, "\r\n")
  filenames <- unlist(filenames)
  
  urls <- grep(pattern = ".tif$", filenames, value = T)
  
  print("Listing files to download")
  urls

  
  # generate the full URLS
  fileurls = paste0(baseurl, urls)
  # generate the destination file paths
  filepaths = file.path(mydir, urls)
  # create a container for loop outputs
  res = vector("list", length = length(filepaths))
  # loop through urls and download
  for(i in seq(length(fileurls)))
    writeBin(getBinaryURL(fileurls[i], userpwd = upw), 
             con = filepaths[i])  
  
  # list all files in folder
  print('select a file from the following list: ')
  list.files(sprintf('%s/',mydir), full.names=F)
  
  # Request filename
  WWF_dataset = readline("Select a geograpahic location from the list: ")
  
  x <- raster(sprintf('data/%s',WWF_dataset))
  x <- setMinMax(x)
  
  return(x)
}
