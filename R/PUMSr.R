# Function for reading IPUMS data using the DII codebook (xml)
# Import the fixed-width data and use the IPUMS DII codebook file to import the positions

pumsr <- function(dat, codebook, large=FALSE, labels=FALSE) {
  # Parse XML codebook
  read <- XML::xmlInternalTreeParse(codebook, useInternalNodes = TRUE)
  
  # Get the 'variable' nodeset
  ns <- XML::getNodeSet(read, "//*[name()='var']")
  
  # Read the values of variable names
  names <- XML::xpathSApply(read,"//*[name()='var']", XML::xmlAttrs) 
  names <- names[1,]
  
  # Get start and end positions
  pos <- XML::xpathSApply(read, "//*[name()='var']/*[name()='location']", XML::xmlAttrs)
  startpos <- as.numeric(pos[1,])
  endpos <- as.numeric(pos[3,])
  
  # Scrape label information
  # Get category value for each variable
  valpaths <- lapply(names, function(x) paste0("//*[name()='var'][@ID='", x, "']/*[name()='catgry']/*[name()='catValu']"))
  catval <- suppressWarnings(lapply(valpaths, function(x) XML::xpathSApply(read, x, XML::xmlValue)))
  
  # Get category label for each value
  lblpath <- lapply(names, function(x) paste0("//*[name()='var'][@ID='", x, "']/*[name()='catgry']/*[name()='labl']"))
  catlbl <- suppressWarnings(lapply(lblpath, function(x) XML::xpathSApply(read, x, XML::xmlValue)))
  type <- pos <- XML::xpathSApply(read, "//*[name()='var']/*[name()='varFormat']", XML::xmlAttrs)
  type <- type[2,]
  coltype <- substr(gsub("numeric", "integer", type), start=1, stop=1)
  
  # For relatively small files, read in directly
  if(large==FALSE){
  #pums <- iotools::input.file(dat, formatter = dstrfw, col_types=type,
  #                   widths = (endpos - startpos) + 1)
  pums <- as.data.frame(readr::read_fwf(dat, readr::fwf_widths((endpos - startpos)+1), col_type=paste(rep("c", 40), collapse="")))
  
  } else {
  # For larger files, use LaF package to load
    pums.laf <- LaF::laf_open_fwf(dat, column_widths=(endpos - startpos) + 1, 
                             column_types=type)
    pums <- ffbase::laf_to_ffdf(pums.laf)
  }
  
  if(labels==TRUE){
  for(i in 1:length(pums)){ # Loops through and adds labels if available. Excludes some variables with more values than labels (such as year variables)
    if(is.null(catlbl[[i]])==FALSE & (length(unique(catval[[i]])) >= length(unique(pums[,i])))==TRUE & (length(which(unique(pums[,i]) %in% catval[[i]]))>0)){
      cat(paste("Adding category labels to", names[i], "\n"))
      pums[,i] <- factor(pums[,i], levels=catval[[i]], labels=catlbl[[i]])
    } else{class(pums[,i]) <- type[i]}
  }
  }
  
  colnames(pums) <- tolower(names)
  return(pums)  
  
}

