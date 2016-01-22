(function() {
  var config;

  config = require('../conf/compiled/conf.js');

  exports.sarRender = {
    'Corporate Parent ID': {
      title: ' ',
      route: ''
    },
    'Corporate Batch ID': {
      title: 'Compound Information',
      route: config.all.server.nodeapi.path + '/api/sarRender/cmpdRegBatch/'
    },
    'Protein Parent': {
      title: ' ',
      route: ''
    },
    'Protein Batch': {
      title: ' ',
      route: ''
    },
    'Gene ID': {
      title: 'Gene ID',
      route: config.all.server.nodeapi.path + '/api/sarRender/geneId/'
    }
  };

}).call(this);
