# The next line is used by PrepareConfigFiles to include this file as a route in rapache, do not modify unless you intend to modify rapache routes (it can be anywhere in the files though)
# ROUTE: /test/getDatabaseConnection

tryCatch({
    library(racas);
    conn <- getDatabaseConnection();
    dbDisconnect(conn)
    },error = function(ex) {cat(paste("R Execution Error:",ex));})
