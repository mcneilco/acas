SERIAL_DILUTION_MODEL_FIELDS = require('./SerialDilutionModel.coffee').SERIAL_DILUTION_MODEL_FIELDS
SIGNIFICANT_FIGS = 4
WellsModel = require('./WellModel.coffee').WellsModel

class SerialDilutionFactory
  getSerialDilutionStrategy: (serialDilutionModel, selectedRegion) ->
    console.log "SerialDilutionFactory serialDilutionModel"
    console.log serialDilutionModel
    if serialDilutionModel.get(SERIAL_DILUTION_MODEL_FIELDS.IS_DILUTION_BY_VOLUME)
      if serialDilutionModel.get(SERIAL_DILUTION_MODEL_FIELDS.DIRECTION) is "diluteRight"
        return new DiluteByVolumeRight(serialDilutionModel.get(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_DOSES), serialDilutionModel.get(SERIAL_DILUTION_MODEL_FIELDS.DESTINATION_WELL_VOLUME), serialDilutionModel.get(SERIAL_DILUTION_MODEL_FIELDS.TRANSFER_VOLUME), selectedRegion)
      else if serialDilutionModel.get(SERIAL_DILUTION_MODEL_FIELDS.DIRECTION) is "diluteUp"
        return new DiluteByVolumeUp(serialDilutionModel.get(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_DOSES), serialDilutionModel.get(SERIAL_DILUTION_MODEL_FIELDS.DESTINATION_WELL_VOLUME), serialDilutionModel.get(SERIAL_DILUTION_MODEL_FIELDS.TRANSFER_VOLUME), selectedRegion)
      else if serialDilutionModel.get(SERIAL_DILUTION_MODEL_FIELDS.DIRECTION) is "diluteLeft"
        return new DiluteByVolumeLeft(serialDilutionModel.get(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_DOSES), serialDilutionModel.get(SERIAL_DILUTION_MODEL_FIELDS.DESTINATION_WELL_VOLUME), serialDilutionModel.get(SERIAL_DILUTION_MODEL_FIELDS.TRANSFER_VOLUME), selectedRegion)
      else if serialDilutionModel.get(SERIAL_DILUTION_MODEL_FIELDS.DIRECTION) is "diluteDown"
        return new DiluteByVolumeDown(serialDilutionModel.get(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_DOSES), serialDilutionModel.get(SERIAL_DILUTION_MODEL_FIELDS.DESTINATION_WELL_VOLUME), serialDilutionModel.get(SERIAL_DILUTION_MODEL_FIELDS.TRANSFER_VOLUME), selectedRegion)
    else
      if serialDilutionModel.get(SERIAL_DILUTION_MODEL_FIELDS.DIRECTION) is "diluteRight"
        return new DiluteByDilutionFactorRight(serialDilutionModel.get(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_DOSES), serialDilutionModel.get(SERIAL_DILUTION_MODEL_FIELDS.DILUTION_FACTOR), selectedRegion)
      else if serialDilutionModel.get(SERIAL_DILUTION_MODEL_FIELDS.DIRECTION) is "diluteUp"
        return new DiluteByDilutionFactorUp(serialDilutionModel.get(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_DOSES), serialDilutionModel.get(SERIAL_DILUTION_MODEL_FIELDS.DILUTION_FACTOR), selectedRegion)
      else if serialDilutionModel.get(SERIAL_DILUTION_MODEL_FIELDS.DIRECTION) is "diluteLeft"
        return new DiluteByDilutionFactorLeft(serialDilutionModel.get(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_DOSES), serialDilutionModel.get(SERIAL_DILUTION_MODEL_FIELDS.DILUTION_FACTOR), selectedRegion)
      else if serialDilutionModel.get(SERIAL_DILUTION_MODEL_FIELDS.DIRECTION) is "diluteDown"
        return new DiluteByDilutionFactorDown(serialDilutionModel.get(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_DOSES), serialDilutionModel.get(SERIAL_DILUTION_MODEL_FIELDS.DILUTION_FACTOR), selectedRegion)

class DilutionStrategy
  constructor: (numberOfDoses, selectedRegion) ->
    @numberOfDoses = numberOfDoses
    @selectedRegion = selectedRegion

class SerialDilutionByVolume extends DilutionStrategy
  constructor: (numberOfDoses, destinationWellVolume, transferVolume, selectedRegion) ->
    super(numberOfDoses, selectedRegion)
    @destinationWellVolume = parseFloat(destinationWellVolume)
    @transferVolume = parseFloat(transferVolume)
    @selectedRegion = selectedRegion

  getConcentration: (previousConcentration) =>
    wellBatchConcentration = (previousConcentration * @transferVolume) / (@destinationWellVolume + @transferVolume)
    # record only SIGNIFICANT_FIGS of precision
    wellBatchConcentration = parseFloat(wellBatchConcentration.toFixed(SIGNIFICANT_FIGS))
    return wellBatchConcentration

class DiluteByVolumeRight extends SerialDilutionByVolume
  constructor: (numberOfDoses, destinationWellVolume, transferVolume, selectedRegion) ->
    console.log "DiluteByVolumeRight"
    super(numberOfDoses, destinationWellVolume, transferVolume, selectedRegion)
    @startingRowIdexes = [selectedRegion.rowStart..selectedRegion.rowStop]
    @secondColIdx = selectedRegion.colStart + 1
    @lastColIdx = (selectedRegion.colStart + numberOfDoses) - 1
    @colIdxs = [@secondColIdx..@lastColIdx]

  getWells: (wells) =>
    @wellsToUpdate = new WellsModel({allWells: wells})
    plateWells = []
    for rowIdx in @startingRowIdexes
      startingCell = @wellsToUpdate.getWellAtRowIdxColIdx(rowIdx, @selectedRegion.colStart)
      previousConcentration = parseFloat(startingCell.batchConcentration)
      for colIdx in @colIdxs
        concentration = @getConcentration(previousConcentration)
        previousConcentration = concentration
        well = {}
        unless colIdx is @lastColIdx
          well =
            amount: @destinationWellVolume
            batchCode: startingCell.batchCode
            batchConcentration: concentration
        else
          finalVolume = @transferVolume + @destinationWellVolume
          well =
            amount: finalVolume
            batchCode: startingCell.batchCode
            batchConcentration: concentration
        @wellsToUpdate.fillWellWithWellObject(rowIdx, colIdx, well)
        plateWells.push [rowIdx, colIdx, well]

      initialWellUpdatedAmount = startingCell.amount - @transferVolume
      initialWellUpdatedAmount = parseFloat(initialWellUpdatedAmount.toFixed(SIGNIFICANT_FIGS))
      well =
        amount: initialWellUpdatedAmount
        batchCode: startingCell.batchCode
        batchConcentration: startingCell.batchConcentration
      plateWells.push [rowIdx, @selectedRegion.colStart, well]
      @wellsToUpdate.fillWellWithWellObject(rowIdx, @selectedRegion.colStart, well)

    @wellsToUpdate.save()
    return plateWells

class DiluteByVolumeLeft extends SerialDilutionByVolume
  constructor: (numberOfDoses, destinationWellVolume, transferVolume, selectedRegion) ->
    console.log "DiluteByVolumeLeft"
    super(numberOfDoses, destinationWellVolume, transferVolume, selectedRegion)
    @startingRowIdexes = [selectedRegion.rowStart..selectedRegion.rowStop]
    @secondColIdx = selectedRegion.colStart - 1
    @lastColIdx = (selectedRegion.colStart - numberOfDoses) + 1
    @colIdxs = [@secondColIdx..@lastColIdx]

  getWells: (wells) =>
    @wellsToUpdate = new WellsModel({allWells: wells})
    plateWells = []
    for rowIdx in @startingRowIdexes
      startingCell = @wellsToUpdate.getWellAtRowIdxColIdx(rowIdx, @selectedRegion.colStart)
      previousConcentration = parseFloat(startingCell.batchConcentration)
      for colIdx in @colIdxs
        concentration = @getConcentration(previousConcentration)
        previousConcentration = concentration
        well = {}
        unless colIdx is @lastColIdx
          well =
            amount: @destinationWellVolume
            batchCode: startingCell.batchCode
            batchConcentration: concentration
        else
          finalVolume = @transferVolume + @destinationWellVolume
          well =
            amount: finalVolume
            batchCode: startingCell.batchCode
            batchConcentration: concentration
        @wellsToUpdate.fillWellWithWellObject(rowIdx, colIdx, well)
        plateWells.push [rowIdx, colIdx, well]

      initialWellUpdatedAmount = startingCell.amount - @transferVolume
      initialWellUpdatedAmount = parseFloat(initialWellUpdatedAmount.toFixed(SIGNIFICANT_FIGS))
      well =
        amount: initialWellUpdatedAmount
        batchCode: startingCell.batchCode
        batchConcentration: startingCell.batchConcentration
      plateWells.push [rowIdx, @selectedRegion.colStart, well]
      @wellsToUpdate.fillWellWithWellObject(rowIdx, @selectedRegion.colStart, well)

    @wellsToUpdate.save()
    return plateWells

class DiluteByVolumeUp extends SerialDilutionByVolume
  constructor: (numberOfDoses, destinationWellVolume, transferVolume, selectedRegion) ->
    console.log "DiluteByVolumeUp"
    super(numberOfDoses, destinationWellVolume, transferVolume, selectedRegion)
    @startingColIdexes = [selectedRegion.colStart..selectedRegion.colStop]
    @secondRowIdx = selectedRegion.rowStart - 1
    @lastRowIdx = (selectedRegion.rowStart - numberOfDoses) + 1
    @rowIdxs = [@secondRowIdx..@lastRowIdx]

  getWells: (wells) =>
    @wellsToUpdate = new WellsModel({allWells: wells})
    plateWells = []
    _.each(@startingColIdexes, (colIdx) =>
      startingCell = @wellsToUpdate.getWellAtRowIdxColIdx(@selectedRegion.rowStart, colIdx)
      previousConcentration = parseFloat(startingCell.batchConcentration)
      _.each(@rowIdxs, (rowIdx) =>
        concentration = @getConcentration(previousConcentration)
        previousConcentration = concentration
        well = {}
        unless rowIdx is @lastRowIdx
          well =
            amount: @destinationWellVolume
            batchCode: startingCell.batchCode
            batchConcentration: concentration
        else
          finalVolume = @transferVolume + @destinationWellVolume
          well =
            amount: finalVolume
            batchCode: startingCell.batchCode
            batchConcentration: concentration
        @wellsToUpdate.fillWellWithWellObject(rowIdx, colIdx, well)
        plateWells.push [rowIdx, colIdx, well]
      )
      initialWellUpdatedAmount = startingCell.amount - @transferVolume
      initialWellUpdatedAmount = parseFloat(initialWellUpdatedAmount.toFixed(SIGNIFICANT_FIGS))
      well =
        amount: initialWellUpdatedAmount
        batchCode: startingCell.batchCode
        batchConcentration: startingCell.batchConcentration
      plateWells.push [@selectedRegion.rowStart, colIdx, well]
      @wellsToUpdate.fillWellWithWellObject(@selectedRegion.rowStart, colIdx, well)
    )

    @wellsToUpdate.save()
    return plateWells

class DiluteByVolumeDown extends SerialDilutionByVolume
  constructor: (numberOfDoses, destinationWellVolume, transferVolume, selectedRegion) ->
    console.log "DiluteByVolumeUp"
    super(numberOfDoses, destinationWellVolume, transferVolume, selectedRegion)
    @startingColIdexes = [selectedRegion.colStart..selectedRegion.colStop]
    @secondRowIdx = selectedRegion.rowStart + 1
    @lastRowIdx = (selectedRegion.rowStart + numberOfDoses) - 1
    @rowIdxs = [@secondRowIdx..@lastRowIdx]

  getWells: (wells) =>
    @wellsToUpdate = new WellsModel({allWells: wells})
    plateWells = []
    _.each(@startingColIdexes, (colIdx) =>
      startingCell = @wellsToUpdate.getWellAtRowIdxColIdx(@selectedRegion.rowStart, colIdx)
      previousConcentration = parseFloat(startingCell.batchConcentration)
      _.each(@rowIdxs, (rowIdx) =>
        concentration = @getConcentration(previousConcentration)
        previousConcentration = concentration
        well = {}
        unless rowIdx is @lastRowIdx
          well =
            amount: @destinationWellVolume
            batchCode: startingCell.batchCode
            batchConcentration: concentration
        else
          finalVolume = @transferVolume + @destinationWellVolume
          well =
            amount: finalVolume
            batchCode: startingCell.batchCode
            batchConcentration: concentration
        @wellsToUpdate.fillWellWithWellObject(rowIdx, colIdx, well)
        plateWells.push [rowIdx, colIdx, well]
      )
      initialWellUpdatedAmount = startingCell.amount - @transferVolume
      initialWellUpdatedAmount = parseFloat(initialWellUpdatedAmount.toFixed(SIGNIFICANT_FIGS))
      well =
        amount: initialWellUpdatedAmount
        batchCode: startingCell.batchCode
        batchConcentration: startingCell.batchConcentration
      plateWells.push [@selectedRegion.rowStart, colIdx, well]
      @wellsToUpdate.fillWellWithWellObject(@selectedRegion.rowStart, colIdx, well)
    )


    @wellsToUpdate.save()
    return plateWells

class SerialDilutionByDilutionFactor extends DilutionStrategy
  constructor: (numberOfDoses, dilutionFactor, selectedRegion) ->
    super(numberOfDoses, selectedRegion)
    @dilutionFactor = parseFloat(dilutionFactor)
    @selectedRegion = selectedRegion

  getConcentration: (previousConcentration) =>
    wellBatchConcentration = previousConcentration / @dilutionFactor
    # record only SIGNIFICANT_FIGS of precision
    wellBatchConcentration = parseFloat(wellBatchConcentration.toFixed(SIGNIFICANT_FIGS))
    return wellBatchConcentration

class DiluteByDilutionFactorRight extends SerialDilutionByDilutionFactor
  constructor: (numberOfDoses, dilutionFactor, selectedRegion) ->
    console.log "DiluteByDilutionFactorRight"
    super(numberOfDoses, dilutionFactor, selectedRegion)
    @startingRowIdexes = [selectedRegion.rowStart..selectedRegion.rowStop]
    @secondColIdx = selectedRegion.colStart + 1
    @lastColIdx = (selectedRegion.colStart + numberOfDoses) - 1
    @colIdxs = [@secondColIdx..@lastColIdx]

  getWells: (wells) =>
    @wellsToUpdate = new WellsModel({allWells: wells})
    plateWells = []
    for rowIdx in @startingRowIdexes
      startingCell = @wellsToUpdate.getWellAtRowIdxColIdx(rowIdx, @selectedRegion.colStart)
      previousConcentration = parseFloat(startingCell.batchConcentration)
      volume = (startingCell.amount - (startingCell.amount / @dilutionFactor))
      volume = parseFloat(volume.toFixed(SIGNIFICANT_FIGS))

      for colIdx in @colIdxs
        concentration = @getConcentration(previousConcentration)
        previousConcentration = concentration
        well = {}
        unless colIdx is @lastColIdx
          well =
            amount: volume
            batchCode: startingCell.batchCode
            batchConcentration: concentration
        else
          finalVolume = startingCell.amount
          well =
            amount: finalVolume
            batchCode: startingCell.batchCode
            batchConcentration: concentration
        @wellsToUpdate.fillWellWithWellObject(rowIdx, colIdx, well)
        plateWells.push [rowIdx, colIdx, well]

      initialWellUpdatedAmount = volume
      well =
        amount: initialWellUpdatedAmount
        batchCode: startingCell.batchCode
        batchConcentration: startingCell.batchConcentration
      plateWells.push [rowIdx, @selectedRegion.colStart, well]
      @wellsToUpdate.fillWellWithWellObject(rowIdx, @selectedRegion.colStart, well)

    @wellsToUpdate.save()
    return plateWells

class DiluteByDilutionFactorLeft extends SerialDilutionByDilutionFactor
  constructor: (numberOfDoses, dilutionFactor, selectedRegion) ->
    console.log "DiluteByDilutionFactorRight"
    super(numberOfDoses, dilutionFactor, selectedRegion)
    @startingRowIdexes = [selectedRegion.rowStart..selectedRegion.rowStop]
    @secondColIdx = selectedRegion.colStart - 1
    @lastColIdx = (selectedRegion.colStart - numberOfDoses) + 1
    @colIdxs = [@secondColIdx..@lastColIdx]

  getWells: (wells) =>
    @wellsToUpdate = new WellsModel({allWells: wells})
    plateWells = []
    for rowIdx in @startingRowIdexes
      startingCell = @wellsToUpdate.getWellAtRowIdxColIdx(rowIdx, @selectedRegion.colStart)
      previousConcentration = parseFloat(startingCell.batchConcentration)
      volume = (startingCell.amount - (startingCell.amount / @dilutionFactor))
      volume = parseFloat(volume.toFixed(SIGNIFICANT_FIGS))
      for colIdx in @colIdxs
        concentration = @getConcentration(previousConcentration)
        previousConcentration = concentration
        well = {}
        unless colIdx is @lastColIdx
          well =
            amount: volume
            batchCode: startingCell.batchCode
            batchConcentration: concentration
        else
          finalVolume = startingCell.amount
          well =
            amount: finalVolume
            batchCode: startingCell.batchCode
            batchConcentration: concentration
        @wellsToUpdate.fillWellWithWellObject(rowIdx, colIdx, well)
        plateWells.push [rowIdx, colIdx, well]

      initialWellUpdatedAmount = volume
      well =
        amount: initialWellUpdatedAmount
        batchCode: startingCell.batchCode
        batchConcentration: startingCell.batchConcentration
      plateWells.push [rowIdx, @selectedRegion.colStart, well]
      @wellsToUpdate.fillWellWithWellObject(rowIdx, @selectedRegion.colStart, well)

    @wellsToUpdate.save()
    return plateWells

class DiluteByDilutionFactorDown extends SerialDilutionByDilutionFactor
  constructor: (numberOfDoses, dilutionFactor, selectedRegion) ->
    console.log "DiluteByDilutionFactorDown"
    super(numberOfDoses, dilutionFactor, selectedRegion)
    @startingColIdexes = [selectedRegion.colStart..selectedRegion.colStop]
    @secondRowIdx = selectedRegion.rowStart + 1
    @lastRowIdx = (selectedRegion.rowStart + numberOfDoses) - 1
    @rowIdxs = [@secondRowIdx..@lastRowIdx]

  getWells: (wells) =>
    @wellsToUpdate = new WellsModel({allWells: wells})
    plateWells = []
    _.each(@startingColIdexes, (colIdx) =>
      startingCell = @wellsToUpdate.getWellAtRowIdxColIdx(@selectedRegion.rowStart, colIdx)
      previousConcentration = parseFloat(startingCell.batchConcentration)
      volume = (startingCell.amount - (startingCell.amount / @dilutionFactor))
      volume = parseFloat(volume.toFixed(SIGNIFICANT_FIGS))
      _.each(@rowIdxs, (rowIdx) =>
        concentration = @getConcentration(previousConcentration)
        previousConcentration = concentration
        well = {}
        unless rowIdx is @lastRowIdx
          well =
            amount: volume
            batchCode: startingCell.batchCode
            batchConcentration: concentration
        else
          finalVolume = startingCell.amount
          well =
            amount: finalVolume
            batchCode: startingCell.batchCode
            batchConcentration: concentration
        @wellsToUpdate.fillWellWithWellObject(rowIdx, colIdx, well)
        plateWells.push [rowIdx, colIdx, well]
      )
      initialWellUpdatedAmount = volume
      well =
        amount: initialWellUpdatedAmount
        batchCode: startingCell.batchCode
        batchConcentration: startingCell.batchConcentration
      plateWells.push [@selectedRegion.rowStart, colIdx, well]
      @wellsToUpdate.fillWellWithWellObject(@selectedRegion.rowStart, colIdx, well)
    )

    @wellsToUpdate.save()
    return plateWells

class DiluteByDilutionFactorUp extends SerialDilutionByDilutionFactor
  constructor: (numberOfDoses, dilutionFactor, selectedRegion) ->
    super(numberOfDoses, dilutionFactor, selectedRegion)
    @startingColIdexes = [selectedRegion.colStart..selectedRegion.colStop]
    @secondRowIdx = selectedRegion.rowStart - 1
    @lastRowIdx = (selectedRegion.rowStart - numberOfDoses) + 1
    @rowIdxs = [@secondRowIdx..@lastRowIdx]

  getWells: (wells) =>
    @wellsToUpdate = new WellsModel({allWells: wells})
    plateWells = []
    _.each(@startingColIdexes, (colIdx) =>
      startingCell = @wellsToUpdate.getWellAtRowIdxColIdx(@selectedRegion.rowStart, colIdx)
      previousConcentration = parseFloat(startingCell.batchConcentration)
      volume = (startingCell.amount - (startingCell.amount / @dilutionFactor))
      volume = parseFloat(volume.toFixed(SIGNIFICANT_FIGS))
      _.each(@rowIdxs, (rowIdx) =>
        concentration = @getConcentration(previousConcentration)
        previousConcentration = concentration
        well = {}
        unless rowIdx is @lastRowIdx
          well =
            amount: volume
            batchCode: startingCell.batchCode
            batchConcentration: concentration
        else
          finalVolume = startingCell.amount
          well =
            amount: finalVolume
            batchCode: startingCell.batchCode
            batchConcentration: concentration
        @wellsToUpdate.fillWellWithWellObject(rowIdx, colIdx, well)
        plateWells.push [rowIdx, colIdx, well]
      )
      initialWellUpdatedAmount = volume
      well =
        amount: initialWellUpdatedAmount
        batchCode: startingCell.batchCode
        batchConcentration: startingCell.batchConcentration
      plateWells.push [@selectedRegion.rowStart, colIdx, well]
      @wellsToUpdate.fillWellWithWellObject(@selectedRegion.rowStart, colIdx, well)
    )

    @wellsToUpdate.save()
    return plateWells

module.exports =
  SerialDilutionFactory: SerialDilutionFactory