# Function for reading IPUMS data using the DII codebook (xml)
# Import the fixed-width data and use the IPUMS DII codebook file to import the positions

require(XML)

PUMSr <- function(dat, codebook) {
  # Parse XML codebook
  read <- xmlInternalTreeParse(codebook, useInternalNodes = TRUE)
  
  # Get the 'variable' nodeset
  ns <- getNodeSet(read, "//*[name()='var']")
  
  # Read the values of variable names
  names <- xpathSApply(read,"//*[name()='var']",xmlAttrs) 
  names <- names[1,]
  
  # Get start and end positions
  pos <- xpathSApply(read, "//*[name()='var']/*[name()='location']", xmlAttrs)
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
  
  library(iotools)
  pums <- input.file(dat, formatter = dstrfw, col_types=type,
                     widths = (endpos - startpos) + 1)
  colnames(pums) <- tolower(names)
  return(pums)  
}

