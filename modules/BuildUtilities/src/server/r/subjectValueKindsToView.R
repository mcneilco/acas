
subjecValueKindsToView <- function(request) {
  viewName <- request$viewName
  library(racas)
  library(data.table)
  conn <- getDatabaseConnection()
  on.exit(dbDisconnect(conn))
  valueKinds <- as.data.table(query("select ls_type, ls_kind, count(*) from subject_value group by ls_type, ls_kind"), conn = conn)
  setnames(valueKinds, c("typeName", "kindName", "count"))
  # Removing duplicate value kinds by selecting max amount of rows
  valueKinds <- valueKinds[, .SD[count == max(count)],  by = c("kindName")]
  
  columnTypes <- as.data.table(query("select column_name, data_type from information_schema.columns where table_name = 'subject_value'"), conn = conn);
  columnMap <- data.table(typeName = c("clobValue","codeValue","dateValue","fileValue","numericValue","stringValue"),
                          column = c("clob_value", "code_value", "date_value", "file_value", "numeric_value", "string_value"))
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
  setkey(valueKinds, kindName, typeName)
  select <- paste0(valueKinds$typeName,'."',valueKinds$kindName,'"',collapse = ",")
  dropped <- query(paste0('drop view if exists ', viewName, " cascade"), conn = conn)
  query(paste0("create or replace view ",viewName," as select subject_state.id as subject_state_id,",select,"\nfrom\nsubject_state\n",answer), catchError=FALSE, conn = conn)
  dbCommit(conn)
  cat(viewName, "view created\n")
}

#if(!interactive()) {
#  args <- commandArgs(TRUE)
#  if(length(args) != 1) {
#    cat("Usage: Rscript subjectValueKindsToView.R viewName\n")
#    quit("no")
#  } else {
#    viewName <- args[1]
#  }
#  request <- list(viewName = viewName)
#  subjecValueKindsToView(request)
#}
