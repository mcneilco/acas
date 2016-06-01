WellsModel = require('./WellModel.coffee').WellsModel

PLATE_FILLER_STRATEGY_TYPES =
  RANDOM: 'random'
  IN_ORDER: 'inOrder'
  SAME_IDENTIFIER: 'sameIdentifier'
  CHECKER_BOARD_1: 'checkerBoard1'
  CHECKER_BOARD_2: 'checkerBoard2'
  ALL_EMPTY: 'fillAllEmptyWells'

CHECKER_BOARD_WIDTH = 4
CHECKER_BOARD_HEIGHT = 2

class PlateFillerFactory
  getPlateFiller: (strategy, fillDirection, identifiers, selectedRegion, plateMetaData) ->
    plateFiller = null
    switch strategy
      when PLATE_FILLER_STRATEGY_TYPES.IN_ORDER then plateFiller = new InOrderPlateFillerStrategy(identifiers, selectedRegion, fillDirection, plateMetaData)
      when PLATE_FILLER_STRATEGY_TYPES.RANDOM then plateFiller = new RandomPlateFillerStrategy(identifiers, selectedRegion, plateMetaData)
      when PLATE_FILLER_STRATEGY_TYPES.SAME_IDENTIFIER then plateFiller = new SameIdentifierPlateFillerStrategy(identifiers, selectedRegion, plateMetaData)
      when PLATE_FILLER_STRATEGY_TYPES.CHECKER_BOARD_1 then plateFiller = new CheckerBoard1PlateFillerStrategy(identifiers, selectedRegion, plateMetaData)
      when PLATE_FILLER_STRATEGY_TYPES.CHECKER_BOARD_2 then plateFiller = new CheckerBoard2PlateFillerStrategy(identifiers, selectedRegion, plateMetaData)
      when PLATE_FILLER_STRATEGY_TYPES.ALL_EMPTY then plateFiller = new FillAllEmptyPlateFillerStrategy(identifiers, selectedRegion, plateMetaData)


    plateFiller


class PlateFillerStrategy
  constructor: (identifiers, selectedRegionBoundries, plateMetaData) ->
    @identifiers = identifiers
    @selectedRegionBoundries = selectedRegionBoundries
    @plateMetaData = plateMetaData

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
    wellsToUpdate.resetWells()
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
    wellsToUpdate.resetWells()
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
    wellsToUpdate.resetWells()
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
    wellsToUpdate.resetWells()
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


class CheckerBoard1PlateFillerStrategy extends PlateFillerStrategy
  getWells: (wells, batchConcentration, amount) ->
    wellsToUpdate = new WellsModel({allWells: wells})
    wellsToUpdate.resetWells()
    rowIndexes = [@selectedRegionBoundries.rowStart..@selectedRegionBoundries.rowStop]
    columnIndexes = [@selectedRegionBoundries.colStart..@selectedRegionBoundries.colStop]
    plateWells = []
    wellContentOverwritten = []
    valueIdx = 0
    identifiersToRemove = []

    numberOfHorizontalCheckers = parseInt(_.size(columnIndexes) / CHECKER_BOARD_WIDTH)
    numberOfVerticalCheckers = parseInt(_.size(rowIndexes) / CHECKER_BOARD_HEIGHT)

    checkerRowIndexes = [0..numberOfVerticalCheckers]
    checkerColIndexes = [0..numberOfHorizontalCheckers]
    rowIsEven = true
    _.each(checkerRowIndexes, (rowIdx) =>
      if (rowIdx % 2) is 0
        rowIsEven = true
      else
        rowIsEven = false
      _.each(checkerColIndexes, (colIdx) =>
        offsetRowIdx = (rowIdx * CHECKER_BOARD_HEIGHT) + @selectedRegionBoundries.rowStart
        offsetColIdx = (colIdx * CHECKER_BOARD_WIDTH) + @selectedRegionBoundries.colStart
        unless rowIsEven
          offsetColIdx = offsetColIdx + 2
        batchCode = @identifiers[0]

        if (offsetRowIdx <= @selectedRegionBoundries.rowStop) and (offsetColIdx <= @selectedRegionBoundries.colStop)
          [wco, well] = @populateWell(wellsToUpdate, offsetRowIdx, offsetColIdx, batchConcentration, amount, batchCode)
          plateWells.push [offsetRowIdx, offsetColIdx, well]
          wellsToUpdate.fillWellWithWellObject(offsetRowIdx, offsetColIdx, well)
          if wco
            wellContentOverwritten = wellContentOverwritten.concat(wco)

        if ((offsetRowIdx + 1) <= @selectedRegionBoundries.rowStop) and (offsetColIdx <= @selectedRegionBoundries.colStop)
          [wco, well] = @populateWell(wellsToUpdate, offsetRowIdx + 1, offsetColIdx, batchConcentration, amount, batchCode)
          plateWells.push [offsetRowIdx + 1, offsetColIdx, well]
          wellsToUpdate.fillWellWithWellObject((offsetRowIdx + 1), offsetColIdx, well)
          if wco
            wellContentOverwritten = wellContentOverwritten.concat(wco)

        if (offsetColIdx + 1) <= @selectedRegionBoundries.colStop  and (offsetRowIdx <= @selectedRegionBoundries.rowStop)
          [wco, well] = @populateWell(wellsToUpdate, offsetRowIdx, offsetColIdx + 1, batchConcentration, amount, batchCode)
          plateWells.push [offsetRowIdx, offsetColIdx + 1, well]
          wellsToUpdate.fillWellWithWellObject(offsetRowIdx, (offsetColIdx + 1), well)
          if wco
            wellContentOverwritten = wellContentOverwritten.concat(wco)

        if ((offsetColIdx + 1) <= @selectedRegionBoundries.colStop) and ((offsetRowIdx + 1) <= @selectedRegionBoundries.rowStop)
          [wco, well] = @populateWell(wellsToUpdate, offsetRowIdx + 1, offsetColIdx + 1, batchConcentration, amount, batchCode)
          plateWells.push [offsetRowIdx + 1, offsetColIdx + 1, well]
          wellsToUpdate.fillWellWithWellObject((offsetRowIdx + 1), (offsetColIdx + 1), well)
          if wco
            wellContentOverwritten = wellContentOverwritten.concat(wco)

        identifiersToRemove.push @identifiers[0]

        valueIdx++
      )

    )
    if _.size(wellContentOverwritten) is 0
      wellContentOverwritten = null
    [plateWells, identifiersToRemove, wellsToUpdate, wellContentOverwritten]

class CheckerBoard2PlateFillerStrategy extends PlateFillerStrategy
  getWells: (wells, batchConcentration, amount) ->
    wellsToUpdate = new WellsModel({allWells: wells})
    wellsToUpdate.resetWells()
    rowIndexes = [@selectedRegionBoundries.rowStart..@selectedRegionBoundries.rowStop]
    columnIndexes = [@selectedRegionBoundries.colStart..@selectedRegionBoundries.colStop]
    plateWells = []
    wellContentOverwritten = []
    valueIdx = 0
    identifiersToRemove = []

    numberOfHorizontalCheckers = parseInt(_.size(columnIndexes) / CHECKER_BOARD_WIDTH)
    numberOfVerticalCheckers = parseInt(_.size(rowIndexes) / CHECKER_BOARD_HEIGHT)

    checkerRowIndexes = [0..numberOfVerticalCheckers]
    checkerColIndexes = [0..numberOfHorizontalCheckers]
    rowIsEven = true
    _.each(checkerRowIndexes, (rowIdx) =>
      if (rowIdx % 2) is 0
        rowIsEven = true
      else
        rowIsEven = false
      _.each(checkerColIndexes, (colIdx) =>
        offsetRowIdx = (rowIdx * CHECKER_BOARD_HEIGHT) + @selectedRegionBoundries.rowStart
        offsetColIdx = (colIdx * CHECKER_BOARD_WIDTH) + @selectedRegionBoundries.colStart
        if rowIsEven
          offsetColIdx = offsetColIdx + 2
        batchCode = @identifiers[0]


        if (offsetRowIdx <= @selectedRegionBoundries.rowStop) and (offsetColIdx <= @selectedRegionBoundries.colStop)
          [wco, well] = @populateWell(wellsToUpdate, offsetRowIdx, offsetColIdx, batchConcentration, amount, batchCode)
          plateWells.push [offsetRowIdx, offsetColIdx, well]
          wellsToUpdate.fillWellWithWellObject(offsetRowIdx, offsetColIdx, well)
          if wco
            wellContentOverwritten = wellContentOverwritten.concat(wco)

        if ((offsetRowIdx + 1) <= @selectedRegionBoundries.rowStop) and (offsetColIdx <= @selectedRegionBoundries.colStop)
          [wco, well] = @populateWell(wellsToUpdate, offsetRowIdx + 1, offsetColIdx, batchConcentration, amount, batchCode)
          plateWells.push [offsetRowIdx + 1, offsetColIdx, well]
          wellsToUpdate.fillWellWithWellObject((offsetRowIdx + 1), offsetColIdx, well)
          if wco
            wellContentOverwritten = wellContentOverwritten.concat(wco)

        if (offsetColIdx + 1) <= @selectedRegionBoundries.colStop  and (offsetRowIdx <= @selectedRegionBoundries.rowStop)
          [wco, well] = @populateWell(wellsToUpdate, offsetRowIdx, offsetColIdx + 1, batchConcentration, amount, batchCode)
          plateWells.push [offsetRowIdx, offsetColIdx + 1, well]
          wellsToUpdate.fillWellWithWellObject(offsetRowIdx, (offsetColIdx + 1), well)
          if wco
            wellContentOverwritten = wellContentOverwritten.concat(wco)

        if ((offsetColIdx + 1) <= @selectedRegionBoundries.colStop) and ((offsetRowIdx + 1) <= @selectedRegionBoundries.rowStop)
          [wco, well] = @populateWell(wellsToUpdate, offsetRowIdx + 1, offsetColIdx + 1, batchConcentration, amount, batchCode)
          plateWells.push [offsetRowIdx + 1, offsetColIdx + 1, well]
          wellsToUpdate.fillWellWithWellObject((offsetRowIdx + 1), (offsetColIdx + 1), well)
          if wco
            wellContentOverwritten = wellContentOverwritten.concat(wco)

        identifiersToRemove.push @identifiers[0]

        valueIdx++
      )

    )
    if _.size(wellContentOverwritten) is 0
      wellContentOverwritten = null
    [plateWells, identifiersToRemove, wellsToUpdate, wellContentOverwritten]

class FillAllEmptyPlateFillerStrategy extends PlateFillerStrategy
  getWells: (wells, batchConcentration, amount) ->
    wellsToUpdate = new WellsModel({allWells: wells})
    wellsToUpdate.resetWells()
    rowIndexes = [0..(@plateMetaData.numberOfRows - 1)]
    columnIndexes = [0..(@plateMetaData.numberOfColumns - 1)]
    plateWells = []
    wellContentOverwritten = []
    identifiersToRemove = []
    batchCode = @identifiers[0]
    _.each(rowIndexes, (rowIdx) =>
      _.each(columnIndexes, (colIdx) =>
        if wellsToUpdate.isWellAtRowIdxColIdxEmpty(rowIdx, colIdx)
          [wco, well] = @populateWell(wellsToUpdate, rowIdx, colIdx, batchConcentration, amount, batchCode)
          plateWells.push [rowIdx, colIdx, well]
          wellsToUpdate.fillWellWithWellObject(rowIdx, colIdx, well)

      )

    )
    identifiersToRemove.push @identifiers[0]
    if _.size(wellContentOverwritten) is 0
      wellContentOverwritten = null
    [plateWells, identifiersToRemove, wellsToUpdate, wellContentOverwritten]


module.exports =
  PlateFillerFactory: PlateFillerFactory