# Creates new protocols, use this code on first load

require(racas)
require(RCurl)

# protocolNameList <- c("ADME_Human Liver Microsome Stability", "ADME_Mouse Liver Microsome Stability", "ADME_Rat Liver Microsome Stability", "ADME_uSol_Kinetic_Solubility", "BBB-PAMPA", "Cyp 2D6 Blue Fluorescence Production", "Cyp 2D6 Cyan Fluorescence Production", "Cyp 3A4 Green Fluorescence Production", "Cyp 3A4 Red Fluorescence Production", "GIT-PAMPA", "MDCK Permeability", "Mouse_BTB", "Rat_BTB")
# shortDescription <- "protocol created for galileo etl"
# protocolsFrame <- data.frame(protocolName = protocolNameList, shortDescription)

protocolNameList <- c("Rat IVPO PK noavg", "Mouse IVPO PK noavg", "Dog IVPO PK noavg", "Rat PO CNS penetration noavg", "Mouse PO CNS penetration noavg", "Ferret PO CNS penetration noavg", "ADME_uSol_Kinetic_Solubility")
shortDescription <- "dmpk protocol"
extraProtocolsFrame1 <- data.frame(protocolName = protocolNameList, shortDescription)

protocolNameList <- c("Mouse Novel Object Recognition Task", "Rat Novel Object Recognition Task", "Mouse Contextual Fear Conditioning", "Rat Contextual Fear Conditioning")
shortDescription <- "behavior protocol"
extraProtocolsFrame2 <- data.frame(protocolName = protocolNameList, shortDescription)

# protocolNameList <- c("CRO CYP DR 2C19", "CRO GABA DR [H3] Flunitrazepam Binding Rat Brain", "CRO GABA SHIFT DR", "CRO Microsome Screen 15Min Human S9", "CRO Microsome Screen 30Min Mouse S9", "CRO Microsome Screen 34.8Min Mouse S9", "CRO Solubility Assay", "CYP 1A2 10uM", "CYP 2C19 10uM", "Cytotoxicity SCRN MTS CHO-K1", "GlyT1 Glycine Uptake SPA Production", "GlyT1 SCRN Glycine SPA HEK293 B6", "Microsome Screen 30Min-Mouse", "CRO MAO-A DR MAO-Glo  Bac Enz", "CRO Microsome Screen 60Min Mouse S9", "CRO PDE4 DR cAMP FRET IMAP PDE4D3 Bac Enz", "CRO SCRN Electrophys GABA a5b2g2s", "MAO-A GLO luminescence production SAR", "MAO-B GLO luminescence production SAR", "PDE4 DR CRE-Luc Roche SK-N-MC clone", "PDE4 DR cAMP FRET Cisbio HEK293", "PDE4 SCRN CRE-Luc SK-N-MC N-CRE", "CRO GlyT1 SCRN Binding Rat Brain", "CRO HERG DR", "CRO MAO-B Alternate SCRN", "CRO Microsome Screen 64.8Min Mouse S9", "CRO PDE4 SCRN [H3] Rolipram Binding Mouse CNS Brain", "CYP 2C9 10uM", "PDE4 DR cAMP FRET IMAP PDE4D3 Bac Enz", "CRO GABA DR ELECTROPHYS a5b2g2s", "CRO GLYT1 DR Radioactive Binding Rat Brain", "CRO Microsome Screen 60Min Human S9", "CYP 2D6 10uM", "CYP 3A4 10uM", "GlyT1 Reversibility Glycine SPA CHO", "GlyT1 SCRN FLEX HEK293 B10", "Microsome Screen 30Min-Human", "CRO GABA DR ELECTROPHYS a2b2g2s", "CRO LOG D ASSAY", "CRO PDE4 DR [H3] Rolipram Binding Rat CNS Brain", "CRO Permeability Caco-2", "GlyT2 Glycine Uptake SPA Production_Screening", "MAO-A SCRN MAO-Glo Bac Enz", "Microsome Screen 30Min-Rat", "Brain Plasma Ratio", "CRO CYP DR 1A2", "CRO CYP DR 2C9", "CRO GABA DR ELECTROPHYS a1b2g2s", "CRO GABA DR ELECTROPHYS a3b2g2s", "CRO GABA SCRN [H3] Flunitrazepam Binding Rat Brain", "CRO MAO-B DR MAO-Glo Bac Enz", "Contextual Fear Conditioning", "GlyT2 Alternate SCRN", "MAO-A Alternate SCRN", "PDE4 DR Enzyme Coupled Abs PDE4D7 Bac Enz BPS", "CRO CYP DR 2D6", "CRO CYP DR 3A4", "CRO PDE4 SCRN [H3] Rolipram Binding Rat CNS Brain", "CRO Permeability MDCK-MDR1", "Cytotoxicity SCRN Alamar Blue HEK293", "Full Pharmacokinetics Study", "GC SCRN Soluble Guanylyl Cyclase Agonist", "Bioavailability Assay V1.0", "CRO GlyT1 SCRN Alternate Binding Rat Brain", "CRO Microsome Screen 30Min Human S9", "CRO Microsome Screen 30Min Rat S9", "CRO PDE4 DR [H3] Rolipram Binding Mouse Brain", "GC SCRN Soluble Guanylyl Cyclase Antagonist", "Hot Plate", "PDE4 SCRN CRE-Luc SK-N-MC R-CRE")
# shortDescription <- "protocol created for core etl"
# extraProtocolsFrame3 <- data.frame(protocolName = protocolNameList, shortDescription)

protocolNameList <- c("CYP 1A2 10uM", "CYP 2C19 10uM", "CYP 2C9 10uM", "CYP 2D6 10uM", "CYP 3A4 10uM")
shortDescription <- "dmpk cyp protocol"
extraProtocolsFrame4 <- data.frame(protocolName = protocolNameList, shortDescription)

protocolNameList <- c("PAMPA-BBB", "PAMPA-GIT")
shortDescription <- "dmpk permeability protocol"
extraProtocolsFrame5 <- data.frame(protocolName = protocolNameList, shortDescription)

#testOnlyProtocol <- data.frame(protocolName = "TEST", shortDescription = "for TEST only, not for production")

protocolsFrame <- rbind(extraProtocolsFrame1, extraProtocolsFrame2, extraProtocolsFrame4, extraProtocolsFrame5)
#protocolsFrame <- rbind(protocolsFrame, extraProtocolsFrame1, extraProtocolsFrame2, extraProtocolsFrame3, extraProtocolsFrame4) #testOnlyProtocol)

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