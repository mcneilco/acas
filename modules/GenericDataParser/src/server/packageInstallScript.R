#REQUIRED PACKAGES
#Usage: Rscript requiredPackages.R
repo <- 'http://cran.stat.ucla.edu'
requiredPackages <- c('rjson',
                      'gdata',
                      'RJDBC',
                      'RCurl',
                      'reshape',
                      'brew',
                      'compiler',
                      'XML')


is.installed <- function(mypkg) is.element(mypkg, installed.packages()[,1]) 

for(p in requiredPackages) {
  cat(paste0('Required Package: ',p,'\n'))
  if(!is.installed(p)) {
    cat('Installing...\n')
    install.packages(p,dep=TRUE, repos = repo)
  } else {
    cat('Already installed...skipping\n')
  }
}