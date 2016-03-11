PlateTableController = require('../src/client/PlateTableController.coffee').PlateTableController
PLATE_TABLE_CONTROLLER_EVENTS = require('../src/client/PlateTableController.coffee').PLATE_TABLE_CONTROLLER_EVENTS
plateWellContent = require('./testFixtures/PlateTableControllerFixtures.coffee').plateWellContent

$ = require('jquery')
_ = require('lodash')


describe "PlateTableController", ->
  beforeEach ->
    fixture = '<div id="fixture"></div>';
    document.body.insertAdjacentHTML('afterbegin', fixture)
    @startUpParams = {}
  it "should exist", ->
    plateTable = new PlateTableController(@startUpParams)
    expect(plateTable).toBeTruthy()

  describe "fields", ->
    beforeEach ->
      @plateTable = new PlateTableController(@startUpParams)
      $("#fixture").html @plateTable.render().el
      @plateTable.completeInitialization(plateWellContent)

    it "should have a handsonetable instance variable 1", ->
      expect(@plateTable.handsOnTable).toBeTruthy()

  describe "UI event handlers", ->
    beforeEach ->
      @plateTable = new PlateTableController(@startUpParams)
      $("#fixture").html @plateTable.render().el
      @plateTable.completeInitialization(plateWellContent)

    xit "should call handleDeleteClick when the 'Delete' button is clicked", (done) ->
      spyOn(@plateTable, 'handleDeleteClick')
      @plateTable.delegateEvents()
      $("#fixture").find("[name='delete']").click()
      _.defer(=>
        expect(@plateTable.handleDeleteClick).toHaveBeenCalled()
        done()
      )

  describe "event bindings", ->
    beforeEach ->
      @plateTable = new PlateTableController(@startUpParams)
      $("#fixture").html @plateTable.render().el

    xit "should call 'regionSelected' when the selected region changes", (done) ->
      spyOn(@plateTable, 'regionSelected')
      @plateTable.handsOnTable.trigger ""
      $("#fixture").find("[name='delete']").click()
      _.defer(=>
        expect(@plateTable.handleDeleteClick).toHaveBeenCalled()
        done()
      )


  describe "emitted events", ->
    beforeEach ->
      @plateTable = new PlateTableController(@startUpParams)
      $("#fixture").html @plateTable.render().el
      @plateTable.completeInitialization(plateWellContent)

    it "should emit a REGION_SELECTED event when 'handleRegionSelected' is called", (done) ->
      @plateTable.on PLATE_TABLE_CONTROLLER_EVENTS.REGION_SELECTED, ->
        expect(true).toBeTruthy()
        done()

      @plateTable.handleRegionSelected()

    it "should emit a PLATE_CONTENT_UPDATED event when 'handleContentUpdated' is called", (done) ->
      @plateTable.on PLATE_TABLE_CONTROLLER_EVENTS.PLATE_CONTENT_UPADATED, ->
        expect(true).toBeTruthy()
        done()

      @plateTable.handleContentUpdated([[0, 0, null, "test2"]], "paste")

    it "should send the selected region boundries when the PLATE_CONTENT_UPDATED event is triggered", (done) ->
      @plateTable.on PLATE_TABLE_CONTROLLER_EVENTS.REGION_SELECTED, (selectedRegionBoundries) ->
        expect(selectedRegionBoundries.rowStart).toEqual 1
        expect(selectedRegionBoundries.colStart).toEqual 2
        expect(selectedRegionBoundries.rowStop).toEqual 3
        expect(selectedRegionBoundries.colStop).toEqual 4
        done()

      @plateTable.handleRegionSelected(1, 2, 3, 4)

  describe "handleContentUpdated", ->
    beforeEach ->
      @plateTable = new PlateTableController(@startUpParams)
      $("#fixture").html @plateTable.render().el
      @plateTable.completeInitialization(plateWellContent)

    describe "update sources", ->
      it "should only emit a PLATE_CONTENT_UPDATED event if the update source is 'edit'", (done) ->
        @plateTable.updateDataDisplayed 'batchCode'
        @plateTable.on PLATE_TABLE_CONTROLLER_EVENTS.PLATE_CONTENT_UPADATED, (updatedValues) ->
          expect(updatedValues[0].colIdx).toEqual 0
          expect(updatedValues[0].rowIdx).toEqual 0
          expect(updatedValues[0].value).toEqual "test2"
          done()

        @plateTable.handleContentUpdated( [[0, 0, null, "test2"]], "edit")

      it "should only emit a PLATE_CONTENT_UPDATED event if the update source is 'autofill'", (done) ->
        @plateTable.updateDataDisplayed 'batchCode'
        @plateTable.on PLATE_TABLE_CONTROLLER_EVENTS.PLATE_CONTENT_UPADATED, (updatedValues) ->
          expect(updatedValues[0].colIdx).toEqual 0
          expect(updatedValues[0].rowIdx).toEqual 0
          expect(updatedValues[0].value).toEqual "test2"
          done()

        @plateTable.handleContentUpdated( [[0, 0, null, "test2"]], "autofill")

      it "should only emit a PLATE_CONTENT_UPDATED event if the update source is 'paste'", (done) ->
        @plateTable.updateDataDisplayed 'batchCode'
        @plateTable.on PLATE_TABLE_CONTROLLER_EVENTS.PLATE_CONTENT_UPADATED, (updatedValues) ->
          expect(updatedValues[0].colIdx).toEqual 0
          expect(updatedValues[0].rowIdx).toEqual 0
          expect(updatedValues[0].value).toEqual "test2"
          done()

        @plateTable.handleContentUpdated( [[0, 0, null, "test2"]], "paste")

    describe "update wellsToUpdate object", ->
      it "should update the batchCode field when the batchCode field is the selected view", (done) ->
        @plateTable.updateDataDisplayed 'batchCode'
        @plateTable.on PLATE_TABLE_CONTROLLER_EVENTS.PLATE_CONTENT_UPADATED, (updatedValues) =>
          console.log "@plateTable.wellsToUpdate!!!"
          console.log @plateTable.wellsToUpdate
          expect(@plateTable.wellsToUpdate.get('wells')[0].batchCode).toEqual "test2"
          done()
        console.log '@plateTable.wellsToUpdate'
        console.log @plateTable.wellsToUpdate
        @plateTable.handleContentUpdated( [[0, 0, null, "test2"]], "edit")

      it "should update the batchCode field when the batchCode field is the selected view", (done) ->
        @plateTable.updateDataDisplayed 'batchCode'
        @plateTable.on PLATE_TABLE_CONTROLLER_EVENTS.PLATE_CONTENT_UPADATED, (updatedValues) =>
          expect(@plateTable.wellsToUpdate.get('wells')[0].batchCode).toEqual "test2"
          done()
        @plateTable.handleContentUpdated( [[0, 0, null, "test2"]], "edit")

      it "should update the batchConcentration field when the batchConcentration field is the selected view", (done) ->
        @plateTable.updateDataDisplayed 'batchConcentration'
        @plateTable.on PLATE_TABLE_CONTROLLER_EVENTS.PLATE_CONTENT_UPADATED, (updatedValues) =>
          expect(@plateTable.wellsToUpdate.get('wells')[0].batchConcentration).toEqual "3"
          done()
        @plateTable.handleContentUpdated( [[0, 0, null, "3"]], "edit")

      it "should update the amount field when the amount field is the selected view", (done) ->
        @plateTable.updateDataDisplayed 'amount'
        @plateTable.on PLATE_TABLE_CONTROLLER_EVENTS.PLATE_CONTENT_UPADATED, (updatedValues) =>
          expect(@plateTable.wellsToUpdate.get('wellsToUpdate').amount).toEqual "3"
          done()
        @plateTable.handleContentUpdated( [[0, 0, null, "30"]], "edit")


  describe "helper methods", ->
    beforeEach ->
      @plateTable = new PlateTableController(@startUpParams)
      $("#fixture").html @plateTable.render().el
      @plateTable.completeInitialization(plateWellContent)

    describe "reformatUpdatedValues", ->
      it "should properly format the updated value object when a single cell is updated", ->
        updateValue = @plateTable.reformatUpdatedValues [[0,0,null, 2]]
        expectedUpdateValue = [
          rowIdx: 0
          colIdx: 0
          value: 2
        ]
        expect(updateValue).toEqual expectedUpdateValue

      it "should properly format the updated value object when multiple cells are updated", ->
        updateValue = @plateTable.reformatUpdatedValues [[0,0,null, 2], [0,1,null, 3], [0,2,null, 4]]
        expectedUpdateValue = [
          rowIdx: 0
          colIdx: 0
          value: 2
        ,
          rowIdx: 0
          colIdx: 1
          value: 3
        ,
          rowIdx: 0
          colIdx: 2
          value: 4
        ]
        expect(updateValue).toEqual expectedUpdateValue