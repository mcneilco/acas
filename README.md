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

ACAS has been configured to run a full stack in the docker environment.  The instructions below outline the process of getting a basic working stack running on your system.

Some of the docker images in the ACAS stack are available in the mcneilco dockerhub repository while others (due to license restrictions) must be built by the developer.

Available Images:

* [ACAS] (https://hub.docker.com/r/mcneilco/acas-oss)
* [RACAS] (https://hub.docker.com/r/mcneilco/racas-oss)
* [ACAS-Postgres] (https://hub.docker.com/r/mcneilco/acas-postgres)

Images Built by Developer (instructions below):

* ACAS Roo Server
* ACAS Compound Registration Roo Server

### Requirements

* [Docker] (https://www.docker.com)
 * [Docker for Mac] (https://docs.docker.com/docker-for-mac/)
 * [Docker for Windows] (https://docs.docker.com/docker-for-windows/)

### Installation

#### Docker settings

Download and install docker for your operating system.  


##### Memory
It is recommended to run the stack with at least `4GB` of memory but is helpful to have up to `8GB` available.  Docker for mac and windows do not need to reserve the entire 8GB for itself so it's ok to give it a little extra if you have it available.

See docker instructions for you operating system to adjust

#### Make a working folder

```
mkdir -p ~/Documents/mcneilco/oss/
```

#### Building a working image for ACAS Roo Server

Due to license restrictions, this is one of the images that must be built by the developer.

##### Checkout

```
cd ~/Documents/mcneilco/oss/
git clone git@github.com:mcneilco/acas-roo-server.git
cd acas-roo-server
git checkout 1.10-release
```

##### Build
```
cd ~/Documents/mcneilco/oss/acas-roo-server
docker build -t mcneilco/acas-roo-server-oss:1.10.0 .
```

#### Building a working image for Compound Registration ROO Server
##### Checkout

```
cd ~/Documents/mcneilco/oss/
git clone git@github.com:mcneilco/acas-cmpdreg-roo-server.git
cd acas-cmpdreg-roo-server
git checkout 1.10-release
```

##### Build
```
cd ~/Documents/mcneilco/oss/acas-cmpdreg-roo-server
mkdir lib
cd lib
curl -O http://trac.labsynch.com/maven-repository/com/chemaxon/jchem/16.4.25.0/jchem-16.4.25.0.jar
cd ..
docker build -t mcneilco/cmpdreg-oss:1.10.0 .
```

#### ACAS
The acas repository contains a docker-compose.yml file that orchestrates the creation of the ACAS stack.  For this reason, it is helpful to have a clone of the ACAS repo even if you aren't doing ACAS development or don't need compound registration.

##### Checkout
```
cd ~/Documents/mcneilco/oss/
git clone git@github.com:mcneilco/acas.git
cd acas
git checkout 1.10-release
```

##### Add chemaxon licenses and download marvin4js

```
mkdir -p chemaxon/licenses
```

##### Place your marvin4js-license.cxl and license.cxl (jchem base license) as follows:

```
cp <path/to/marvin4js-license.cxl> chemaxon/licenses
cp <path/to/license.cxl> chemaxon/licenses
```

Place your marvin4js download into a folder called "marvinjs" as follows:

```
cp -r <path/to/marvinjs-16.10.17-all> chemaxon/marvinjs
```

#### Start acas stack

```
cd ~/Documents/mcneilco/oss/acas
docker-compose up -d
```

#### Login
```
http://localhost:3000
```

#### Viewing logs

docker-compose logs --tail=20 -f <service>

e.g. for all containers
```
docker-compose logs --tail=20 -f 
```

e.g. for only tomcat

```
docker-compose logs --tail=20 -f tomcat
```

#### Troubleshooting

* There is a known timing issue where tomcat may try to connect to the database before the database is accepting connections.  If this happens, try restarting tomcat.

```
docker-compose restart tomcat
```

## License
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](http://www.gnu.org/licenses/gpl-3.0)
[License] (./LICENSE)

ChemAxon license note: Subject to possession of valid license, you may use ChemAxon's proprietary software JChemBase and Marvin JS under John McNeil &Co., Inc's application as known as ACAS Compound Registration. Note that it is a restricted license, which is not valid for other (open source) applications. Terms and conditions of such license are covered by ChemAxon standard EULA (available at https://docs.chemaxon.com/display/docs/End+User+License+Agreement+(EULA)+LIC) with the exemption of bullet six (6) of section entitled 'YOU MAY NOT'. Please contact ChemAxon for obtaining the license at sales [at] chemaxon.com.

## Copyright
[Copyright (c) 2012-2016 John McNeil & Co. Inc. All rights reserved.] (./COPYRIGHT.txt)
