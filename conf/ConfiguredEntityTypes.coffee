exports.entityTypes =
	'Corporate Parent ID':
    type: 'compound'
    kind: 'parent name'
    codeOrigin: 'ACAS CmpdReg'
    displayName: 'Corporate Parent ID'
    sourceExternal: true
    parent: true

  'Corporate Batch ID':
    type: 'compound'
    kind: 'batch name'
    codeOrigin: 'ACAS CmpdReg'
    displayName: 'Corporate Batch ID'
    sourceExternal: true
    parent: false

  'Protein Parent':
    type: 'parent'
    kind: 'protein'
    codeOrigin: 'ACAS LsThing'
    displayName: 'Protein Parent'
    sourceExternal: false
    parent: true

  'Protein Batch':
    type: 'batch'
    kind: 'protein'
    codeOrigin: 'ACAS LsThing'
    displayName: 'Protein Batch'
    sourceExternal: false
    parent: false

  'Gene ID':
    type: 'gene'
    kind: 'entrez gene'
    codeOrigin: 'ACAS LsThing'
    displayName: 'Gene ID'
    sourceExternal: false
    parent: false

  'Container Plate':
    type: 'container'
    kind: 'plate'
    codeOrigin: 'ACAS Container'
    displayName: 'Plate'
    sourceExternal: false
    parent: false
    model: require("../routes/ServerUtilityFunctions.js").ContainerPlate

  'Container Tube':
    type: 'container'
    kind: 'tube'
    codeOrigin: 'ACAS Container'
    displayName: 'Tube'
    sourceExternal: false
    parent: false
    model: require("../routes/ServerUtilityFunctions.js").ContainerTube

  'Definition Container Plate':
    type: 'definition container'
    kind: 'plate'
    codeOrigin: 'ACAS Container'
    displayName: 'Definition Plate'
    sourceExternal: false
    parent: false
    model: require("../routes/ServerUtilityFunctions.js").DefinitionContainerPlate

  'Definition Container Tube':
    type: 'definition container'
    kind: 'tube'
    codeOrigin: 'ACAS Container'
    displayName: 'Definition Tube'
    sourceExternal: false
    parent: false
    model: require("../routes/ServerUtilityFunctions.js").DefinitionContainerTube
