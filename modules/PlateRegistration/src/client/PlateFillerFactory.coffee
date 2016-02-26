
PLATE_FILLER_STRATEGY_TYPES =
  RANDOM: 'random'
  IN_ORDER: 'inOrder'
  SAME_IDENTIFIER: 'sameIdentifier'

class PlateFillerFactory
  getPlateFiller: (strategy, identifiers, selectedRegion) ->
    plateFiller = null
    switch strategy
      when PLATE_FILLER_STRATEGY_TYPES.IN_ORDER then plateFiller = new InOrderPlateFillerStrategy(identifiers, selectedRegion)
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

class WellsModel extends Backbone.Model
  url: '/api/updateWellStatus'
  initialize: (options) ->
    @allWells = options.allWells
  defaults:
    'wells': []

  fillWell: (rowIndex, columnIndex, amount, batchCode, batchConcentration) ->
    well = _.find(@allWells, (w) ->
      if w.columnIndex is columnIndex and w.rowIndex is rowIndex
        return true
      else
        return false
    )
    well.amount = amount
    well.amountUnits = "uL"
    well.batchCode = batchCode
    well.batchConcentration = batchConcentration
    recordedDate = new Date()
    well.recordedDate = recordedDate.getTime()
    @get("wells").push well


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
        plateWells.push [rowIdx, colIdx, @identifiers[0]]
        identifiersToRemove.push @identifiers[0]
        wellsToUpdate.fillWell(rowIdx, colIdx, amount, @identifiers[0], batchConcentration)

        valueIdx++
      )
    )
    wellsToUpdate.save()

    [plateWells, identifiersToRemove]


class InOrderPlateFillerStrategy extends PlateFillerStrategy
  getWells: (wells, batchConcentration, amount) ->
    wellsToUpdate = new WellsModel({allWells: wells})
    rowIndexes = [@selectedRegionBoundries.rowStart..@selectedRegionBoundries.rowStop]
    columnIndexes = [@selectedRegionBoundries.colStart..@selectedRegionBoundries.colStop]
    plateWells = []
    valueIdx = 0
    identifiersToRemove = []
    _.each(rowIndexes, (rowIdx) =>
      _.each(columnIndexes, (colIdx) =>
        plateWells.push [rowIdx, colIdx, @identifiers[valueIdx]]
        identifiersToRemove.push @identifiers[valueIdx]
        wellsToUpdate.fillWell(rowIdx, colIdx, amount, @identifiers[valueIdx], batchConcentration)
        valueIdx++
      )
    )
    wellsToUpdate.save()

    [plateWells, identifiersToRemove]


module.exports =
  PlateFillerFactory: PlateFillerFactory