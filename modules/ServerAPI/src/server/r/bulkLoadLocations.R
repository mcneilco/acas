# The next line is used by PrepareConfigFiles to include this file as a route in rapache, do not modify unless you intend to modify rapache routes (it can be anywhere in the files though)
# ROUTE: /bulkLoadLocations

library(data.table)

bulkLoadLocations <- function(postData, GET) {
  createLocation <- function(labelText, labelType, labelKind, recordedBy) {
    label <- createContainerLabel(labelText = labelText, lsType = labelType, lsKind = labelKind, recordedBy = recordedBy, preferred = TRUE)
    container <- createContainer(lsType = "location", lsKind = "default", recordedBy = recordedBy, containerLabels = list(label))
    return(container)
  }
  createInteraction <- function(data, ptempid, firstID, recordedBy) {
    interaction <- createContainerContainerInteraction(lsType = "moved to", lsKind = "location_location", recordedBy = recordedBy, firstContainer = firstID, secondContainer = data[tempid == ptempid,]$id)
    interaction$firstContainer <- data[tempid == firstID,]$savedContainer[[1]]
    interaction$secondContainer <- data[tempid == ptempid,]$savedContainer[[1]]
    return(interaction)
  }

  data <- as.data.table(jsonlite::fromJSON(postData))
  recordedBy <- GET$recordedBy
  data[ , container := list(list(createLocation(label, labeltype, labelkind, recordedBy = recordedBy))), by = tempid]
  containers <- saveContainers(data$container)
  containerDT <- rbindlist(lapply(containers, function(x) {list(id = x$id, label = x$lsLabels[[1]]$labelText, savedContainer = list(x))}))
  setkey(data, label)
  setkey(containerDT, label)
  data <- data[containerDT]
  data[ !is.na(parenttempid), interaction := list(list(createInteraction(data, parenttempid, tempid, recordedBy = recordedBy))), by = tempid]
  interactions <- saveContainerContainerInteractions(data[!is.na(parenttempid)]$interaction)
  cat(jsonlite::toJSON(data, auto_unbox = TRUE))
}

postData <- rawToChar(receiveBin())
out <- bulkLoadLocations(postData, GET)
cat(out)
DONE
