_ = require('lodash')
mongojs = require('mongojs')

mongoPort = 27017
databaseName = "plateRegistration"
dbConnectionString = "#{process.env.DOCKER_HOST_IP}:#{mongoPort}/#{databaseName}"
console.log "dbConnectionString"
console.log dbConnectionString
db = mongojs(dbConnectionString, ['plates', 'wells'])

batchIds = [1..100]

generatePlates = (numberOfPlates, plateType) ->
  plateIndex = 1
  plates = []
  _.each([1..numberOfPlates], (plateIdx) ->
    plate = {
      objectGraphSchemaVersion: 1,
      codeName: "CONT-#{plateIdx}",
      deleted: false,
      id: plateIndex,
      ignored: false,
      lsKind: "plate",
      wells: generateWells(plateType)
      lsLabels: [
        {
          deleted: false,
          id: 144523,
          ignored: false,
          labelText: "C1123312",
          lsKind: "barcode",
          lsTransaction: 1,
          lsType: "barcode",
          lsTypeAndKind: "barcode_barcode",
          physicallyLabled: true,
          preferred: true,
          recordedBy: "acas",
          recordedDate: 1455323304684,
          version: 0
        }
      ],
      lsStates: [
        {
          deleted: false,
          id: 124184,
          ignored: false,
          lsKind: "container",
          lsTransaction: 1,
          lsType: "metadata",
          lsTypeAndKind: "metadata_container",
          lsValues: [
            {
              codeKind: "plate type",
              codeOrigin: "ACAS DDICT",
              codeType: "plate type",
              codeTypeAndKind: "plate type_plate type",
              codeValue: "hitpick master plate",
              deleted: false,
              id: 497530,
              ignored: false,
              lsKind: "plate type",
              lsTransaction: 1,
              lsType: "codeValue",
              lsTypeAndKind: "codeValue_plate type",
              operatorTypeAndKind: "null_null",
              publicData: true,
              recordedBy: "acas",
              recordedDate: 1455323304684,
              unitTypeAndKind: "null_null",
              version: 0
            },
            {
              codeTypeAndKind: "null_null",
              deleted: false,
              id: 497022,
              ignored: false,
              lsKind: "description",
              lsTransaction: 1,
              lsType: "stringValue",
              lsTypeAndKind: "stringValue_description",
              operatorTypeAndKind: "null_null",
              publicData: true,
              recordedBy: "acas",
              recordedDate: 1455323304684,
              stringValue: "CMG00443:CQ 10UL",
              unitTypeAndKind: "null_null",
              version: 0
            },
            {
              codeKind: "kplate id",
              codeOrigin: "KPLATE",
              codeType: "kplate id",
              codeTypeAndKind: "kplate id_kplate id",
              codeValue: "311713",
              deleted: false,
              id: 497454,
              ignored: false,
              lsKind: "k plate id",
              lsTransaction: 1,
              lsType: "codeValue",
              lsTypeAndKind: "codeValue_k plate id",
              operatorTypeAndKind: "null_null",
              publicData: true,
              recordedBy: "acas",
              recordedDate: 1455323304684,
              unitTypeAndKind: "null_null",
              version: 0
            },
            {
              codeTypeAndKind: "null_null",
              deleted: false,
              id: 497023,
              ignored: false,
              lsKind: "created user",
              lsTransaction: 1,
              lsType: "stringValue",
              lsTypeAndKind: "stringValue_created user",
              operatorTypeAndKind: "null_null",
              publicData: true,
              recordedBy: "acas",
              recordedDate: 1455323304684,
              stringValue: "cmg_user",
              unitTypeAndKind: "null_null",
              version: 0
            },
            {
              codeKind: "supplier code",
              codeOrigin: "KPLATE",
              codeType: "supplier code",
              codeTypeAndKind: "supplier code_supplier code",
              codeValue: "BOF002",
              deleted: false,
              id: 497639,
              ignored: false,
              lsKind: "supplier code",
              lsTransaction: 1,
              lsType: "codeValue",
              lsTypeAndKind: "codeValue_supplier code",
              operatorTypeAndKind: "null_null",
              publicData: true,
              recordedBy: "acas",
              recordedDate: 1455323304684,
              unitTypeAndKind: "null_null",
              version: 0
            },
            {
              codeKind: "availability",
              codeType: "availability",
              codeTypeAndKind: "availability_availability",
              codeValue: "0",
              deleted: false,
              id: 497358,
              ignored: false,
              lsKind: "availability",
              lsTransaction: 1,
              lsType: "codeValue",
              lsTypeAndKind: "codeValue_availability",
              operatorTypeAndKind: "null_null",
              publicData: true,
              recordedBy: "acas",
              recordedDate: 1455323304684,
              unitTypeAndKind: "null_null",
              version: 0
            },
            {
              codeTypeAndKind: "null_null",
              dateValue: 1370298139000,
              deleted: false,
              id: 497210,
              ignored: false,
              lsKind: "created date",
              lsTransaction: 1,
              lsType: "dateValue",
              lsTypeAndKind: "dateValue_created date",
              operatorTypeAndKind: "null_null",
              publicData: true,
              recordedBy: "acas",
              recordedDate: 1455323304684,
              unitTypeAndKind: "null_null",
              version: 0
            },
            {
              codeTypeAndKind: "null_null",
              dateValue: 1370298139000,
              deleted: false,
              id: 497211,
              ignored: false,
              lsKind: "registration date",
              lsTransaction: 1,
              lsType: "dateValue",
              lsTypeAndKind: "dateValue_registration date",
              operatorTypeAndKind: "null_null",
              publicData: true,
              recordedBy: "acas",
              recordedDate: 1455323304684,
              unitTypeAndKind: "null_null",
              version: 0
            }
          ],
          recordedBy: "acas",
          recordedDate: 1455323304684,
          version: 0
        }
      ],
      lsTransaction: 1,
      lsType: "container",
      lsTypeAndKind: "container_plate",
      recordedBy: "acas",
      recordedDate: 1455323304684,
      version: 0
    }
    plates.push plate
  )
  plates


generateWells = (plateType) ->
  maxCol = 12
  maxRow = 8

  if plateType is "2-well"
    maxCol = 1
    maxRow = 2
  else if plateType is "96-well"
    maxCol = 12
    maxRow = 8
  else if plateType is "384-well"
    maxCol = 24
    maxRow = 16
  else if plateType is "1536-well"
    maxCol = 48
    maxRow = 32
  wellIndex = 1
  wells = []
  _.each([1..maxCol], (colIdx) ->
    _.each([1..maxRow], (rowIdx) ->
      batchId = batchIds[Math.floor(Math.random() * _.size(batchIds)) + 1]
      well = {
        codeName: "WELL-#{wellIndex}",
        columnIndex: colIdx,
        deleted: false,
        id: wellIndex,
        ignored: false,
        lsKind: "default",
        lsLabels: [
          {
            deleted: false,
            id: 206888,
            ignored: false,
            labelText: "N036",
            lsKind: "well name",
            lsTransaction: 1,
            lsType: "name",
            lsTypeAndKind: "name_well name",
            physicallyLabled: false,
            preferred: true,
            recordedBy: "acas",
            recordedDate: 1455323310690,
            version: 0
          }
        ],
        lsStates: [
          {
            deleted: false,
            id: 178897,
            ignored: false,
            lsKind: "content",
            lsTransaction: 1,
            lsType: "status",
            lsTypeAndKind: "status_content",
            lsValues: [
              {
                codeKind: "solvent code",
                codeType: "solvent code",
                codeTypeAndKind: "solvent code_solvent code",
                codeValue: "DNS000000001::1",
                deleted: false,
                id: 930194,
                ignored: false,
                lsKind: "solvent code",
                lsTransaction: 1,
                lsType: "codeValue",
                lsTypeAndKind: "codeValue_solvent code",
                operatorTypeAndKind: "null_null",
                publicData: true,
                recordedBy: "acas",
                recordedDate: 1455323310690,
                unitTypeAndKind: "null_null",
                version: 0
              },
              {
                codeKind: "physical",
                codeType: "state",
                codeTypeAndKind: "state_physical",
                codeValue: "liquid",
                deleted: false,
                id: 804246,
                ignored: false,
                lsKind: "physical state",
                lsTransaction: 1,
                lsType: "codeValue",
                lsTypeAndKind: "codeValue_physical state",
                operatorTypeAndKind: "null_null",
                publicData: true,
                recordedBy: "acas",
                recordedDate: 1455323310690,
                unitTypeAndKind: "null_null",
                version: 0
              },
              {
                codeTypeAndKind: "null_null",
                deleted: false,
                id: 568849,
                ignored: false,
                lsKind: "amount",
                lsTransaction: 1,
                lsType: "numericValue",
                lsTypeAndKind: "numericValue_amount",
                numericValue: 10,
                operatorTypeAndKind: "null_null",
                publicData: true,
                recordedBy: "acas",
                recordedDate: 1455323310690,
                unitKind: "uL",
                unitTypeAndKind: "null_uL",
                version: 0
              },
              {
                codeKind: "batch code",
                codeType: "batch code",
                codeTypeAndKind: "batch code_batch code",
                codeValue: "DNS#{batchId}::1",
                concUnit: "mM",
                concentration: 1,
                deleted: false,
                id: 636917,
                ignored: false,
                lsKind: "batch code",
                lsTransaction: 1,
                lsType: "codeValue",
                lsTypeAndKind: "codeValue_batch code",
                operatorTypeAndKind: "null_null",
                publicData: true,
                recordedBy: "acas",
                recordedDate: 1455323310690,
                unitTypeAndKind: "null_null",
                version: 0
              }
            ],
            recordedBy: "acas",
            recordedDate: 1455323310690,
            version: 0
          }
        ],
        lsTransaction: 1,
        lsType: "well",
        lsTypeAndKind: "well_default",
        recordedBy: "acas",
        recordedDate: 1455323310690,
        rowIndex: rowIdx,
        version: 0
      }

      wellIndex++
      wells.push well
    )
  )

  wells

##db.plates.find({"wells.lsStates.lsValues": {$elemMatch:{$and:[{"lsKind":"batch code"},{"codeValue":"DNS000216385::1"}]}}}, {"wells.$": 1})
plate = generatePlates(500, "1536-well")
#console.log "plate"
#console.log plate

console.time("dbBulkInsert")
db.plates.insert(plate, (err) ->
  if err
    console.log "err"
    console.log err
  else
    db.plates.createIndex({"wells.lsStates.lsValues.codeValue": 1, "wells.lsStates.lsValues.lsKind": 1})
    db.plates.createIndex({"wells.lsStates.lsValues.lsKind": 1})
    console.log "loaded everything fine...."
    console.timeEnd("dbBulkInsert")
)

findWellsWithBatchCode = (batchCode, callback) ->

#  query1 =
#    $project:
#      "wells.lsStates.lsValues":
#        $filter:
#          input: '$wells.lsStates.lsValues',
#          as: 'item',
#          cond:
#            $and: [
#              {"$$item.lsKind":"batch code"}
#              {"$$item.codeValue": batchCode}
#            ]
#
#  query =
#
#      $elemMatch:
#        $and:[
#          {"lsKind":"batch code"}
#          {"codeValue": batchCode}
#        ]
#  projection =
#    "wells.$": 1

#  checkData = () ->
#    db.wells.find( (err, docs) ->
#      if err
#        console.log err
#      else
#        console.log "results?"
#        console.log('\n', docs);
#
#    #db.close();
#    )

#  mapper = () ->
#    wells = []
#    _.each(@.wells.lsStates.lsValues, (value) ->
#      console.log "value"
#      console.log value
#      if value.lsKind is "batch code" and value.codeValue is batchCode
#        console.log "found a match... ?"
#        wells.push value
#    )

#  db.plates.mapReduce(
#    () ->
#      emit('foo', 1)
#    , (k, v) ->
##      console.log 'v'
##      console.log v
#      return Array.sum(v)
#    , {out: 'test4'})

#  mapper = () ->
#    emit("foo", 1)
#
#  reducer = (values) ->
#    return Array.sum(values)
#
#  db.plates.mapReduce(
#    mapper,
#    reducer,
#    {
#      out: "wells"
#    }
#  )
#  db.wells.find((err, docs) ->
#    console.log "docs"
#    console.log docs
#  )

#
#  db.plates.find(query1, projection, (err, results) ->
#    wells = []
#    _.each(results, (result) ->
#      console.log "_.size(result.wells)"
#      console.log _.size(result.wells)
#      Array.prototype.push.apply(wells, result.wells);
#      #wells = _.concat(wells, result.wells)
#    )
#    callback(null, wells)
#  )
#console.time("performQuery")
##findWellsWithBatchCode("DNS2::1", (err, response) ->
##  _.each(response, (well) ->
##    console.log well
##  )
##
##  console.log _.size(response)
##  console.timeEnd("performQuery")
##)
##return 0
#console.time('search')
#db.plates.find(
#  {
#    "wells.lsStates.lsValues": {
#      $elemMatch: {
#        lsKind: "batch code"
#        codeValue: "DNS2::1"
#      }
#    }
#  }
#,{ "wells.$": 1}
#, (err, docs) ->
#  if err
#    console.error("the following error occurred:")
#    console.log(err)
#  else
#    console.timeEnd('search')
#
#  console.log "docs[0]"
#  console.log docs[0]
#
#)