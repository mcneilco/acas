#!/bin/bash
#
# Launcher for the ACAS Node app.
#
# This was historically a large SysV-init script that managed the node app via
# `forever`, plus Apache/rapache and R. In a container the runtime (Docker /
# Kubernetes) is the process manager, so this is now a thin launcher that just
# prepares config and runs the app in the foreground (PID 1). Supported forms:
#
#   bin/acas.sh run [acas]          prepare config, then `node app.js`
#   bin/acas.sh run [acas] start    same as above
#   bin/acas.sh run [acas] dev      prepare config, then `gulp dev` (watch)
#

scriptPath=$(readlink -f "${BASH_SOURCE[0]}")
ACAS_HOME=$(cd "$(dirname "$scriptPath")"/..; pwd)
cd "$ACAS_HOME" || exit 1
export PATH=/usr/local/bin:${PATH}
echo "ACAS_HOME=$ACAS_HOME"

# Customer-specific environment overrides, if present.
[ -f "$ACAS_HOME/bin/setenv.sh" ] && . "$ACAS_HOME/bin/setenv.sh"

# Regenerate the compiled config from the environment.
if [ "$PREPARE_CONFIG_FILES" = "true" ]; then
    node "$ACAS_HOME/src/javascripts/BuildUtilities/PrepareConfigFiles.js"
fi

# Load the compiled config into the shell (needed for the persistence URL below).
counter=0
until [ -f "$ACAS_HOME/conf/compiled/conf.properties" ] || [ $counter -ge 5 ]; do
    printf "."
    sleep 1
    counter=$((counter + 1))
done
if [ -f "$ACAS_HOME/conf/compiled/conf.properties" ]; then
    source /dev/stdin <<< "$(awk -f "$ACAS_HOME/bin/readproperties.awk" "$ACAS_HOME/conf/compiled/conf.properties")"
fi

# Once the persistence service (roo) is up, (re)generate module config. Runs in
# the background so it doesn't block the app from starting.
if [ "$PREPARE_MODULE_CONF_JSON" = "true" ]; then
    (
        persistence_service_url=$client_service_persistence_fullpath/protocoltypes
        until curl --output /dev/null --silent --head --fail "$persistence_service_url"; do
            echo "PrepareModuleConfJSON.js: $persistence_service_url unavailable, retrying in 1s"
            sleep 1
        done
        echo "PrepareModuleConfJSON.js: Running"
        if node "$ACAS_HOME/src/javascripts/BuildUtilities/PrepareModuleConfJSON.js"; then
            echo "PrepareModuleConfJSON.js: Success"
        else
            echo "PrepareModuleConfJSON.js: Failed"
        fi
    ) &
fi

# Run the app. `dev` => gulp watch/rebuild; anything else => plain node.
if [ "${@: -1}" = "dev" ]; then
    exec npm run dev
else
    exec node app.js
fi
