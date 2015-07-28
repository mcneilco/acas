# PrimaryScreen Module #

## Description ##

This module takes instrument files that are uploaded by a user, parses them, gets compound information, performs calculations, creates graphs, and saves to an ACAS database. There are also options to produce a Spotfire file and upload a well flagging file.


## File Organization Overview ##

The file structure has been put together with the intent to make the analysis modular - making it easier to change calculations and instruments as the customer changes. We don't want all of the different instrument formats to be available to a customer unless they have "paid" for it, and also we don't want all of the instrument types available to all customers. We also have different calculations as determined by the customer. Because of this, specific folders are sourced within the primaryScreen code so that you can take out the "performCalculations.R" code for one customer and insert the "performCalculation.R" code for a different customer. (This is also the case for specificDataPreProcessor.R, getCompoundAssignment.R, and createPDF.R.)


## Stepping through the code ##

The user sets the positive and negative controls in the GUI. They also upload a zip file that contains files produced by the instrument reader. This zip file should contain certain specific items, depending on the client and which parser is being used. 

![GUI Controls](./spec/readmeResources/primaryScreen-controls.png)

Currently, this readme only covers zip files that contain a single plate association file (.csv) and plate files (.txt) that are listed in the plate association file. There will also be zip files that contain a different set of files - this capability has not yet been merged in as of 7/22/2015.


### Specific Data Pre Processor ###
aka instrument file parsing (rdap)

This expects a **plate association** file as a .csv and **plate/instrument file(s)** that are .txt. There should be a plate file for every row in the plate association file. If there are not, then an error is thrown. If there are .txt files that are not in the plate association file, then a warning is thrown.


#### Plate Association File ####

2-3 columns (no headers) are expected in each association file. The first column is always the assay plate barcode. The parser uses this barcode to find the correct file to parse. The other column(s) are the compound plate barcodes. If there are 3 columns, the 2nd column is the sidecar barcode. 


#### Instrument Files ####

The .txt files cannot be parsed until the instrument parameters have been loaded in to the ACAS file system.

The instruments that are included in the current system can be found in ./src/conf/instruments. To add other instruments, put their folders in this location.

The instruments folder holds three items:
1. **detectionLine.json** - This contains the "magic line" that is found in the first 10 lines of code in the .txt file for this instrument. This is used to verify that the instrument that the user put in to the GUI matches the instrument that created the .txt files.
2. **instrumentType.json** - This contains the instrument name. This is used to verify that the instrument folders were loaded correctly.
3. **paramList.json** - This contains the parameters used for parsing the instrument files. 

The instrument classes can be found in ./src/server/instrumentSpecific
The instrumentSpecific folder holds the actual code that will be used to parse the files. 


### Compound Assignment ###

Once the instrument files have been parsed, the compound plate information (compound plate barcodes are found in the plate association file) will be queried from the customer database. This information is then merged in to the result from the instrument parsing files.

Controls will be marked based on client input from the GUI. 


### Calculations ###

"Canned" read calculations are performed (eg, R1/R2). These are based off other reads as specified in the GUI. 

"Internal" calculations are all based off the 'activity' column as defined by the user in the GUI. These calculations include:

1. **Normalization** - normalizes to the positive and negative controls. Two-step normalization is also a part of this - eg, normalizing by plate order and then normalizing by row (across all plates).
2. **Transformed: Percent efficacy** - uses the normalized activity
3. **Transformed: SD Score** - uses the normalized activity
4. **Z Prime calculations** - uses the normalized activity but also includes raw (off the raw activity numbers) Z' and Z' by plate








