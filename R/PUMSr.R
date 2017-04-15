# Function for reading IPUMS data using the DII codebook (xml)
# Import the fixed-width data and use the IPUMS DII codebook file to import the positions

PUMSr <- function(dat, codebook, large=FALSE) {
  # Parse XML codebook
  read <- XML::xmlInternalTreeParse(codebook, useInternalNodes = TRUE)
  
  # Get the 'variable' nodeset
  ns <- XML::getNodeSet(read, "//*[name()='var']")
  
  # Read the values of variable names
  names <- XML::xpathSApply(read,"//*[name()='var']",xmlAttrs) 
  names <- names[1,]
  
  # Get start and end positions
  pos <- XML::xpathSApply(read, "//*[name()='var']/*[name()='location']", xmlAttrs)
  startpos <- as.numeric(pos[1,])
  endpos <- as.numeric(pos[3,])
  
  # Scrape label information
  # Get category value for each variable
  valpaths <- lapply(names, function(x) paste0("//*[name()='var'][@ID='", x, "']/*[name()='catgry']/*[name()='catValu']"))
  catval <- lapply(valpaths, function(x) xpathSApply(read, x, xmlValue))
  
  # Get category label for each value
  lblpath <- lapply(names, function(x) paste0("//*[name()='var'][@ID='", x, "']/*[name()='catgry']/*[name()='labl']"))
  catlbl <- lapply(lblpath, function(x) xpathSApply(read, x, xmlValue))
  type <- pos <- xpathSApply(read, "//*[name()='var']/*[name()='varFormat']", xmlAttrs)
  type <- type[2,]
  
  # For relatively small files, read in directly
  if(large==FALSE){
  library(iotools)
  pums <- input.file(dat, formatter = dstrfw, col_types=type,
                     widths = (endpos - startpos) + 1)
  } else {
  # For larger files, use FF package to load
    temp <- file(dat)
    pums <- sqldf
  }
  colnames(pums) <- tolower(names)
  return(pums)  
}

