SerialDilutionController = require('../src/client/SerialDilutionController.coffee').SerialDilutionController
SERIAL_DILUTION_MODEL_FIELDS = require('../src/client/SerialDilutionModel.coffee').SERIAL_DILUTION_MODEL_FIELDS
SerialDilutionModel = require('../src/client/SerialDilutionModel.coffee').SerialDilutionModel

$ = require('jquery')
_ = require('lodash')


describe "SerialDilutionController", ->
  beforeEach ->
    fixture = '<div id="fixture"></div>';
    document.body.insertAdjacentHTML('afterbegin', fixture)
    @startUpParams = {model: new SerialDilutionModel()}
  it "should exist", ->
    serialDilutionController = new SerialDilutionController(@startUpParams)
    expect(serialDilutionController).toBeTruthy()

  describe "template content", ->
    beforeEach ->
      @serialDilutionController = new SerialDilutionController(@startUpParams)
      $("#fixture").html @serialDilutionController.render().el

    it "should have a template property", ->
      expect(@serialDilutionController.template).toBeTruthy()

  describe "fields", ->
    beforeEach ->
      @serialDilutionController = new SerialDilutionController(@startUpParams)
      $("#fixture").html @serialDilutionController.render().el

  describe "field / model binding", ->
    beforeEach ->
      @serialDilutionController = new SerialDilutionController(@startUpParams)
      $("#fixture").html @serialDilutionController.render().el

    it "should update the NUMBER_OF_DOSES model field when the number of doses is entered", ->
      $("#fixture").find("[name='numberOfDoses']").val(5)
      $("#fixture").find("[name='numberOfDoses']").trigger "change"
      expect(@serialDilutionController.model.get(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_DOSES)).toEqual 5

    it "should set the DIRECTION model field to 'diluteLeft' when the dilute left button is clicked", ->
      $("#fixture").find("[name='diluteLeft']").click()
      expect(@serialDilutionController.model.get(SERIAL_DILUTION_MODEL_FIELDS.DIRECTION)).toEqual "diluteLeft"

    it "should set the DIRECTION model field to 'diluteRight' when the dilute right button is clicked", ->
      $("#fixture").find("[name='diluteRight']").click()
      expect(@serialDilutionController.model.get(SERIAL_DILUTION_MODEL_FIELDS.DIRECTION)).toEqual "diluteRight"

    it "should set the DIRECTION model field to 'diluteDown' when the dilute down button is clicked", ->
      $("#fixture").find("[name='diluteDown']").click()
      expect(@serialDilutionController.model.get(SERIAL_DILUTION_MODEL_FIELDS.DIRECTION)).toEqual "diluteDown"

    it "should set the DIRECTION model field to 'diluteUp' when the dilute up button is clicked", ->
      $("#fixture").find("[name='diluteUp']").click()
      expect(@serialDilutionController.model.get(SERIAL_DILUTION_MODEL_FIELDS.DIRECTION)).toEqual "diluteUp"

    it "should set IS_DILUTION_BY_VOLUME model field to true when the dilute by volume option is selected", ->
      $("#fixture").find(".bv_volume").click()
      expect(@serialDilutionController.model.get(SERIAL_DILUTION_MODEL_FIELDS.IS_DILUTION_BY_VOLUME)).toBeTruthy()

    it "should set IS_DILUTION_BY_VOLUME model field to false when the dilute by dilution factor option is selected", ->
      $("#fixture").find(".bv_dilutionFactor").click()
      expect(@serialDilutionController.model.get(SERIAL_DILUTION_MODEL_FIELDS.IS_DILUTION_BY_VOLUME)).toBeFalsy()

    it "should set TRANSFER_VOLUME model field to 5 when the user enters 5 in the transfer volume input box", ->
      $("#fixture").find("[name='transferVolume']").val(5)
      $("#fixture").find("[name='transferVolume']").trigger "change"
      expect(@serialDilutionController.model.get(SERIAL_DILUTION_MODEL_FIELDS.TRANSFER_VOLUME)).toEqual 5

    it "should set DESTINATION_WELL_VOLUME model field to 5 when the user enters 5 in the destination well volume input box", ->
      $("#fixture").find("[name='destinationWellVolume']").val(5)
      $("#fixture").find("[name='destinationWellVolume']").trigger "change"
      expect(@serialDilutionController.model.get(SERIAL_DILUTION_MODEL_FIELDS.DESTINATION_WELL_VOLUME)).toEqual 5

    it "should set DILUTION_FACTOR model field to 5 when the user enters 5 in the dilution factor input box", ->
      $("#fixture").find("[name='dilutionFactor']").val(5)
      $("#fixture").find("[name='dilutionFactor']").trigger "change"
      expect(@serialDilutionController.model.get(SERIAL_DILUTION_MODEL_FIELDS.DILUTION_FACTOR)).toEqual 5

  describe "submit button state behavior", ->
    beforeEach ->
      fixture = '<div id="fixture"></div>';
      document.body.insertAdjacentHTML('afterbegin', fixture)

      @serialDilutionController = new SerialDilutionController(@startUpParams)
      $("#fixture").html @serialDilutionController.render().el

    it "should initially be disabled", ->
      expect(@serialDilutionController.$("button[name='applyDilution']").prop("disabled")).toBeTruthy()

    xit "should be enabled when the required fields are entered and the user has selected a valid region", ->
      @serialDilutionController.model.set(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_DOSES, 5)
      @serialDilutionController.model.set(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_COLUMNS_SELECTED, 2)
      @serialDilutionController.model.set(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_ROWS_SELECTED, 1)
      @serialDilutionController.model.set(SERIAL_DILUTION_MODEL_FIELDS.SELECTED_COLUMN_IDX, 1)
      @serialDilutionController.model.set(SERIAL_DILUTION_MODEL_FIELDS.SELECTED_ROW_IDX, 1)
      @serialDilutionController.model.set(SERIAL_DILUTION_MODEL_FIELDS.DIRECTION, "diluteDown")
      @serialDilutionController.model.set(SERIAL_DILUTION_MODEL_FIELDS.LOWEST_VOLUME_WELL, 5)
      @serialDilutionController.model.set(SERIAL_DILUTION_MODEL_FIELDS.ALL_WELLS_HAVE_VOLUME, true)
      @serialDilutionController.model.set(SERIAL_DILUTION_MODEL_FIELDS.ALL_WELLS_HAVE_CONCENTRATION, true)
      @serialDilutionController.setStateOfSubmitButton()
      expect(@serialDilutionController.$("button[name='applyDilution']").prop("disabled")).toBeFalsy()

    it "should be enabled when the required fields are entered and the user has selected a valid region", ->
      @serialDilutionController.model.set(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_DOSES, 5)
      @serialDilutionController.model.set(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_COLUMNS_SELECTED, 2)
      @serialDilutionController.model.set(SERIAL_DILUTION_MODEL_FIELDS.NUMBER_OF_ROWS_SELECTED, 1)
      @serialDilutionController.model.set(SERIAL_DILUTION_MODEL_FIELDS.SELECTED_COLUMN_IDX, 1)
      @serialDilutionController.model.set(SERIAL_DILUTION_MODEL_FIELDS.SELECTED_ROW_IDX, 1)
      @serialDilutionController.model.set(SERIAL_DILUTION_MODEL_FIELDS.DIRECTION, "diluteUp")
      @serialDilutionController.setStateOfSubmitButton()
      expect(@serialDilutionController.$("button[name='applyDilution']").prop("disabled")).toBeTruthy()

  describe "UI behavior", ->
    beforeEach ->
      fixture = '<div id="fixture"></div>';
      document.body.insertAdjacentHTML('afterbegin', fixture)

      @serialDilutionController = new SerialDilutionController(@startUpParams)
      $("#fixture").html @serialDilutionController.render().el

    describe "initial state of form", ->
      it "diluteRight button should initially be active", ->
        expect(@serialDilutionController.$("button[name='diluteRight']").hasClass("active")).toBeTruthy()

      it "transfer volume and destination well volume text fields should initially be enabled", ->
        expect(@serialDilutionController.$("input[name='transferVolume']").prop("disabled")).toBeFalsy()
        #expect(@serialDilutionController.$("input[name='transferVolume']").hasClass("disabled")).toBeFalsy()
        expect(@serialDilutionController.$("input[name='destinationWellVolume']").prop("disabled")).toBeFalsy()
        #expect(@serialDilutionController.$("input[name='destinationWellVolume']").hasClass("disabled")).toBeFalsy()

      it "dilution factor text field should initially be disabled", ->
        expect(@serialDilutionController.$("input[name='dilutionFactor']").prop("disabled")).toBeTruthy()


      it "Dilute by volume option should be checked", ->
        expect(@serialDilutionController.$(".bv_volume").prop('checked')).toBeTruthy()

      it "Dilute by dilution factor option should not be checked", ->
        expect(@serialDilutionController.$(".bv_dilutionFactor").prop('checked')).toBeFalsy()

    describe "changing dilution strategy", ->
      it "should enable the dilution factor text input field and disable the dilute by volume input fields when dilute by dilution factor option is selected", ->
        @serialDilutionController.$(".bv_dilutionFactor").click()
        expect(@serialDilutionController.$("input[name='dilutionFactor']").prop("disabled")).toBeFalsy()
        #expect(@serialDilutionController.$("input[name='dilutionFactor']").hasClass("disabled")).toBeFalsy()

        expect(@serialDilutionController.$("input[name='transferVolume']").prop("disabled")).toBeTruthy()
        #expect(@serialDilutionController.$("input[name='transferVolume']").hasClass("disabled")).toBeTruthy()
        expect(@serialDilutionController.$("input[name='destinationWellVolume']").prop("disabled")).toBeTruthy()
        #expect(@serialDilutionController.$("input[name='destinationWellVolume']").hasClass("disabled")).toBeTruthy()

      it "should enable the dilute by volume input fields and disabled the dilution factor input field when dilute by volume option is selected", ->
        @serialDilutionController.$(".bv_dilutionFactor").click()
        @serialDilutionController.$(".bv_volume").click()
        expect(@serialDilutionController.$("input[name='dilutionFactor']").prop("disabled")).toBeTruthy()
        #expect(@serialDilutionController.$("input[name='dilutionFactor']").hasClass("disabled")).toBeTruthy()

        expect(@serialDilutionController.$("input[name='transferVolume']").prop("disabled")).toBeFalsy()
        #expect(@serialDilutionController.$("input[name='transferVolume']").hasClass("disabled")).toBeFalsy()
        expect(@serialDilutionController.$("input[name='destinationWellVolume']").prop("disabled")).toBeFalsy()
        #expect(@serialDilutionController.$("input[name='destinationWellVolume']").hasClass("disabled")).toBeFalsy()


  #  describe "UI event handlers", ->
  #    beforeEach ->
  #      @plateView = new PlateViewController(@startUpParams)
  #      $("#fixture").html @plateView.render().el
  #
  #    xit "should call handleDeleteClick when the 'Delete' button is clicked", (done) ->
  #      spyOn(@plateView, 'handleDeleteClick')
  #      @plateInfo.delegateEvents()
  #      $("#fixture").find("[name='delete']").click()
  #      _.defer(=>
  #        expect(@plateInfo.handleDeleteClick).toHaveBeenCalled()
  #        done()
  #      )
  #
  #  describe "emitted events", ->
  #    beforeEach ->
  #      @plateView = new PlateViewController(@startUpParams)
  #      $("#fixture").html @plateView.render().el
  #
  #
  #    xit "should emit a DELETE_PLATE event when the 'Delete' button is clicked", (done) ->
  #      @plateView.on PLATE_INFO_CONTROLLER_EVENTS.DELETE_PLATE, ->
  #        expect(true).toBeTruthy()
  #        done()
  #
  #      @plateInfo.handleDeleteClick()
#
#  describe "events", ->
#    beforeEach ->
#      @plateView = new PlateViewController(@startUpParams)
#      $("#fixture").html @plateView.render().el
#      @plateView.completeInitialization()
#
#    describe "REGION_SELECTED", ->
#      it "should call 'handleRegionSelected' when plateTableController triggers 'REGION_SELECTED' event", (done) ->
#        spyOn(@plateView, 'handleRegionSelected')
#        @plateView.delegateEvents()
#        @plateView.plateTableController.trigger PLATE_TABLE_CONTROLLER_EVENTS.REGION_SELECTED
#
#        _.defer( =>
#          expect(@plateView.handleRegionSelected).toHaveBeenCalled()
#          done()
#        )