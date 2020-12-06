exports.entityTypes = [
    code: 'Corporate Parent ID'
    type: 'compound'
    kind: 'parent name'
    codeOrigin: 'ACAS CmpdReg'
    displayName: 'Corporate Parent ID'
    sourceExternal: true
    parent: true
    isTestedEntity: false
  ,
    code: 'Corporate Batch ID'
    type: 'compound'
    kind: 'batch name'
    codeOrigin: 'ACAS CmpdReg'
    displayName: 'Corporate Batch ID'
    sourceExternal: true
    parent: false
    isTestedEntity: true
  ,
    code: 'Protein Parent'
    type: 'parent'
    kind: 'protein'
    codeOrigin: 'ACAS LsThing'
    displayName: 'Protein Parent'
    sourceExternal: false
    parent: true
    isTestedEntity: false
  ,
    code: 'Protein Batch'
    type: 'batch'
    kind: 'protein'
    codeOrigin: 'ACAS LsThing'
    displayName: 'Protein Batch'
    sourceExternal: false
    parent: false
    isTestedEntity: false
  ,
    code: 'Gene ID'
    type: 'gene'
    kind: 'entrez gene'
    codeOrigin: 'ACAS LsThing'
    displayName: 'Gene ID'
    sourceExternal: false
    parent: false
    isTestedEntity: false
  ,
    code: 'Container Plate'
    type: 'container'
    kind: 'plate'
    codeOrigin: 'ACAS LsContainer'
    displayName: 'Plate'
    sourceExternal: false
    parent: false
    model: require("../routes/ServerUtilityFunctions.js").ContainerPlate
    isTestedEntity: false
  ,
    code: 'Container Tube'
    type: 'container'
    kind: 'tube'
    codeOrigin: 'ACAS LsContainer'
    displayName: 'Tube'
    sourceExternal: false
    parent: false
    model: require("../routes/ServerUtilityFunctions.js").ContainerTube
    isTestedEntity: false
  ,
    code: 'Definition Container Plate'
    type: 'definition container'
    kind: 'plate'
    codeOrigin: 'ACAS LsContainer'
    displayName: 'Definition Plate'
    sourceExternal: false
    parent: false
    model: require("../routes/ServerUtilityFunctions.js").DefinitionContainerPlate
    isTestedEntity: false
  ,
    code: 'Definition Container Tube'
    type: 'definition container'
    kind: 'tube'
    codeOrigin: 'ACAS LsContainer'
    displayName: 'Definition Tube'
    sourceExternal: false
    parent: false
    model: require("../routes/ServerUtilityFunctions.js").DefinitionContainerTube
    isTestedEntity: false
  ,
    code: 'Solution Container Tube'
    type: 'container'
    kind: 'tube'
    codeOrigin: 'ACAS LsContainer'
    displayName: 'Solution Aliquot'
    sourceExternal: false
    parent: false
    isTestedEntity: false
  ,
    code: 'Location Container'
    type: 'location'
    kind: 'default'
    codeOrigin: 'ACAS LsContainer'
    displayName: 'Location'
    sourceExternal: false
    parent: false
    model: require("../routes/ServerUtilityFunctions.js").LocationContainer
    isTestedEntity: false
]
