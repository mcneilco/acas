
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


class SameIdentifierPlateFillerStrategy extends PlateFillerStrategy


  getWells: (wells, batchConcentration, amount) ->
    wellsToUpdate = []
    rowIndexes = [@selectedRegionBoundries.rowStart..@selectedRegionBoundries.rowStop]
    columnIndexes = [@selectedRegionBoundries.colStart..@selectedRegionBoundries.colStop]
    plateWells = []
    valueIdx = 0
    identifiersToRemove = []
    _.each(rowIndexes, (rowIdx) =>
      _.each(columnIndexes, (colIdx) =>
        plateWells.push [rowIdx, colIdx, @identifiers[0]]
        identifiersToRemove.push @identifiers[0]
        well = _.find(wells, (w) ->
          if w.columnIndex is colIdx and w.rowIndex is rowIdx
            return true
          else
            return false
        )
        console.log "well"
        console.log well
        well.amount = amount
        well.amountUnits = "uL"
        well.batchCode = @identifiers[0]
        well.batchConcentration = batchConcentration
        recordedDate = new Date()
        well.recordedDate = recordedDate.getTime()
        wellsToUpdate.push well
        valueIdx++
      )
    )
    console.log "wellsToUpdate"
    console.log wellsToUpdate
    $.ajax(
      data: JSON.stringify({wells: wellsToUpdate})
      dataType: "json"
      method: "POST"
      url: '/api/updateWellStatus '
    )
    .done((data, textStatus, jqXHR) =>
      console.log "saved / updated wells... ?"
    )
    .fail((jqXHR, textStatus, errorThrown) =>
      console.error("error")
    )

    console.log "updated wells?"
    console.log wells
    window.FOOWELLS = wells

    [plateWells, identifiersToRemove]


class InOrderPlateFillerStrategy extends PlateFillerStrategy
  getWells: ->
    rowIndexes = [@selectedRegionBoundries.rowStart..@selectedRegionBoundries.rowStop]
    columnIndexes = [@selectedRegionBoundries.colStart..@selectedRegionBoundries.colStop]
    plateWells = []
    valueIdx = 0
    identifiersToRemove = []
    _.each(rowIndexes, (rowIdx) =>
      _.each(columnIndexes, (colIdx) =>
        plateWells.push [rowIdx, colIdx, @identifiers[valueIdx]]
        identifiersToRemove.push @identifiers[valueIdx]
        valueIdx++
      )
    )

    [plateWells, identifiersToRemove]

module.exports =
  PlateFillerFactory: PlateFillerFactory