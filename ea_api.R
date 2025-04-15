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

ongoing_projects <- data.table::rbindlist(ongoing_projects)

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

## These work
#https://environment.data.gov.uk/asset-management/id/asset/382266.json?
#https://environment.data.gov.uk/asset-management/id/capital-project/2019/20-000096.json
#https://environment.data.gov.uk/asset-management/id/completed-capital-project/ACC451E/000A/633A.json

#https://environment.data.gov.uk/asset-management/id/capital-project.json?_limit=50

