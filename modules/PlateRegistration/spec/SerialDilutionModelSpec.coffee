$ = require('jquery')
_ = require('lodash')

SerialDilutionModel = require('../src/client/SerialDilutionModel.coffee').SerialDilutionModel
SERIAL_DILUTION_MODEL_FIELDS = require('../src/client/SerialDilutionModel.coffee').SERIAL_DILUTION_MODEL_FIELDS

describe "SerialDilutionModel", ->
  beforeEach ->
    @sdm = new SerialDilutionModel()
    @sdm.set SERIAL_DILUTION_MODEL_FIELDS.MAX_NUMBER_OF_COLUMNS, 12
    @sdm.set SERIAL_DILUTION_MODEL_FIELDS.MAX_NUMBER_OF_ROWS, 8
    @sdm.set SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_COLUMNS_SELECTED, 1
    @sdm.set SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_ROWS_SELECTED, 2
    @sdm.set SERIAL_DILUTION_MODEL_FIELDS.SELECTED_ROW_IDX, 3
    @sdm.set SERIAL_DILUTION_MODEL_FIELDS.SELECTED_COLUMN_IDX, 3
    @sdm.set SERIAL_DILUTION_MODEL_FIELDS.TRANSFER_VOLUME, 10
    @sdm.set SERIAL_DILUTION_MODEL_FIELDS.DESTINATION_WELL_VOLUME, 10
    @sdm.set SERIAL_DILUTION_MODEL_FIELDS.IS_DILUTION_BY_VOLUME, true


  it "should exist", ->
    expect(@sdm).toBeTruthy()

  describe "validation methods", ->
    describe "validateNumberOfDoses", ->
      it "should return false if the user enters 0", ->
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_DOSES, 0
        expect(@sdm.validateNumberOfDoses()).toBeFalsy()
      it "should return false if the user enters a value less than 0", ->
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_DOSES, -1
        expect(@sdm.validateNumberOfDoses()).toBeFalsy()
      it "should return false if the user enters a non-numeric value", ->
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_DOSES, "this isn't a number!"
        expect(@sdm.validateNumberOfDoses()).toBeFalsy()
      it "should return true if the user enters a numeric value greater than 0", ->
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_DOSES, 1
        expect(@sdm.validateNumberOfDoses()).toBeTruthy()

    describe "validateTransferVolume", ->
      beforeEach ->
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.IS_DILUTION_BY_VOLUME, true
      it "should return false if the user leaves the field blank", ->
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.TRANSFER_VOLUME, ""
        expect(@sdm.validateTransferVolume()).toBeFalsy()
      it "should return false if the user enters 0", ->
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.TRANSFER_VOLUME, 0
        expect(@sdm.validateTransferVolume()).toBeFalsy()
      it "should return false if the user enters a value less than 0", ->
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.TRANSFER_VOLUME, -1
        expect(@sdm.validateTransferVolume()).toBeFalsy()
      it "should return false if the user enters a non-numeric value", ->
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.TRANSFER_VOLUME, "this isn't a number!"
        expect(@sdm.validateTransferVolume()).toBeFalsy()
      it "should return true if the user enters a numeric value greater than 0", ->
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.TRANSFER_VOLUME, 1
        expect(@sdm.validateTransferVolume()).toBeTruthy()
      it "should return true if it's empty and IS_DILUTION_BY_VOLUME is false", ->
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.IS_DILUTION_BY_VOLUME, false
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.TRANSFER_VOLUME, ""
        expect(@sdm.validateTransferVolume()).toBeTruthy()

    describe "validateDestinationVolume", ->
      beforeEach ->
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.IS_DILUTION_BY_VOLUME, true
      it "should return false if the user leaves the field blank", ->
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.DESTINATION_WELL_VOLUME, ""
        expect(@sdm.validateDestinationVolume()).toBeFalsy()
      it "should return false if the user enters 0", ->
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.DESTINATION_WELL_VOLUME, 0
        expect(@sdm.validateDestinationVolume()).toBeFalsy()
      it "should return false if the user enters a value less than 0", ->
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.DESTINATION_WELL_VOLUME, -1
        expect(@sdm.validateDestinationVolume()).toBeFalsy()
      it "should return false if the user enters a non-numeric value", ->
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.DESTINATION_WELL_VOLUME, "this isn't a number!"
        expect(@sdm.validateDestinationVolume()).toBeFalsy()
      it "should return true if the user enters a numeric value greater than 0", ->
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.DESTINATION_WELL_VOLUME, 1
        expect(@sdm.validateDestinationVolume()).toBeTruthy()
      it "should return true if it's empty and IS_DILUTION_BY_VOLUME is false", ->
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.IS_DILUTION_BY_VOLUME, false
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.DESTINATION_WELL_VOLUME, ""
        expect(@sdm.validateDestinationVolume()).toBeTruthy()

    describe "validateDilutionFactor", ->
      beforeEach ->
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.IS_DILUTION_BY_VOLUME, false
      it "should return false if the user leaves the field blank", ->
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.DILUTION_FACTOR, ""
        expect(@sdm.validateDilutionFactor()).toBeFalsy()
      it "should return false if the user enters 0", ->
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.DILUTION_FACTOR, 0
        expect(@sdm.validateDilutionFactor()).toBeFalsy()
      it "should return false if the user enters a value less than 0", ->
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.DILUTION_FACTOR, -1
        expect(@sdm.validateDilutionFactor()).toBeFalsy()
      it "should return false if the user enters a non-numeric value", ->
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.DILUTION_FACTOR, "this isn't a number!"
        expect(@sdm.validateDilutionFactor()).toBeFalsy()
      it "should return true if the user enters a numeric value greater than 0", ->
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.DILUTION_FACTOR, 1
        expect(@sdm.validateDilutionFactor()).toBeTruthy()
      it "should return true if it's empty and IS_DILUTION_BY_VOLUME is true", ->
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.IS_DILUTION_BY_VOLUME, true
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.DILUTION_FACTOR, ""
        expect(@sdm.validateDilutionFactor()).toBeTruthy()


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

    describe "aSingleCellIsSelected", ->
      it "should return true if 1 row and 1 column is selected", ->
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_ROWS_SELECTED, 1
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_COLUMNS_SELECTED, 1
        expect(@sdm.aSingleCellIsSelected()).toBeTruthy()

      it "should return false if one row and more than column is selected", ->
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_ROWS_SELECTED, 1
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_COLUMNS_SELECTED, 2
        expect(@sdm.aSingleCellIsSelected()).toBeFalsy()

      it "should return false if one column and more than row is selected", ->
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_ROWS_SELECTED, 2
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_COLUMNS_SELECTED, 1
        expect(@sdm.aSingleCellIsSelected()).toBeFalsy()

      it "should return false if no rows or columns are selected", ->
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_ROWS_SELECTED, 0
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_COLUMNS_SELECTED, 0
        expect(@sdm.aSingleCellIsSelected()).toBeFalsy()

    describe "enoughSpaceForNumberOfDoses", ->
      describe "when dilution direction is 'diluteLeft'", ->
        it "should return false if the number of doses exceeds the number of available columns to the left of the selected column", ->
          @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.DIRECTION, "diluteLeft")
          @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.SELECTED_ROW_IDX, 3)
          @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.SELECTED_COLUMN_IDX, 3)
          @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_DOSES, 4)
          expect(@sdm.enoughSpaceForNumberOfDoses()).toBeFalsy()

        it "should return true if the number of doses is less than the number of available columns to the left of the selected column", ->
          @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.DIRECTION, "diluteLeft")
          @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.SELECTED_COLUMN_IDX, 5)
          @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.SELECTED_ROW_IDX, 3)
          @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_DOSES, 3)
          expect(@sdm.enoughSpaceForNumberOfDoses()).toBeTruthy()

      describe "when dilution direction is 'diluteRight'", ->
        it "should return false if the number of doses exceeds the number of available columns to the left of the selected column", ->
          @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.DIRECTION, "diluteRight")
          @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.SELECTED_COLUMN_IDX, 10)
          @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.SELECTED_ROW_IDX, 3)
          @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_DOSES, 3)
          expect(@sdm.enoughSpaceForNumberOfDoses()).toBeFalsy()

        it "should return true if the number of doses is less than the number of available columns to the left of the selected column", ->
          @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.DIRECTION, "diluteRight")
          @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.SELECTED_COLUMN_IDX, 8)
          @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.SELECTED_ROW_IDX, 3)
          @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_DOSES, 3)
          expect(@sdm.enoughSpaceForNumberOfDoses()).toBeTruthy()

      describe "when dilution direction is 'diluteUp'", ->
        it "should return false if the number of doses exceeds the number of available columns to the left of the selected column", ->
          @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.DIRECTION, "diluteUp")
          @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.SELECTED_ROW_IDX, 1)
          @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.SELECTED_COLUMN_IDX, 1)
          @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_DOSES, 2)
          expect(@sdm.enoughSpaceForNumberOfDoses()).toBeFalsy()

        it "should return true if the number of doses is less than the number of available columns to the left of the selected column", ->
          @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.DIRECTION, "diluteUp")
          @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.SELECTED_ROW_IDX, 2)
          @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.SELECTED_COLUMN_IDX, 1)
          @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_DOSES, 2)
          expect(@sdm.enoughSpaceForNumberOfDoses()).toBeTruthy()

      describe "when dilution direction is 'diluteDown'", ->
        it "should return false if the number of doses exceeds the number of available rows below the selected row", ->
          @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.DIRECTION, "diluteDown")
          @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.SELECTED_ROW_IDX, 7)
          @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.SELECTED_COLUMN_IDX, 1)
          @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_DOSES, 3)
          expect(@sdm.enoughSpaceForNumberOfDoses()).toBeFalsy()

        it  "should return true if the number of doses is less than the number of available rows below the selected row", ->
          @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.DIRECTION, "diluteDown")
          @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.SELECTED_ROW_IDX, 4)
          @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.SELECTED_COLUMN_IDX, 1)
          @sdm.set(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_DOSES, 3)
          expect(@sdm.enoughSpaceForNumberOfDoses()).toBeTruthy()

    describe "validRegionSelected", ->
      it "should return true if a single cell is selected", ->
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_ROWS_SELECTED, 1
        @sdm.set SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_COLUMNS_SELECTED, 1
        expect(@sdm.validRegionSelected()).toBeTruthy()