# The next line is used by PrepareConfigFiles to include this file as a route in rapache, do not modify unless you intend to modify rapache routes (it can be anywhere in the files though)
# ROUTE: /bulkLoadLocations

library(data.table)

bulkLoadLocations <- function(postData, GET) {

  createLocation <- function(labelText, labelType, labelKind, recordedBy) {
    label <- createContainerLabel(labelText = labelText, lsType = labelType, lsKind = labelKind, recordedBy = recordedBy, preferred = TRUE)
    container <- createContainer(lsType = "location", lsKind = "default", recordedBy = recordedBy, containerLabels = list(label))
    return(container)
  }
  createInteraction <- function(data, ptempid, parentid, firstID, recordedBy) {
    if(!is.na(ptempid)) {
      secondContainerID <- data[tempid == ptempid,]$id
      secondContainer <- data[tempid == ptempid,]$savedContainer[[1]]
    } else {
      secondContainerID <- parentid
      secondContainer <- list(id = parentid, version = 0)
    }
    interaction <- createContainerContainerInteraction(lsType = "moved to", lsKind = "location_location", recordedBy = recordedBy, firstContainer = firstID, secondContainer = secondContainerID)
    interaction$firstContainer <- data[tempid == firstID,]$savedContainer[[1]]
    interaction$secondContainer <- secondContainer
    return(interaction)
  }
  
  data <- as.data.table(jsonlite::fromJSON(postData))
  if(!"parenttempid" %in% names(data)) {
    data[ , parenttempid := NA_integer_]
  }
  if(!"parentid" %in% names(data)) {
    data[ , parentid := NA_integer_]
  }
  recordedBy <- GET$recordedBy
  data[ , container := list(list(createLocation(label, labeltype, labelkind, recordedBy = recordedBy))), by = tempid]
  containers <- saveContainers(data$container)
  containerDT <- rbindlist(lapply(containers, function(x) {list(id = x$id, label = x$lsLabels[[1]]$labelText, savedContainer = list(x))}))
  setkey(data, label)
  setkey(containerDT, label)
  data <- data[containerDT]
  data[ !is.na(parenttempid) | !is.na(parentid), interaction := list(list(createInteraction(data, parenttempid, parentid, tempid, recordedBy = recordedBy))), by = tempid]
  interactions <- saveContainerContainerInteractions(data[!is.na(parenttempid) | !is.na(parentid)]$interaction)
  cat(jsonlite::toJSON(data, auto_unbox = TRUE))
}

postData <- rawToChar(receiveBin())
out <- bulkLoadLocations(postData, GET)
cat(out)
DONE
