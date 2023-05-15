# Do not add content to this file, this is strictly for client usage to allow a script to be executed on start
path = require 'path'
fs = require 'fs'

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
        # Write a file to the file system to indicate that the migration has started
        fileServices = require "#{ACAS_HOME}/routes/FileServices.js"
        await fileServices.init()

        # Check if lock file exists in the datafiles relative path location then exist
        lockFilePath = path.join(config.all.server.datafiles.relative_path, 'files.lock')
        exists = !!(await (fs.promises.stat lockFilePath).catch (err) -> false)
        if exists
            console.log "Lock file exists at: #{lockFilePath}. Exiting."
            process.exit -1
        else
            await fs.promises.writeFile(lockFilePath, 'lock')
            # When we exit the function delete the lock file
            console.log "Created lock file at: #{lockFilePath}"
        try
            await fileServices.migrateCmpdRegBulkLoaderFilesToSubfolders()
        catch err
            console.error "Error migrating files to subfolders: #{err}"
        finally
            await fs.promises.unlink(lockFilePath)
            console.log "Deleted lock file at: #{lockFilePath}"

    if config.all.server.migrateFromLocalToExternalFileHandlerOnStart? && config.all.server.migrateFromLocalToExternalFileHandlerOnStart
        # Write a file to the file system to indicate that the migration has started
        fileServices = require "#{ACAS_HOME}/routes/FileServices.js"
        await fileServices.init()

        # Check if lock file exists in the datafiles relative path location then exist
        lockFilePath = path.join(config.all.server.datafiles.relative_path, 'files.lock')
        exists = !!(await (fs.promises.stat lockFilePath).catch (err) -> false)
        if exists
            console.log "Lock file exists at: #{lockFilePath}. Exiting."
            process.exit -1
        else
            await fs.promises.writeFile(lockFilePath, 'lock')
            # When we exit the function delete the lock file
            console.log "Created lock file at: #{lockFilePath}"
        try
            await fileServices.migrateFromLocalToExternalFileHandler(lockFilePath)
        catch err
            console.error "Error migrating files to external file handler: #{err}"
        finally
            await fs.promises.unlink(lockFilePath)
            console.log "Deleted lock file at: #{lockFilePath}"

if require.main == module
    exports.main()