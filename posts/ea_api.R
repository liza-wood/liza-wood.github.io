library(jsonlite)
library(httr)

## API source
# https://environment.data.gov.uk/asset-management/doc/reference

x = 100
page = 0
i = 1
ongoing_projects <- list()
while(x == 100){
  proj <- "https://environment.data.gov.uk/asset-management/id/capital-project.json?_offset="
  response <- VERB("GET", paste0(proj, page))
  response <- fromJSON(httr::content(response, "text")) 
  ongoing_projects[[i]] <- response$items
  x <- nrow(response$items)
  page = page+100
  i = i+1
}

ongoing_projects <- data.frame(data.table::rbindlist(ongoing_projects))
ongoing_projects <- ongoing_projects[,-which(colnames(ongoing_projects) %in% c("type"))]

x = 100
page = 0
i = 1
completed_projects <- list()
while(x == 100){
  proj <- "https://environment.data.gov.uk/asset-management/id/completed-capital-project.json?_offset="
  response <- VERB("GET", paste0(proj, page))
  response <- fromJSON(httr::content(response, "text")) 
  completed_projects[[i]] <- response$items
  x <- nrow(response$items)
  page = page+100
  i = i+1
}

completed_projects <- data.frame(data.table::rbindlist(completed_projects))
completed_projects <- completed_projects[,-which(colnames(completed_projects) %in% c( "isPartOf", "type"))]
 
library(stringr)
ongoing_list <- list()
base_ongoing <- "https://environment.data.gov.uk/asset-management/id/capital-project/"
for(i in 1:nrow(ongoing_projects)){
  if(str_detect(ongoing_projects$notation[i], 'TBC\\d')){ next }
  url <- paste0(base_ongoing, ongoing_projects$notation[i], '.json')
  response <- VERB("GET", url)
  response <- fromJSON(httr::content(response, "text")) 
  proj <- response$items
  ongoing_list[[i]] <- proj
}

ongoing_df <- dplyr::bind_rows(ongoing_list)

completed_list <- list()
base_completed <- "https://environment.data.gov.uk/asset-management/id/completed-capital-project/"
for(i in 1:nrow(completed_projects)){
  if(str_detect(completed_projects$notation[i], 'TBC\\d')){ next }
  url <- paste0(base_completed, completed_projects$notation[i], '.json')
  response <- VERB("GET", url)
  response <- fromJSON(httr::content(response, "text")) 
  proj <- response$items
  completed_list[[i]] <- proj
}

completed_df <- dplyr::bind_rows(completed_list)



 
  ## These work
#https://environment.data.gov.uk/asset-management/id/asset/382266.json?
#https://environment.data.gov.uk/asset-management/id/capital-project/2019/20-000096.json
#https://environment.data.gov.uk/asset-management/id/completed-capital-project/ACC451E/000A/633A.json

#https://environment.data.gov.uk/asset-management/id/capital-project.json?_limit=50


notations <- completed_projects$notation
sort(notations)


test <- "https://environment.data.gov.uk/asset-management/id/completed-capital-project/ACC451E/000A/633A.json?"
response <- VERB("GET", test)
response <- fromJSON(httr::content(response, "text")) 
proj <- response$items


"SOS003E/002A/003A" %in% completed_projects$notation
"SOS003E/000A/016A" %in% completed_projects$notation

#This call gets an error:
test <- "https://environment.data.gov.uk/asset-management/id/completed-capital-project/2020/21-002714.json?_view=full"
#This call does not:
test <- "https://environment.data.gov.uk/asset-management/id/completed-capital-project/2020/21-002714.json?_view=default"

#Likewise, this call gets an error:
test <- "https://environment.data.gov.uk/asset-management/id/capital-project/2019/20-000096.json?_view=full"
#This call does not:
test <- "https://environment.data.gov.uk/asset-management/id/capital-project/2019/20-000096.json?_view=default"


