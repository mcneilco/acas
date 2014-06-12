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
	if(length(args) < 1 | length(args) > 2) {
	  cat("Usage: Rscript install.R auth_user password (Ex. Rscript install.R mcneilco mcneilco_pass)\n")
	  quit("no")
	} else {
	  auth_user <- args[1]
	  password <- args[2]
	  if(is.na(password)) {
		password <- passwordPrompt(auth_user, "repo.labsynch.com")
	  }
	}
} else {
	auth_user <- userPrompt("username","repo.labsynch.com")
	password <- passwordPrompt(auth_user,"repo.labsynch.com")
}

#Setting common lib path items to make sure we are always hitting the correct lib directory
acasHome <- normalizePath("..")
rLibs <- file.path(acasHome,"r_libs")
dir.create(rLibs, recursive = TRUE, showWarnings = FALSE)
Sys.setenv(ACAS_HOME=acasHome)
Sys.setenv(R_LIBS=rLibs)
.libPaths(rLibs)

tryInstall <- function(auth_user, password, attempts = 3) {
	for(i in 1:attempts) {
		outcome <- try(install.packages(repos=paste0('http://',auth_user,':',password,'@repo.labsynch.com/R'), method='curl', pkgs='racas', dep= c("Depends", "Imports", "LinkingTo")))
		if(class(outcome) == "try-error") {
			if(i < attempts) {
				auth_user <- userPrompt("username", "repo.labsynch.com")
				password <- passwordPrompt(auth_user,"repo.labsynch.com")
			} else {
				stop(outcome)
			}
		} else {
			break
		}
	}
}
tryInstall(auth_user = auth_user, password = password, attempts = 3)

#When racas loads it attempts to load the package specified for database connectons
#The following option will make it so it automatically installs this package when loaded
options(racasInstallDep = TRUE)
library(racas, lib.loc = rLibs)
