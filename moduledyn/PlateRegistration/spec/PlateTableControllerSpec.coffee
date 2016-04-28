PlateTableController = require('../src/client/PlateTableController.coffee').PlateTableController
PLATE_TABLE_CONTROLLER_EVENTS = require('../src/client/PlateTableController.coffee').PLATE_TABLE_CONTROLLER_EVENTS
plateWellContent = require('./testFixtures/PlateTableControllerFixtures.coffee').plateWellContent
plateMetaData = require('./testFixtures/PlateTableControllerFixtures.coffee').plateMetaData

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

  describe "initiailization", ->
    beforeEach ->
      @plateTable = new PlateTableController(@startUpParams)
      $("#fixture").html @plateTable.render().el
      @plateTable.completeInitialization(plateWellContent, plateMetaData)
    describe "completeInitialization", ->
      it "should set the number of columns in the table based on the  plateAndWellData.plateMetadata object passed in", ->
        tableSettings = @plateTable.handsOnTable.getSettings()
        expect(tableSettings.startCols).toEqual plateMetaData.numberOfColumns
        expect(tableSettings.startRows).toEqual plateMetaData.numberOfRows


  describe "fields", ->
    beforeEach ->
      @plateTable = new PlateTableController(@startUpParams)
      $("#fixture").html @plateTable.render().el
      @plateTable.completeInitialization(plateWellContent, plateMetaData)

    it "should have a handsonetable instance variable 1", ->
      expect(@plateTable.handsOnTable).toBeTruthy()

  describe "UI event handlers", ->
    beforeEach ->
      @plateTable = new PlateTableController(@startUpParams)
      $("#fixture").html @plateTable.render().el
      @plateTable.completeInitialization(plateWellContent, plateMetaData)

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
      @plateTable.completeInitialization(plateWellContent, plateMetaData)

    it "should emit a REGION_SELECTED event when 'handleRegionSelected' is called", (done) ->
      @plateTable.on PLATE_TABLE_CONTROLLER_EVENTS.REGION_SELECTED, ->
        expect(true).toBeTruthy()
        done()

      @plateTable.handleRegionSelected()

    it "should emit a PLATE_CONTENT_UPDATED event when 'handleContentUpdated' is called", (done) ->
      @plateTable.dataFieldToDisplay = "batchConcentration"
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
      @plateTable.completeInitialization(plateWellContent, plateMetaData)

    describe "update sources", ->
      it "should only emit a PLATE_CONTENT_UPDATED event if the update source is 'edit'", (done) ->
        @plateTable.updateDataDisplayed 'batchConcentration'
        @plateTable.on PLATE_TABLE_CONTROLLER_EVENTS.PLATE_CONTENT_UPADATED, (updatedValues) ->
          expect(true).toBeTruthy()
          done()

        @plateTable.handleContentUpdated( [[0, 0, null, 23]], "edit")

      it "should only emit a PLATE_CONTENT_UPDATED event if the update source is 'autofill'", (done) ->
        @plateTable.updateDataDisplayed 'batchConcentration'
        @plateTable.on PLATE_TABLE_CONTROLLER_EVENTS.PLATE_CONTENT_UPADATED, (updatedValues) ->
          expect(true).toBeTruthy()
          done()

        @plateTable.handleContentUpdated( [[0, 0, null, 23]], "autofill")

      it "should only emit a PLATE_CONTENT_UPDATED event if the update source is 'paste'", (done) ->
        @plateTable.updateDataDisplayed 'batchConcentration'
        @plateTable.on PLATE_TABLE_CONTROLLER_EVENTS.PLATE_CONTENT_UPADATED, (updatedValues) ->
          expect(true).toBeTruthy()
          done()

        @plateTable.handleContentUpdated( [[0, 0, null, 23]], "paste")

    describe "update wellsToUpdate object", ->
      xit "should update the batchCode field when the batchCode field is the selected view", (done) ->
        @plateTable.updateDataDisplayed 'batchConcentration'
        @plateTable.on PLATE_TABLE_CONTROLLER_EVENTS.PLATE_CONTENT_UPADATED, (updatedValues) =>
          expect(@plateTable.wellsToUpdate.get('wells')[0].batchCode).toEqual 23
          done()
        @plateTable.handleContentUpdated( [[0, 0, null, 23]], "edit")

      it "should update the batchConcentration field when the batchConcentration field is the selected view", (done) ->
        @plateTable.updateDataDisplayed 'batchConcentration'
        @plateTable.on PLATE_TABLE_CONTROLLER_EVENTS.PLATE_CONTENT_UPADATED, (updatedValues) =>
          expect(@plateTable.wellsToUpdate.get('wells')[0].batchConcentration).toEqual "3"
          done()
        @plateTable.handleContentUpdated( [[0, 0, null, "3"]], "edit")

      it "should update the amount field when the amount field is the selected view", (done) ->
        @plateTable.updateDataDisplayed 'amount'
        @plateTable.on PLATE_TABLE_CONTROLLER_EVENTS.PLATE_CONTENT_UPADATED, (updatedValues) =>
          expect(@plateTable.wellsToUpdate.get('wells')[0].amount).toEqual "30"
          done()
        @plateTable.handleContentUpdated( [[0, 0, null, "30"]], "edit")
        #expect(@plateTable.wellsToUpdate.get('wellsToUpdate').amount).toEqual "3"
        done()


  describe "helper methods", ->
    beforeEach ->
      @plateTable = new PlateTableController(@startUpParams)
      $("#fixture").html @plateTable.render().el
      @plateTable.completeInitialization(plateWellContent, plateMetaData)

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

    describe "validatePasteContentRowRange", ->
      it "should return an empty array if the number of rows being pasted in will fit in the table", ->
        changes = [
          [4, 1, 'test'],
          [5, 1, 'test'],
          [6, 1, 'test']
        ]
        invalidRows = @plateTable.validatePasteContentRowRange changes, 8
        expect(_.size(invalidRows)).toEqual 0

      it "should return an array of rows being pasted that won't fit in the table", ->
        changes = [
          [7, 1, 'test'],
          [8, 1, 'test'],
          [9, 1, 'test']
        ]
        invalidRows = @plateTable.validatePasteContentRowRange changes, 8
        expect(_.size(invalidRows)).toEqual 2
        expect(invalidRows[0]).toEqual changes[1]

    describe "validatePasteContentColumnRange", ->
      it "should return an empty array if the number of rows being pasted in will fit in the table", ->
        changes = [
          [1, 5, 'test'],
          [1, 6, 'test'],
          [1, 7, 'test']
        ]
        invalidCols = @plateTable.validatePasteContentColumnRange changes, 8
        expect(_.size(invalidCols)).toEqual 0

      it "should return an array of rows being pasted that won't fit in the table", ->
        changes = [
          [1, 5, 'test'],
          [1, 6, 'test'],
          [1, 7, 'test']
        ]
        invalidCols = @plateTable.validatePasteContentColumnRange changes, 6
        expect(_.size(invalidCols)).toEqual 2
        expect(invalidCols[0]).toEqual changes[1]