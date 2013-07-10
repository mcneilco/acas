# Creates new protocols, use this code on first load

require(racas)
require(RCurl)

protocolNameList <- c("ADME_Human Liver Microsome Stability", "ADME_Mouse Liver Microsome Stability", "ADME_Rat Liver Microsome Stability", "ADME_uSol_Kinetic_Solubility", "BBB-PAMPA", "Cyp 2D6 Blue Fluorescence Production", "Cyp 2D6 Cyan Fluorescence Production", "Cyp 3A4 Green Fluorescence Production", "Cyp 3A4 Red Fluorescence Production", "GIT-PAMPA", "MDCK Permeability", "Mouse_BTB", "Rat_BTB")
shortDescription <- "protocol created for galileo etl"
protocolsFrame <- data.frame(protocolName = protocolNameList, shortDescription)

protocolNameList <- c("Rat IVPO PK noavg", "Mouse IVPO PK noavg", "Dog IVPO PK noavg", "Rat PO CNS penetration noavg", "Mouse PO CNS penetration noavg", "Ferret PO CNS penetration noavg")
shortDescription <- "dmpk protocol"
extraProtocolsFrame1 <- data.frame(protocolName = protocolNameList, shortDescription)

protocolNameList <- c("Mouse Novel Object Recognition Task", "Rat Novel Object Recognition Task", "Mouse Contextual Fear Conditioning", "Rat Contextual Fear Conditioning")
shortDescription <- "behavior protocol"
extraProtocolsFrame2 <- data.frame(protocolName = protocolNameList, shortDescription)

testOnlyProtocol <- data.frame(protocolName = "TEST", shortDescription = "for TEST only, not for production")

protocolsFrame <- rbind(protocolsFrame, extraProtocolsFrame1, extraProtocolsFrame2, testOnlyProtocol)

#Add new ones here...
#protocolsFrame <- data.frame(protocolName = "TEST", shortDescription = "for TEST only, not for production")

recordedBy = "smeyer"

for (row in 1:nrow(protocolsFrame)) {
  protocolName <- protocolsFrame$protocolName[row]
  shortDescription <- protocolsFrame$protocolName[row]
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