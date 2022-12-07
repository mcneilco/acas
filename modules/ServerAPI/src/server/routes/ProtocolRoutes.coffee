exports.setupRoutes = (app, loginRoutes) ->
	app.post '/api/getTemplateSELFile', loginRoutes.ensureAuthenticated, exports.getTemplateSELFile

exports.getTemplateSELFile = (req, resp) ->
    config = require '../conf/compiled/conf.js'
    experimentServiceRoutes = require './ExperimentServiceRoutes.js'
    
    protocolCode = req.body.protocolCode
    protocolName = req.body.protocolName
    protocolScientist = req.body.protocolScientist
    protocolDate = req.body.protocolDate
    protocolProject = req.body.protocolProject

    endpointNames = req.body.endpointData.endpointNames
    endpointUnits = req.body.endpointData.endpointUnits
    endpointDataTypes = req.body.endpointData.endpointDataTypes
    endpointConc = req.body.endpointData.endpointConc
    endpointConcUnits = req.body.endpointData.endpointConcUnits
    endpointTime = req.body.endpointData.endpointTime
    endpointTimeUnits = req.body.endpointData.endpointTimeUnits
    endpointHidden = req.body.endpointData.endpointHidden

    try
        # create a CSV file with the endpoints	
        blankElements = ["NA", "undefined", "", null, undefined]

        endpointNameRowString = "Corporate Batch ID,"
        dataTypeRowString = "Datatype,"
        for indexNum in [0..endpointNames.length]
            endpointRowEntry = ""
            dataTypeEntry = ""

            endpointHasNoValues = true

            if endpointNames[indexNum] not in blankElements
                endpointRowEntry = endpointRowEntry + endpointNames[indexNum] + " "
                endpointHasNoValues = false
            if endpointUnits[indexNum] not in blankElements
                endpointRowEntry = endpointRowEntry + "(" + endpointUnits[indexNum] + ") "
                endpointHasNoValues = false

            # construct a different string for concentration depending on which combination of conc and conc units are present or not
            if endpointConc[indexNum] not in blankElements && endpointConcUnits[indexNum] not in blankElements
                endpointRowEntry = endpointRowEntry + "[" + endpointConc[indexNum] + " " + endpointConcUnits[indexNum] + "] "
                endpointHasNoValues = false
            if endpointConc[indexNum] in blankElements && endpointConcUnits[indexNum] not in blankElements
                endpointRowEntry = endpointRowEntry + "[" + endpointConcUnits[indexNum] + "] "
                endpointHasNoValues = false
            if endpointConc[indexNum] not in blankElements && endpointConcUnits[indexNum] in blankElements
                endpointRowEntry = endpointRowEntry + "[" + endpointConc[indexNum] + "] "
                endpointHasNoValues = false

            # construct a different string for time depending on which combination of time and time units are present or not
            if endpointTime[indexNum] not in blankElements && endpointTimeUnits[indexNum] not in blankElements
                endpointRowEntry = endpointRowEntry + "{" + endpointTime[indexNum] + " " + endpointTimeUnits[indexNum] + "} " 
                endpointHasNoValues = false
            if endpointTime[indexNum] not in blankElements && endpointTimeUnits[indexNum] in blankElements
                endpointRowEntry = endpointRowEntry + "{" + endpointTime[indexNum] + "} "
                endpointHasNoValues = false
            if endpointTime[indexNum] in blankElements && endpointTimeUnits[indexNum] not in blankElements
                endpointRowEntry = endpointRowEntry + "{" + endpointTimeUnits[indexNum] + "} "
                endpointHasNoValues = false

            # only attach the endpoint to the csv if it has any values 
            if endpointHasNoValues == false
                endpointNameRowString = endpointNameRowString + endpointRowEntry + ","
                
                # we only record the data type value if the other endpoint values are not empty 
                if endpointDataTypes[indexNum] == "numericValue"
                    dataTypeRowEntry = "Number "					
                else if endpointDataTypes[indexNum] == "stringValue"
                    dataTypeRowEntry = "Text "

                # mark if the endpoint is hidden or not
                if endpointHidden[indexNum] == "TRUE"
                    dataTypeRowEntry = dataTypeRowEntry + "(Hidden),"
                else
                    dataTypeRowEntry = dataTypeRowEntry + ","	
            
                dataTypeRowString = dataTypeRowString + dataTypeRowEntry
            
            
        # marking the file as a .csv
        csvContent = "data:text/csv;charset=utf-8," 

        # adding the SEL content
        csvContent = csvContent + "Experiment Metadata\nFormat,Generic\nProtocol Name," + protocolName + 
        "\nExperiment Name,,\nScientist," + protocolScientist + "\nNotebook,,\nPage,,\nAssay Date," + protocolDate +
        "\nProject," + protocolProject + "\n\nCalculated Results,\n" + dataTypeRowString + "\n" + endpointNameRowString

        resp.json csvContent
        

    catch e
        console.log 'got an error trying to construct template SEL file:' + e
        resp.end JSON.stringify "Error"

