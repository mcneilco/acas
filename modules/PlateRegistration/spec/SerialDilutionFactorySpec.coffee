$ = require('jquery')
_ = require('lodash')

SerialDilutionFactory = require('../src/client/SerialDilutionFactory.coffee').SerialDilutionFactory
SerialDilutionByVolume = require('../src/client/SerialDilutionFactory.coffee').SerialDilutionByVolume
SerialDilutionModel = require('../src/client/SerialDilutionModel.coffee').SerialDilutionModel
SERIAL_DILUTION_MODEL_FIELDS = require('../src/client/SerialDilutionModel.coffee').SERIAL_DILUTION_MODEL_FIELDS

describe "SerialDilutionFactory", ->
  beforeEach ->
    @sdf = new SerialDilutionFactory()

  it "should exist", ->
    expect(@sdf).toBeTruthy()

  describe "getSerialDilutionStrategy", ->
    describe "should return the correct SerialDilutionStrategy based on the input SerialDultionModel", ->
      describe "when dilutionModel.isDilutionByVolume is true", ->
        it "should return a SerialDilutionStrategy of type SerialDilutionByVolume", ->
          sdm = new SerialDilutionModel()
          sdm.set SERIAL_DILUTION_MODEL_FIELDS.IS_DILUTION_BY_VOLUME, true
          sds = @sdf.getSerialDilutionStrategy sdm
          expect(sds instanceof SerialDilutionByVolume).toBeTruthy()