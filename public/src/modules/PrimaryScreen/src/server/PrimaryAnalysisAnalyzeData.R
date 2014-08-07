# ROUTE: /experiment/primaryanalysis
require(data.table)

write_csv <- function(x, file, rows = 1000L, ...) {
  passes <- NROW(x) %/% rows
  remaining <- NROW(x) %% rows
  k <- 1L
  if(passes > 0) {
    write.table(x[k:rows, ], file, quote = FALSE,row.names = FALSE, ...)
  } else {
    write.table(x, file, quote = FALSE,row.names = FALSE, ...)
    return(invisible())
  }
  k <- k + rows
  for(i in seq_len(passes)[-1]) {
    write.table(x[k:(rows*i), ], file, quote = FALSE,, append = TRUE, row.names =
                  FALSE, col.names = FALSE, ...)
    k <- k + rows
  }
  if(remaining > 0) {
    write.table(x[k:NROW(x), ], file, quote = FALSE, append = TRUE, row.names =
                  FALSE, col.names = FALSE, ...)
  }
}
dataframe_to_csvstring <- function(x) {
  t <- tempfile()
  on.exit(unlink(t))
  write_csv(x,t, sep = ",")
  csv_string <- readChar(t, file.info(t)$size)
}

normalizeData <- function() {
    csv_data <- rawToChar(receiveBin(-1))
    data <- fread(csv_data)
    setkey(data, assayBarcode, wellReference)
    readColumnIndexes <- which(grepl("{R[0-9].*}",names(data), perl = TRUE))
    readColumnNames <- names(data)[readColumnIndexes]
    normalizedNames <- paste0(readColumnNames," [NORMALIZED]")
    normalizedData <- data[ , get("normalizedNames"):={
             lapply(readColumnNames, function(x) get(x)*3)
             }, by = c("assayBarcode","wellReference")]

    csv_data <- dataframe_to_csvstring(normalizedData)
    setHeader("Access-Control-Allow-Origin","*")
    setHeader("Content-Length",nchar(csv_data))
    setContentType("text/csv;")
    cat(csv_data)
    DONE
}

normalizeData()
