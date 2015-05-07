(function() {
  var _, apacheHardCodedConfigs, csUtilities, flat, fs, getApacheCompileOptions, getApacheSpecificConfString, getRApacheSpecificConfString, getRFileHandlerString, getRFilesWithRoute, glob, os, path, properties, shell, sysEnv, underscoreDeepExtend, writeApacheConfFile, writeClientJSONFormat, writeJSONFormat, writePropertiesFormat;

  csUtilities = require("../public/src/conf/CustomerSpecificServerFunctions.js");

  properties = require("properties");

  _ = require("underscore");

  underscoreDeepExtend = require("underscoreDeepExtend");

  _.mixin({
    deepExtend: underscoreDeepExtend(_)
  });

  fs = require('fs');

  flat = require('flat');

  glob = require('glob');

  shell = require('shelljs');

  path = require('path');

  os = require('os');

  global.deployMode = "Dev";

  sysEnv = process.env;

  csUtilities.getConfServiceVars(sysEnv, function(confVars) {
    var configDir, configFile, configFileAdvanced, configSuffix, options, substitutions;
    substitutions = {
      env: sysEnv,
      conf: confVars
    };
    options = {
      path: true,
      namespaces: true,
      sections: true,
      variables: true,
      include: true,
      vars: substitutions
    };
    configDir = "./";
    configSuffix = process.argv[2];
    if (typeof configSuffix === "undefined") {
      configFile = "config.properties";
      configFileAdvanced = "config_advanced.properties";
    } else {
      configFile = "config-" + configSuffix + ".properties";
      configFileAdvanced = "config_advanced-" + configSuffix + ".properties";
    }
    console.log("Using " + configFile);
    console.log("Using " + configFileAdvanced);
    return properties.parse(configDir + configFile, options, function(error, conf) {
      if (error != null) {
        return console.log("Problem parsing config.properties: " + error);
      } else {
        return properties.parse(configDir + configFileAdvanced, options, function(error, confAdv) {
          var allConf;
          if (typeof errors !== "undefined" && errors !== null) {
            return console.log("Problem parsing config_advanced.properties: " + error);
          } else {
            allConf = _.deepExtend(confAdv, conf);
            if (allConf.client.deployMode === "Prod") {
              allConf.server.enableSpecRunner = false;
            } else {
              allConf.server.enableSpecRunner = true;
            }
            allConf.server.run = {
              user: (function(_this) {
                return function() {
                  if (allConf.server.run == null) {
                    console.log("server.run.user is not set");
                    if (sysEnv.USER) {
                      console.log("using process.env.USER " + sysEnv.USER);
                      return sysEnv.USER;
                    } else {
                      console.log("process.env.USER is not set");
                      if (process.getuid()) {
                        console.log("using process.getuid " + (process.getuid()));
                        return process.getuid();
                      } else {
                        console.log("could not get run user exiting");
                        process.exit(1);
                      }
                    }
                  }
                  return allConf.server.run.user;
                };
              })(this)()
            };
            writeJSONFormat(allConf);
            writeClientJSONFormat(allConf);
            writePropertiesFormat(allConf);
            return writeApacheConfFile();
          }
        });
      }
    });
  });

  writeJSONFormat = function(conf) {
    return fs.writeFileSync("./compiled/conf.js", "exports.all=" + JSON.stringify(conf) + ";");
  };

  writeClientJSONFormat = function(conf) {
    return fs.writeFileSync("../public/src/conf/conf.js", "window.conf=" + JSON.stringify(conf.client) + ";");
  };

  writePropertiesFormat = function(conf) {
    var attr, configOut, flatConf, value;
    fs = require('fs');
    flatConf = flat.flatten(conf);
    configOut = "";
    for (attr in flatConf) {
      value = flatConf[attr];
      if (value !== null) {
        configOut += attr + "=" + value + "\n";
      } else {
        configOut += attr + "=\n";
      }
    }
    return fs.writeFileSync("./compiled/conf.properties", configOut);
  };

  getRFilesWithRoute = function() {
    var data, i, len, rFile, rFilePath, rFiles, route, routeMatch, routes;
    rFiles = glob.sync('public/src/modules/*/src/server/*.R', {
      cwd: path.resolve(__dirname, '..')
    });
    routes = [];
    for (i = 0, len = rFiles.length; i < len; i++) {
      rFile = rFiles[i];
      rFilePath = path.resolve('..', rFile);
      data = fs.readFileSync(rFilePath, "utf8", function(err) {
        if (err) {
          return console.log(err);
        }
      });
      routeMatch = data.match('# ROUTE:.*');
      if (routeMatch != null) {
        route = routeMatch[0].replace('# ROUTE:', '').trim();
        if (route !== "") {
          routes.push({
            filePath: rFile,
            route: route
          });
        }
      }
    }
    return routes;
  };

  getRFileHandlerString = function(rFilesWithRoute, config, acasHome) {
    var i, len, rFile, rapacheHandlerText, route, routes;
    rapacheHandlerText = '<Location /' + config.all.client.service.rapache.path + '* ROUTE_TO_BE_REPLACED_BY_PREPAREMODULEINCLUDES *>\n\tSetHandler r-handler\n\tRFileHandler ' + acasHome + '/* FILE_TO_BE_REPLACED_BY_PREPAREMODULEINCLUDES *\n</Location>';
    routes = [];
    routes.push('<Location /' + config.all.client.service.rapache.path + '/hello>\n\tSetHandler r-handler\n\tREval "hello()"\n</Location>');
    routes.push('<Location /' + config.all.client.service.rapache.path + '/RApacheInfo>\n\tSetHandler r-info\n</Location>');
    for (i = 0, len = rFilesWithRoute.length; i < len; i++) {
      rFile = rFilesWithRoute[i];
      route = rapacheHandlerText.replace('* ROUTE_TO_BE_REPLACED_BY_PREPAREMODULEINCLUDES *', rFile.route);
      route = route.replace('* FILE_TO_BE_REPLACED_BY_PREPAREMODULEINCLUDES *', rFile.filePath);
      routes.push(route);
    }
    return routes.join('\n\n');
  };

  getApacheCompileOptions = function() {
    var apacheCommand, apacheVersion, compileOptionStrings, compileOptions, compileString, i, j, len, len1, option, possibleCommand, posssibleCommands;
    posssibleCommands = ['httpd', 'apachectl', '/usr/sbin/apachectl', '/usr/sbin/httpd2-prefork', '/usr/sbin/httpd2'];
    for (i = 0, len = posssibleCommands.length; i < len; i++) {
      possibleCommand = posssibleCommands[i];
      if (shell.which(possibleCommand)) {
        apacheCommand = possibleCommand;
        break;
      }
    }
    if (apacheCommand == null) {
      console.log('Could not find apache command in list: ' + posssibleCommands.join(', ') + 'skipping apache config');
      return 'skip';
    }
    compileString = shell.exec(apacheCommand + ' -V', {
      silent: true
    });
    compileOptionStrings = compileString.output.split("\n");
    compileOptions = [];
    apacheVersion = '';
    for (j = 0, len1 = compileOptionStrings.length; j < len1; j++) {
      option = compileOptionStrings[j];
      if (option.match('Server version')) {
        if (option.match('Ubuntu')) {
          apacheVersion = 'Ubuntu';
        } else {
          if (option.match('SUSE')) {
            apacheVersion = 'SUSE';
          } else {
            if (os.type() === "Darwin") {
              apacheVersion = 'Darwin';
            } else {
              apacheVersion = 'Redhat';
            }
          }
        }
      } else {
        option = option.match(/^ -D .*/);
        if (option != null) {
          option = option[0].replace(' -D ', '');
          option = option.split('=');
          option = {
            option: option[0],
            value: option[1]
          };
          compileOptions.push(option);
        }
      }
    }
    console.log(apacheVersion);
    compileOptions.push({
      option: 'ApacheVersion',
      value: apacheVersion
    });
    return compileOptions;
  };

  getRApacheSpecificConfString = function(config, apacheCompileOptions, apacheHardCodedConfigs, acasHome) {
    var confs, runUser, urlPrefix;
    confs = [];
    runUser = shell.exec('whoami', {
      silent: true
    }).output.replace('\n', '');
    if (config.all.server.run != null) {
      if (config.all.server.run.user != null) {
        runUser = config.all.server.run.user;
      }
    }
    confs.push('User ' + runUser);
    confs.push('Group ' + shell.exec('id -g -n ' + runUser, {
      silent: true
    }).output.replace('\n', ''));
    confs.push('Listen ' + config.all.server.rapache.listen + ':' + config.all.client.service.rapache.port);
    confs.push('PidFile ' + acasHome + '/bin/apache.pid');
    confs.push('StartServers ' + _.findWhere(apacheHardCodedConfigs, {
      directive: 'StartServers'
    }).value);
    confs.push('ServerSignature ' + _.findWhere(apacheHardCodedConfigs, {
      directive: 'ServerSignature'
    }).value);
    confs.push('ServerName ' + config.all.client.host);
    confs.push('HostnameLookups ' + _.findWhere(apacheHardCodedConfigs, {
      directive: 'HostnameLookups'
    }).value);
    confs.push('ServerAdmin ' + _.findWhere(apacheHardCodedConfigs, {
      directive: 'ServerAdmin'
    }).value);
    confs.push('LogFormat ' + _.findWhere(apacheHardCodedConfigs, {
      directive: 'LogFormat'
    }).value);
    confs.push('ErrorLog ' + config.all.server.log.path + '/racas.log');
    confs.push('LogLevel ' + config.all.server.log.level.toLowerCase());
    if (Boolean(config.all.client.use.ssl)) {
      urlPrefix = 'https';
      confs.push('SSLEngine On');
      confs.push('SSLCertificateFile ' + config.all.server.ssl.cert.file.path);
      confs.push('SSLCertificateKeyFile ' + config.all.server.ssl.key.file.path);
      confs.push('SSLCACertificateFile ' + config.all.server.ssl.cert.authority.file.path);
      confs.push('SSLPassPhraseDialog ' + '\'|' + path.resolve(acasHome, 'conf', 'executeNodeScript.sh') + ' ' + path.resolve(acasHome, 'conf', 'getSSLPassphrase.js' + '\''));
    } else {
      urlPrefix = 'http';
    }
    confs.push('DirectoryIndex index.html\n<Directory />\n\tOptions FollowSymLinks\n\tAllowOverride None\n</Directory>');
    confs.push('<Directory ' + acasHome + '>\n\tOptions Indexes FollowSymLinks\n\tAllowOverride None\n</Directory>');
    confs.push('RewriteEngine On');
    confs.push("RewriteRule ^/$ " + urlPrefix + "://" + config.all.client.host + ":" + config.all.client.port + "/$1 [L,R,NE]");
    confs.push('REvalOnStartup \'Sys.setenv(ACAS_HOME = \"' + acasHome + '\");.libPaths(file.path(\"' + acasHome + '/r_libs\"));require(racas)\'');
    return confs.join('\n');
  };

  getApacheSpecificConfString = function(config, apacheCompileOptions, apacheHardCodedConfigs, acasHome) {
    var apacheSpecificConfs, apacheVersion, modulesDir, serverRoot, typesConfig;
    apacheSpecificConfs = [];
    apacheVersion = _.findWhere(apacheCompileOptions, {
      option: 'ApacheVersion'
    }).value;
    switch (apacheVersion) {
      case 'Ubuntu':
        serverRoot = '\"/usr/lib/apache2\"';
        modulesDir = 'modules/';
        typesConfig = '/etc/mime.types';
        break;
      case 'Redhat':
        serverRoot = '\"/etc/httpd\"';
        modulesDir = 'modules/';
        typesConfig = '/etc/mime.types';
        break;
      case 'SUSE':
        serverRoot = '\"/usr\"';
        modulesDir = 'lib64/apache2/';
        typesConfig = '/etc/mime.types';
        break;
      case 'Darwin':
        serverRoot = '\"/usr\"';
        modulesDir = 'libexec/apache2/';
        typesConfig = '/private/etc/apache2/mime.types';
    }
    apacheSpecificConfs.push('ServerRoot ' + serverRoot);
    apacheSpecificConfs.push('LoadModule mime_module ' + modulesDir + "mod_mime.so");
    apacheSpecificConfs.push('TypesConfig ' + typesConfig);
    if (apacheVersion === 'Redhat' || apacheVersion === 'Darwin' || apacheVersion === 'SUSE') {
      apacheSpecificConfs.push('LoadModule log_config_module ' + modulesDir + "mod_log_config.so");
      apacheSpecificConfs.push('LoadModule logio_module ' + modulesDir + "mod_logio.so");
    }
    if (apacheVersion === 'Darwin') {
      apacheSpecificConfs.push('Mutex default:' + acasHome + '/bin');
      apacheSpecificConfs.push("LoadModule unixd_module " + modulesDir + "mod_unixd.so");
      apacheSpecificConfs.push("LoadModule authz_core_module " + modulesDir + "mod_authz_core.so");
    }
    apacheSpecificConfs.push('LoadModule dir_module ' + modulesDir + "mod_dir.so");
    if (Boolean(config.all.client.use.ssl)) {
      apacheSpecificConfs.push('LoadModule ssl_module ' + modulesDir + "mod_ssl.so");
    } else {

    }
    apacheSpecificConfs.push('LoadModule rewrite_module ' + modulesDir + "mod_rewrite.so");
    return apacheSpecificConfs.join('\n');
  };

  apacheHardCodedConfigs = [
    {
      directive: 'StartServers',
      value: '5'
    }, {
      directive: 'ServerSignature',
      value: 'On'
    }, {
      directive: 'HostnameLookups',
      value: 'On'
    }, {
      directive: 'ServerAdmin',
      value: 'root@localhost'
    }, {
      directive: 'ServerSignature',
      value: 'On'
    }, {
      directive: 'LogFormat',
      value: '"%h %l %u %t \\"%r\\" %>s %b \\"%{Referer}i\\" \\"%{User-Agent}i\\"" combined'
    }, {
      directive: 'RewriteEngine',
      value: 'On'
    }
  ];

  writeApacheConfFile = function() {
    var acasHome, apacheCompileOptions, apacheSpecificConfString, config, rFileHandlerString, rFilesWithRoute, rapacheConfString;
    config = require('./compiled/conf.js');
    acasHome = path.resolve(__dirname, '..');
    apacheCompileOptions = getApacheCompileOptions();
    if (apacheCompileOptions !== 'skip') {
      apacheSpecificConfString = getApacheSpecificConfString(config, apacheCompileOptions, apacheHardCodedConfigs, acasHome);
    } else {
      apacheSpecificConfString = '';
    }
    rapacheConfString = getRApacheSpecificConfString(config, apacheCompileOptions, apacheHardCodedConfigs, acasHome);
    rFilesWithRoute = getRFilesWithRoute();
    rFileHandlerString = getRFileHandlerString(rFilesWithRoute, config, acasHome);
    fs.writeFileSync("./compiled/apache.conf", [apacheSpecificConfString, rapacheConfString, rFileHandlerString].join('\n'));
    return fs.writeFileSync("./compiled/rapache.conf", [rapacheConfString, rFileHandlerString].join('\n'));
  };

}).call(this);
