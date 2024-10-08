library(pdftools)
library(xlsx)
library(stringr)
# Identify your storage path
storage_path <- "~/Desktop/test_folder/"

# Read in and input all of the water system IDs you are interested in
# So if there are in a data frame just do like this ids <- df$id
ids <- c('CA5400544', 'CA2810004', 'CA3910005', 'CA5401003', 'CA1910041')

# Honestly everything else from here should run on its own in your computer
# What you'll end with is your storange path folder all full of reports
# and a data frame called log that tells you which are missing
years <- 2018:2023

# These are the parts of the CCR report url that we are just going to put together
# with varying queries for the ID and the Year
ccr_url_pt1 <- 'https://ear.waterboards.ca.gov/Home/ViewCCR?PwsID='
ccr_url_pt2 <- '&Year='
ccr_url_pt3 <- '&isCert=false'

# Now we will iterate through each combo of ID and year and see if we can download the report
# We will use trycatch which will just skip over those that don't have reports instead of breaking
for(i in 1:length(ids)){
  for(j in 1:length(years)){
    ccr_url <- paste0(ccr_url_pt1, ids[i], ccr_url_pt2, years[j], ccr_url_pt3)
    dest_file <- paste0(storage_path, ids[i], "_", years[j], ".pdf")
    # the next line says don't redownload if the 'destination file' it already stored
    # (e.g. don't re-download to save you time)
    if(paste0(ids[i], "_", years[j], ".pdf") %in% list.files(storage_path)) {next} 
    else {tryCatch(download.file(ccr_url, dest_file),
                           error = function(e) NA )}
  }
}

# Now, those that are not PDFs will be saved with a .pdf extension, but it won't go well
# So let's evaluate each file
pdf_error_fls <- list()
fls <- list.files(storage_path, full.names = T)
pdf_fls <- fls[str_detect(fls, '.pdf')]
for(i in 1:length(pdf_fls)){
  output <- tryCatch(pdf_info(pdf_fls[i]),
                   error = function(e) pdf_fls[i])
  pdf_error_fls[[i]] <-ifelse(output == pdf_fls[i], pdf_fls[i], NA)
}
pdf_error_fls <- unlist(pdf_error_fls)
pdf_error_fls <- pdf_error_fls[!is.na(pdf_error_fls)]

## Remove them from the database
file.remove(pdf_error_fls)

## Then try to set these right. Revisit the url and try with Excel
for(i in 1:length(pdf_error_fls)){
  id = str_extract(pdf_error_fls[i], 'CA\\d+(?=_)')
  yr = str_extract(pdf_error_fls[i], '\\d{4}(?=\\.pdf)')
  ccr_url <- paste0(ccr_url_pt1, id, ccr_url_pt2, yr, ccr_url_pt3)
  dest_file <- paste0(storage_path, id, "_", yr, ".xls")
  if(paste0(id, "_", yr, ".xls") %in% list.files(storage_path)) {next} 
  tryCatch(download.file(ccr_url, dest_file), error = function(e) NA )
}

## And just like with PDFs, do a check on whether these seem like valid Excel files
xls_error_fls <- list()
fls <- list.files(storage_path, full.names = T)
xls_fls <- fls[str_detect(fls, '.xls')]
for(i in 1:length(xls_fls)){
  output <- tryCatch(read.xlsx(xls_fls[i], 1),
                     error = function(e) xls_fls[i])
  xls_error_fls[[i]] <-ifelse(output == xls_fls[i], xls_fls[i], NA)
}
xls_error_fls <- unlist(xls_error_fls)
xls_error_fls <- xls_error_fls[!is.na(xls_error_fls)]

## Remove the errors from the database
file.remove(xls_error_fls)

## Then try to set these right. Revisit the url and try as a doc
for(i in 1:length(xls_error_fls)){
  id = str_extract(xls_error_fls[i], 'CA\\d+(?=_)')
  yr = str_extract(xls_error_fls[i], '\\d{4}(?=\\.xls)')
  ccr_url <- paste0(ccr_url_pt1, id, ccr_url_pt2, yr, ccr_url_pt3)
  dest_file <- paste0(storage_path, id, "_", yr, ".doc")
  tryCatch(download.file(ccr_url, dest_file), error = function(e) NA )
}

# In the end I am hoping everything else is a doc. There might be errors there but can duplicate previous process

# You can check what worked and what didn't by making a dataframe of what
log <- data.frame('id' = rep(ids, each = length(years)),
                  'year' = rep(years, times = length(ids)))
log$status <- ifelse(str_detect(paste0(log$id, "_", log$year), 
                    paste0(str_remove_all(list.files(storage_path), 
                                          '\\.pdf|\\.xls|\\.doc'), collapse = "|")),
                                 'downloaded', 'missing')

# Old, works to get hidden ids used for other things, but is irrelevant ----
#library(rvest)
#library(xml2)
#library(stringr)
#
### This has all of the water systems. So we want their links
#url <- 'https://sdwis.waterboards.ca.gov/PDWW/JSP/SearchDispatch?number=&name=&county#=&WaterSystemType=All&WaterSystemStatus=A&SourceWaterType=All&action=Search+For+Water+Systems'
#links <- read_html(url) %>% 
#  xml_find_all('//*[(@id = "AutoNumber7")]//a') %>% 
#  html_attr('href') %>% 
#  unlist %>% trimws()
#df <- data.frame('ws_id' = str_extract(links, '(?<=wsnumber\\=).*'),
#                 'hidden_id' = str_extract(links, '(?<=is_number\\=).+(?=\\&tinwsys_st)'),
#                 'link' = links)
#