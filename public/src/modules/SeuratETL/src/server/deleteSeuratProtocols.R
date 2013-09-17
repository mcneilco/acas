# To run overnight:
# nohup R CMD BATCH deleteSeuratProtocols.R &

setwd('/opt/node_apps/acas')
require(racas)
setwd('~/coreetl')
protocolNameList <- readLines("public/src/modules/SeuratETL/src/server/assaylist.txt")
getProtocolByName <- function(protocolName, configList, formFormat) {
  # Gets the protocol entered as an input
  # 
  # Args:
  #   protocolName:     	    A string name of the protocol
  #   lsTransaction:          A list that is a lsTransaction tag
  #   recordedBy:             A string that is the scientist name
  #   dryRun:                 A boolean that marks if information should be saved to the server
  #
  # Returns:
  #  A list that is a protocol
  
  require('RCurl')
  require('rjson')
  require('gdata')
  
  tryCatch({
    protocolList <- fromJSON(getURL(paste0(configList$serverPath, "protocols?FindByProtocolName&protocolName=", URLencode(protocolName, reserved = TRUE))))
  }, error = function(e) {
    stop("There was an error in accessing the protocol. Please contact your system administrator.")
  })
  
  # If no protocol with the given name exists, warn the user
  if (length(protocolList)==0) {
  	return(NA)
  }
  protocol <- protocolList[[1]]
  return(protocol)
  
}

configList <- racas::applicationSettings
protocols <- lapply(X=protocolNameList, FUN=getProtocolByName, configList=configList, formFormat="Generic")
deleteProtocol <- function(protocol) {
	if(is.na(protocol[[1]])) {
		print("one already done")
		return(NA)
	}
	deleteEntity(protocol, acasCategory="protocols")
	print(paste("deleted", protocol$id))
	return(1)
}
lapply(protocols, deleteProtocol)
print("done")