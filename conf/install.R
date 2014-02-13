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
    cat(paste0("bitbucket password for ",auth_user,": "))
    system("stty -echo")
    password <- readLines(con="stdin", 1)
    system("stty echo")
    cat("\n")
  }
}

#Setting common lib path items to make sure we are always hitting the correct lib directory
acasHome <- normalizePath("..")
rLibs <- file.path(acasHome,"r_libs")
dir.create(rLibs, recursive = TRUE, showWarnings = FALSE)
Sys.setenv(ACAS_HOME=acasHome)
Sys.setenv(R_LIBS=rLibs)
.libPaths(rLibs)


#Rstudio repos apparently redirects to the best server
repos <- "http://cran.rstudio.com/"
options(repos = "http://cran.rstudio.com/")
if(!require('devtools', lib.loc = rLibs)){
  install.packages('devtools', lib = rLibs, repos = repos)
}
library(devtools, lib.loc = rLibs)
#Need to load methods because of a bug in dev tools can remove when bug is fixed
if(!require('methods', lib.loc = rLibs)){
  install.packages('methods', lib = rLibs, repos = repos)
}
library(methods, lib.loc = rLibs)
install_bitbucket(repo = "racas", username = "mcneilco", ref = ref, auth_user = auth_user, password = password)

#When racas loads it attempts to load the package specified for database connectons
#The following option will make it so it automatically installs this package when loaded
options(racasInstallDep = TRUE)
library(racas, lib.loc = rLibs)

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
writeLines(c(installDate,hash,href,date,message),file.path(rLibs,"racas","install_info.txt"))
