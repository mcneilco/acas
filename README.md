# ACAS (Assay Capture and Analysis System)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](http://www.gnu.org/licenses/gpl-3.0)

This repository Contains the source code for the main ACAS NodeJS/Web app. 

The other required ACAS Open Source Projects can be found here:

 - [ACAS Roo Server](https://github.com/mcneilco/acas-roo-server)
 - [ACAS Compound Registration Roo Server](https://github.com/mcneilco/acas-cmpdreg-roo-server)
 - [Racas](https://github.com/mcneilco/racas)

JM&Co offer a number of commercial ACAS modules. An introduction to ACAS with additional modules is available [here] (http://www.mcneilco.com/acas.html)

This Open Source release includes the Experiment Loader, Dose Response, and Compound Registration modules, as well as the various ACAS APIs.

### ACAS Requirements
* Postgres (or optionally oracle)

### Commercial Third-party (optional) requirements
* Oracle
* Compound Registration 
 * Chemaxon jchembase (with valid license to be obtained at sales [at] chemaxon.com See note in license section of this file)
 * Chemaxon marvinjs (with valid license to be obtained at sales [at] chemaxon.com See note in license section of this file)
 

## Docker installation instructions

We greatly simplified the installation procedure in version 1.10. That version is pre-release, but you can see the instructions in that branch.
If you'd like to deploy the official release version, contact us at support [at] mcneilco.com

## License
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](http://www.gnu.org/licenses/gpl-3.0)
[License] (./LICENSE)

ChemAxon license note: Subject to possession of valid license, you may use ChemAxon's proprietary software JChemBase and Marvin JS under John McNeil &Co., Inc's application as known as ACAS Compound Registration. Note that it is a restricted license, which is not valid for other (open source) applications. Terms and conditions of such license are covered by ChemAxon standard EULA (available at https://docs.chemaxon.com/display/docs/End+User+License+Agreement+(EULA)+LIC) with the exemption of bullet six (6) of section entitled 'YOU MAY NOT'. Please contact ChemAxon for obtaining the license at sales [at] chemaxon.com.

## Copyright
[Copyright (c) 2012-2017 John McNeil & Co. Inc. All rights reserved.] (./COPYRIGHT.txt)
