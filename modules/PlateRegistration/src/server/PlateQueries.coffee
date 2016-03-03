_ = require('lodash')
mongojs = require('mongojs')

mongoPort = 27017
databaseName = "plateRegistration"
dbConnectionString = "#{process.env.DOCKER_HOST_IP}:#{mongoPort}/#{databaseName}"
console.log "dbConnectionString"
console.log dbConnectionString
db = mongojs(dbConnectionString, ['plates', 'wells'])

findAllWellsContainingBatchId = (batchId, callback) ->
  console.time('search')
  db.plates.find(
    {
      "wells.lsStates.lsValues": {
        $elemMatch: {
          lsKind: "batch code"
          codeValue: batchId
        }
      }
    }
  ,{ "wells.$": 1, "codeName": 1}
  , (err, docs) ->
    if err
      console.error("the following error occurred:")
      console.log(err)
      callback(err, null)
    else
      console.timeEnd('search')
      callback(null, docs)
  )

#findAllWellsContainingBatchId("DNS3::1", (err, docs) ->
#  unless err
#    _.each(docs, (doc) ->
#      console.log "plate code name: " + doc.codeName
#      _.each(doc.wells, (well) ->
#        console.log "well code name: " + well.codeName
#        _.each(well.lsStates, (lsState) ->
#          _.each(lsState.lsValues, (lsValue) ->
#            if lsValue.lsKind is "batch code"
#              console.log "well contents batch id: " + lsValue.codeValue
#          )
#        )
#      )
#    )
#    console.log "found #{_.size(docs)} plates with wells containing #{"DNS3::1"}"
#)

findAllWellsContainingBatchId1 = (batchId, callback) ->
  console.time('search')
  db.plates.find(
    {
      "wells.lsStates.lsValues.codeValue": batchId
    }
  ,{ "wells.$": 1, "codeName": 1}
  , (err, docs) ->
    if err
      console.error("the following error occurred:")
      console.log(err)
      callback(err, null)
    else
      console.timeEnd('search')
      callback(null, docs)
  )

findAllWellsContainingBatchId("DNS3::1", (err, docs) ->
  unless err
    _.each(docs, (doc) ->
      #console.log "plate code name: " + doc.codeName
      console.log "number of wells returned: #{_.size(doc.wells)}"
      _.each(doc.wells, (well) ->
        console.log "well code name: " + well.codeName
        _.each(well.lsStates, (lsState) ->
          _.each(lsState.lsValues, (lsValue) ->
            if lsValue.lsKind is "batch code"
              true
              #console.log "well contents batch id: " + lsValue.codeValue
          )
        )
      )
    )
    console.log "found #{_.size(docs)} plates with wells containing #{"DNS3::1"}  1"
)