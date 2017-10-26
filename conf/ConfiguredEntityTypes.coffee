exports.entityTypes = [
    code: 'Corporate Parent ID'
    type: 'compound'
    kind: 'parent name'
    codeOrigin: 'ACAS CmpdReg'
    displayName: 'Corporate Parent ID'
    sourceExternal: true
    parent: true
  ,
    code: 'Corporate Batch ID'
    type: 'compound'
    kind: 'batch name'
    codeOrigin: 'ACAS CmpdReg'
    displayName: 'Corporate Batch ID'
    sourceExternal: true
    parent: false
  ,
    code: 'Protein Parent'
    type: 'parent'
    kind: 'protein'
    codeOrigin: 'ACAS LsThing'
    displayName: 'Protein Parent'
    sourceExternal: false
    parent: true
  ,
    code: 'Protein Batch'
    type: 'batch'
    kind: 'protein'
    codeOrigin: 'ACAS LsThing'
    displayName: 'Protein Batch'
    sourceExternal: false
    parent: false
  ,
    code: 'Gene ID'
    type: 'gene'
    kind: 'entrez gene'
    codeOrigin: 'ACAS LsThing'
    displayName: 'Gene ID'
    sourceExternal: false
    parent: false
  ,
    code: 'Container Plate'
    type: 'container'
    kind: 'plate'
    codeOrigin: 'ACAS LsContainer'
    displayName: 'Plate'
    sourceExternal: false
    parent: false
    model: require("../routes/ServerUtilityFunctions.js").ContainerPlate
  ,
    code: 'Container Tube'
    type: 'container'
    kind: 'tube'
    codeOrigin: 'ACAS LsContainer'
    displayName: 'Tube'
    sourceExternal: false
    parent: false
    model: require("../routes/ServerUtilityFunctions.js").ContainerTube
  ,
    code: 'Definition Container Plate'
    type: 'definition container'
    kind: 'plate'
    codeOrigin: 'ACAS LsContainer'
    displayName: 'Definition Plate'
    sourceExternal: false
    parent: false
    model: require("../routes/ServerUtilityFunctions.js").DefinitionContainerPlate
  ,
    code: 'Definition Container Tube'
    type: 'definition container'
    kind: 'tube'
    codeOrigin: 'ACAS LsContainer'
    displayName: 'Definition Tube'
    sourceExternal: false
    parent: false
    model: require("../routes/ServerUtilityFunctions.js").DefinitionContainerTube
  ,
    code: 'Solution Container Tube'
    type: 'container'
    kind: 'tube'
    codeOrigin: 'ACAS LsContainer'
    displayName: 'Solution Aliquot'
    sourceExternal: false
    parent: false
]
