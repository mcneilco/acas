# parsePK-ACAS.r
#
#
# James Harr
# May 29, 2013
# jharr@dartneuroscience.com
#########################################################################
#########################################################################
##
## Creates a generic uploader file for PK data exported from Phoenix
##
## input:
## Export of Phoenix data file (.xls)
##
## output:
## ACAS uploader file (.xls)
##
#########################################################################
#########################################################################



#########################################################################
#########################################################################
##                         FUNCTIONS                                   ##
#########################################################################
#########################################################################

##put the units from row 1 into the column names
addUnits <- function(df){
  names(df)<- paste(t(names(df)), " (", t(df[1,]), ")", sep="")
  names(df)<-gsub(" \\(\\)", "", names(df))
  names(df)<-gsub(" \\(NA\\)", "", names(df))
  return(names(df))
}
##pivot the t/c data into short/wide columns
pivotTimeConc <- function(df){
  tc <- data.frame(t(df[,c("Time (hr)","PK_Concentration (ng/mL)")]))
  for (i in 1:ncol(tc)){
    names(tc)[i] <- paste("PK_Concentration ", tc[1,i], "hr(ng/mL)", sep="")
  }
  tc <- data.frame(tc[2,])
  return(tc)
}
##copy column names into their own row
namesRow <- function(df){
  namesDF <- t(data.frame(names(df), stringsAsFactors=F))
  colnames(namesDF) <- colnames(df)
  df <- rbind(namesDF, df)
  return(df)
}
#make the data type row
typeRow <- function(df, textColumns){
  typeDF <- data.frame("Number", names(df), stringsAsFactors=F)
  typeDF[which(typeDF[,2] %in% textColumns[,1]),1] <- "Text"
  typeDF <- t(typeDF)
  colnames(typeDF) <- typeDF[2,]
  return(typeDF[1,])
}

#add spaces to the header block labels
deCamel <- function(str){
  str <- gsub("([A-Z])","\\ \\1", str)
  substring(str, 1, 1) <- toupper(substring(str, 1, 1))
  if(identical(str," A U C Type")){
    str<-"AUC Type"
  }
  else{
    return(trim(str))
  }
}

concUnits <- function(str){
  if(grepl("PK_Concentration", str)){
    str <- gsub("(\\D)(\\.)", "\\1 ", str)
    str <- sub("ng mL ", "(ng/mL)", str)
    return(str)
  }
  else {return(str)}
}


#########################################################################
#########################################################################
##                          CONTROL                                    ##
#########################################################################
#########################################################################

preprocessPK <- function(parameterList) {
  library(plyr)
  library(gdata)
  options(stringsAsFactors=FALSE)
  dnsDeployMode <- Sys.getenv("DNSDeployMode")
  originalDir <- getwd()
  #perlexe <- "C:\\strawberry\\perl\\bin\\perl.exe"
  perlexe <- "perl"
  textColumns <- data.frame(c("Animal", "Route", "Formulation", "Gender", "Batch", "AUCType", "food_effect", "Species"))
  doNotRepeat <- c("Corporate Batch ID", "Formulation")
  
  ##Get args()
  ## in1 is the data file
  ## in2 is the header list
  ## out1 is the output file name
  #args <- commandArgs(TRUE)
  in1 <- parameterList$fileLocation
  #in1 <- args[1]
  #print(in1)
  if (is.na(in1)) {
    stop("need in1 file argument")
  }
  
  headerBlock <- parameterList
  #in2 <- args[2]
  #print(in2)
#   if (is.na(in2)) {
#     stop("need in2 header list argument")
#   }
  
  out1 <- paste0(parameterList$fileLocation, "Processed.csv")
  #out1 <- args[3]
  #print(out1)
#   if (is.na(out1)) {
#     stop("need out1 argument")
#   }
  
  #in1 <- "Input v4.xls"
  #in2 <- "PKHeaderBlock.txt"
  #out1 <- "out"
  
  #########################################################################
  
  
  ##read input .xls
  rawDF <- read.xls(in1, blank.lines.skip=T, perl=perlexe)
  
  #get the header file and format it - cut off the bioavailability rows for use later
  #headerBlock <- source("PKHeaderBlock.txt")
  headerBlock <- data.frame(t(data.frame(headerBlock)))
  row.names(headerBlock) <- gsub("value.", "", row.names(headerBlock))
  headerBlock <- cbind(row.names(headerBlock), headerBlock)
  bioavail <- headerBlock[(nrow(headerBlock)-1):(nrow(headerBlock)),]
  headerBlock <- headerBlock[1:(nrow(headerBlock)-2),]
  headerBlock <- headerBlock[row.names(headerBlock)!="fileLocation",]
  
  #add the bioavailability data
  rawDF <- data.frame(c(rawDF, t(bioavail)[2,]))
  rawDF[grep("IV", rawDF[,"Route"]),c("bioavailability", "AUCType")] <- NA
  
  #put parenthetical names on the column names
  names(rawDF) <- addUnits(rawDF[1,])
  rawDF <- rawDF[2:nrow(rawDF),]
  names(rawDF)[grep("bioavailability", names(rawDF))] <- "Bioavailability (%)"
  names(rawDF)[grep("AUCType", names(rawDF))] <- "AUCType"
  
  #if this is not a dose escallation study, pivot the time/conc data and remove redundant rows
  if(length(unique(rawDF[,grep("Route",names(rawDF))]))>1){
    timeConc <- ddply(rawDF, .(Animal), .fun=pivotTimeConc)
  }
  names(timeConc) <- lapply(names(timeConc), concUnits)
  
  #fix the format of the time/conc column names and copy the names into the data matrix
  finalDF <- unique(rawDF[,!names(rawDF) %in% c("Time (hr)","PK_Concentration (ng/mL)","Concentration (ng/mL)")])
  finalDF <- cbind(finalDF, timeConc[,2:length(timeConc)])
  finalDF <- namesRow(finalDF)
  
  #add the data type row and apply 3 sig figs to numeric data
  finalDF <- rbind(typeRow(finalDF, textColumns), finalDF)
  for(i in which(finalDF[1,]=="Number")){
    finalDF[3:nrow(finalDF),i] <- suppressWarnings(signif(as.numeric(finalDF[3:nrow(finalDF),i]), digits=3))
  }
  
  #clean-up steps
  row.names(finalDF) <- 1:nrow(finalDF)
  finalDF <- data.frame(finalDF, stringsAsFactors=F)
  finalDF[2,grep("Batch", names(finalDF))] <- "Corporate Batch ID"
  
  #split the Routes out to their own columns and add the route to the name row
  finalIVdf <- rbind(finalDF[1:2,], finalDF[grep("IV", finalDF[,"Route"]),])
  finalIVdf[2,] <- paste("IV - ", finalIVdf[2,], sep="")
  for (label in doNotRepeat) {
    finalIVdf[2,grep(paste0("IV - ", label), finalIVdf[2,])] <- label
  }
  finalPOdf <- rbind(finalDF[1:2,which(!finalDF[2,] %in% doNotRepeat)], finalDF[grep("PO", finalDF[,"Route"]),which(!finalDF[2,] %in% doNotRepeat)])
  finalPOdf[2,] <- paste("PO - ", finalPOdf[2,], sep="")
  finalDF <- cbind(finalIVdf, finalPOdf)
  
  #remove columns that contain only <NA>
  finalDF <- finalDF[,colSums(is.na(finalDF[3:nrow(finalDF),]))<3]
  
  #add the header block to the top of the data.frame
  names(headerBlock) <- names(finalDF)[1:2]
  temprow <- matrix(c(rep.int(NA,length(headerBlock))),nrow=1,ncol=length(headerBlock))
  for(i in 1:nrow(headerBlock)){
    headerBlock[i,1] <- deCamel(headerBlock[i,1])
  }
  finalDF <- rbind.fill(headerBlock, finalDF)
  if (any(grepl("\\..", finalDF[,1]))) {
    finalDF[grep("\\..", finalDF[,1]),1] <- NA
  }
  
  #write the final output file
  write.table(finalDF, out1, na="", row.names=F, col.names = F, sep = ",")
  return(out1)
}
