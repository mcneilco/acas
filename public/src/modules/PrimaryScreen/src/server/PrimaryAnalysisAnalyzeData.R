# ROUTE: /experiment/primaryanalysis

csvstring_to_dataframe <- function(string, ...) {
  on.exit(close(tc))
  dfr <- read.csv(tc <- textConnection(string), ...)
  return(dfr)
}
dataframe_to_csvstring <- function(x) {
  on.exit(close(tc))
  tc <- textConnection("foo", "w")
  write.csv(x, tc, row.names = FALSE)
  csvstring <- paste0(textConnectionValue(tc),collapse="\n")
  return(csvstring )
}

post_data <- rawToChar(receiveBin(-1))
post_data_list <- fromJSON(post_data)

csv_data <- csvstring_to_dataframe(post_data_list$csv)

numeric_columns <- sapply(csv_data,class) %in% c("numeric","integer")
if(!any(numeric_columns)) {
  cat(post_data)
  DONE
}
first_numeric_column <- csv_data[,which(numeric_columns)[1], drop = FALSE]
normalized_data <- first_numeric_column*3
names(normalized_data) <- paste0(names(normalized_data), " NORAMALIZED (MULTIPLIED BY 3)")
output_data_frame <- data.frame(csv_data, normalized_data, check.names = FALSE)
output_csv_string <- dataframe_to_csvstring(output_data_frame)
output_list <- list(
  csv = output_csv_string
)
cat(toJSON(output_list))
DONE