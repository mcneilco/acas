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

class RandomPlateFillerStrategy extends PlateFillerStrategy
  getWells: ->
    return {}


class SameIdentifierPlateFillerStrategy extends PlateFillerStrategy
  getWells: (wells, batchConcentration, amount) ->
    wellsToUpdate = new WellsModel({allWells: wells})
    rowIndexes = [@selectedRegionBoundries.rowStart..@selectedRegionBoundries.rowStop]
    columnIndexes = [@selectedRegionBoundries.colStart..@selectedRegionBoundries.colStop]
    plateWells = []
    valueIdx = 0
    identifiersToRemove = []
    _.each(rowIndexes, (rowIdx) =>
      _.each(columnIndexes, (colIdx) =>
#        well =
#          amount: amount
#          batchCode: @identifiers[0]
#          batchConcentration: batchConcentration
#        wellsToUpdate.fillWellWithWellObject(rowIdx, colIdx, well)
        existingWell = wellsToUpdate.getWellAtRowIdxColIdx(rowIdx, colIdx)
        am = amount
        bConc = batchConcentration
        bCode = @identifiers[0]
        if amount is ""
          am = existingWell.amount
        if batchConcentration is ""
          bConc = existingWell.batchConcentration
        if bCode is ""
          bCode = existingWell.batchCode
        well =
          amount: am
          batchCode: bCode
          batchConcentration: bConc

        plateWells.push [rowIdx, colIdx, well]
        identifiersToRemove.push @identifiers[0]

        valueIdx++
      )
    )
    wellsToUpdate.save()

    [plateWells, identifiersToRemove]


class InOrderPlateFillerStrategy extends PlateFillerStrategy
  constructor: (identifiers, selectedRegion, fillDirection) ->
    super(identifiers, selectedRegion)
    @fillDirection = fillDirection

  getWells: (wells, batchConcentration, amount) ->
    if @fillDirection is "columnMajor"
      return @getWellsColumnMajor(wells, batchConcentration, amount)
    else if @fillDirection is "rowMajor"
      return @getWellsRowMajor(wells, batchConcentration, amount)

#    wellsToUpdate = new WellsModel({allWells: wells})
#    rowIndexes = [@selectedRegionBoundries.rowStart..@selectedRegionBoundries.rowStop]
#    columnIndexes = [@selectedRegionBoundries.colStart..@selectedRegionBoundries.colStop]
#    plateWells = []
#    valueIdx = 0
#    identifiersToRemove = []
#    _.each(rowIndexes, (rowIdx) =>
#      _.each(columnIndexes, (colIdx) =>
#        existingWell = wellsToUpdate.getWellAtRowIdxColIdx(rowIdx, colIdx)
#        am = amount
#        bConc = batchConcentration
#        bCode = @identifiers[valueIdx]
#        if amount is ""
#          am = existingWell.amount
#        if batchConcentration is ""
#          bConc = existingWell.batchConcentration
#        if bCode is ""
#          bCode = existingWell.batchCode
#        well =
#          amount: am
#          batchCode: bCode
#          batchConcentration: bConc
#        wellsToUpdate.fillWellWithWellObject(rowIdx, colIdx, well)
#        plateWells.push [rowIdx, colIdx, well]
#        identifiersToRemove.push @identifiers[valueIdx]
#        valueIdx++
#      )
#    )
#    wellsToUpdate.save()
#
#    [plateWells, identifiersToRemove]

  getWellsColumnMajor: (wells, batchConcentration, amount) ->
    wellsToUpdate = new WellsModel({allWells: wells})
    rowIndexes = [@selectedRegionBoundries.rowStart..@selectedRegionBoundries.rowStop]
    columnIndexes = [@selectedRegionBoundries.colStart..@selectedRegionBoundries.colStop]
    plateWells = []
    valueIdx = 0
    identifiersToRemove = []
    _.each(rowIndexes, (rowIdx) =>
      _.each(columnIndexes, (colIdx) =>
        existingWell = wellsToUpdate.getWellAtRowIdxColIdx(rowIdx, colIdx)
        am = amount
        bConc = batchConcentration
        bCode = @identifiers[valueIdx]
        if amount is ""
          am = existingWell.amount
        if batchConcentration is ""
          bConc = existingWell.batchConcentration
        if bCode is ""
          bCode = existingWell.batchCode
        well =
          amount: am
          batchCode: bCode
          batchConcentration: bConc
        wellsToUpdate.fillWellWithWellObject(rowIdx, colIdx, well)
        plateWells.push [rowIdx, colIdx, well]
        identifiersToRemove.push @identifiers[valueIdx]
        valueIdx++
      )
    )
    wellsToUpdate.save()

    [plateWells, identifiersToRemove]


  getWellsRowMajor: (wells, batchConcentration, amount) ->
    wellsToUpdate = new WellsModel({allWells: wells})
    rowIndexes = [@selectedRegionBoundries.rowStart..@selectedRegionBoundries.rowStop]
    columnIndexes = [@selectedRegionBoundries.colStart..@selectedRegionBoundries.colStop]
    plateWells = []
    valueIdx = 0
    identifiersToRemove = []
    _.each(columnIndexes, (colIdx) =>
      _.each(rowIndexes, (rowIdx) =>
        existingWell = wellsToUpdate.getWellAtRowIdxColIdx(rowIdx, colIdx)
        am = amount
        bConc = batchConcentration
        bCode = @identifiers[valueIdx]
        if amount is ""
          am = existingWell.amount
        if batchConcentration is ""
          bConc = existingWell.batchConcentration
        if bCode is ""
          bCode = existingWell.batchCode
        well =
          amount: am
          batchCode: bCode
          batchConcentration: bConc
        wellsToUpdate.fillWellWithWellObject(rowIdx, colIdx, well)
        plateWells.push [rowIdx, colIdx, well]
        identifiersToRemove.push @identifiers[valueIdx]
        valueIdx++
      )
    )
    wellsToUpdate.save()

    [plateWells, identifiersToRemove]


module.exports =
  PlateFillerFactory: PlateFillerFactory