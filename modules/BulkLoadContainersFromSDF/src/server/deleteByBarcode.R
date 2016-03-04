require(RCurl)
require(rjson)
require(racas)

#barcodes <- c("DMSO", "SUCROLOSE", "SUCROSE", "S6973")
barcodes <- c("AP00000981")
plateIds <- query(paste0("select container_id from container_label where label_text IN (", sqliz(barcodes), ")"))$CONTAINER_ID

itx_container_containers <- query(paste0("select id, second_container_id from itx_container_container where first_container_id IN (", sqliz(plateIds), ")"))
interactionIds <- itx_container_containers$ID

wellIds <- itx_container_containers$SECOND_CONTAINER_ID

containerIds <- c(plateIds, wellIds)
print(system.time(lapply(interactionIds, function(x) deleteEntity(list(id=x, version=0), "itxcontainercontainers"))))
print(system.time(lapply(containerIds, function(x) deleteEntity(list(id=x, version=0), "containers"))))
