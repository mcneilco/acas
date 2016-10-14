# ACAS CONF file view
library(racas)
library(data.table)
args <- commandArgs(TRUE)
if(length(args) != 2) {
  cat("Usage: Rscript conf_to_view.R /path/to/moduleConfJSON.js viewName\n")
  quit("no")
} else {
  configFilePath <- args[1]
  viewName <- args[2]
}

readConfigFile <- function(configFilePath) {
  configFilePath <- normalizePath(configFilePath)
  out <- paste(suppressWarnings(system(paste0("node -e '",
          paste0("testStateMap=require(\"", configFilePath,"\");console.log(JSON.stringify(testStateMap));'")
        ), intern = TRUE)), collapse = "")
  configList <- fromJSON(out)
}

configList <- readConfigFile(configFilePath)

columnTypes <- as.data.table(query("select column_name, data_type from information_schema.columns where table_name = 'subject_value'"));
columnMap <- data.table(typeName = c("clobValue","codeValue","dateValue","fileValue","numericValue","stringValue"),
                        column = c("clob_value", "code_value", "date_value", "file_value", "numeric_value", "string_value"))
valueKinds <- unique(rbindlist(configList$typeKindList$valuekinds))
setkey(valueKinds, typeName)
setkey(columnMap, typeName)
valueKindMap <- valueKinds[columnMap]
setkey(valueKindMap, column)
setkey(columnTypes, column_name)
valueKindMap <- columnTypes[valueKindMap]

setkey(valueKindMap, kindName)
crossTabs <- valueKindMap[ ,{
  crossTab <- paste0("select * from\n",
          "crosstab('select subject_state_id, ls_kind, ", column_name, " from subject_value where ls_type = ''", typeName, "'' order by 1,2',\n",
          "'select unnest(array[",paste0("''",kindName,"''",collapse = ","),"])')\n",
         paste0(" AS ct(subject_state_id bigint, ", paste0('"',kindName,'" ', data_type, collapse = ", "), ")")
         )
}, by = c('column_name', 'data_type', 'typeName')]

answer <- crossTabs[ , {
  join <- paste0("subject_state",".id=",typeName,".subject_state_id")
  paste0("left join (", V1,") ",typeName,"\n", " on ", join,"\n", collapse = "")
}]

select <- paste0(valueKinds$typeName,'."',valueKinds$kindName,'"',collapse = ",")
#viewName <- sub("^([^.]*).*", "\\1", basename(configFilePath))
dropped <- query(paste0('drop view if exists ', viewName, " cascade"))
query(paste0("create or replace view ",viewName," as select subject_state.id as subject_state_id,",select,"\nfrom\nsubject_state\n",answer))
cat(viewName, "view created\n")
