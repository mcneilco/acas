# Do not add content to this file, this is strictly for client usage to allow a script to be executed on start

exports.main = (callback) ->
    # Example install of LD client python library on start
    ACAS_HOME="../../.."
    config = require "#{ACAS_HOME}/conf/compiled/conf.js"
    if config.all.server.liveDesign.installClientOnStart? && config.all.server.liveDesign.installClientOnStart
        exec = require('child_process').exec
        command = "pip3.6 install --upgrade --force-reinstall --user #{config.all.client.service.result.viewer.liveDesign.baseUrl}/ldclient.tar.gz"
        console.log "About to call python using command: "+command
        child = exec command,  (error, stdout, stderr) ->
            console.log stdout
            if error?
                console.warn "Error installing ld client. This can happen if Live Design was down during ACAS start or otherwise ACAS could not communicate with Live Design.  This is just a warning as LD client might already be installed and be the correction version."
                console.error stderr
                callback(error)
            else
                callback(null)
    if config.all.server.migrateCmpdRegBulkLoaderFilesToSubfoldersOnStart? && config.all.server.migrateCmpdRegBulkLoaderFilesToSubfoldersOnStart
        fileServices = require "#{ACAS_HOME}/routes/FileServices.js"
        await fileServices.init()
        bulkLoadFiles = await fileServices.migrateCmpdRegBulkLoaderFilesToSubfolders()

if require.main == module
    exports.main()