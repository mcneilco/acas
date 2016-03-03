_ = require('lodash')
mongojs = require('mongojs')

mongoPort = 27017
databaseName = "plateRegistration"
dbConnectionString = "#{process.env.DOCKER_HOST_IP}:#{mongoPort}/#{databaseName}"
console.log "dbConnectionString"
console.log dbConnectionString
db = mongojs(dbConnectionString, ['plates', 'wells'])

searchForWellsBy = (batchCode, callback) ->
  db.plates.find(
    { "wells.lsStates.lsValues": { $elemMatch: {lsKind: "batch code", codeValue: batchCode} } }
  ,
    { "wells.codeName": 1 }
  , callback(err, docs)
  )


module.exports =
  searchForWellsBy: searchForWellsBy