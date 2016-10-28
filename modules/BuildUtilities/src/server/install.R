###
# install.R
# Installs racas and depencies
##

userPrompt <- function(userTypeName = "user", appName = "") {
  cat(paste0(appName," ", userTypeName,": "))
  username <- readLines(con="stdin", 1)
  cat("\n")
  return(username)
}
if(!interactive()) {
  args <- commandArgs(TRUE)
  if(length(args) < 1 | length(args) > 1) {
    cat("Usage: Rscript install.R ref (Ex. Rscript install.R master)\n")
    quit("no")
  } else {
    ref <- args[1]
  }
} else {
  ref <- userPrompt("branch","github")
}

#Setting common lib path items to make sure we are always hitting the correct lib directory
acasHome <- normalizePath("../../../")
rLibs <- file.path(acasHome,"r_libs")
dir.create(rLibs, recursive = TRUE, showWarnings = FALSE)
Sys.setenv(ACAS_HOME=acasHome)
Sys.setenv(R_LIBS=rLibs)
.libPaths(rLibs)

#Rstudio repos apparently redirects to the best server
repos <- "http://cran.rstudio.com/"
options(repos = "http://cran.rstudio.com/")

installGitHub <- function(ref) {
  originalWD <- getwd()
  on.exit(setwd(originalWD))
  tempracasdir <- tempfile()
  dir.create(tempracasdir)
  setwd(tempracasdir)
  download.file(paste0("https://github.com/mcneilco/racas/tarball/",ref), "racas.tar.gz")
  untar("racas.tar.gz")
  setwd(list.dirs(recursive=FALSE))
  source("./R/installation.R", local = TRUE)
  installDeps()
  install.packages(".", type = 'source', repos = NULL)
  setwd(originalWD)
}
installGitHub(ref = ref)
#When racas loads it attempts to load the package specified for database connectons
#The following option will make it so it automatically installs this package when loaded
options(racasInstallDep = TRUE)
library(racas, lib.loc = rLibs)

