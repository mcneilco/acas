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

  getLocationTreeByLabel <- function(labels, lsServerURL = racas::applicationSettings$server.nodeapi.path) {
    label <- applicationSettings$client.compoundInventory.rootLocationLabel
    url <- paste0(lsServerURL, '/api/getLocationCodesByBreadcrumbArray?rootLabel=', label)
    json <- postJSONURL(url,  postfields = rjson::toJSON(labels))
    containers <- as.data.table(jsonlite::fromJSON(json$body))
  }
  getRootLocation <- function() {
    label <- applicationSettings$client.compoundInventory.rootLocationLabel
    containers <- getLocationTreeByLabel(list(label))
    rootContainer <- list()
    if(nrow(containers)> 0) {
      containers <- containers[level == 1,]
      if(nrow(containers) > 0) {
        rootContainers <- getContainersByCodeNames(containers$codeName)
        rootContainer <- rootContainers[[1]]$container
      }
    }
    return(rootContainer)
  }
  getOrCreateRootLocation <- function(recordedBy) {
    rootLocation <- getRootLocation()
    if(length(rootLocation) == 0) {
      label <- applicationSettings$client.compoundInventory.rootLocationLabel
      location <- createLocation(label, "name", "common", recordedBy)
      rootLocation <- saveContainers(list(location))[[1]]
    }
    return(rootLocation)
  }


  
  recordedBy <- GET$recordedBy

  # Get or create the root location because we want everything anchored off of it
  rootLocation <- getOrCreateRootLocation(recordedBy)
  rootLocationRow <- data.table(label=applicationSettings$client.compoundInventory.rootLocationLabel, tempid=0, savedContainer=list(rootLocation))

  # For convenience, we want to also create the other default locations here
  trash <- getLocationTreeByLabel(list(paste0(applicationSettings$client.compoundInventory.rootLocationLabel,">",applicationSettings$client.compoundInventory.trashLocationLabel)))
  if(nrow(trash) == 0) {
      trash <- createLocation(applicationSettings$client.compoundInventory.trashLocationLabel, "name", "common", recordedBy = recordedBy)
      trashLocation <- saveContainers(list(trash))
      interaction <- createContainerContainerInteraction(lsType = "moved to", lsKind = "location_location", recordedBy = recordedBy, firstContainer = trashLocation[[1]], secondContainer = rootLocation)
      interactions <- saveContainerContainerInteractions(list(interaction))
  }
  benches <- getLocationTreeByLabel(list(paste0(applicationSettings$client.compoundInventory.rootLocationLabel,">",applicationSettings$client.compoundInventory.benchesLocationLabel)))
  if(nrow(benches) == 0) {
      benches <- createLocation(applicationSettings$client.compoundInventory.benchesLocationLabel, "name", "common", recordedBy = recordedBy)
      benchesLocation <- saveContainers(list(benches))
      interaction <- createContainerContainerInteraction(lsType = "moved to", lsKind = "location_location", recordedBy = recordedBy, firstContainer = benchesLocation[[1]], secondContainer = rootLocation)
      interactions <- saveContainerContainerInteractions(list(interaction))
  } 

  data <- as.data.table(jsonlite::fromJSON(postData))
 
  if(nrow(data) == 0) {
    return(jsonlite::toJSON(rootLocationRow, auto_unbox = TRUE))
  
  } else {
    if(!"parenttempid" %in% names(data)) {
      data[ , parenttempid := NA_integer_]
    }
    if(!"parentid" %in% names(data)) {
      data[ , parentid := NA_integer_]
    }
    # Make sure everything has a tempid
    if(!"tempid" %in% names(data)) {
      data[ , tempid := NA_integer_]
    }

    maxTempId <- 0
    if(nrow(data[!is.na(tempid)])> 0) {
      maxTempId <- max(data[!is.na(tempid)]$tempid)
    } else {
      maxTempId <- 0
    }
    data[is.na(tempid), tempid:=maxTempId+1:.N]
  }

  # Create the containers in  memory (not saved yet)
  data[ , container := list(list(createLocation(label, labeltype, labelkind, recordedBy = recordedBy))), by = tempid]

  # Save the new locations
  data[ , savedContainer:=list(saveContainers(container)), by = tempid]
  data[ , id := savedContainer[[1]]$id, by = tempid]

  # Anything without a temporary parent id or without a parentid, need to be passed their parentid as the root location
  data[is.na(parenttempid) & is.na(parentid), parentid := rootLocation$id]

  # Add the root location to the data after the save for use in interactions
  data <- rbind(rootLocationRow, data, fill = TRUE)

  if(nrow(data[ !is.na(parenttempid) | !is.na(parentid), ]) > 0) {


    # Create the interactions in memory (not saved yet)
    data[ !is.na(parenttempid) | !is.na(parentid), interaction := list(list(createInteraction(data, parenttempid, parentid, tempid, recordedBy = recordedBy))), by = tempid]

    # Save interactions
    interactions <- saveContainerContainerInteractions(data[!is.na(parenttempid) | !is.na(parentid)]$interaction)

  }

  # Respond
  cat(jsonlite::toJSON(data, auto_unbox = TRUE))
}

postData <- rawToChar(receiveBin())
out <- bulkLoadLocations(postData, GET)
cat(out)
DONE
