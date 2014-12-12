#!/bin/bash

HOSTNAMEFQDN=$(hostname --fqdn)
if [ -z "$ACAS_HOME" ]; then
    ACAS_HOME=$(cd "$(dirname "$scriptPath")"/../..; pwd)
fi
echo "ACAS_HOME=$ACAS_HOME"
source /dev/stdin <<< "$(cat $ACAS_HOME/conf/compiled/conf.properties | awk -f $ACAS_HOME/conf/readproperties.awk)"
echo "client.host=$client_host"
if [ "$client_host" == "localhost" ];then
    echo "client_host is set to localhost"
    read -r -p "Are you sure that this is the path from the user back to the client host?? [y/N] " response
    response=${response,,}    # tolower
    if [[ $response =~ ^(yes|y)$ ]];then
        echo "continuing with localhost"
    else
        echo "set the client.host property in config.properties"
        echo "exiting"
        exit 1
    fi
fi

curl -i -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '[
{typeName: "default"}
]' http://localhost:8080/acas/protocoltypes/jsonArray

curl -i -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '[
{kindName: "default", lsType:{id:1, version:0}},
{kindName: "flipr screening assay", lsType:{id:1, version:0}}
]' http://localhost:8080/acas/protocolkinds/jsonArray


curl -i -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '[
{typeName: "default"}
]' http://localhost:8080/acas/experimenttypes/jsonArray

curl -i -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '[
{kindName: "default", lsType:{id:1, version:0}}
]' http://localhost:8080/acas/experimentkinds/jsonArray





curl -i -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '[
{typeVerb: "first added to second", typeName:"added to"},
{typeVerb: "first removed from second", typeName:"removed from"},
{typeVerb: "first operated on second", typeName:"operated on"},
{typeVerb: "first created by second", typeName:"created by"},
{typeVerb: "first destroyed by second", typeName:"destroyed by"},
{typeVerb: "first refers to second", typeName:"refers to"},
{typeVerb: "first has second as a member", typeName:"has member"},
{typeVerb: "first was moved to second", typeName:"moved to"},
{typeVerb: "contents of first were transferred to second", typeName:"transferred to"}
]' http://localhost:8080/acas/interactiontypes/jsonArray

curl -i -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '[
{kindName: "test subject", lsType:{id:6, version:0}},
{kindName: "plate well", lsType:{id:7, version:0}}
]' http://localhost:8080/acas/interactionkinds/jsonArray


curl -i -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '[
{typeName: "material"},
{typeName: "plate"},
{typeName: "well"}
]' http://localhost:8080/acas/containertypes/jsonArray

curl -i -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '[
{kindName: "animal", lsType:{id:1, version:0}},
{kindName: "384 well compound plate", lsType:{id:2, version:0}},
{kindName: "plate well", lsType:{id:3, version:0}}
]' http://localhost:8080/acas/containerkinds/jsonArray


curl -i -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '[
{typeName: "metadata"},
{typeName: "data"},
{typeName: "constants"},
{typeName: "status"}
]' http://localhost:8080/acas/statetypes/jsonArray

curl -i -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '[
{kindName: "raw results locations", lsType:{id:1, version:0}},
{kindName: "experiment metadata", lsType:{id:1, version:0}},
{kindName: "dose response", lsType:{id:2, version:0}},
{kindName: "results", lsType:{id:2, version:0}},
{kindName: "test compound treatment", lsType:{id:2, version:0}},
{kindName: "animal information", lsType:{id:1, version:0}},
{kindName: "treatment", lsType:{id:2, version:0}},
{kindName: "raw data", lsType:{id:2, version:0}},
{kindName: "calculated data", lsType:{id:2, version:0}},
{kindName: "report locations", lsType:{id:1, version:0}},
{kindName: "plate format", lsType:{id:3, version:0}},
{kindName: "test compound content", lsType:{id:4, version:0}},
{kindName: "solvent content", lsType:{id:4, version:0}},
{kindName: "transfer data", lsType:{id:2, version:0}},
{kindName: "protocol metadata", lsType:{id:1, version:0}},
{kindName: "plate information", lsType:{id:1, version:0}},
{kindName: "subject metadata", lsType:{id:1, version:0}}
]' http://localhost:8080/acas/statekinds/jsonArray


curl -i -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '[
{typeName: "stringValue"},
{typeName: "fileValue"},
{typeName: "urlValue"},
{typeName: "dateValue"},
{typeName: "clobValue"},
{typeName: "blobValue"},
{typeName: "numericValue"},
{typeName: "codeValue"},
{typeName: "inlineFileValue"}
]' http://localhost:8080/acas/valuetypes/jsonArray

curl -i -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '[
{kindName: "batch code", lsType:{id:8, version:0}},
{kindName: "tested concentration", lsType:{id:7, version:0}},
{kindName: "source file", lsType:{id:2, version:0}},
{kindName: "notebook", lsType:{id:1, version:0}},
{kindName: "notebook page", lsType:{id:1, version:0}},
{kindName: "completion date", lsType:{id:4, version:0}},
{kindName: "scientist", lsType:{id:1, version:0}},
{kindName: "status", lsType:{id:1, version:0}},
{kindName: "analysis status", lsType:{id:1, version:0}},
{kindName: "analysis result html", lsType:{id:5, version:0}},
{kindName: "project", lsType:{id:8, version:0}},
{kindName: "time", lsType:{id:7, version:0}},
{kindName: "Rendering Hint", lsType:{id:1, version:0}},
{kindName: "curve id", lsType:{id:1, version:0}},
{kindName: "Dose", lsType:{id:7, version:0}},
{kindName: "Response", lsType:{id:7, version:0}},
{kindName: "flag", lsType:{id:1, version:0}},
{kindName: "annotation file", lsType:{id:2, version:0}},
{kindName: "rows", lsType:{id:7, version:0}},
{kindName: "columns", lsType:{id:7, version:0}},
{kindName: "wells", lsType:{id:7, version:0}},
{kindName: "concentration", lsType:{id:7, version:0}},
{kindName: "volume", lsType:{id:7, version:0}},
{kindName: "date prepared", lsType:{id:4, version:0}},
{kindName: "report file", lsType:{id:2, version:0}},
{kindName: "target", lsType:{id:1, version:0}},
{kindName: "assay format", lsType:{id:1, version:0}},
{kindName: "experiment status", lsType:{id:1, version:0}},
{kindName: "control type", lsType:{id:1, version:0}},
{kindName: "reader instrument", lsType:{id:1, version:0}},
{kindName: "data source", lsType:{id:1, version:0}},
{kindName: "data transformation rule", lsType:{id:1, version:0}},
{kindName: "normalization rule", lsType:{id:1, version:0}},
{kindName: "active efficacy threshold", lsType:{id:7, version:0}},
{kindName: "active SD threshold", lsType:{id:7, version:0}},
{kindName: "curve min", lsType:{id:7, version:0}},
{kindName: "curve max", lsType:{id:7, version:0}},
{kindName: "replicate aggregation", lsType:{id:1, version:0}},
{kindName: "barcode", lsType:{id:8, version:0}},
{kindName: "seq file", lsType:{id:2, version:0}},
{kindName: "min file", lsType:{id:2, version:0}},
{kindName: "max file", lsType:{id:2, version:0}},
{kindName: "raw r results location", lsType:{id:2, version:0}},
{kindName: "data results location", lsType:{id:2, version:0}},
{kindName: "summary location", lsType:{id:2, version:0}},
{kindName: "well type", lsType:{id:1, version:0}},
{kindName: "well name", lsType:{id:1, version:0}},
{kindName: "maximum", lsType:{id:7, version:0}},
{kindName: "minimum", lsType:{id:7, version:0}},
{kindName: "fluorescent", lsType:{id:1, version:0}},
{kindName: "transformed efficacy", lsType:{id:7, version:0}},
{kindName: "normalized efficacy", lsType:{id:7, version:0}},
{kindName: "over efficacy threshold", lsType:{id:1, version:0}},
{kindName: "fluorescencePoints", lsType:{id:5, version:0}},
{kindName: "timePoints", lsType:{id:5, version:0}},
{kindName: "data analysis parameters", lsType:{id:5, version:0}},
{kindName: "description", lsType:{id:5, version:0}},
{kindName: "comparison graph", lsType: {id:9, version:0}},
{kindName: "previous experiment code", lsType:{id:8, version:0}},
{kindName: "late peak", lsType:{id:1, version:0}},
{kindName: "max time", lsType:{id:7, version:0}},
{kindName: "has agonist", lsType:{id:1, version:0}}
]' http://localhost:8080/acas/valuekinds/jsonArray


curl -i -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '[
{typeName: "name"},
{typeName: "barcode"}
]' http://localhost:8080/acas/labeltypes/jsonArray

curl -i -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '[
{kindName: "protocol name", lsType:{id:1, version:0}},
{kindName: "experiment name", lsType:{id:1, version:0}},
{kindName: "container name", lsType:{id:1, version:0}},
{kindName: "plate barcode", lsType:{id:2, version:0}},
{kindName: "well name", lsType:{id:1, version:0}}
]' http://localhost:8080/acas/labelkinds/jsonArray


curl -i -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '[
{typeName: "comparison"},
{typeName: "mathematical"},
{typeName: "boolean"}
]' http://localhost:8080/acas/operatortypes/jsonArray

curl -i -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '[
{kindName: ">", lsType:{id:1, version:0}},
{kindName: "<", lsType:{id:1, version:0}},
{kindName: "<=", lsType:{id:1, version:0}},
{kindName: ">=", lsType:{id:1, version:0}},
{kindName: "=", lsType:{id:1, version:0}}
]' http://localhost:8080/acas/operatorkinds/jsonArray


curl -i -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '[
{typeName: "PK"},
{typeName: "time"},
{typeName: "frequency"},
{typeName: "concentration"},
{typeName: "mass"},
{typeName: "specific volume"},
{typeName: "percentage"},
{typeName: "volume"},
{typeName: "length"},
{typeName: "density"},
{typeName: "pressure"},
{typeName: "energy"},
{typeName: "power"}
]' http://localhost:8080/acas/unittypes/jsonArray

curl -i -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '[
{kindName: "1/hr", lsType:{id:3, version:0}},
{kindName: "hr", lsType:{id:2, version:0}},
{kindName: "ng/mL", lsType:{id:4, version:0}},
{kindName: "kg*ng/mL/mg", lsType:{id:1, version:0}},
{kindName: "hr*ng/mL", lsType:{id:1, version:0}},
{kindName: "%", lsType:{id:7, version:0}},
{kindName: "hr*hr*ng/mL", lsType:{id:1, version:0}},
{kindName: "L/kg", lsType:{id:6, version:0}},
{kindName: "mL/min/kg", lsType:{id:1, version:0}},
{kindName: "mg/kg", lsType:{id:4, version:0}},
{kindName: "g", lsType:{id:5, version:0}},
{kindName: "min", lsType:{id:2, version:0}},
{kindName: "% Freezing", lsType:{id:7, version:0}}
]' http://localhost:8080/acas/unitkinds/jsonArray

curl -i -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '[
{"digits":8,"groupDigits":false, "labelPrefix":"PROT","labelSeparator":"-","labelTypeAndKind":"id_codeName","latestNumber":1, "thingTypeAndKind":"document_protocol"},
{"digits":8,"groupDigits":false, "labelPrefix":"EXPT","labelSeparator":"-","labelTypeAndKind":"id_codeName","latestNumber":1, "thingTypeAndKind":"document_experiment"},
{"digits":8,"groupDigits":false, "labelPrefix":"AG","labelSeparator":"-","labelTypeAndKind":"id_codeName","latestNumber":1, "thingTypeAndKind":"document_analysis group"},
{"digits":8,"groupDigits":false, "labelPrefix":"TG","labelSeparator":"-","labelTypeAndKind":"id_codeName","latestNumber":1, "thingTypeAndKind":"document_treatment group"},
{"digits":8,"groupDigits":false, "labelPrefix":"SUBJ","labelSeparator":"-","labelTypeAndKind":"id_codeName","latestNumber":1, "thingTypeAndKind":"document_subject"},
{"digits":8,"groupDigits":false, "labelPrefix":"CONT","labelSeparator":"-","labelTypeAndKind":"id_codeName","latestNumber":1, "thingTypeAndKind":"material_container"},
{"digits":8,"groupDigits":false, "labelPrefix":"CITX","labelSeparator":"-","labelTypeAndKind":"id_codeName","latestNumber":1, "thingTypeAndKind":"interaction_containerContainer"},
{"digits":8,"groupDigits":false, "labelPrefix":"SITX","labelSeparator":"-","labelTypeAndKind":"id_codeName","latestNumber":1, "thingTypeAndKind":"interaction_subjectContainer"}
]' http://localhost:8080/acas/labelsequences/jsonArray

if [ "$client_use_ssl" == 'true' ]; then
 urlPrefix=https
else
 urlPrefix=http
fi

curl -i -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '[
{propName:"BatchDocumentsURL", propValue: "'$urlPrefix'://'$client_host':'${client_port}'/dataFiles/"},
{propName:"batch_code_experiment_url", propValue: "'$urlPrefix'://'$client_host':'${client_port}'/flipr_screening_assay/codeName/"}
]' http://localhost:8080/acas/applicationsettings/jsonArray
