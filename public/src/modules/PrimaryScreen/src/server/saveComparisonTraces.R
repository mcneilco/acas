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
#             - barcode
#             - Maximum
#             - Minimum
#             - timePoints: one record per trial, containing a string
#                           of tab-delimited data
#             - sequences: same as timePoints
#             - batchName
#             - wellType
#        filePath, where the plots should be saved (will be created if necessary)
#        debugMode, if true, plots are printed to the screen instead of saved
# Output: Writes graphs to a user-specified file path, or prints
#         them to the screen in debugging mode. Creates the desired
#         folder if it does not exist. Names files by their barcode
#         and batch name.
#         Modifies the table by adding a column of file names
saveComparisonTraces <- function(resultTable, filePath, debugMode = FALSE) {
  keyResultTable(resultTable)
  filePath <- trimTrailingBackslash(filePath)
  
  # Make a clean table of just 'test' and 'no agonist'
  cleanedTable <- resultTable[wellType == 'test' | wellType == 'no agonist']
  
  # Determine the point on the x-axis to which we normalize the data
  normalizingIndex <- normalizingIndex(cleanedTable$sequence)
  
  # Get the (normalized) mean of the negative controls
  ncTable <- resultTable[wellType == 'NC']
  ncMeans <- ncTable[, meanNC(sequence, normalizingIndex), by = "barcode,batchName"]
  
  batchFactor <- factor(unique(resultTable$batchName))
  barcodeFactor <- factor(unique(resultTable$barcode))
  
  cleanedTable[, plotMany(timePoints, sequence, Minimum, Maximum, 
                          wellType, batchFactor, batchName, barcode, ncMeans,
                          filePath, debugMode, normalizingIndex, barcodeFactor), 
               by = "batchName,barcode"]
  
  # Generate the vector of file names and add it to the table
  tableWithFiles <- fileNames(resultTable, filePath)
  
  return(tableWithFiles)
}


# keyResultTable
# Input: resultTable, from the instrument
# Output: Keys the table based on the batchName and barcode
keyResultTable <- function(resultTable) {
  setkey(resultTable, batchName, barcode)
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
plotMany <- function(timePoints, sequence, Minimum, Maximum, wellType, 
                     batchFactor, batchName, code, ncMeans, filePath, 
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
    png(file.path(fullPath, paste(barcodeFactor[code], "_", batchName, ".png", sep = "")))
  }
  
  sampleRange <- max(Maximum) - min(Minimum)
  
  plot(c(0, maxTime), 
       c(-15, max(sampleRange, max(ncMeans$V1))),
       type = 'n', 
       xlab = "Time (sec)",
       ylab = "Activity (rfu)")
  title(main = paste(barcodeFactor[code], ": ", batchName, sep = ""))
  
  mapply(plotOne, splitx, splity, wellType, normalizingIndex)

  # Only plot the negative controls with the barcode you want
  setkey(ncMeans, barcode, batchName)
  filteredNC <- ncMeans[barcode==barcodeFactor[code]]
  filteredNC[, plotOne(splitx[1], V1, "NC", weight = 2.5), by = "barcode,batchName"]
  
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
plotOne <- function(splitx, splity, wellType, normalizingIndex, weight = 1) {
  xData <- as.numeric(unlist(splitx))
  yData <- as.numeric(unlist(splity))
  
  # Normalize data
  if (wellType == 'NC') {
    # NC has already been normalized
  } else {
    yData <- yData - yData[normalizingIndex]
  }
  
  # Add lines to a pre-existing plot
  lines(xData, yData, type = 'l', col = getColor(wellType), lwd = weight)
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

  return(yNormalized)
}


# fileNames
# Creates a vector whose nth entry is the filename to
# which the resultTable's nth row of data was plotted.
# Any rows with wellType other than 'no agonist' or
# 'test' are given an entry of NA
fileNames <- function(resultTable, filePath) {
  # Generate a file path if the wellType is test or no agonist,
  # otherwise leave the file path as NA
  fileTable <- transform(resultTable, comparisonTraceFile = 
                           ifelse((wellType == 'no agonist' | wellType == 'test'),
                                  file.path(filePath, paste(barcode, "_", batchName, ".png", sep = "")),
                                  NA_character_))
  return(fileTable)
}


# getColor
# Determine what color the line should be, based on the well type
# Input: wellType, which should be one of four predetermined types
# Ouput: the color corresponding to that well type
# Error cases: "orange" if the wellType is 'PC', which we should
#               not be plotting.
#              "black" and an error message if the well type is
#               unrecognized
getColor <- function(wellType) {
  if (wellType == "NC") {
    return("darkgreen")
  } else if (wellType == "no agonist") {
    return("blue")
  } else if (wellType == "test") {
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
