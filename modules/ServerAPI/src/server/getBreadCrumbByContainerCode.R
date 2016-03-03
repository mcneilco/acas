# The next line is used by PrepareConfigFiles to include this file as a route in rapache, do not modify unless you intend to modify rapache routes (it can be anywhere in the files though)
# ROUTE: /getBreadCrumbByContainerCode

getBreadCrumbByContainerCode <- function(postData) {
    containerCodes <- jsonlite::fromJSON(postData)
    breadCrumbDT <- racas::getBreadCrumbByContainerCode(containerCodes)
    return(jsonlite::toJSON(breadCrumbDT))
}
postData <- rawToChar(receiveBin())
out <- getBreadCrumbByContainerCode(postData)
cat(out)
DONE

