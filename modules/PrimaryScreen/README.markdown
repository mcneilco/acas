# PrimaryScreen Module #

## Description ##

This module takes assay plate files that are uploaded by a user, parses them, gets compound information, performs calculations, creates graphs, and saves to an ACAS database. There are also options to produce a Spotfire file and upload a well flagging file.


## File Organization Overview ##

The file structure has been put together with the intent to make the analysis modular - making it easier to change calculations and instruments as the customer changes. We also have different calculations as determined by the customer. Because of this, specific folders are sourced within the primaryScreen code so that you can take out the "performCalculations.R" code for one customer and insert the "performCalculation.R" code for a different customer. (This is also the case for specificDataPreProcessor.R, getCompoundAssignment.R, and createPDF.R.)


## Stepping through the code ##

The user sets the positive and negative controls in the GUI. They also upload a zip file that contains files produced by the instrument reader. This zip file should contain certain specific items, depending on the client and which parser is being used. 

![GUI Controls](./spec/readmeResources/primaryScreen-controls.png)

Currently, this readme only covers zip files that contain a single plate association file (.csv) and plate files (.txt) that are listed in the plate association file. There will also be zip files that contain a different set of files - this capability has not yet been merged in as of 7/22/2015.


### Specific Data Pre Processor ###
aka assay plate file parsing (rdap)

This expects a **plate association** file as a .csv and **plate/assay plate file(s)** that are .txt. There should be a plate file for every row in the plate association file. If there are not, then an error is thrown. If there are .txt files that are not in the plate association file, then a warning is thrown.


#### Plate Association File ####

* 2-3 columns (no headers) are expected in each association file. 
* Comma delimited
* The first column is always the assay plate barcode. The parser uses this barcode to find the correct file to parse. 
* The other column(s) are the compound plate barcodes. If there are 3 columns, the 2nd column is the sidecar barcode. 


#### Assay Plate Files ####

The .txt files cannot be parsed until the instrument parameters have been loaded in to the ACAS file system.

The instruments that are included in the current system can be found in ./src/conf/instruments. To add other instruments, put their folders in this location.

The instruments folder holds three items:

1. **detectionLine.json** - This contains the "magic line" that is found in the first 10 lines of code in the .txt file for this instrument. This is used to verify that the instrument that the user put in to the GUI matches the instrument that created the .txt files.
2. **instrumentType.json** - This contains the instrument name. This is used to verify that the instrument folders were loaded correctly.
3. **paramList.json** - This contains the parameters used for parsing the assay plate files. 


##### Instrument Read Param List #####

1. **header row search string** - this field should usually be filled in. If files from an instrument do not have a well-defined header row, then this field can be NA. This goes hand in hand with **header exists** - if this is NA, then that needs to be FALSE.
2. **data row search string** - this field should be what the first part of the first row of actual data looks like
3. **separation character** - this is what the assay plate file uses as a separation character - eg "\t" or ","
4. **header exists** - TRUE or FALSE - see comments on **header row search string**
5. **begin data column number** - this is the column that the data begins at. If the **data format** is **list format**, this item is not used
6. **data title identifier** - this is only used in **plate format - multi-file** instruments. This is used to parse out the individual titles for the multiple data sets
7. **data format** - this defines the instrument class


#### Instrument Classes ####
see Instrument Read Param List above (#7)

The instrument classes can be found in ./src/server/instrumentSpecific

These folders contain the actual code that will be used to parse the files. There are currently three main instrument classes:

1. **List Format - Single File per plate** - these files have data in a "list" format - every well has a single row - and there is only one data set per file
2. **Plate Format - Single File per plate** - these files have data in a "plate" format - the data is in an assay plate row by column format so needs to be transposed so that every well has a single row - and there is only one data set per file
3. **Plate Format - Multi Files per plate** - these files also have data in a "plate format", but there are multiple data sets per file. Coding for this format has not been completed as of 7/31/2015


#### Expected Output of Specific Data Pre Processor ####

Named list with three items:

1. **plateAssociationDT** - derived from the plate association file, this will include up to 8 columns:

  * **plateOrder** - (numeric): an index of the plate order
  
  * **readPosition** - (numeric): an index of the read within the assay plate file
  
  * **assayBarcode** - (text): taken from the plate association file
  
  * **compoundBarcode_1** - (text): taken from the plate association file, this will just be compoundBarcode if there are only 2 columns in the plate association file
  
  * **sidecarBarcode** - (text): taken from the plate association file, this will not show up if there are only 2 columns in the plate association file
  
  * **assayFileName** - (text): the name of the file associated with the assayBarcode
  
  * **instrumentType** - (text): the verified instrument for each file - this will match what the user input
  
  * **dataTitle** - (text) the titles/reads that are found in the assay plate file
  
2. **assayData** - this is the result of parsing the assay plate files, this will have a row per well and includes the following columns:

  * **assayFileName** - (text): the name of the file associated with the assayBarcode
  
  * **assayBarcode** - (text): taken from the plate association file
  
  * **plateOrder** - (numeric): the plate that the well is found on
  
  * **rowName** - (text): the row designation, buffered to 2 characters with a "-". (eg: "-A" or "AA")
  
  * **colName** - (text): the column designation, buffered to 2 characters with a "0" **verify this with a plate format instrument**
  
  * **wellReference** - (text): the concatenation of rowName and colName with the last three characters being the column (eg: A001 for row A column 1 & A012 for row A column 12)
  
  * data - there will be one column for every **dataTitle** found in the **plateAssociationDT**
  
3. **userInputReadTable** - this is a read table based off the reads from the GUI with some extra columns

  * **userReadOrder** - (numeric) - 1:n, in the order as received from the GUI
  
  * **userReadPosition** - (numeric) - received from the GUI - this is the column # that the data is found in (or, in the case of plate format instruments, the nth position of the data)
  
  * **userReadName** - (text) - this is provided by d dict values
  
  * **activityCol** - TRUE or FALSE (only one can be TRUE) - this is the read that will be used as the "raw values" for all of the calculations
  
  * **calculatedRead** - TRUE or FALSE - this is determined by the code based on the read name (it recognizes reads that begin with "Calc:" as calculated reads
  
  * **activityColName** - (text) - this is the activity name identified by the code based off the read position
  
  * **newActivityColName** - (text) - this is what will replace the **activityColName** in the data, the format is: "Rn {read name}" (eg: "R3 {Calc: R2/R1}")


### Compound Assignment ###

Once the assay plate files have been parsed, the compound plate information (compound plate barcodes are found in the plate association file) will be queried from the customer database based on the compound plate barcodes. The expected fields from this query are:
* **cmpdBarcode**
* **plateType**
* **wellReference** - same format as found in **assayData** above
* **corp_name**
* **batch_number**
* **cmpdConc**
* **supplier**

This information is then merged in to the result from the instrument parsing files. 

Controls will be marked based on client input from the GUI (both the compound barcode and the concentration that it was tested at).


### Calculations ###

"Canned" read calculations are performed (eg, R1/R2). These are based off other reads as specified in the GUI. 

"Internal" calculations are all based off the 'activity' column as defined by the user in the GUI. These calculations include:

1. **Normalization** - normalizes to the positive and negative controls. Two-step normalization is also a part of this - eg, normalizing by plate order and then normalizing by row (across all plates).
2. **Transformed: Percent efficacy** - uses the normalized activity
3. **Transformed: SD Score** - uses the normalized activity
4. **Z Prime calculations** - uses the normalized activity but also includes raw (off the raw activity numbers) Z' and Z' by plate