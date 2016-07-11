# saveComparisonTraces
# Author: Jennifer Rogers
#
# Generates graphs of fluorescence vs. time,
# color-coded by type (negative control, test, or
# no agonist)
# Modifies the input table by adding a column of
# file names (including the path) where each row
# is graphed.
# Warning: Also keys and reorders the data.table
#          Do not subset your data.table after
#          assigning factors and before passing
#          it to this function, unless you refactor
#          it
#

library(data.table)
library(plyr)
library(racas)

# saveComparisonTraces
# Input: resultTable, a data.table with the following columns:
#             - assayBarcode
#             - Maximum
#             - Minimum
#             - T_timePoints: one record per trial, containing a string
#                           of tab-delimited data
#             - T_sequence: same as timePoints
#             - batchCode
#             - wellType
#        filePath, where the plots should be saved (will be created if necessary, will have getUploadedFilePath run)
#        debugMode, if true, plots are printed to the screen instead of saved
# Output: Writes graphs to a user-specified file path, or prints
#         them to the screen in debugging mode. Creates the desired
#         folder if it does not exist. Names files by their barcode
#         and batch name.
#         Modifies the table by adding a column of file names
saveComparisonTraces <- function(resultTable, filePath, debugMode = FALSE) {
  save(resultTable, filePath, file="public/comparisonTest.Rda")
  resultTable <- copy(resultTable)
  keyResultTable(resultTable)
  filePath <- trimTrailingBackslash(filePath)
  
  # Make a clean table of just 'test' compounds
  cleanedTable <- resultTable[wellType == 'test']
  
  # Determine the point on the x-axis to which we normalize the data
  normalizingIndex <- normalizingIndex(cleanedTable$T_sequence)
  
  # Get the (normalized) mean of the negative controls
  ncTable <- resultTable[wellType == 'NC']
  ncMeans <- ncTable[, meanNC(T_sequence, normalizingIndex), by = "assayBarcode,batchCode"]
  
  batchFactor <- factor(unique(resultTable$batchCode))
  barcodeFactor <- factor(unique(resultTable$assayBarcode))
  names(barcodeFactor) <- barcodeFactor
  minName <- grep("\\{minimum\\}", names(cleanedTable), value = TRUE)
  maxName <- grep("\\{maximum\\}", names(cleanedTable), value = TRUE)
  cleanedTable[, Minimum := get(minName)]
  cleanedTable[, Maximum := get(maxName)]
  cleanedTable[, plotMany(T_timePoints, T_sequence, Minimum, Maximum, 
                          wellType, agonistConc, batchFactor, batchCode, assayBarcode, ncMeans,
                          filePath, debugMode, normalizingIndex, barcodeFactor), 
               by = "batchCode,assayBarcode"]
  
  return(NULL)
}


# keyResultTable
# Input: resultTable, from the instrument
# Output: Keys the table based on the batchCode and barcode
keyResultTable <- function(resultTable) {
  setkey(resultTable, batchCode, assayBarcode)
}


# normalizingIndex
# Find the data point that is closest to the minimum for
# all of the non-NC trials. 
# Input: a nested list of strings (the 'sequence' column
#        from the resultTable, for example), all with
#        the same number of entries
# Output: the index that best approximates the initial
#         dip in the data
normalizingIndex <- function(sequence) {
  # An empty data.table has a null number of rows
  if (length(sequence) == 0) {
    stop("Internal error: No wells of type 'test' or 'no agonist' were supplied")
  }
  numberSequence <- listToNumber(sequence)
  
  # We only need to check the first 20 columns, because the dip
  # won't be after 19 seconds
  range <- min(20, length(numberSequence[1,]))
  
  mindexList <- apply(numberSequence[,1:range, drop = FALSE], 1, which.min)
  
    
  return(round(mean(mindexList)))
}


# plotMany
# Start with data from one compound, and plot each line in its required color
# Input: timePoints, the times at which data was recorded (seconds)
#        sequence, the amount of fluorescence at each time point
#        Minimum, a vector with the minimum fluorescence for each trial
#        Maximum, a vector with the maximum fluorescence for each trial
#        wellType, what type of trial was it? (Positive control, test, etc)
#        batchFactor, the batch names, as an R factor
#        code, identifying which negative control goes with which trials (barcode)
#        ncMeans, a data.table of the average means, along with their corresponding
#                 batch names and barcodes
#        filePath, to write the plots
#        debugMode, whether to write the plots to the screen
#        normalizingIndex, the time point whose value will be subtracted from the
#                          series
#        barcodeFactor, the levels of the barcode, which are being passed in
#                       as numbers
# Output: Plots the given sequences (through a call to plotOne), and returns
#         the maximum fluorescense from a test or "no agonist" trial. The
#         return value is unimportant as long as it's not NULL (the data.table
#         method that calls this function can't deal with type NULL)
plotMany <- function(timePoints, sequence, Minimum, Maximum, wellType, agonistConc, 
                     batchFactor, batchCode, code, ncMeans, filePath, 
                     debugMode, normalizingIndex, barcodeFactor) {
  splitx <- strsplit(timePoints, "\t", fixed = TRUE)
  splity <- strsplit(sequence, "\t", fixed = TRUE)
  # Get the max time -- should be constant across a given compound
  maxTime <- tail(as.numeric(unlist(splitx[1])), 1)
  
  if (!debugMode) { # Write to screen in debug mode, else write to file
    fullPath <- getUploadedFilePath(filePath)
    if (!file.exists(fullPath)) {
      dir.create(fullPath, recursive = TRUE)
    }
    png(file.path(fullPath, paste(barcodeFactor[code], "_", batchCode, ".png", sep = "")))
  }
  
  sampleRange <- max(Maximum) - min(Minimum)
  
  plot(c(0, maxTime), 
       c(-15, max(sampleRange, max(unlist(ncMeans$V1)))),
       type = 'n', 
       xlab = "Time (sec)",
       ylab = "Activity (rfu)")
  title(main = paste(barcodeFactor[code], ": ", batchCode, sep = ""))
  
  mapply(plotOne, splitx, splity, wellType, agonistConc, normalizingIndex)

  # Only plot the negative controls with the barcode you want
  setkey(ncMeans, assayBarcode, batchCode)
  filteredNC <- ncMeans[assayBarcode==barcodeFactor[code]]
  filteredNC[, plotOne(splitx[1], V1, "NC", 0, normalizingIndex, weight = 2.5), by = "assayBarcode,batchCode"]
  
  if (!debugMode) {
    dev.off()
  }
  
  return(0)
}


# plotOne
# Plot a single line, given two lists of strings
# Input: splitx, a list the time points as strings
#        splity, a list of the fluorescence values as strings
#        wellType, a string indicating which type of well is to be plotted
#        weight, the weight of the line
plotOne <- function(splitx, splity, wellType, agonistConc, normalizingIndex, weight = 1) {
  xData <- as.numeric(unlist(splitx))
  yData <- as.numeric(unlist(splity))
  
  # Normalize data
  if (wellType == 'NC') {
    # NC has already been normalized
  } else {
    yData <- yData - yData[normalizingIndex]
  }
  
  # Add lines to a pre-existing plot
  lines(xData, yData, type = 'l', col = getColor(wellType, agonistConc), lwd = weight)
}

# meanNC
# Find the mean of the negative controls, then normalize them
# Input: sequence, a column from the resultTable, only containing
#                  data from one barcode
#        normalizingIndex, the index whose flourescence value will
#                  be subtracted from the rest of the data in
#                  the series
# Output: the averaged, normalized negative control data
meanNC <- function(sequence, normalizingIndex) {
  yValues <- listToNumber(sequence)
  
  averagedY <- apply(yValues, 2, mean)
  
  # Normalize to the predetermined index
  yNormalized <- averagedY - averagedY[normalizingIndex]

  return(list(list(yNormalized)))
}


# getColor
# Determine what color the line should be, based on the well type
# Input: wellType, which should be one of four predetermined types
# Ouput: the color corresponding to that well type
# Error cases: "orange" if the wellType is 'PC', which we should
#               not be plotting.
#              "black" and an error message if the well type is
#               unrecognized
getColor <- function(wellType, agonistConc) {
  if (wellType == "NC") {
    return("darkgreen")
  } else if (agonistConc == 0) {
    return("blue")
  } else {
    return("red")
  }
}

# listToNumber
# Given a nested list of numbers represented as strings,
# return a matrix of those numbers represented
# as numbers
listToNumber <- function(stringList) {
  split <- strsplit(stringList, "\t", fixed = TRUE)
  numberList <- laply(split, as.numeric)
  # If there's only one dimension, we will get a vector
  if (class(numberList) != 'matrix') {
    numberList <- t(as.matrix(numberList))
  }
  return(numberList)
}

# trimTrailingBackslash
# If the file path comes in with a trailing backslash,
# remove it (otherwise the file path R creates will
# have two backslashes in it)
trimTrailingBackslash <- function(filePath) {
  if (substr(filePath, nchar(filePath), nchar(filePath)) == "/") {
    return(substr(filePath, 1, nchar(filePath)-1))
  } else {
    return(filePath)
  }
}
