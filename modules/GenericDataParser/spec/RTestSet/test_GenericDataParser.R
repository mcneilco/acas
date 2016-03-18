# To collect data use
# save(metaData, file = "public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/normalMetaData.Rda")
# at the beginning and end of the function

test.tryCatch.W.E <- function() {
  throwNoErrors <- function() {return("hello world!")}
  checkIdentical(list(value="hello world!",warningList=list()),tryCatch.W.E(throwNoErrors()))
  throwAnError <- function() {stop("Stop Now")}
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/TryCatch.W.EcaughtError.Rda")
  checkIdentical(caughtError,tryCatch.W.E(throwAnError()))
  
  throwAWarning <- function() {
    warning("This is a warning") 
    return("hello world!")
  }
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/TryCatch.W.EcaughtWarning.Rda")
  checkIdentical(caughtWarning,tryCatch.W.E(throwAWarning()))
  
  throwTwoWarningsAndAnError <- function() {
    warning("This is a warning")
    warning("This is also a warning") 
    stop("Stop Now")
  }
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/TryCatch.W.EcaughtTwoWarningsAndAnError.Rda")
  checkIdentical(caughtWarningsAndError, tryCatch.W.E(throwTwoWarningsAndAnError()))
}

test.validateDate <- function() {
  checkEquals(as.Date("2012-12-05"), validateDate("2012-12-05"))
  
  # These use today's date, so I am only checking that there is a warning
  output <- tryCatch.W.E(checkEquals(as.Date("2012-02-05"), validateDate("02-05-2012")))
  checkTrue(output$value)
  checkEquals(1,length(output$warningList))
  
  output <- tryCatch.W.E(checkEquals(as.Date("2005-03-16"), validateDate("3/16/05")))
  checkTrue(output$value)
  checkEquals(1,length(output$warningList))
}

test.validateCharacter <- function() {
  checkEquals("hello world!", validateCharacter("hello world!"))
  checkEquals(NULL, validateCharacter(NULL))
  checkEquals("42", validateCharacter(42))
}

test.validateNumeric <- function() {
  checkEquals(42,validateNumeric(42))
  checkEquals(3.14159,validateNumeric(3.14159))
  checkEquals(43,validateNumeric(factor(43)))
  
  errorList<<-list()
  checkTrue(is.na(validateNumeric("pi")))
  checkIdentical(list("An entry was expected to be a number but was: 'pi'. Please enter a number instead."), errorList)
  
  errorList<<-list()
  checkTrue(is.na(validateNumeric(as.Date("2013-01-04"))))
  checkIdentical(list("An entry was expected to be a number but was: '2013-01-04'. Please enter a number instead."), errorList)
}

test.validateMetaData <- function() {
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/normalValidatedMetaData.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/normalMetaData.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/MetaDataExpectedDataFormat.Rda")
  checkIdentical(validatedMetaData,validateMetaData(metaData,expectedDataFormat))
  
  errorList <<- list()
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/missingRowsValidatedMetaData.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/missingRowsMetaData.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/MetaDataExpectedDataFormat.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/missingRowsErrorsForValidateMetaData.Rda")
  checkIdentical(validatedMetaData,validateMetaData(metaData,expectedDataFormat))
  checkIdentical(errorListExpected,errorList)
  
  errorList <<- list()
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/addedRowsValidateMetaData.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/addedRowsMetaData.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/MetaDataExpectedDataFormat.Rda")
  checkIdentical(addedRowsValidateMetaData,tryCatch.W.E(validateMetaData(metaData,expectedDataFormat)))
  checkIdentical(list(),errorList)
  
  errorList <<- list()
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/addedColumnsValidatedMetaData.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/addedColumnsMetaData.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/MetaDataExpectedDataFormat.Rda")
  checkIdentical(validatedMetaData,validateMetaData(metaData,expectedDataFormat))
  checkIdentical(list("Extra data were found next to the Experiment Meta Data and should be removed: 'One more row', 'Another row'"), errorList)
}

test.getHiddenColumns <- function() {
  checkIdentical(c(FALSE,TRUE,TRUE,FALSE,FALSE),getHiddenColumns(c("Text(shown)","Text (hidden)","Date(hidden)","String","NotADatatype(")))
  errorList <<- list()
  checkIdentical(c(FALSE,FALSE),getHiddenColumns(c("Text","Text (hello world!)")))
  checkIdentical(list("In Datatype column B, there is an entry in the parentheses that cannot be understood: 'hello world!'. Please enter 'shown' or 'hidden'."),
                 errorList)
}

test.getExcelColumnFromNumber <- function() {
  checkEquals("A",getExcelColumnFromNumber(1))
  checkEquals("AP",getExcelColumnFromNumber(42))
  
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/getExcelColumn0.Rda")
  checkIdentical(getExcelColumn0,tryCatch.W.E(getExcelColumnFromNumber(0)))
  
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/getExcelColumnNegative1.Rda")
  checkIdentical(getExcelColumnNegative1,tryCatch.W.E(getExcelColumnFromNumber(-1)))
  checkEquals("RFU",getExcelColumnFromNumber(12345))
}

test.validateCalculatedResultDatatypes <- function() {
  checkIdentical(c("Datatype", "Text", "Number", "Date"),
                 validateCalculatedResultDatatypes(c("Datatype","Text","Number","Date"),
                                                   c("Corporate Batch ID","Rendering Hint","curve id","Max")))
  checkIdentical(c("Datatype", "Text", "Number", "Date"),
                 validateCalculatedResultDatatypes(c("Datatype","Text (none)","Number(shown)","Date (hidden)"),
                                                   c("Corporate Batch ID","Rendering Hint","curve id","Max")))
  
  errorList <<- list()
  checkIdentical(c("Datatype", "frog", "Number", "Date"),
                 validateCalculatedResultDatatypes(c("Datatype","frog","Number","Date"),
                                                   c("Corporate Batch ID","Rendering Hint","curve id","Max")))
  checkIdentical(list("The loader found classes in the Datatype row that it does not understand: 'frog'. Please enter 'Number','Text', or 'Date'."),
                 errorList)
  
  errorList <<- list()
  checkIdentical(c("killer rabbit", "Text", "Number", "Date"),
                 validateCalculatedResultDatatypes(c("killer rabbit","Text","Number","Date"),
                                                   c("Corporate Batch ID","Rendering Hint","curve id","Max")))
  checkIdentical(list("The first row below 'Calculated Results' must begin with 'Datatype'. Right now, it is 'killer rabbit'."),
                 errorList)
  
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/validateCalculatedResultDatatypesFixDatatypes.Rda")
  checkIdentical(validateCalculatedResultDatatypesFixDatatypes,
                 tryCatch.W.E(validateCalculatedResultDatatypes(c("Datatype","numerical peacock","date","string"), 
                                                                c("Corporate Batch ID","Rendering Hint","curve id","Max"))))
  
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/validateCalculatedResultDatatypesMissingDatatype.Rda")
  checkIdentical(validateCalculatedResultDatatypesMissingDatatype,
                 tryCatch.W.E(validateCalculatedResultDatatypes(c("Datatype","","","Number"), 
                                                                c("Corporate Batch ID","Rendering Hint","curve id","Max"))))
}

test.getWarningMessage <- function() {
  checkEquals("This is a warning",getWarningMessage(simpleWarning("This is a warning")))
}

test.getSection <- function() {
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/getSectionNormal.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/getSectionNormalMetaData.Rda")
  checkIdentical(experimentMetaData,getSection(genericDataFileDataFrame,lookFor = "Experiment Meta Data", transpose = TRUE))
  
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/getSectionNormal.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/getSectionNormalCalculatedResults.Rda")
  checkIdentical(calculatedResults,getSection(genericDataFileDataFrame,lookFor = "Calculated Results"))
  
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/getSectionNormal.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/getSectionNormalRawResults.Rda")
  checkIdentical(rawResults,getSection(genericDataFileDataFrame,lookFor = "Raw Results"))
  
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/getSectionMissingRawResultsInput.Rda")
  checkIdentical(NULL,getSection(genericDataFileDataFrame,lookFor = "Raw Results"))
  
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/getSectionMissingExperimentMetaData.Rda")
  checkIdentical(missingExperimentMetaData,tryCatch.W.E(getSection(genericDataFileDataFrame,lookFor="Experiment Meta Data", transpose = TRUE)))
  
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/getSection_MissingCalculatedResults.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/getSection_MissingCalculatedResultsOutput.Rda")
  checkIdentical(output,tryCatch.W.E(getSection(genericDataFileDataFrame,lookFor)))
}

test.validateTreatmentGroupData <- function() {
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/validateTreatmentGroupData_Normal.Rda")
  checkIdentical(list(value=NULL,warningList=list()),
                 tryCatch.W.E(validateTreatmentGroupData(treatmentGroupData,calculatedResults,tempIdLabel)))
  
  errorList <<- list()
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/validateTreatmentGroupData_Missing1Raw.Rda")
  checkIdentical(list(value=NULL,warningList=list()),
                 tryCatch.W.E(validateTreatmentGroupData(treatmentGroupData,calculatedResults,tempIdLabel)))
  checkIdentical(list("In the Raw Results section, there is a temp id that has no match in the Calculated Results section: '7'. Please ensure that all id's have a matching row in the Calculated Results."),errorList)
  
  errorList <<- list()
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/validateTreatmentGroupData_Missing2Raw.Rda")
  checkIdentical(list(value=NULL,warningList=list()),
                 tryCatch.W.E(validateTreatmentGroupData(treatmentGroupData,calculatedResults,tempIdLabel)))
  checkIdentical(list("In the Raw Results section, there are temp id's that have no match in the Calculated Results section: '8', '7'. Please ensure that all id's have a matching row in the Calculated Results."),errorList)
  
  errorList <<- list()
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/validateTreatmentGroupData_TextCurveId.Rda")
  checkIdentical(list(value=NULL,warningList=list()),
                 tryCatch.W.E(validateTreatmentGroupData(treatmentGroupData,calculatedResults,tempIdLabel)))
  checkIdentical(list("In the Calculated Results section, there is a curve id that has text: 'CMP'. Remove text from all temp id's."),errorList)
  
  errorList <<- list()
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/validateTreatmentGroupData_2TextCurveId.Rda")
  checkIdentical(list(value=NULL,warningList=list()),
                 tryCatch.W.E(validateTreatmentGroupData(treatmentGroupData,calculatedResults,tempIdLabel)))
  checkIdentical(list("In the Calculated Results section, there are curve id's that have text: 'CMP', 'CMP'. Remove text from all temp id's."),errorList)  

  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/validateTreatmentGroupData_1ExtraTempId.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/validateTreatmentGroupData_1ExtraTempIdOutput.Rda")
  checkIdentical(validateTreatmentGroupData_1ExtraTempIdOutput,
                 tryCatch.W.E(validateTreatmentGroupData(treatmentGroupData,calculatedResults,tempIdLabel)))
  
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/validateTreatmentGroupData_2ExtraTempId.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/validateTreatmentGroupData_2ExtraTempIdOutput.Rda")
  checkIdentical(validateTreatmentGroupData_2ExtraTempIdOutput,
                 tryCatch.W.E(validateTreatmentGroupData(treatmentGroupData,calculatedResults,tempIdLabel)))
}

test.validateCalculatedResults <- function() {
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/validateCalculatedResults_Normal.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/validateCalculatedResults_NormalOutput.Rda")
  checkIdentical(output,
                 validateCalculatedResults(calculatedResults,preferredIdService=configList$preferredBatchIdService, testMode=TRUE))
  
  errorList <<- list()
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/validateCalculatedResults_Missing.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/validateCalculatedResults_MissingOutput.Rda")
  checkIdentical(output,
                 tryCatch.W.E(validateCalculatedResults(calculatedResults,
                                                        preferredIdService=configList$preferredBatchIdService, 
                                                        testMode=TRUE)))
  checkIdentical(list("Corporate Batch Id 'none_CMPD-0000127-01' has not been registered in the system. Contact your system administrator for help."),
                 errorList)
  
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/validateCalculatedResults_Alias.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/validateCalculatedResults_AliasOutput.Rda")
  checkIdentical(output,
                 tryCatch.W.E(validateCalculatedResults(calculatedResults,
                                                        preferredIdService=configList$preferredBatchIdService, 
                                                        testMode=TRUE)))            
}

test.extractResultTypes <- function() {
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/extractResultTypes_Normal.Rda")
  checkIdentical(extractResultTypes_Normal,
                 extractResultTypes(c("Corporate Batch ID","Rendering Hint", "Reported Max (efficacy)","Fitted Hill slole(-)","hello(","Inhibition (%) [10uM]"),
                                    c("Corporate Batch ID")))
  
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/extractResultTypes_MissingOutput.Rda")
  checkIdentical(output,
                 tryCatch.W.E(extractResultTypes(c("Corporate Batch ID","","Reported Max (efficacy)","Fitted Hill slole(-)","hello(","Inhibition (%) [10uM]"),
                                    c("Corporate Batch ID"))))
}

test.organizeCalculatedResults <- function() {
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/organizeCalculatedResults_NormalOutput.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/organizeCalculatedResults_Normal.Rda")
  checkIdentical(organizedData,organizeCalculatedResults(calculatedResults))
  
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/organizeCalculatedResults_MissingCorpBatchId.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/organizeCalculatedResults_MissingCorpBatchIdOutput.Rda")
  checkIdentical(output,tryCatch.W.E(organizeCalculatedResults(calculatedResults)))
  
  errorList <<- list()
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/organizeCalculatedResults_MissingDatatype.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/organizeCalculatedResults_MissingDatatypeOutput.Rda")
  checkIdentical(output,tryCatch.W.E(organizeCalculatedResults(calculatedResults)))
  checkIdentical(list("The first row below 'Calculated Results' must begin with 'Datatype'. Right now, it is 'Text'."),errorList)
  
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/organizeCalculatedResults_MissingColumns.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/organizeCalculatedResults_MissingColumnsOutput.Rda")
  checkIdentical(output,tryCatch.W.E(organizeCalculatedResults(calculatedResults)))
  
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/organizeCalculatedResults_MissingCorpBatchId.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/organizeCalculatedResults_MissingCorpBatchIdOutput.Rda")
  checkIdentical(output,tryCatch.W.E(organizeCalculatedResults(calculatedResults)))
}

test.organizeRawResults <- function() {
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/organizeRawResults_Normal.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/organizeRawResults_NormalOutput.Rda")
  checkIdentical(output,organizeRawResults(rawResults,calculatedResults))
  
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/organizeRawResults_WrongLabel.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/organizeRawResults_WrongLabelOuptput.Rda")
  checkIdentical(output,tryCatch.W.E(organizeRawResults(rawResults,calculatedResults)))
  
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/organizeRawResults_Empty.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/organizeRawResults_EmptyOutput.Rda")
  checkIdentical(output,tryCatch.W.E(organizeRawResults(rawResults,calculatedResults)))
  
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/organizeRawResults_MissingLabel.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/organizeRawResults_MissingLabelOutput.Rda")
  checkIdentical(output,tryCatch.W.E(organizeRawResults(rawResults,calculatedResults)))
  
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/organizeRawResults_MissingTwoLabels.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/organizeRawResults_MissingTwoLabelsOutput.Rda")
  checkIdentical(output,tryCatch.W.E(organizeRawResults(rawResults,calculatedResults)))
  
}

test.saveValuesFromLongFormat <- function () {
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/saveValuesFromLongFormat_Normal.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/saveValuesFromLongFormat_NormalOutput.Rda")
  checkIdentical(output, saveValuesFromLongFormat(subjectDataWithBatchCodeRows, "subject", stateGroups, lsTransaction, testMode=TRUE))
}

test.meltBatchCodes <- function () {
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/meltBatchCodes_Normal.Rda")
  load("public/src/modules/GenericDataParser/spec/RTestSet/IO_for_test_files/meltBatchCodes_NormalOutput.Rda")
  checkIdentical(output, meltBatchCodes(subjectData, batchCodeStateIndices))
}
