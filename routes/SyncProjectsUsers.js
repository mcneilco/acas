(function() {
  var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  exports.setupRoutes = function(app, loginRoutes) {
    return app.get('/api/syncLiveDesignProjectsUsers', loginRoutes.ensureAuthenticated, exports.syncLiveDesignProjectsUsers);
  };

  exports.syncLiveDesignProjectsUsers = function(req, resp) {
    var _, cmpdRegRoutes, config, exec, request;
    exec = require('child_process').exec;
    config = require('../conf/compiled/conf.js');
    request = require('request');
    _ = require("underscore");
    cmpdRegRoutes = require('../routes/CmpdRegRoutes.js');
    return request.get({
      url: config.all.client.service.persistence.fullpath + "authorization/groupsAndProjects",
      json: true
    }, (function(_this) {
      return function(error, response, body) {
        var acasGroupsAndProjects, child, command, configJSON, groupsJSON, projectCodes, projectsJSON, serverError;
        serverError = error;
        acasGroupsAndProjects = body;
        groupsJSON = {};
        groupsJSON.groups = {};
        groupsJSON.projects = [];
        projectsJSON = {};
        projectsJSON.projects = [];
        _.each(acasGroupsAndProjects.groups, function(group) {
          return groupsJSON.groups[group.name] = group.members;
        });
        _.each(acasGroupsAndProjects.projects, function(project) {
          var projectEntry, projectGroups;
          projectGroups = {
            alias: project.code,
            groups: project.groups
          };
          groupsJSON.projects.push(projectGroups);
          projectEntry = {
            id: project.id,
            name: project.code,
            active: project.active != null ? ['N', 'Y'][+project.active] : 'Y',
            is_restricted: project.isRestricted != null ? +project.isRestricted : 0,
            project_desc: project.name
          };
          return projectsJSON.projects.push(projectEntry);
        });
        configJSON = {
          ld_server: {
            ld_url: config.all.client.service.result.viewer.liveDesign.baseUrl,
            ld_username: config.all.client.service.result.viewer.liveDesign.username,
            ld_password: config.all.client.service.result.viewer.liveDesign.password
          },
          livedesign_db: {
            dbname: config.all.client.service.result.viewer.liveDesign.database.name,
            user: config.all.client.service.result.viewer.liveDesign.database.username,
            password: config.all.client.service.result.viewer.liveDesign.database.password,
            host: config.all.client.service.result.viewer.liveDesign.database.hostname,
            port: config.all.client.service.result.viewer.liveDesign.database.port
          }
        };
        command = "python ./public/src/modules/ServerAPI/src/server/syncProjectsUsers/sync_projects.py ";
        command += "\'" + (JSON.stringify(configJSON)) + "\' " + "\'" + (JSON.stringify(projectsJSON)) + "\'";
        console.log("About to call python using command: " + command);
        child = exec(command, function(error, stdout, stderr) {
          var reportURL, reportURLPos;
          reportURLPos = stdout.indexOf(config.all.client.service.result.viewer.liveDesign.baseUrl);
          reportURL = stdout.substr(reportURLPos);
          console.warn("stderr: " + stderr);
          return console.log("stdout: " + stdout);
        });
        projectCodes = _.pluck(acasGroupsAndProjects.projects, 'code');
        console.debug('project codes are:' + JSON.stringify(projectCodes));
        cmpdRegRoutes.getProjects(req, function(projectResponse) {
          var foundProjectCodes, foundProjects, i, len, newProjectCodes, newProjects, oldProject, projectToUpdate, projectsToUpdate;
          foundProjects = JSON.parse(projectResponse);
          foundProjectCodes = _.pluck(foundProjects, 'code');
          console.debug('found projects are: ' + foundProjectCodes);
          newProjectCodes = _.difference(projectCodes, foundProjectCodes);
          newProjects = _.filter(acasGroupsAndProjects.projects, function(project) {
            var ref;
            return ref = project.code, indexOf.call(newProjectCodes, ref) >= 0;
          });
          projectsToUpdate = _.filter(acasGroupsAndProjects.projects, function(project) {
            var found, unchanged;
            found = (_.findWhere(foundProjects, {
              code: project.code
            })) != null;
            unchanged = (_.findWhere(foundProjects, {
              code: project.code,
              name: project.name
            })) != null;
            return found && !unchanged;
          });
          if (((newProjects != null) && newProjects.length > 0) || ((projectsToUpdate != null) && projectsToUpdate.length > 0)) {
            if ((newProjects != null) && newProjects.length > 0) {
              console.debug('saving new projects with JSON: ' + JSON.stringify(newProjects));
              return cmpdRegRoutes.saveProjects(newProjects, function(saveProjectsResponse) {});
            } else {
              for (i = 0, len = projectsToUpdate.length; i < len; i++) {
                projectToUpdate = projectsToUpdate[i];
                oldProject = _.findWhere(foundProjects, {
                  code: projectToUpdate.code
                });
                projectToUpdate.id = oldProject.id;
                projectToUpdate.version = oldProject.version;
              }
              console.debug('updating projects with JSON: ' + JSON.stringify(projectsToUpdate));
              return cmpdRegRoutes.updateProjects(projectsToUpdate, function(updateProjectsResponse) {});
            }
          } else {
            return console.debug('CmpdReg projects are up-to-date');
          }
        });
        command = "python ./public/src/modules/ServerAPI/src/server/syncProjectsUsers/ld_entitlements.py ";
        command += "\'" + (JSON.stringify(configJSON.ld_server)) + "\' " + "\'" + (JSON.stringify(groupsJSON)) + "\'";
        console.log("About to call python using command: " + command);
        child = exec(command, function(error, stdout, stderr) {
          var reportURL, reportURLPos;
          reportURLPos = stdout.indexOf(config.all.client.service.result.viewer.liveDesign.baseUrl);
          reportURL = stdout.substr(reportURLPos);
          console.warn("stderr: " + stderr);
          return console.log("stdout: " + stdout);
        });
        return resp.end("Done");
      };
    })(this));
  };

}).call(this);
