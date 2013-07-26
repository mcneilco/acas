# Creates new protocols, use this code on first load

require(racas)
require(RCurl)

protocolNameList <- c("Example 1", "Example 2")
shortDescription <- "example protocol"
extraProtocolsFrame1 <- data.frame(protocolName = protocolNameList, shortDescription)

protocolNameList <- c("Example 3", "Example 4")
shortDescription <- "other example protocol"
extraProtocolsFrame2 <- data.frame(protocolName = protocolNameList, shortDescription)

protocolsFrame <- rbind(extraProtocolsFrame1, extraProtocolsFrame2)

recordedBy = "smeyer"

for (row in 1:nrow(protocolsFrame)) {
  protocolName <- protocolsFrame$protocolName[row]
  shortDescription <- protocolsFrame$shortDescription[row]
  lsTransaction <- createLsTransaction()$id
  
  protocolLabels <- list()
  protocolLabels[[length(protocolLabels)+1]] <- createProtocolLabel(lsTransaction = lsTransaction, 
                                                                    recordedBy=recordedBy, 
                                                                    lsType="name", 
                                                                    lsKind="protocol name",
                                                                    labelText=protocolName,
                                                                    preferred=TRUE)
  
  # Create the protocol
  protocol <- createProtocol(lsTransaction = lsTransaction,
                             shortDescription=shortDescription,  
                             recordedBy=recordedBy, 
                             protocolLabels=protocolLabels)
  
  protocol <- saveProtocol(protocol)
  print("protocol saved")
}