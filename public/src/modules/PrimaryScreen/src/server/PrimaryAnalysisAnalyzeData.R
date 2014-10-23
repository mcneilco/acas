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

dataframe_to_csvstring <- function(x, ...) {
  t <- tempfile()
  on.exit(unlink(t))
  write_csv(x,t, sep = "\t", ...)
  csv_string <- readChar(t, file.info(t)$size)
}

normalizeData <- function() {
    experimentCode <- POST$experimentCode
    data <- fread(paste0("file://",FILES$file$tmp_name))
    data[, originalOrder:=1:nrow(data)]
    keyColumns <- c("Assay Barcode", "Well")
    setkeyv(data, keyColumns)
    normalizedNames <- c("Efficacy", "SD Score", "Z' By Plate", "Z'", "Activity", "Normalized Activity", "Auto Flag Type", "Auto Flag Observation", "Auto Flag Reason")
    data[ , "Efficacy":=runif(.N, 0, 100)]
    data[ , "SD Score":=runif(.N, -1, 10)]
    data[ , "Z' By Plate":=runif(.N, 0, 1)]
    data[ , "Z'":=runif(.N, 0, 1)]
    data[ , "Activity":=runif(.N, 0, 50000)]
    data[ , "Normalized Activity":= runif(.N, 0, 50000)]
    flags <- list(
        list("Auto Flag Type" = "KO - Well Knocked Out", "Auto Flag Observation" = "Low - Signal too low", "Auto Flag Reason" = "Bad Tip"),
        list("Auto Flag Type" = "KO - Well Knocked Out", "Auto Flag Observation" = "Low - Signal too high", "Auto Flag Reason" = "Pin carryover"),
        list("Auto Flag Type" = "Hit", "Auto Flag Observation" = "Threshold", "Auto Flag Reason" = "Agonist Hit")
        )
    flags <- rbindlist(flags)
    cols <- names(flags)
    data[sample(1:.N,.N/10), get("cols"):=flags[sample(1:nrow(flags),.N, replace = TRUE)]]
    setkey(data,originalOrder)
    keepColumns <- c(keyColumns,normalizedNames)
    data[ , setdiff(colnames(data),keepColumns):=NULL, with = FALSE]
    csv_data <- dataframe_to_csvstring(data, na = "")
    setHeader("Access-Control-Allow-Origin","*")
    setHeader("Content-Length",nchar(csv_data))
    setContentType("text/csv;")
    cat(csv_data)
    DONE
}

normalizeData()
