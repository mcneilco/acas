# To run overnight:
# nohup R CMD BATCH deleteSeuratProtocols.R &

require(racas)

resetSeuratETL <- function() {
  
  experimentIDs <- query("select id
  from api_experiment 
  where TO_DATE(recorded_date,'dd-mon-yyyy') > (select TO_DATE(sysdate -3,'dd-mon-yyyy') from dual)
  and recorded_by = 'bbolt'")
  
  names(experimentIDs) <- "id"
  experimentsToDelete <- split(experimentIDs, row.names(experimentIDs))
  deletedExperiments <- lapply(experimentsToDelete, deleteEntity, acasCategory = "experiments")
  
  protocolIDs <- query("select protocol_id as id
                             from api_protocol 
                             where short_description = 'created by seurat etl'")
  names(protocolIDs) <- "id"
  protocolsToDelete <- split(protocolIDs, row.names(protocolIDs))
  deletedProtocols <- lapply(protocolsToDelete, deleteEntity, acasCategory = "protocols")                       
}

resetSeuratETL()