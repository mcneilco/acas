###
# install.R
# Installs racas and depencies
##

passwordPrompt <- function(auth_user, appName = "") {
  cat(paste0(appName, " password for ",auth_user,": "))
  system("stty -echo")
  password <- readLines(con="stdin", 1)
  system("stty echo")
  cat("\n")
  return(password)
}
userPrompt <- function(userTypeName = "user", appName = "") {
  cat(paste0(appName," ", userTypeName,": "))
  username <- readLines(con="stdin", 1)
  cat("\n")
  return(username)
}
if(!interactive()) {
  args <- commandArgs(TRUE)
  if(length(args) < 2 | length(args) > 3) {
    cat("Usage: Rscript install.R ref auth_user password (Ex. Rscript install.R master mcneilco mcneilco_pass)\n")
    quit("no")
  } else {
    ref <- args[1]
    auth_user <- args[2]
    password <- args[3]
    if(is.na(password)) {
      password <- passwordPrompt(auth_user, "bitbucket")
    }
  }
} else {
  ref <- userPrompt("branch","bitbucket")
  auth_user <- userPrompt("username","bitbucket")
  password <- passwordPrompt(auth_user,"bitbucket")
}

#Setting common lib path items to make sure we are always hitting the correct lib directory
acasHome <- normalizePath("../../../")
rLibs <- file.path(acasHome,"r_libs")
cat("HERE ", rLibs)
dir.create(rLibs, recursive = TRUE, showWarnings = FALSE)
Sys.setenv(ACAS_HOME=acasHome)
Sys.setenv(R_LIBS=rLibs)
.libPaths(rLibs)

#Rstudio repos apparently redirects to the best server
repos <- "http://cran.rstudio.com/"
options(repos = "http://cran.rstudio.com/")

tryBitbucket <- function(ref, auth_user, password, repo = "racas", username = "mcneilco", attempts = 3) {
  url <- paste0("https://bitbucket.org/",username,"/",repo,"/get/",ref,".tar.gz")
  user <- paste0(auth_user,":",password)
  originalWD <- getwd()
  on.exit(setwd(originalWD))
  tempracasdir <- tempfile()
  dir.create(tempracasdir)
  setwd(tempracasdir)
  system(paste0("curl --user ",user, " ", url," | tar xvz --strip-components=1"))
  source("./R/installation.R", local = TRUE)
  installDeps()
  install.packages(".", type = 'source', repos = NULL)
  setwd(originalWD)
}
tryBitbucket(ref = ref, auth_user = auth_user, password = password, attempts = 3, repo = "racas", username = "mcneilco")

#When racas loads it attempts to load the package specified for database connectons
#The following option will make it so it automatically installs this package when loaded
options(racasInstallDep = TRUE)
library(racas, lib.loc = rLibs)

#After the install include the bitbucket repoNumber
if(!'RCurl' %in% row.names(installed.packages(lib.loc = rLibs))){
  install.packages('RCurl', repos = repos)
}
require(RCurl)
branchCommitsJSON <- getURL(paste0("https://bitbucket.org/api/2.0/repositories/mcneilco/racas/commits?include=",ref),.opts=list(userpwd=paste0(auth_user,":",password)))

if(!'rjson' %in% row.names(installed.packages(lib.loc = rLibs))){
  install.packages('rjson', repos = repos)
}

require(rjson)
branchCommits <- fromJSON(branchCommitsJSON)
hash <- paste0("hash: ",branchCommits$values[[1]]$hash)
href <- paste0("href: ",branchCommits$values[[1]]$links$self$href)
date <- paste0("commitdate: ",branchCommits$values[[1]]$date)
message <- paste0("commitmessage: ",branchCommits$values[[1]]$message)
installDate <- paste0("installdate: ", Sys.time())
writeLines(c(installDate,hash,href,date,message),file.path(rLibs,"racas","install_info.txt"))
