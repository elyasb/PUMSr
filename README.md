# pumsr

pumsr is a simple package for directly importing fixed-width [IPUMS data](http://www.ipums.org) into R using the XML DDI codebook. IPUMS extracts currently only include fixed-width data files and command files for Stata, SPSS, or SAS. 

## Installation

pumsr is currently only available through Github.

```{r}
# To install the development version from GitHub:
# install.packages("devtools")
devtools::install_github("elyasb/pumsr")
```
## Usage

Simply provide the filenames for the fixed-width data (.dat) and DDI codebook (.xml), and pumsr will create a data frame. For files too large for a standard import (more than 10 gb or so, depending on memory restrictions), specifying `large=TRUE` will read the data as a [ffdf](https://cran.r-project.org/web/packages/ffbase/ffbase.pdf) object.

The default import uses original codes for all factor variables. Running pumsr with `labels=TRUE` will replace factor levels with the category value labels from the codebook. Double-check labels after import, as there are occassionally discrepencies between the number of variable values and the labels in the IPUMS codebook.
