###
# install.R
# Installs racas and depencies
## 
args <- commandArgs(TRUE)
if(length(args) < 2 | length(args) > 3) {
  cat("Usage: Rscript install.R ref auth_user password (Ex. Rscript install.R master mcneilco mcneilco_pass)\n")
  quit("no")
} else {
  ref <- args[1]
  auth_user <- args[2]
  password <- args[3]
  if(is.na(password)) {
    cat(paste0("password for ",auth_user,": "))
    system("stty -echo")
    password <- readLines(con="stdin", 1)
    system("stty echo")
    cat("\n")
  }
}
acasHome <- Sys.getenv("ACAS_HOME")
if(acasHome == "") {
  installDirectory <- .libPaths()[1]
  warning(paste0("ACAS_HOME environment variable not set"))
  altInstall <- "?"
  while(!altInstall %in% c("y","n")) {
    cat(paste0("Attempt to install racas in '", installDirectory,"'? (y or n):"))
    altInstall <- readLines(con="stdin", 1)
  }
  if(altInstall == "n") {
    quit("no")
  }
} else {
  installDirectory <- file.path(acasHome,"r_libs")
  dir.create(installDirectory, recursive = TRUE, showWarnings = FALSE)
}

#Setting common lib path items to make sure we are always hitting the correct lib directory
Sys.setenv(R_LIBS=installDirectory)
.libPaths(installDirectory)

#Rstudio repos apparently redirects to the best server
repos <- "http://cran.rstudio.com/"
options(repos = "http://cran.rstudio.com/")
if(!require('devtools')){
  install.packages('devtools', lib = installDirectory, repos = repos)
}
library(devtools, lib.loc = installDirectory)
#Need to load methods because of a bug in dev tools can remove when bug is fixed
if(!require('methods')){
  install.packages('methods', lib = installDirectory, repos = repos)
}
library(methods, lib.loc = installDirectory)
install_bitbucket(repo = "racas", username = "mcneilco", ref = ref, auth_user = auth_user, password = password)

#When racas loads it attempts to load the package specified for database connectons
#The following option will make it so it automatically installs this package when loaded
options(racasInstallDep = TRUE)
library(racas)

#After the install include the bitbucket repoNumber
if(!require('RCurl')){
  install.packages('RCurl', repos = repos)
}
require(RCurl)
branchCommitsJSON <- getURL(paste0("https://bitbucket.org/api/2.0/repositories/mcneilco/racas/commits?include=",ref),.opts=list(userpwd=paste0(auth_user,":",password)))

if(!require('rjson')){
  install.packages('RCurl', repos = repos)
}
require(rjson)
branchCommits <- fromJSON(branchCommitsJSON)
hash <- paste0("hash: ",branchCommits$values[[1]]$hash)
href <- paste0("href: ",branchCommits$values[[1]]$links$self$href)
date <- paste0("commitdate: ",branchCommits$values[[1]]$date)
message <- paste0("commitmessage: ",branchCommits$values[[1]]$message)
installDate <- paste0("installdate: ", Sys.time())
writeLines(c(installDate,hash,href,date,message),file.path(installDirectory,"racas","install_info.txt"))
