#' Import fixed-width files from ipums.org directly into R
#' @param dat The fixed-width data file.
#' @param codebook The XML version of the codebook for the corresponding ipums extract.
#' @param large Files designated as "large" are imported using the LaF and ffbase packages to avoid memory problems. Defaults to FALSE. Factor labels are currently not supported with large files.
#' @param labels If TRUE, the labels option converts character variables to factors and attaches value labels. Defaults to FALSE.
#' @examples
#' ihis <- pumsr("ihis_00001.dat", "ihis_00001.xml", labels=TRUE)
#' @export
pumsr <- function(dat, codebook, labels=FALSE) {
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

  # Read in data
  pums <- as.data.frame(readr::read_fwf(dat, readr::fwf_widths((endpos - startpos)+1), col_type=paste(rep("c", length(type)), collapse="")))
  
    # Convert to factors if labels==TRUE
    if (labels==TRUE) {
      for(i in 1:length(pums)){ # Loops through and adds labels if available. Excludes some variables with more values than labels (such as year variables)
        if(is.null(catlbl[[i]])==FALSE & (length(unique(catval[[i]])) >= length(unique(pums[,i])))==TRUE & (length(which(unique(pums[,i]) %in% catval[[i]]))>0)){
          cat(paste("Adding category labels to", names[i], "\n"))
          pums[,i] <- factor(pums[,i], levels=catval[[i]], labels=catlbl[[i]])
        } else{
          cat(paste("Converting", names[i], "to", type[i], "\n"))
          class(pums[,i]) <- type[i]
          }
      }
    }
  
  
  colnames(pums) <- tolower(names)
  return(pums)  
  
}

