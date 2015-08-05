exports.entityTypes =
	'Corporate Parent ID':
    type: 'compound'
    kind: 'parent name'
    codeOrigin: 'ACAS CmpdReg'
    displayName: 'Corporate Parent ID'
    sourceExternal: true

  'Corporate Batch ID':
    type: 'compound'
    kind: 'batch name'
    codeOrigin: 'ACAS CmpdReg'
    displayName: 'Corporate Batch ID'
    sourceExternal: true

  'Protein Parent':
    type: 'parent'
    kind: 'protein'
    codeOrigin: 'ACAS LSThing'
    displayName: 'Protein Parent'
    sourceExternal: false

  'Protein Batch':
    type: 'batch'
    kind: 'protein'
    codeOrigin: 'ACAS LSThing'
    displayName: 'Protein Batch'
    sourceExternal: false

  'Gene ID':
    type: 'gene'
    kind: 'entrez gene'
    codeOrigin: 'ACAS LSThing'
    displayName: 'Gene ID'
    sourceExternal: false

