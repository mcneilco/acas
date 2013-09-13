# To run overnight:
# nohup R CMD BATCH deleteCoreProtocols.R &

setwd('/opt/node_apps/acas')
require(racas)
setwd('~/coreetl')
protocolNameList <- c("CRO CYP DR 2C19", "CRO GABA DR [H3] Flunitrazepam Binding Rat Brain", "CRO GABA SHIFT DR", "CRO Microsome Screen 15Min Human S9", "CRO Microsome Screen 30Min Mouse S9", "CRO Microsome Screen 34.8Min Mouse S9", "CRO Solubility Assay", "CYP 1A2 10uM", "CYP 2C19 10uM", "Cytotoxicity SCRN MTS CHO-K1", "GlyT1 Glycine Uptake SPA Production", "GlyT1 SCRN Glycine SPA HEK293 B6", "Microsome Screen 30Min-Mouse", "CRO MAO-A DR MAO-Glo  Bac Enz", "CRO Microsome Screen 60Min Mouse S9", "CRO PDE4 DR cAMP FRET IMAP PDE4D3 Bac Enz", "CRO SCRN Electrophys GABA a5b2g2s", "MAO-A GLO luminescence production SAR", "MAO-B GLO luminescence production SAR", "PDE4 DR CRE-Luc Roche SK-N-MC clone", "PDE4 DR cAMP FRET Cisbio HEK293", "PDE4 SCRN CRE-Luc SK-N-MC N-CRE", "CRO GlyT1 SCRN Binding Rat Brain", "CRO HERG DR", "CRO MAO-B Alternate SCRN", "CRO Microsome Screen 64.8Min Mouse S9", "CRO PDE4 SCRN [H3] Rolipram Binding Mouse CNS Brain", "CYP 2C9 10uM", "PDE4 DR cAMP FRET IMAP PDE4D3 Bac Enz", "CRO GABA DR ELECTROPHYS a5b2g2s", "CRO GLYT1 DR Radioactive Binding Rat Brain", "CRO Microsome Screen 60Min Human S9", "CYP 2D6 10uM", "CYP 3A4 10uM", "GlyT1 Reversibility Glycine SPA CHO", "GlyT1 SCRN FLEX HEK293 B10", "Microsome Screen 30Min-Human", "CRO GABA DR ELECTROPHYS a2b2g2s", "CRO LOG D ASSAY", "CRO PDE4 DR [H3] Rolipram Binding Rat CNS Brain", "CRO Permeability Caco-2", "GlyT2 Glycine Uptake SPA Production_Screening", "MAO-A SCRN MAO-Glo Bac Enz", "Microsome Screen 30Min-Rat", "Brain Plasma Ratio", "CRO CYP DR 1A2", "CRO CYP DR 2C9", "CRO GABA DR ELECTROPHYS a1b2g2s", "CRO GABA DR ELECTROPHYS a3b2g2s", "CRO GABA SCRN [H3] Flunitrazepam Binding Rat Brain", "CRO MAO-B DR MAO-Glo Bac Enz", "Contextual Fear Conditioning", "GlyT2 Alternate SCRN", "MAO-A Alternate SCRN", "PDE4 DR Enzyme Coupled Abs PDE4D7 Bac Enz BPS", "CRO CYP DR 2D6", "CRO CYP DR 3A4", "CRO PDE4 SCRN [H3] Rolipram Binding Rat CNS Brain", "CRO Permeability MDCK-MDR1", "Cytotoxicity SCRN Alamar Blue HEK293", "Full Pharmacokinetics Study", "GC SCRN Soluble Guanylyl Cyclase Agonist", "Bioavailability Assay V1.0", "CRO GlyT1 SCRN Alternate Binding Rat Brain", "CRO Microsome Screen 30Min Human S9", "CRO Microsome Screen 30Min Rat S9", "CRO PDE4 DR [H3] Rolipram Binding Mouse Brain", "GC SCRN Soluble Guanylyl Cyclase Antagonist", "Hot Plate", "PDE4 SCRN CRE-Luc SK-N-MC R-CRE")
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