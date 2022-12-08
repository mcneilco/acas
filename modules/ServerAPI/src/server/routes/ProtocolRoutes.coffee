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
    #baseurl = "http://localhost:3000/api/experiments/protocolCodename/#{protocolCode}"    

    experimentServiceRoutes.experimentsByProtocolCodenameInternal protocolCode, false, (statusCode, experiments) ->
        if statusCode == 200
            # Part 1: Find all unique endpoints across experiments that use this protocol code
            # arrays for recording endpoint data
            endpointNames = []
            endpointUnits = []
            endpointDataTypes = []
            endpointConc = []
            endpointConcUnits = []
            endpointTime = []
            endpointTimeUnits = []
            endpointHidden = []

            endpointStrings = []

            for experiment in experiments
                for i in experiment.lsStates
                    #go through the experiment data to check if the endpoint data is there
                    if i.lsKind == 'data column order' and i.ignored == false

                        # create NAs for each entry in case we don't find a variable, we'll plug these in instead
                        endpointNamesEntry = "NA"
                        endpointUnitsEntry = "NA"
                        endpointDataTypeEntry = "NA"
                        endpointConcEntry = "NA"
                        endpointConcUnitsEntry = "NA"
                        endpointTimeEntry = "NA"
                        endpointTimeUnitsEntry = "NA"
                        endpointHiddenEntry = "NA"

                        for j in i.lsValues
                            # only looking at the data that is not ignored
                            # TODO - add try/catch 
                            if j.lsKind == "column name" and j.ignored == false
                                endpointNamesEntry = j.codeValue
                            if j.lsKind == "column units" and j.ignored == false
                                endpointUnitsEntry = j.codeValue
                            if j.lsKind == "column type" and j.ignored == false
                                endpointDataTypeEntry = j.codeValue
                            if j.lsKind == "column concentration" and j.ignored == false
                                endpointConcEntry = j.numericValue
                            if j.lsKind == "column conc units" and j.ignored == false
                                endpointConcUnitsEntry = j.codeValue
                            if j.lsKind = "column time" and j.ignored == false
                                endpointTimeEntry = j.numericValue
                            if j.lsKind == "column time units" and j.ignored == false
                                endpointTimeUnitsEntry = j.codeValue
                            if j.lsTypeAndKind == "codeValue_hide column" and j.ignored == false
                                endpointHiddenEntry = j.codeValue

                        # create a string of all the different sections put together to identify duplicates
                        endpointString = endpointNamesEntry + endpointUnitsEntry + endpointDataTypeEntry + String(endpointConcEntry) + endpointConcUnitsEntry + String(endpointTimeEntry) + endpointTimeUnitsEntry

                        # if the endpoint is not already in there, record it
                        if endpointString not in endpointStrings
                            endpointStrings.push endpointString							

                            # record the endpoint data
                            endpointNames.push endpointNamesEntry
                            endpointUnits.push endpointUnitsEntry
                            endpointDataTypes.push endpointDataTypeEntry
                            endpointConc.push endpointConcEntry
                            endpointConcUnits.push endpointConcUnitsEntry
                            endpointTime.push endpointTimeEntry
                            endpointTimeUnits.push endpointTimeUnitsEntry
                            endpointHidden.push endpointHiddenEntry

            # Part 2: create a CSV file with the endpoints	
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

        else
            console.log 'got ajax error'
            console.log error
            console.log baseurl 
            console.log protocolCode
            console.log experiments
            console.log response
            resp.end JSON.stringify "Error"