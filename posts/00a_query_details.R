

# Select the parameters for the analysis:
## VERSION: Query version. VERSION = 'BOTH' and VERSION = "EXACT_PHRASE" queries the same search (environmental governance and process words) for title and keywords. The difference is that the abstract query changes, either for the words "environmental" and "governance" (BOTH) or EXACT_PHRASE. VERSION = "V1_QUERY" is the search we did in the first version of TS
VERSION <- "EXACT_PHRASE"
MINIMUM_CITES = 5
MIN_CLUSTER_SIZE = 100
RUN_RAKE = F
GOVERNANCE_PROCESS_Q = F

# For response to reviewers:
TYPES_TO_KEEP = c('Article','Review')#,'Book','Book Chapter')
WOS_ONLY = F
USE_V1_MANUAL_DATA = F
ADD_SUPPL_WOS_REFS = F # This uses the WOS API to grab references for works that OA has not references for. Then it uses OA to add them manually into the edgelist (script 04).


if(VERSION == "BOTH"){
  LOCATION <- ifelse("Review" %in% TYPES_TO_KEEP,
                     'data/query_EandG/',
              ifelse(!("Review" %in% TYPES_TO_KEEP),
                     'data/query_EandG_noreview/', NA))
} else if(VERSION == "EXACT_PHRASE"){
  LOCATION <- ifelse(GOVERNANCE_PROCESS_Q == T,
                     'data/query_EG_govncprocess/',
                    ifelse("Review" %in% TYPES_TO_KEEP & ADD_SUPPL_WOS_REFS == F,
                     'data/query_EG/',
                     ifelse("Review" %in% TYPES_TO_KEEP &
                              ADD_SUPPL_WOS_REFS == T,
                            'data/query_EG_suppl_refs/',
                     ifelse(!("Review" %in% TYPES_TO_KEEP),
                            'data/query_EG_noreview/', NA))))
} else if(VERSION == "V1_QUERY"){
  LOCATION <- ifelse(WOS_ONLY == T & !("Review" %in% TYPES_TO_KEEP) &
                       USE_V1_MANUAL_DATA == T,
                     'data/query_V1/',
              ifelse(WOS_ONLY == T & !("Review" %in% TYPES_TO_KEEP) &
                       USE_V1_MANUAL_DATA == F,
                     'data/query_V1_api/',
              ifelse(WOS_ONLY == T & ("Review" %in% TYPES_TO_KEEP),
                     'data/query_V1_add_review/',
              ifelse(WOS_ONLY == F & ("Review" %in% TYPES_TO_KEEP),
                     'data/query_V1_add_review_and_scopus/',
              ifelse(WOS_ONLY == F & !("Review" %in% TYPES_TO_KEEP),
                     'data/query_V1_add_scopus/', NA)))))
  } else {
  print("Not a valid version.")
}

if(!dir.exists(LOCATION)){dir.create(LOCATION)}
if(!dir.exists(stringr::str_replace(LOCATION,'data','output'))){dir.create(stringr::str_replace(LOCATION,'data','output'))}
process_words <- c('process', 'processes', #temporarily removing
                   'participation', 'participatory', 'collaborat*', 'learning','deliberat*','cooperat*','engagement','co-manag*','comanag*','co-produc*','coproduc*')
if(GOVERNANCE_PROCESS_Q == T){
  process_words <- c(#'process', 'processes', #temporarily removing
                     'governance process', 'governance processes',
                     'participation', 'participatory', 'collaborat*', 'learning','deliberat*','cooperat*','engagement','co-manag*','comanag*','co-produc*','coproduc*')
}
# CUT: design, arrangement
# ADDED: co-management, co-produc, participation
# OLD: ("process" OR "processes" OR  "arrangement*" OR "design" OR "participatory" OR "collaborat*" OR "deliberat*" OR "cooperat*" OR "learning" OR "engagement") NOT "machine learning"))
your_email_here <- 'belwood@formerstudents.ucdavis.edu'

# WOS KEY?
WOS_KEY_LOCATION <- '../wos_key.R'
# SCOPUS KEY?
SCOPUS_KEY_LOCATION <- '../scopus_key.R'

