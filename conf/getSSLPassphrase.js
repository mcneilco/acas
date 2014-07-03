#!/usr/bin/env node
(function() {
  var configs;

  configs = require('./compiled/conf.js');

  console.log(configs.all.server.ssl.cert.passphrase);

}).call(this);
