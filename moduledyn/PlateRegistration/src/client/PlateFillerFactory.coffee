WellsModel = require('./WellModel.coffee').WellsModel

PLATE_FILLER_STRATEGY_TYPES =
  RANDOM: 'random'
  IN_ORDER: 'inOrder'
  SAME_IDENTIFIER: 'sameIdentifier'

class PlateFillerFactory
  getPlateFiller: (strategy, fillDirection, identifiers, selectedRegion) ->
    plateFiller = null
    switch strategy
      when PLATE_FILLER_STRATEGY_TYPES.IN_ORDER then plateFiller = new InOrderPlateFillerStrategy(identifiers, selectedRegion, fillDirection)
      when PLATE_FILLER_STRATEGY_TYPES.RANDOM then plateFiller = new RandomPlateFillerStrategy(identifiers, selectedRegion)
      when PLATE_FILLER_STRATEGY_TYPES.SAME_IDENTIFIER then plateFiller = new SameIdentifierPlateFillerStrategy(identifiers, selectedRegion)

    plateFiller


class PlateFillerStrategy
  constructor: (identifiers, selectedRegionBoundries) ->
    @identifiers = identifiers
    @selectedRegionBoundries = selectedRegionBoundries

  getWells: ->
    throw "Method 'getWells' not implemented"

  populateWell: (wellsToUpdate, rowIdx, colIdx, batchConcentration, amount, batchCode) ->
    existingWell = wellsToUpdate.getWellAtRowIdxColIdx(rowIdx, colIdx)
    wellContentBeingOverwrittern = []
    if amount
      if amount is ""
        amount = existingWell.amount
      else if existingWell.amount
        if existingWell.amount isnt ""
          wellContentBeingOverwrittern.push
            rowIdx: rowIdx
            colIdx: colIdx
            existingValue: existingWell.amount
            newValue: amount
            fieldName: "amount"
    else
      amount = existingWell.amount

    if batchConcentration
      if batchConcentration is ""
        batchConcentration = existingWell.batchConcentration
      else if existingWell.batchConcentration
        if existingWell.batchConcentration isnt ""
          wellContentBeingOverwrittern.push
            rowIdx: rowIdx
            colIdx: colIdx
            existingValue: existingWell.batchConcentration
            newValue: batchConcentration
            fieldName: "batchConcentration"
    else
      batchConcentration = existingWell.batchConcentration

    if batchCode
      if batchCode is ""
        batchCode = existingWell.batchCode
      else if existingWell.batchCode
        if existingWell.batchCode isnt ""
          wellContentBeingOverwrittern.push
            rowIdx: rowIdx
            colIdx: colIdx
            existingValue: existingWell.batchCode
            newValue: batchCode
            fieldName: "batchCode"
    else
      batchCode = existingWell.batchCode

    well =
      amount: amount
      batchCode: batchCode
      batchConcentration: batchConcentration

    if _.size(wellContentBeingOverwrittern) is 0
      return [null, well]
    else
      return [wellContentBeingOverwrittern, well]

class RandomPlateFillerStrategy extends PlateFillerStrategy
  getWells: (wells, batchConcentration, amount) ->
    wellsToUpdate = new WellsModel({allWells: wells})
    rowIndexes = [@selectedRegionBoundries.rowStart..@selectedRegionBoundries.rowStop]
    columnIndexes = [@selectedRegionBoundries.colStart..@selectedRegionBoundries.colStop]
    plateWells = []
    wellContentOverwritten = []
    valueIdx = 0
    identifiersToRemove = []
    _.each(rowIndexes, (rowIdx) =>
      _.each(columnIndexes, (colIdx) =>

        identifierIdx = parseInt(Math.random() * _.size(@identifiers))
        identifier = @identifiers.splice(identifierIdx, (identifierIdx + 1))
        batchCode = identifier[0]
        [wellContentOverwritten, well] = @populateWell(wellsToUpdate, rowIdx, colIdx, batchConcentration, amount, batchCode)
        plateWells.push [rowIdx, colIdx, well]
        identifiersToRemove.push batchCode
        wellsToUpdate.fillWellWithWellObject(rowIdx, colIdx, well)
      )
    )

    [plateWells, identifiersToRemove, wellsToUpdate, wellContentOverwritten]


class SameIdentifierPlateFillerStrategy extends PlateFillerStrategy
  getWells: (wells, batchConcentration, amount) ->
    wellsToUpdate = new WellsModel({allWells: wells})
    rowIndexes = [@selectedRegionBoundries.rowStart..@selectedRegionBoundries.rowStop]
    columnIndexes = [@selectedRegionBoundries.colStart..@selectedRegionBoundries.colStop]
    plateWells = []
    wellContentOverwritten = []
    valueIdx = 0
    identifiersToRemove = []
    _.each(rowIndexes, (rowIdx) =>
      _.each(columnIndexes, (colIdx) =>
        existingWell = wellsToUpdate.getWellAtRowIdxColIdx(rowIdx, colIdx)
        batchCode = @identifiers[0]
        [wellContentOverwritten, well] = @populateWell(wellsToUpdate, rowIdx, colIdx, batchConcentration, amount, batchCode)
        plateWells.push [rowIdx, colIdx, well]
        identifiersToRemove.push @identifiers[0]
        wellsToUpdate.fillWellWithWellObject(rowIdx, colIdx, well)
        valueIdx++
      )
    )

    [plateWells, identifiersToRemove, wellsToUpdate, wellContentOverwritten]


class InOrderPlateFillerStrategy extends PlateFillerStrategy
  constructor: (identifiers, selectedRegion, fillDirection) ->
    super(identifiers, selectedRegion)
    @fillDirection = fillDirection

  getWells: (wells, batchConcentration, amount) ->
    if @fillDirection is "columnMajor"
      return @getWellsColumnMajor(wells, batchConcentration, amount)
    else if @fillDirection is "rowMajor"
      return @getWellsRowMajor(wells, batchConcentration, amount)

  getWellsColumnMajor: (wells, batchConcentration, amount) ->
    wellsToUpdate = new WellsModel({allWells: wells})
    rowIndexes = [@selectedRegionBoundries.rowStart..@selectedRegionBoundries.rowStop]
    columnIndexes = [@selectedRegionBoundries.colStart..@selectedRegionBoundries.colStop]
    plateWells = []
    wellContentOverwritten = []
    valueIdx = 0
    identifiersToRemove = []
    _.each(rowIndexes, (rowIdx) =>
      _.each(columnIndexes, (colIdx) =>
        batchCode = @identifiers[valueIdx]
        [wellContentOverwritten, well] = @populateWell(wellsToUpdate, rowIdx, colIdx, batchConcentration, amount, batchCode)
        wellsToUpdate.fillWellWithWellObject(rowIdx, colIdx, well)
        plateWells.push [rowIdx, colIdx, well]
        identifiersToRemove.push @identifiers[valueIdx]
        valueIdx++
      )
    )

    [plateWells, identifiersToRemove, wellsToUpdate, wellContentOverwritten]


  getWellsRowMajor: (wells, batchConcentration, amount) ->
    wellsToUpdate = new WellsModel({allWells: wells})
    rowIndexes = [@selectedRegionBoundries.rowStart..@selectedRegionBoundries.rowStop]
    columnIndexes = [@selectedRegionBoundries.colStart..@selectedRegionBoundries.colStop]
    plateWells = []
    wellContentOverwritten = []
    valueIdx = 0
    identifiersToRemove = []
    _.each(columnIndexes, (colIdx) =>
      _.each(rowIndexes, (rowIdx) =>
        batchCode = @identifiers[valueIdx]
        [wellContentOverwritten, well] = @populateWell(wellsToUpdate, rowIdx, colIdx, batchConcentration, amount, batchCode)
        wellsToUpdate.fillWellWithWellObject(rowIdx, colIdx, well)
        plateWells.push [rowIdx, colIdx, well]
        identifiersToRemove.push @identifiers[valueIdx]
        valueIdx++
      )
    )

    [plateWells, identifiersToRemove, wellsToUpdate, wellContentOverwritten]


module.exports =
  PlateFillerFactory: PlateFillerFactory