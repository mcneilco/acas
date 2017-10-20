# The next line is used by PrepareConfigFiles to include this file as a route in rapache, do not modify unless you intend to modify rapache routes (it can be anywhere in the files though)
# ROUTE: /getBreadCrumbByContainerCode

getBreadCrumbByContainerCode <- function(postData, GET) {
    containerCodes <- jsonlite::fromJSON(postData)
    if(!is.null(GET$delimeter)) {
      delimeter=GET$delimeter
    } else {
      delimeter="\t"
    }
    breadCrumbDT <- racas::getBreadCrumbByContainerCode(containerCodes, sep = delimeter)
    return(jsonlite::toJSON(breadCrumbDT))
}
postData <- rawToChar(receiveBin())
out <- getBreadCrumbByContainerCode(postData, GET)
cat(out)
DONE

