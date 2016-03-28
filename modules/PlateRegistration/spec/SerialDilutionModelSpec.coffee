$ = require('jquery')
_ = require('lodash')

SerialDilutionModel = require('../src/client/SerialDilutionModel.coffee').SerialDilutionModel
SERIAL_DILUTION_MODEL_FIELDS = require('../src/client/SerialDilutionModel.coffee').SERIAL_DILUTION_MODEL_FIELDS

describe "SerialDilutionModel", ->
  beforeEach ->
    @sdm = new SerialDilutionModel()

  it "should exist", ->
    expect(@sdm).toBeTruthy()

  describe "utility methods", ->
    describe "aRowIsSelected", ->
      it "should return true if more than 1 column is selected", ->
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_COLUMNS_SELECTED, 3
        expect(@sdm.aRowIsSelected()).toBeTruthy()

      it "should return false if only 1 column is selected", ->
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_COLUMNS_SELECTED, 1
        expect(@sdm.aRowIsSelected()).toBeFalsy()

    describe "aColumnIsSelected", ->
      it "should return true if more than 1 row is selected", ->
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_ROWS_SELECTED, 3
        expect(@sdm.aColumnIsSelected()).toBeTruthy()

      it "should return false if only 1 column is selected", ->
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_ROWS_SELECTED, 1
        expect(@sdm.aColumnIsSelected()).toBeFalsy()

      describe "enoughSpaceForNumberOfDoses", ->
        describe "when dilution direction is 'diluteLeft'", ->
          it "should return false if the number of doses exceeds the number of available columns to the left of the selected column", ->
            @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.DIRECTION, "diluteLeft")
            @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.SELECTED_COLUMN_IDX, 3)
            @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_DOSES, 3)
            expect(@sdm.enoughSpaceForNumberOfDoses()).toBeFalsy()

          it "should return true if the number of doses is less than the number of available columns to the left of the selected column", ->
            @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.DIRECTION, "diluteLeft")
            @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.SELECTED_COLUMN_IDX, 5)
            @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_DOSES, 3)
            expect(@sdm.enoughSpaceForNumberOfDoses()).toBeFalsy()

        describe "when dilution direction is 'diluteRight'", ->
          it "should return false if the number of doses exceeds the number of available columns to the left of the selected column", ->
            @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.DIRECTION, "diluteLeft")
            @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.SELECTED_COLUMN_IDX, 3)
            @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_DOSES, 3)
            expect(@sdm.enoughSpaceForNumberOfDoses()).toBeFalsy()

          it "should return true if the number of doses is less than the number of available columns to the left of the selected column", ->
            @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.DIRECTION, "diluteLeft")
            @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.SELECTED_COLUMN_IDX, 5)
            @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_DOSES, 3)
            expect(@sdm.enoughSpaceForNumberOfDoses()).toBeFalsy()