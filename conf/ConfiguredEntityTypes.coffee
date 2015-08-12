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
    codeOrigin: 'ACAS LSThing'
    displayName: 'Protein Parent'
    sourceExternal: false
    parent: true

  'Protein Batch':
    type: 'batch'
    kind: 'protein'
    codeOrigin: 'ACAS LSThing'
    displayName: 'Protein Batch'
    sourceExternal: false
    parent: false

  'Gene ID':
    type: 'gene'
    kind: 'entrez gene'
    codeOrigin: 'ACAS LSThing'
    displayName: 'Gene ID'
    sourceExternal: false
    parent: false
