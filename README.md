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
 
## ACAS Documentation
[Public Documentation Table of Contents](https://docs.google.com/document/d/1tPz5VliAhCD0sELDsZlNvt9jcGiNxi7iQQB4NJ1120Y/edit?usp=sharing)

## Release Notes
[https://github.com/mcneilco/acas/releases](https://github.com/mcneilco/acas/releases)

## Docker installation instructions

ACAS has been configured to run a full stack in the docker environment.  The instructions below outline the process of getting a basic working stack running on your system.

Some of the docker images in the ACAS stack are available in the mcneilco dockerhub repository while others (due to license restrictions) must be built by the developer.

Available Images:

* [ACAS](https://hub.docker.com/r/mcneilco/acas-oss)
* [RACAS](https://hub.docker.com/r/mcneilco/racas-oss)
* [ACAS-Postgres](https://hub.docker.com/r/mcneilco/acas-postgres)

Images Built by Developer (instructions below):

* ACAS Roo Server
* ACAS Compound Registration Roo Server

### Requirements

* [Docker](https://www.docker.com)
 * [Docker for Mac](https://docs.docker.com/docker-for-mac/)
 * [Docker for Windows](https://docs.docker.com/docker-for-windows/)

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
```

##### Build
```
docker build -t mcneilco/acas-roo-server-oss:latest .
```

#### Building a working image for Compound Registration ROO Server
##### Checkout

```
cd ~/Documents/mcneilco/oss/
git clone git@github.com:mcneilco/acas-cmpdreg-roo-server.git
cd acas-cmpdreg-roo-server
```

##### Add chemaxon jar file


* Go to [https://www.chemaxon.com](https://www.chemaxon.com)
* Login and/or Sign-Up
* Click Download > JChem Suite > JChem
* Scroll down to Archives and select 16.4.25.0, click Get Archive
* Download [jchem-merged-lib-16.4.25.0.zip](https://chemaxon.com/download?dl=%2Fdata%2Fdownload%2Fjchem%2F16.4.25.0%2Fjchem-merged-lib-16.4.25.0.zip)
* Unzip it and rename jchem.jar to jchem-16.4.25.0.jar

##### Add chemaxon jar file to a lib folder in the checkout

```
cd ~/Documents/mcneilco/oss/acas-cmpdreg-roo-server
mkdir lib
cd lib
cp <jchem-16.4.25.0.jar> .
cd ..
```
##### Build

```
docker build -t mcneilco/acas-cmpdreg-roo-server-oss:latest .
```

#### ACAS
The acas repository contains a docker-compose.yml file that orchestrates the creation of the ACAS stack.  For this reason, it is helpful to have a clone of the ACAS repo even if you aren't doing ACAS development or don't need compound registration.

##### Checkout
```
cd ~/Documents/mcneilco/oss/
git clone git@github.com:mcneilco/acas.git
cd acas
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

Visit `http://localhost:3000` in your browser to login. You will need to create a user in order to access the web app: 

```bash
curl localhost:3001/api/systemTest/getOrCreateACASBob
curl localhost:3001/api/systemTest/getOrCreateGlobalProject
curl localhost:3001/api/systemTest/getOrCreateGlobalProjectRole
curl localhost:3001/api/systemTest/giveBobRoles
curl localhost:3001/api/systemTest/getOrCreateCmpdRegBob
curl localhost:3001/api/systemTest/syncRoles
```
Optionally you could run the shell script `docker_bob_setup.sh` in this repository instead of manually `curl`ing each endpoint.

This will create a user "bob" with password "secret". 

#### Viewing logs

```
docker-compose logs --tail=20 -f <service>
```

e.g. for all containers

```
docker-compose logs -f 
```

e.g. for only tomcat

```
docker-compose logs --tail=20 -f tomcat
```

Stop the web stack

```bash
docker-compose down
```

#### Troubleshooting

* There is a known timing issue where tomcat may try to connect to the database before the database is accepting connections.  If this happens, try restarting tomcat.

```
docker-compose restart tomcat
```

## Configuration


### Environment variable configuration overrides

ACAS can read configuration overrides from environment variables prefixed with `ACAS_`.  ACAS maps environment variable names to flat file configuration names by a 4 step process (e.g. `ACAS_CLIENT_MODULEMENUS_LOGOTEXT=ACME Labs`):

1. Match any environment variable name prefixed with `ACAS_` and remove the prefix from the name. 

Step output: CLIENT_MODULEMENUS_LOGOTEXT

2. Replace `_` characters with `.` characters in the environment variable name.
> Note, that you can escape substitution for flat file configs contain underscore by using double underscores `__` in the environment variable.

Step output: ACAS.CLIENT.MODULEMENUS.LOGOTEXT

3. Do a case insensitive match of the now processed environment variable name with a flat file configuration name.

Match: `client.moduleMenus.logoText`

4. Replace the value in the flat file name with the value provided by the matched environment variable.

Final outcome: client.moduleMenus.logoText=ACME Labs

#### Example environment variables:

##### Simple override: 
Replaces `client.moduleMenus.logoText`
```
ACAS_CLIENT_MODULEMENUS_LOGOTEXT=ACME Labs
```

Escape character usage using `__`
Replaces `server.datafiles.relative_path` (note this isn't a realistic example of a config you would ever override but demonstrates the escape sequence)
```
ACAS_SERVER_DATAFILES_RELATIVE__PATH=..
```

##### Override containing configs which will be replaced with other configs:
Replaces `client.service.cmpdReg.persistence.fullpath`
```
 - ACAS_CLIENT_SERVICE_CMPDREG_PERSISTENCE_FULLPATH=http://$${client.service.cmpdReg.persistence.host}:$${client.service.persistence.port}/$${client.service.cmpdReg.persistence.path}/
```

Shell example requires escape `$`
```
ACAS_CLIENT_SERVICE_CMPDREG_PERSISTENCE_FULLPATH=http://\${client.service.cmpdReg.persistence.host}:\${client.service.persistence.port}/\${client.service.cmpdReg.persistence.path}/
```
or

```
ACAS_CLIENT_SERVICE_CMPDREG_PERSISTENCE_FULLPATH='http://${client.service.cmpdReg.persistence.host}:${client.service.persistence.port}/${client.service.cmpdReg.persistence.path}/'
```



## License
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](http://www.gnu.org/licenses/gpl-3.0)
[License] (./LICENSE)

ChemAxon license note: Subject to possession of valid license, you may use ChemAxon's proprietary software JChemBase and Marvin JS under John McNeil &Co., Inc's application as known as ACAS Compound Registration. Note that it is a restricted license, which is not valid for other (open source) applications. Terms and conditions of such license are covered by ChemAxon standard EULA (available at https://docs.chemaxon.com/display/docs/End+User+License+Agreement+(EULA)+LIC) with the exemption of bullet six (6) of section entitled 'YOU MAY NOT'. Please contact ChemAxon for obtaining the license at sales [at] chemaxon.com.

## Copyright
[Copyright (c) 2012-2016 John McNeil & Co. Inc. All rights reserved.] (./COPYRIGHT.txt)
