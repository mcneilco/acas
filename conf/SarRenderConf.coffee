# Name will become the column title
# route should be a GET route where a referenceCode could be appended and returns html for that entity
# routes internal to acas do not need a domain
# e.g. /api/sarRender/geneId/
config = require '../conf/compiled/conf.js'
exports.sarRender =
  'Corporate Parent ID':
    title: ' '
    route: ''
  'Corporate Batch ID':
    title: 'Compound Information'
    route: config.all.server.nodeapi.path + '/api/sarRender/cmpdRegBatch/'
  'Protein Parent':
    title:' '
    route: ''
  'Protein Batch':
    title: ' '
    route: ''
  'Gene ID':
    title: 'Gene ID'
    route: config.all.server.nodeapi.path + '/api/sarRender/geneId/'
