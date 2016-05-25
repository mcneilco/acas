(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.ProjectLeader = (function(superClass) {
    extend(ProjectLeader, superClass);

    function ProjectLeader() {
      return ProjectLeader.__super__.constructor.apply(this, arguments);
    }

    ProjectLeader.prototype.defaults = function() {
      return {
        scientist: "unassigned"
      };
    };

    return ProjectLeader;

  })(Backbone.Model);

  window.ProjectLeaderList = (function(superClass) {
    extend(ProjectLeaderList, superClass);

    function ProjectLeaderList() {
      this.validateCollection = bind(this.validateCollection, this);
      return ProjectLeaderList.__super__.constructor.apply(this, arguments);
    }

    ProjectLeaderList.prototype.model = ProjectLeader;

    ProjectLeaderList.prototype.validateCollection = function() {
      var currentLeader, i, index, model, modelErrors, ref, usedLeaders;
      modelErrors = [];
      usedLeaders = {};
      if (this.length !== 0) {
        for (index = i = 0, ref = this.length - 1; 0 <= ref ? i <= ref : i >= ref; index = 0 <= ref ? ++i : --i) {
          model = this.at(index);
          currentLeader = model.get('scientist');
          if (currentLeader in usedLeaders) {
            modelErrors.push({
              attribute: 'scientist:eq(' + index + ')',
              message: "The same scientist can not be chosen more than once"
            });
            modelErrors.push({
              attribute: 'scientist:eq(' + usedLeaders[currentLeader] + ')',
              message: "The same scientist can not be chosen more than once"
            });
          } else {
            usedLeaders[currentLeader] = index;
          }
        }
      }
      return modelErrors;
    };

    return ProjectLeaderList;

  })(Backbone.Collection);

  window.ProjectUser = (function(superClass) {
    extend(ProjectUser, superClass);

    function ProjectUser() {
      return ProjectUser.__super__.constructor.apply(this, arguments);
    }

    ProjectUser.prototype.defaults = function() {
      return {
        user: "unassigned",
        saved: false
      };
    };

    return ProjectUser;

  })(Backbone.Model);

  window.ProjectUserList = (function(superClass) {
    extend(ProjectUserList, superClass);

    function ProjectUserList() {
      this.validateCollection = bind(this.validateCollection, this);
      return ProjectUserList.__super__.constructor.apply(this, arguments);
    }

    ProjectUserList.prototype.model = ProjectUser;

    ProjectUserList.prototype.validateCollection = function() {
      var currentUser, i, index, model, modelErrors, ref, usedUsers;
      modelErrors = [];
      usedUsers = {};
      if (this.length !== 0) {
        for (index = i = 0, ref = this.length - 1; 0 <= ref ? i <= ref : i >= ref; index = 0 <= ref ? ++i : --i) {
          model = this.at(index);
          currentUser = model.get('user');
          if (currentUser in usedUsers) {
            modelErrors.push({
              attribute: 'user:eq(' + index + ')',
              message: "The same user can not be chosen more than once"
            });
            modelErrors.push({
              attribute: 'user:eq(' + usedUsers[currentUser] + ')',
              message: "The same scientist can not be chosen more than once"
            });
          } else {
            usedUsers[currentUser] = index;
          }
        }
      }
      return modelErrors;
    };

    return ProjectUserList;

  })(Backbone.Collection);

  window.ProjectAdmin = (function(superClass) {
    extend(ProjectAdmin, superClass);

    function ProjectAdmin() {
      return ProjectAdmin.__super__.constructor.apply(this, arguments);
    }

    ProjectAdmin.prototype.defaults = function() {
      return {
        admin: "unassigned",
        saved: false
      };
    };

    return ProjectAdmin;

  })(Backbone.Model);

  window.ProjectAdminList = (function(superClass) {
    extend(ProjectAdminList, superClass);

    function ProjectAdminList() {
      this.validateCollection = bind(this.validateCollection, this);
      return ProjectAdminList.__super__.constructor.apply(this, arguments);
    }

    ProjectAdminList.prototype.model = ProjectAdmin;

    ProjectAdminList.prototype.validateCollection = function() {
      var currentAdmin, i, index, model, modelErrors, ref, usedAdmins;
      modelErrors = [];
      usedAdmins = {};
      if (this.length !== 0) {
        for (index = i = 0, ref = this.length - 1; 0 <= ref ? i <= ref : i >= ref; index = 0 <= ref ? ++i : --i) {
          model = this.at(index);
          currentAdmin = model.get('admin');
          if (currentAdmin in usedAdmins) {
            modelErrors.push({
              attribute: 'admin:eq(' + index + ')',
              message: "The same admin can not be chosen more than once"
            });
            modelErrors.push({
              attribute: 'admin:eq(' + usedAdmins[currentAdmin] + ')',
              message: "The same admin can not be chosen more than once"
            });
          } else {
            usedAdmins[currentAdmin] = index;
          }
        }
      }
      return modelErrors;
    };

    return ProjectAdminList;

  })(Backbone.Collection);

  window.Project = (function(superClass) {
    extend(Project, superClass);

    function Project() {
      this.getProjectLeaders = bind(this.getProjectLeaders, this);
      this.getAnalyticalFiles = bind(this.getAnalyticalFiles, this);
      return Project.__super__.constructor.apply(this, arguments);
    }

    Project.prototype.urlRoot = "/api/things/project/project";

    Project.prototype.className = "Project";

    Project.prototype.initialize = function() {
      this.set({
        lsType: "project",
        lsKind: "project"
      });
      return Project.__super__.initialize.call(this);
    };

    Project.prototype.lsProperties = {
      defaultLabels: [
        {
          key: 'project name',
          type: 'name',
          kind: 'project name',
          preferred: true
        }, {
          key: 'project alias',
          type: 'name',
          kind: 'project alias',
          preferred: false
        }
      ],
      defaultValues: [
        {
          key: 'start date',
          stateType: 'metadata',
          stateKind: 'project metadata',
          type: 'dateValue',
          kind: 'start date'
        }, {
          key: 'project status',
          stateType: 'metadata',
          stateKind: 'project metadata',
          type: 'codeValue',
          kind: 'project status',
          codeType: 'project',
          codeKind: 'status',
          codeOrigin: 'ACAS DDICT',
          value: 'active'
        }, {
          key: 'short description',
          stateType: 'metadata',
          stateKind: 'project metadata',
          type: 'stringValue',
          kind: 'short description'
        }, {
          key: 'project details',
          stateType: 'metadata',
          stateKind: 'project metadata',
          type: 'clobValue',
          kind: 'project details'
        }, {
          key: 'live design id',
          stateType: 'metadata',
          stateKind: 'project metadata',
          type: 'numericValue',
          kind: 'live design id'
        }, {
          key: 'is restricted',
          stateType: 'metadata',
          stateKind: 'project metadata',
          type: 'codeValue',
          kind: 'is restricted',
          codeType: 'project',
          codeKind: 'restricted',
          codeOrigin: 'ACAS DDICT',
          value: 'true'
        }
      ],
      defaultFirstLsThingItx: [],
      defaultSecondLsThingItx: []
    };

    Project.prototype.validate = function(attrs) {
      var alias, bestName, errors, nameError;
      errors = [];
      bestName = attrs.lsLabels.pickBestName();
      nameError = true;
      if (bestName != null) {
        nameError = true;
        if (bestName.get('labelText') !== "" && bestName.get('labelText') !== "unassigned") {
          nameError = false;
        }
      }
      if (nameError) {
        errors.push({
          attribute: 'projectName',
          message: "Name must be set and unique"
        });
      }
      if (attrs["project alias"] != null) {
        alias = attrs["project alias"].get('labelText');
        if (alias === "" || alias === void 0 || alias === null) {
          errors.push({
            attribute: 'projectAlias',
            message: "Alias must be set and unique"
          });
        }
      }
      if (errors.length > 0) {
        return errors;
      } else {
        return null;
      }
    };

    Project.prototype.getAnalyticalFiles = function(fileTypes) {
      var afm, analyticalFileState, analyticalFileValues, attachFileList, file, i, j, len, len1, type;
      attachFileList = new AttachFileList();
      for (i = 0, len = fileTypes.length; i < len; i++) {
        type = fileTypes[i];
        analyticalFileState = this.get('lsStates').getOrCreateStateByTypeAndKind("metadata", "project metadata");
        analyticalFileValues = analyticalFileState.getValuesByTypeAndKind("fileValue", type.code);
        if (analyticalFileValues.length > 0 && type.code !== "unassigned") {
          for (j = 0, len1 = analyticalFileValues.length; j < len1; j++) {
            file = analyticalFileValues[j];
            if (!file.get('ignored')) {
              afm = new AttachFile({
                fileType: type.code,
                fileValue: file.get('fileValue'),
                id: file.get('id'),
                comments: file.get('comments')
              });
              attachFileList.add(afm);
            }
          }
        }
      }
      return attachFileList;
    };

    Project.prototype.getProjectLeaders = function() {
      var projLeaders, projMetaState;
      projMetaState = this.get('lsStates').getStatesByTypeAndKind("metadata", "project metadata")[0];
      projLeaders = projMetaState.getValuesByTypeAndKind("codeValue", "project leader");
      return projLeaders;
    };

    Project.prototype.prepareToSave = function() {
      var rBy, rDate;
      rBy = this.get('recordedBy');
      rDate = new Date().getTime();
      this.set({
        recordedDate: rDate
      });
      this.get('lsLabels').each((function(_this) {
        return function(lab) {
          return _this.setRByAndRDate(lab);
        };
      })(this));
      this.get('lsStates').each((function(_this) {
        return function(state) {
          _this.setRByAndRDate(state);
          return state.get('lsValues').each(function(val) {
            return _this.setRByAndRDate(val);
          });
        };
      })(this));
      if (this.get('secondLsThings') != null) {
        return this.get('secondLsThings').each((function(_this) {
          return function(itx) {
            _this.setRByAndRDate(itx);
            return itx.get('lsStates').each(function(state) {
              _this.setRByAndRDate(state);
              return state.get('lsValues').each(function(val) {
                return _this.setRByAndRDate(val);
              });
            });
          };
        })(this));
      }
    };

    Project.prototype.setRByAndRDate = function(data) {
      var rBy, rDate;
      rBy = this.get('recordedBy');
      rDate = new Date().getTime();
      if (data.get('recordedBy') === "") {
        data.set({
          recordedBy: rBy
        });
      }
      if (data.get('recordedDate') === null) {
        return data.set({
          recordedDate: rDate
        });
      }
    };

    Project.prototype.isEditable = function() {
      var status;
      status = this.get('project status').get('value');
      switch (status) {
        case "active":
          return true;
        case "inactive":
          return false;
      }
    };

    return Project;

  })(Thing);

  window.ProjectList = (function(superClass) {
    extend(ProjectList, superClass);

    function ProjectList() {
      return ProjectList.__super__.constructor.apply(this, arguments);
    }

    ProjectList.prototype.model = Project;

    return ProjectList;

  })(Backbone.Collection);

  window.ProjectLeaderController = (function(superClass) {
    extend(ProjectLeaderController, superClass);

    function ProjectLeaderController() {
      this.clear = bind(this.clear, this);
      this.updateModel = bind(this.updateModel, this);
      this.render = bind(this.render, this);
      return ProjectLeaderController.__super__.constructor.apply(this, arguments);
    }

    ProjectLeaderController.prototype.template = _.template($("#ProjectLeaderView").html());

    ProjectLeaderController.prototype.tagName = "div";

    ProjectLeaderController.prototype.events = function() {
      return {
        "change .bv_scientist": "attributeChanged",
        "click .bv_deleteProjectLeader": "clear"
      };
    };

    ProjectLeaderController.prototype.initialize = function() {
      this.errorOwnerName = 'ProjectLeaderController';
      this.setBindings();
      return this.model.on("destroy", this.remove, this);
    };

    ProjectLeaderController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template(this.model.attributes));
      this.setupScientistSelect();
      return this;
    };

    ProjectLeaderController.prototype.setupScientistSelect = function() {
      this.scientistList = new PickListList();
      this.scientistList.url = "/api/authors";
      return this.scientistListController = new PickListSelectController({
        el: this.$('.bv_scientist'),
        collection: this.scientistList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Scientist"
        }),
        selectedCode: this.model.get('scientist')
      });
    };

    ProjectLeaderController.prototype.updateModel = function() {
      var newModel, scientist;
      scientist = this.scientistListController.getSelectedCode();
      if (this.model.get('id') != null) {
        newModel = new ProjectLeader({
          scientist: scientist
        });
        this.model.set("ignored", true);
        this.$('.bv_projectLeaderWrapper').hide();
        this.trigger('addNewModel', newModel);
      } else {
        this.model.set({
          scientist: scientist
        });
      }
      return this.trigger('amDirty');
    };

    ProjectLeaderController.prototype.clear = function() {
      if (this.model.get('id') != null) {
        this.model.set("ignored", true);
        this.$('.bv_projectLeaderWrapper').hide();
      } else {
        this.model.destroy();
      }
      return this.trigger('amDirty');
    };

    return ProjectLeaderController;

  })(AbstractFormController);

  window.ProjectLeaderListController = (function(superClass) {
    extend(ProjectLeaderListController, superClass);

    function ProjectLeaderListController() {
      this.clearValidationErrorStyles = bind(this.clearValidationErrorStyles, this);
      this.validationError = bind(this.validationError, this);
      this.isValid = bind(this.isValid, this);
      this.addProjectLeader = bind(this.addProjectLeader, this);
      this.addNewProjectLeader = bind(this.addNewProjectLeader, this);
      this.render = bind(this.render, this);
      return ProjectLeaderListController.__super__.constructor.apply(this, arguments);
    }

    ProjectLeaderListController.prototype.template = _.template($("#ProjectLeaderListView").html());

    ProjectLeaderListController.prototype.events = {
      "click .bv_addProjectLeaderButton": "addNewProjectLeader"
    };

    ProjectLeaderListController.prototype.initialize = function() {
      var newModel;
      if (this.collection == null) {
        this.collection = new ProjectLeaderList();
        newModel = new ProjectLeader;
        return this.collection.add(newModel);
      }
    };

    ProjectLeaderListController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.collection.each((function(_this) {
        return function(leaderInfo) {
          return _this.addProjectLeader(leaderInfo);
        };
      })(this));
      if (this.collection.length === 0) {
        this.addNewProjectLeader();
      }
      this.trigger('renderComplete');
      return this;
    };

    ProjectLeaderListController.prototype.addNewProjectLeader = function() {
      var newModel;
      newModel = new ProjectLeader;
      this.collection.add(newModel);
      this.addProjectLeader(newModel);
      return this.trigger('amDirty');
    };

    ProjectLeaderListController.prototype.addProjectLeader = function(leaderInfo) {
      var plc;
      plc = new ProjectLeaderController({
        model: leaderInfo
      });
      plc.on('addNewModel', (function(_this) {
        return function(newModel) {
          _this.collection.add(newModel);
          return _this.addProjectLeader(newModel);
        };
      })(this));
      plc.on('amDirty', (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      return this.$('.bv_projectLeaderInfo').append(plc.render().el);
    };

    ProjectLeaderListController.prototype.isValid = function() {
      var errors, validCheck;
      validCheck = true;
      errors = this.collection.validateCollection();
      if (errors.length > 0) {
        validCheck = false;
      }
      this.validationError(errors);
      return validCheck;
    };

    ProjectLeaderListController.prototype.validationError = function(errors) {
      this.clearValidationErrorStyles();
      return _.each(errors, (function(_this) {
        return function(err) {
          if (_this.$('.bv_' + err.attribute).attr('disabled') !== 'disabled') {
            _this.$('.bv_group_' + err.attribute).attr('data-toggle', 'tooltip');
            _this.$('.bv_group_' + err.attribute).attr('data-placement', 'bottom');
            _this.$('.bv_group_' + err.attribute).attr('data-original-title', err.message);
            _this.$("[data-toggle=tooltip]").tooltip();
            _this.$("body").tooltip({
              selector: '.bv_group_' + err.attribute
            });
            _this.$('.bv_group_' + err.attribute).addClass('input_error error');
            return _this.trigger('notifyError', {
              owner: _this.errorOwnerName,
              errorLevel: 'error',
              message: err.message
            });
          }
        };
      })(this));
    };

    ProjectLeaderListController.prototype.clearValidationErrorStyles = function() {
      var errorElms;
      errorElms = this.$('.input_error');
      return _.each(errorElms, (function(_this) {
        return function(ee) {
          $(ee).removeAttr('data-toggle');
          $(ee).removeAttr('data-placement');
          $(ee).removeAttr('title');
          $(ee).removeAttr('data-original-title');
          return $(ee).removeClass('input_error error');
        };
      })(this));
    };

    return ProjectLeaderListController;

  })(Backbone.View);

  window.ProjectUserController = (function(superClass) {
    extend(ProjectUserController, superClass);

    function ProjectUserController() {
      this.clear = bind(this.clear, this);
      this.updateModel = bind(this.updateModel, this);
      this.render = bind(this.render, this);
      return ProjectUserController.__super__.constructor.apply(this, arguments);
    }

    ProjectUserController.prototype.template = _.template($("#ProjectUserView").html());

    ProjectUserController.prototype.tagName = "div";

    ProjectUserController.prototype.events = function() {
      return {
        "change .bv_user": "attributeChanged",
        "click .bv_deleteProjectUser": "clear"
      };
    };

    ProjectUserController.prototype.initialize = function() {
      this.errorOwnerName = 'ProjectUserController';
      this.setBindings();
      return this.model.on("destroy", this.remove, this);
    };

    ProjectUserController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template(this.model.attributes));
      this.setupUserSelect();
      return this;
    };

    ProjectUserController.prototype.setupUserSelect = function() {
      this.userList = new PickListList();
      this.userList.url = "/api/authors";
      return this.userListController = new PickListSelectController({
        el: this.$('.bv_user'),
        collection: this.userList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select User"
        }),
        selectedCode: this.model.get('user')
      });
    };

    ProjectUserController.prototype.updateModel = function() {
      var newModel, user;
      user = this.userListController.getSelectedCode();
      if (this.model.get('saved')) {
        newModel = new ProjectUser({
          user: user
        });
        this.model.set("ignored", true);
        this.$('.bv_projectUserWrapper').hide();
        this.trigger('addNewModel', newModel);
      } else {
        this.model.set({
          user: user
        });
      }
      return this.trigger('amDirty');
    };

    ProjectUserController.prototype.clear = function() {
      if (this.model.get('saved') === true) {
        this.model.set("ignored", true);
        this.$('.bv_projectUserWrapper').hide();
      } else {
        this.model.destroy();
      }
      return this.trigger('amDirty');
    };

    return ProjectUserController;

  })(AbstractFormController);

  window.ProjectUserListController = (function(superClass) {
    extend(ProjectUserListController, superClass);

    function ProjectUserListController() {
      this.clearValidationErrorStyles = bind(this.clearValidationErrorStyles, this);
      this.validationError = bind(this.validationError, this);
      this.isValid = bind(this.isValid, this);
      this.addProjectUser = bind(this.addProjectUser, this);
      this.addNewProjectUser = bind(this.addNewProjectUser, this);
      this.render = bind(this.render, this);
      return ProjectUserListController.__super__.constructor.apply(this, arguments);
    }

    ProjectUserListController.prototype.template = _.template($("#ProjectUserListView").html());

    ProjectUserListController.prototype.events = {
      "click .bv_addProjectUserButton": "addNewProjectUser"
    };

    ProjectUserListController.prototype.initialize = function() {
      var newModel;
      if (this.collection == null) {
        this.collection = new ProjectUserList();
        newModel = new ProjectUser;
        return this.collection.add(newModel);
      }
    };

    ProjectUserListController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.collection.each((function(_this) {
        return function(userInfo) {
          return _this.addProjectUser(userInfo);
        };
      })(this));
      if (this.collection.length === 0) {
        this.addNewProjectUser();
      }
      this.trigger('renderComplete');
      return this;
    };

    ProjectUserListController.prototype.addNewProjectUser = function() {
      var newModel;
      newModel = new ProjectUser();
      this.collection.add(newModel);
      this.addProjectUser(newModel);
      return this.trigger('amDirty');
    };

    ProjectUserListController.prototype.addProjectUser = function(userInfo) {
      var plc;
      plc = new ProjectUserController({
        model: userInfo
      });
      plc.on('addNewModel', (function(_this) {
        return function(newModel) {
          _this.collection.add(newModel);
          return _this.addProjectUser(newModel);
        };
      })(this));
      plc.on('amDirty', (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      return this.$('.bv_projectUserInfo').append(plc.render().el);
    };

    ProjectUserListController.prototype.isValid = function() {
      var errors, validCheck;
      validCheck = true;
      errors = this.collection.validateCollection();
      if (errors.length > 0) {
        validCheck = false;
      }
      this.validationError(errors);
      return validCheck;
    };

    ProjectUserListController.prototype.validationError = function(errors) {
      this.clearValidationErrorStyles();
      return _.each(errors, (function(_this) {
        return function(err) {
          if (_this.$('.bv_' + err.attribute).attr('disabled') !== 'disabled') {
            _this.$('.bv_group_' + err.attribute).attr('data-toggle', 'tooltip');
            _this.$('.bv_group_' + err.attribute).attr('data-placement', 'bottom');
            _this.$('.bv_group_' + err.attribute).attr('data-original-title', err.message);
            _this.$("[data-toggle=tooltip]").tooltip();
            _this.$("body").tooltip({
              selector: '.bv_group_' + err.attribute
            });
            _this.$('.bv_group_' + err.attribute).addClass('input_error error');
            return _this.trigger('notifyError', {
              owner: _this.errorOwnerName,
              errorLevel: 'error',
              message: err.message
            });
          }
        };
      })(this));
    };

    ProjectUserListController.prototype.clearValidationErrorStyles = function() {
      var errorElms;
      errorElms = this.$('.input_error');
      return _.each(errorElms, (function(_this) {
        return function(ee) {
          $(ee).removeAttr('data-toggle');
          $(ee).removeAttr('data-placement');
          $(ee).removeAttr('title');
          $(ee).removeAttr('data-original-title');
          return $(ee).removeClass('input_error error');
        };
      })(this));
    };

    return ProjectUserListController;

  })(Backbone.View);

  window.ProjectAdminController = (function(superClass) {
    extend(ProjectAdminController, superClass);

    function ProjectAdminController() {
      this.clear = bind(this.clear, this);
      this.updateModel = bind(this.updateModel, this);
      this.render = bind(this.render, this);
      return ProjectAdminController.__super__.constructor.apply(this, arguments);
    }

    ProjectAdminController.prototype.template = _.template($("#ProjectAdminView").html());

    ProjectAdminController.prototype.tagName = "div";

    ProjectAdminController.prototype.events = function() {
      return {
        "change .bv_admin": "attributeChanged",
        "click .bv_deleteProjectAdmin": "clear"
      };
    };

    ProjectAdminController.prototype.initialize = function() {
      this.errorOwnerName = 'ProjectAdminController';
      this.setBindings();
      return this.model.on("destroy", this.remove, this);
    };

    ProjectAdminController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template(this.model.attributes));
      this.setupAdminSelect();
      return this;
    };

    ProjectAdminController.prototype.setupAdminSelect = function() {
      this.adminList = new PickListList();
      this.adminList.url = "/api/authors";
      return this.adminListController = new PickListSelectController({
        el: this.$('.bv_admin'),
        collection: this.adminList,
        insertFirstOption: new PickList({
          code: "unassigned",
          name: "Select Admin"
        }),
        selectedCode: this.model.get('admin')
      });
    };

    ProjectAdminController.prototype.updateModel = function() {
      var admin, newModel;
      admin = this.adminListController.getSelectedCode();
      if (this.model.get('saved')) {
        newModel = new ProjectAdmin({
          admin: admin
        });
        this.model.set("ignored", true);
        this.$('.bv_projectAdminWrapper').hide();
        this.trigger('addNewModel', newModel);
      } else {
        this.model.set({
          admin: admin
        });
      }
      return this.trigger('amDirty');
    };

    ProjectAdminController.prototype.clear = function() {
      if (this.model.get('saved') === true) {
        this.model.set("ignored", true);
        this.$('.bv_projectAdminWrapper').hide();
      } else {
        this.model.destroy();
      }
      return this.trigger('amDirty');
    };

    return ProjectAdminController;

  })(AbstractFormController);

  window.ProjectAdminListController = (function(superClass) {
    extend(ProjectAdminListController, superClass);

    function ProjectAdminListController() {
      this.clearValidationErrorStyles = bind(this.clearValidationErrorStyles, this);
      this.validationError = bind(this.validationError, this);
      this.isValid = bind(this.isValid, this);
      this.addProjectAdmin = bind(this.addProjectAdmin, this);
      this.addNewProjectAdmin = bind(this.addNewProjectAdmin, this);
      this.render = bind(this.render, this);
      return ProjectAdminListController.__super__.constructor.apply(this, arguments);
    }

    ProjectAdminListController.prototype.template = _.template($("#ProjectAdminListView").html());

    ProjectAdminListController.prototype.events = {
      "click .bv_addProjectAdminButton": "addNewProjectAdmin"
    };

    ProjectAdminListController.prototype.initialize = function() {
      var newModel;
      if (this.collection == null) {
        this.collection = new ProjectAdminList();
        newModel = new ProjectAdmin;
        return this.collection.add(newModel);
      }
    };

    ProjectAdminListController.prototype.render = function() {
      $(this.el).empty();
      $(this.el).html(this.template());
      this.collection.each((function(_this) {
        return function(adminInfo) {
          return _this.addProjectAdmin(adminInfo);
        };
      })(this));
      if (this.collection.length === 0) {
        this.addNewProjectAdmin();
      }
      this.trigger('renderComplete');
      return this;
    };

    ProjectAdminListController.prototype.addNewProjectAdmin = function() {
      var newModel;
      newModel = new ProjectAdmin();
      this.collection.add(newModel);
      this.addProjectAdmin(newModel);
      return this.trigger('amDirty');
    };

    ProjectAdminListController.prototype.addProjectAdmin = function(adminInfo) {
      var plc;
      plc = new ProjectAdminController({
        model: adminInfo
      });
      plc.on('addNewModel', (function(_this) {
        return function(newModel) {
          _this.collection.add(newModel);
          return _this.addProjectAdmin(newModel);
        };
      })(this));
      plc.on('amDirty', (function(_this) {
        return function() {
          return _this.trigger('amDirty');
        };
      })(this));
      return this.$('.bv_projectAdminInfo').append(plc.render().el);
    };

    ProjectAdminListController.prototype.isValid = function() {
      var errors, validCheck;
      validCheck = true;
      errors = this.collection.validateCollection();
      if (errors.length > 0) {
        validCheck = false;
      }
      this.validationError(errors);
      return validCheck;
    };

    ProjectAdminListController.prototype.validationError = function(errors) {
      this.clearValidationErrorStyles();
      return _.each(errors, (function(_this) {
        return function(err) {
          if (_this.$('.bv_' + err.attribute).attr('disabled') !== 'disabled') {
            _this.$('.bv_group_' + err.attribute).attr('data-toggle', 'tooltip');
            _this.$('.bv_group_' + err.attribute).attr('data-placement', 'bottom');
            _this.$('.bv_group_' + err.attribute).attr('data-original-title', err.message);
            _this.$("[data-toggle=tooltip]").tooltip();
            _this.$("body").tooltip({
              selector: '.bv_group_' + err.attribute
            });
            _this.$('.bv_group_' + err.attribute).addClass('input_error error');
            return _this.trigger('notifyError', {
              owner: _this.errorOwnerName,
              errorLevel: 'error',
              message: err.message
            });
          }
        };
      })(this));
    };

    ProjectAdminListController.prototype.clearValidationErrorStyles = function() {
      var errorElms;
      errorElms = this.$('.input_error');
      return _.each(errorElms, (function(_this) {
        return function(ee) {
          $(ee).removeAttr('data-toggle');
          $(ee).removeAttr('data-placement');
          $(ee).removeAttr('title');
          $(ee).removeAttr('data-original-title');
          return $(ee).removeClass('input_error error');
        };
      })(this));
    };

    return ProjectAdminListController;

  })(Backbone.View);

  window.ProjectController = (function(superClass) {
    extend(ProjectController, superClass);

    function ProjectController() {
      this.isValid = bind(this.isValid, this);
      this.checkFormValid = bind(this.checkFormValid, this);
      this.displayInReadOnlyMode = bind(this.displayInReadOnlyMode, this);
      this.checkDisplayMode = bind(this.checkDisplayMode, this);
      this.clearValidationErrorStyles = bind(this.clearValidationErrorStyles, this);
      this.validationError = bind(this.validationError, this);
      this.syncRoles = bind(this.syncRoles, this);
      this.updateProjectRoles = bind(this.updateProjectRoles, this);
      this.createRoleKindAndName = bind(this.createRoleKindAndName, this);
      this.prepareToSaveAuthorRoles = bind(this.prepareToSaveAuthorRoles, this);
      this.prepareToSaveProjectLeaders = bind(this.prepareToSaveProjectLeaders, this);
      this.prepareToSaveAttachedFiles = bind(this.prepareToSaveAttachedFiles, this);
      this.saveProjectAndRoles = bind(this.saveProjectAndRoles, this);
      this.handleValidateReturn = bind(this.handleValidateReturn, this);
      this.handleSaveClicked = bind(this.handleSaveClicked, this);
      this.updateModel = bind(this.updateModel, this);
      this.handleStartDateIconClicked = bind(this.handleStartDateIconClicked, this);
      this.handleProjectCodeNameChanged = bind(this.handleProjectCodeNameChanged, this);
      this.updateEditable = bind(this.updateEditable, this);
      this.handleStatusChanged = bind(this.handleStatusChanged, this);
      this.setupAttachFileListController = bind(this.setupAttachFileListController, this);
      this.modelChangeCallback = bind(this.modelChangeCallback, this);
      this.modelSaveCallback = bind(this.modelSaveCallback, this);
      this.handleSaveFailed = bind(this.handleSaveFailed, this);
      this.render = bind(this.render, this);
      this.completeInitialization = bind(this.completeInitialization, this);
      this.getProject = bind(this.getProject, this);
      return ProjectController.__super__.constructor.apply(this, arguments);
    }

    ProjectController.prototype.template = _.template($("#ProjectView").html());

    ProjectController.prototype.moduleLaunchName = "project";

    ProjectController.prototype.events = function() {
      return {
        "change .bv_status": "handleStatusChanged",
        "change .bv_projectCode": "handleProjectCodeNameChanged",
        "keyup .bv_projectName": "attributeChanged",
        "keyup .bv_projectAlias": "attributeChanged",
        "keyup .bv_startDate": "attributeChanged",
        "click .bv_startDateIcon": "handleStartDateIconClicked",
        "keyup .bv_shortDescription": "attributeChanged",
        "keyup .bv_projectDetails": "attributeChanged",
        "change .bv_restrictedData": "attributeChanged",
        "click .bv_save": "handleSaveClicked"
      };
    };

    ProjectController.prototype.initialize = function() {
      if (this.model != null) {
        return this.completeInitialization();
      } else {
        if (window.AppLaunchParams.moduleLaunchParams != null) {
          if (window.AppLaunchParams.moduleLaunchParams.moduleName === this.moduleLaunchName) {
            return $.ajax({
              type: 'GET',
              url: "/api/projects",
              dataType: 'json',
              error: (function(_this) {
                return function(err) {
                  alert('Could not get projects for this user. Creating a new project');
                  return _this.completeInitialization();
                };
              })(this),
              success: (function(_this) {
                return function(projectsList) {
                  if (_.where(projectsList, {
                    code: window.AppLaunchParams.moduleLaunchParams.code
                  }).length > 0) {
                    return _this.getProject();
                  } else {
                    alert('Could not get project for code in this URL, creating new one');
                    return _this.completeInitialization();
                  }
                };
              })(this)
            });
          } else {
            return this.completeInitialization();
          }
        } else {
          return this.completeInitialization();
        }
      }
    };

    ProjectController.prototype.getProject = function() {
      return $.ajax({
        type: 'GET',
        url: "/api/things/project/project/codename/" + window.AppLaunchParams.moduleLaunchParams.code,
        dataType: 'json',
        error: (function(_this) {
          return function(err) {
            alert('Could not get project for code in this URL, creating new one');
            return _this.completeInitialization();
          };
        })(this),
        success: (function(_this) {
          return function(json) {
            var proj;
            if (json.length === 0) {
              alert('Could not get project for code in this URL, creating new one');
            } else {
              proj = new Project(json);
              proj.set(proj.parse(proj.attributes));
              _this.model = proj;
            }
            return _this.completeInitialization();
          };
        })(this)
      });
    };

    ProjectController.prototype.completeInitialization = function() {
      if (this.model == null) {
        this.model = new Project();
      }
      this.errorOwnerName = 'ProjectController';
      this.setBindings();
      if (this.options.readOnly != null) {
        this.readOnly = this.options.readOnly;
      } else {
        this.readOnly = false;
      }
      this.listenTo(this.model, 'saveFailed', this.handleSaveFailed);
      this.listenTo(this.model, 'sync', this.modelSaveCallback);
      this.listenTo(this.model, 'change', this.modelChangeCallback);
      $(this.el).empty();
      $(this.el).html(this.template(this.model.attributes));
      this.setupProjectStatusSelect();
      this.setupTagList();
      this.setupAttachFileListController();
      this.setupProjectLeaderListController();
      this.setupIsRestrictedCheckbox();
      if (!this.model.isNew()) {
        this.adminRole = {
          lsType: "Project",
          lsKind: this.model.get('codeName'),
          roleName: "Administrator"
        };
      }
      if (!this.model.isNew() && (UtilityFunctions.prototype.testUserHasRoleTypeKindName(window.AppLaunchParams.loginUser, [this.adminRole]) || UtilityFunctions.prototype.testUserHasRole(window.AppLaunchParams.loginUser, [window.conf.roles.acas.adminRole]))) {
        this.setupProjectUserListController();
        this.setupProjectAdminListController();
      }
      return this.render();
    };

    ProjectController.prototype.render = function() {
      var bestName, codeName, startDate;
      if (this.model == null) {
        this.model = new Project();
      }
      codeName = this.model.get('codeName');
      this.$('.bv_projectCode').val(codeName);
      this.$('.bv_projectCode').html(codeName);
      if (this.model.isNew()) {
        this.$('.bv_projectCode').removeAttr('disabled');
      } else {
        this.$('.bv_projectCode').attr('disabled', 'disabled');
      }
      bestName = this.model.get('lsLabels').pickBestName();
      if (bestName != null) {
        this.$('.bv_projectName').val(bestName.get('labelText'));
      }
      if (this.model.get('project alias') != null) {
        this.$('.bv_projectAlias').val(this.model.get('project alias').get('labelText'));
      }
      this.$('.bv_startDate').datepicker();
      this.$('.bv_startDate').datepicker("option", "dateFormat", "yy-mm-dd");
      startDate = this.model.get('start date').get('value');
      if (startDate != null) {
        if (!isNaN(startDate)) {
          this.$('.bv_startDate').val(UtilityFunctions.prototype.convertMSToYMDDate(this.model.get('start date').get('value')));
        }
      }
      this.$('.bv_shortDescription').val(this.model.get('short description').get('value'));
      this.$('.bv_projectDetails').val(this.model.get('project details').get('value'));
      if (this.model.isNew()) {
        this.$('.bv_status').attr('disabled', 'disabled');
        this.$('.bv_manageUserPermissions').hide();
        if (UtilityFunctions.prototype.testUserHasRole(window.AppLaunchParams.loginUser, [window.conf.roles.acas.adminRole])) {
          this.$('.bv_saveBeforeManagingPermissions').show();
        }
      } else {
        this.updateEditable();
      }
      if (this.readOnly === true) {
        this.displayInReadOnlyMode();
      }
      this.$('.bv_save').attr('disabled', 'disabled');
      if (this.model.isNew()) {
        this.$('.bv_save').html("Save");
      } else {
        this.$('.bv_save').html("Update");
      }
      return this;
    };

    ProjectController.prototype.handleSaveFailed = function() {
      this.$('.bv_saveFailed').show();
      this.$('.bv_saveComplete').hide();
      return this.$('.bv_saving').hide();
    };

    ProjectController.prototype.modelSaveCallback = function(method, model) {
      this.$('.bv_save').show();
      this.$('.bv_save').attr('disabled', 'disabled');
      if (!this.$('.bv_saveFailed').is(":visible")) {
        this.$('.bv_saveComplete').show();
        this.$('.bv_saving').hide();
      }
      this.setupAttachFileListController();
      this.setupProjectLeaderListController();
      this.adminRole = {
        lsType: "Project",
        lsKind: this.model.get('codeName'),
        roleName: "Administrator"
      };
      if (UtilityFunctions.prototype.testUserHasRoleTypeKindName(window.AppLaunchParams.loginUser, [this.adminRole]) || UtilityFunctions.prototype.testUserHasRole(window.AppLaunchParams.loginUser, [window.conf.roles.acas.adminRole])) {
        this.setupProjectUserListController();
        this.setupProjectAdminListController();
      }
      this.render();
      return this.trigger('amClean');
    };

    ProjectController.prototype.modelChangeCallback = function(method, model) {
      this.trigger('amDirty');
      this.checkFormValid();
      this.$('.bv_saveComplete').hide();
      return this.$('.bv_saveFailed').hide();
    };

    ProjectController.prototype.setupProjectStatusSelect = function() {
      this.statusList = new PickListList();
      this.statusList.url = "/api/codetables/project/status";
      return this.statusListController = new PickListSelectController({
        el: this.$('.bv_status'),
        collection: this.statusList,
        selectedCode: this.model.get('project status').get('value')
      });
    };

    ProjectController.prototype.setupTagList = function() {
      var lsTags;
      this.$('.bv_tags').val("");
      lsTags = this.model.get('lsTags');
      if (lsTags == null) {
        lsTags = new TagList();
      }
      this.tagListController = new TagListController({
        el: this.$('.bv_tags'),
        collection: lsTags
      });
      return this.tagListController.render();
    };

    ProjectController.prototype.setupAttachFileListController = function() {
      return $.ajax({
        type: 'GET',
        url: "/api/codetables/project metadata/file type",
        dataType: 'json',
        error: function(err) {
          return alert('Could not get list of file types');
        },
        success: (function(_this) {
          return function(json) {
            var attachFileList;
            if (json.length === 0) {
              return alert('Got empty list of file types');
            } else {
              attachFileList = _this.model.getAnalyticalFiles(json);
              return _this.finishSetupAttachFileListController(attachFileList, json);
            }
          };
        })(this)
      });
    };

    ProjectController.prototype.finishSetupAttachFileListController = function(attachFileList, fileTypeList) {
      if (this.attachFileListController != null) {
        this.attachFileListController.undelegateEvents();
      }
      this.attachFileListController = new AttachFileListController({
        autoAddAttachFileModel: false,
        el: this.$('.bv_attachFileList'),
        collection: attachFileList,
        firstOptionName: "Select Method",
        allowedFileTypes: ['xls', 'rtf', 'pdf', 'txt', 'csv', 'sdf', 'xlsx', 'doc', 'docx', 'png', 'gif', 'jpg', 'ppt', 'pptx', 'pzf', 'mol', 'cdx', 'cdxml', 'afr6', 'afe6', 'afs6'],
        fileTypeList: fileTypeList,
        required: false
      });
      this.attachFileListController.on('amClean', (function(_this) {
        return function() {
          return _this.trigger('amClean');
        };
      })(this));
      this.attachFileListController.on('renderComplete', (function(_this) {
        return function() {
          return _this.checkDisplayMode();
        };
      })(this));
      this.attachFileListController.render();
      return this.attachFileListController.on('amDirty', (function(_this) {
        return function() {
          _this.trigger('amDirty');
          _this.$('.bv_saveComplete').hide();
          _this.$('.bv_saveFailed').hide();
          return _this.checkFormValid();
        };
      })(this));
    };

    ProjectController.prototype.setupProjectLeaderListController = function() {
      var projLeaders, projLeadersList;
      if (this.projectLeaderListController != null) {
        this.projectLeaderListController.undelegateEvents();
      }
      projLeadersList = new ProjectLeaderList();
      projLeaders = this.model.getProjectLeaders();
      _.each(projLeaders, (function(_this) {
        return function(leader) {
          var newModel, scientistVal;
          newModel = new ProjectLeader(leader.attributes);
          scientistVal = newModel.get('codeValue');
          newModel.set('scientist', scientistVal);
          return projLeadersList.add(newModel);
        };
      })(this));
      this.projectLeaderListController = new ProjectLeaderListController({
        el: this.$('.bv_projectLeaderList'),
        collection: projLeadersList
      });
      this.projectLeaderListController.on('amClean', (function(_this) {
        return function() {
          return _this.trigger('amClean');
        };
      })(this));
      this.projectLeaderListController.on('renderComplete', (function(_this) {
        return function() {
          return _this.checkDisplayMode();
        };
      })(this));
      this.projectLeaderListController.render();
      return this.projectLeaderListController.on('amDirty', (function(_this) {
        return function() {
          _this.trigger('amDirty');
          _this.$('.bv_saveComplete').hide();
          _this.$('.bv_saveFailed').hide();
          return _this.checkFormValid();
        };
      })(this));
    };

    ProjectController.prototype.setupProjectUserListController = function() {
      var projectCodeName;
      if (this.projectUserListController != null) {
        this.projectUserListController.undelegateEvents();
      }
      projectCodeName = this.model.get('codeName');
      return $.ajax({
        type: 'GET',
        url: "/api/projects/getByRoleTypeKindAndName/Project/" + projectCodeName + "/User?format=codetable",
        dataType: 'json',
        error: function(err) {
          return alert('Could not get list of project users');
        },
        success: (function(_this) {
          return function(json) {
            var users;
            users = new ProjectUserList();
            _.each(json, function(user) {
              return users.add(new ProjectUser({
                user: user.code,
                saved: true
              }));
            });
            _this.projectUserListController = new ProjectUserListController({
              el: _this.$('.bv_projectUserList'),
              collection: users
            });
            _this.projectUserListController.on('amClean', function() {
              return _this.trigger('amClean');
            });
            _this.projectUserListController.on('renderComplete', function() {
              return _this.checkDisplayMode();
            });
            _this.projectUserListController.render();
            return _this.projectUserListController.on('amDirty', function() {
              _this.trigger('amDirty');
              _this.$('.bv_saveComplete').hide();
              _this.$('.bv_saveFailed').hide();
              return _this.checkFormValid();
            });
          };
        })(this)
      });
    };

    ProjectController.prototype.setupProjectAdminListController = function() {
      var projectCodeName;
      if (this.projectAdminListController != null) {
        this.projectAdminListController.undelegateEvents();
      }
      projectCodeName = this.model.get('codeName');
      return $.ajax({
        type: 'GET',
        url: "/api/projects/getByRoleTypeKindAndName/Project/" + projectCodeName + "/Administrator?format=codetable",
        dataType: 'json',
        error: function(err) {
          return alert('Could not get list of project admins');
        },
        success: (function(_this) {
          return function(json) {
            var admins;
            admins = new ProjectAdminList();
            _.each(json, function(admin) {
              return admins.add(new ProjectAdmin({
                admin: admin.code,
                saved: true
              }));
            });
            _this.projectAdminListController = new ProjectAdminListController({
              el: _this.$('.bv_projectAdminList'),
              collection: admins
            });
            _this.projectAdminListController.on('amClean', function() {
              return _this.trigger('amClean');
            });
            _this.projectAdminListController.on('renderComplete', function() {
              return _this.checkDisplayMode();
            });
            _this.projectAdminListController.render();
            return _this.projectAdminListController.on('amDirty', function() {
              _this.trigger('amDirty');
              _this.$('.bv_saveComplete').hide();
              _this.$('.bv_saveFailed').hide();
              return _this.checkFormValid();
            });
          };
        })(this)
      });
    };

    ProjectController.prototype.setupIsRestrictedCheckbox = function() {
      if (this.model.get('is restricted').get('value') === "false") {
        return this.$('.bv_restrictedData').removeAttr('checked');
      } else {
        return this.$('.bv_restrictedData').attr('checked', 'checked');
      }
    };

    ProjectController.prototype.handleStatusChanged = function() {
      var value;
      value = this.statusListController.getSelectedCode();
      if ((value === "inactive") && !this.isValid()) {
        value = value.charAt(0).toUpperCase() + value.substring(1);
        alert('All fields must be valid before changing the status to "' + value + '"');
        return this.statusListController.setSelectedCode(this.model.get('project status').get('value'));
      } else {
        this.model.get("project status").set("value", value);
        this.updateEditable();
        return this.checkFormValid();
      }
    };

    ProjectController.prototype.updateEditable = function() {
      if (this.model.isEditable()) {
        if (UtilityFunctions.prototype.testUserHasRoleTypeKindName(window.AppLaunchParams.loginUser, [this.adminRole]) || UtilityFunctions.prototype.testUserHasRole(window.AppLaunchParams.loginUser, [window.conf.roles.acas.adminRole])) {
          this.enableAllInputs();
          this.$('.bv_projectCode').attr('disabled', 'disabled');
          this.$('.bv_manageUserPermissions').show();
          this.$('.bv_saveBeforeManagingPermissions').hide();
        } else {
          this.enableLimitedEditing();
          this.$('.bv_manageUserPermissions').hide();
        }
      } else {
        this.disableAllInputs();
        if (UtilityFunctions.prototype.testUserHasRoleTypeKindName(window.AppLaunchParams.loginUser, [this.adminRole]) || UtilityFunctions.prototype.testUserHasRole(window.AppLaunchParams.loginUser, [window.conf.roles.acas.adminRole])) {
          this.$('.bv_manageUserPermissions').show();
        } else {
          this.$('.bv_manageUserPermissions').hide();
        }
      }
      return this.$('.bv_status').attr('disabled', 'disabled');
    };

    ProjectController.prototype.enableLimitedEditing = function() {
      this.disableAllInputs();
      this.$('.bv_shortDescription').removeAttr('disabled');
      this.$('.bv_projectDetails').removeAttr('disabled');
      this.$('.bv_fileType').removeAttr('disabled');
      this.$('button').removeAttr('disabled');
      this.$('.bv_deleteProjectLeader').attr('disabled', 'disabled');
      return this.$('.bv_addProjectLeaderButton').attr('disabled', 'disabled');
    };

    ProjectController.prototype.handleProjectCodeNameChanged = function() {
      var codeName;
      codeName = UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_projectCode'));
      if (codeName === "") {
        delete this.model.attributes.codeName;
        return this.model.trigger('change');
      } else {
        return $.ajax({
          type: 'GET',
          url: "/api/things/project/project/codename/" + codeName,
          dataType: 'json',
          error: (function(_this) {
            return function(err) {
              return _this.model.set({
                codeName: codeName
              });
            };
          })(this),
          success: (function(_this) {
            return function(json) {
              _this.$('.bv_notUniqueModalTitle').html("Error: Project code is not unique");
              _this.$('.bv_notUniqueModalBody').html("The entered project code is already used by another project. Please enter in a new code.");
              _this.$('.bv_notUniqueModal').modal('show');
              return _this.$('.bv_projectCode').val(_this.model.get('codeName'));
            };
          })(this)
        });
      }
    };

    ProjectController.prototype.handleStartDateIconClicked = function() {
      return this.$(".bv_startDate").datepicker("show");
    };

    ProjectController.prototype.updateModel = function() {
      var isRestricted;
      this.model.get("project name").set("labelText", UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_projectName')));
      this.model.get("project alias").set("labelText", UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_projectAlias')));
      this.model.get("start date").set("value", UtilityFunctions.prototype.convertYMDDateToMs(UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_startDate'))));
      this.model.get("short description").set("value", UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_shortDescription')));
      this.model.get("project details").set("value", UtilityFunctions.prototype.getTrimmedInput(this.$('.bv_projectDetails')));
      isRestricted = this.$('.bv_restrictedData').is(":checked");
      return this.model.get("is restricted").set("value", isRestricted.toString());
    };

    ProjectController.prototype.handleSaveClicked = function() {
      this.callNameValidationService();
      this.$('.bv_saving').show();
      this.$('.bv_saveFailed').hide();
      return this.$('.bv_saveComplete').hide();
    };

    ProjectController.prototype.callNameValidationService = function() {
      var dataToPost, reformattedModel, validateURL;
      this.$('.bv_saving').show();
      this.$('.bv_save').attr('disabled', 'disabled');
      reformattedModel = this.model.clone();
      reformattedModel.reformatBeforeSaving();
      validateURL = "/api/validateName";
      dataToPost = {
        data: JSON.stringify({
          lsThing: reformattedModel,
          uniqueName: true
        })
      };
      return $.ajax({
        type: 'POST',
        url: validateURL,
        data: dataToPost,
        success: (function(_this) {
          return function(response) {
            return _this.handleValidateReturn(response);
          };
        })(this),
        error: (function(_this) {
          return function(err) {
            return _this.serviceReturn = null;
          };
        })(this),
        dataType: 'json'
      });
    };

    ProjectController.prototype.handleValidateReturn = function(validateResp) {
      var ref;
      if ((validateResp != null ? (ref = validateResp[0]) != null ? ref.errorLevel : void 0 : void 0) != null) {
        alert('The requested project name has already been registered. Please choose a new project name.');
        this.$('.bv_saving').hide();
        return this.$('.bv_saveFailed').show();
      } else if (validateResp === "validate name failed") {
        alert('There was an error validating the project name. Please try again and/or enter a different name.');
        this.$('.bv_saving').hide();
        return this.$('.bv_saveFailed').show();
      } else {
        return this.saveProjectAndRoles();
      }
    };

    ProjectController.prototype.saveProjectAndRoles = function() {
      var newProject;
      this.prepareToSaveAttachedFiles();
      this.prepareToSaveProjectLeaders();
      this.tagListController.handleTagsChanged();
      this.model.prepareToSave();
      this.model.reformatBeforeSaving();
      if (this.model.isNew()) {
        this.$('.bv_saveComplete').html('Save Complete');
        newProject = true;
      } else {
        this.$('.bv_saveComplete').html('Update Complete');
        newProject = false;
      }
      this.$('.bv_save').attr('disabled', 'disabled');
      if (this.model.isNew()) {
        return this.model.save(null, {
          success: (function(_this) {
            return function(model, response) {
              if (response === "update lsThing failed") {
                return _this.model.trigger('saveFailed');
              } else {
                return _this.createRoleKindAndName();
              }
            };
          })(this)
        });
      } else {
        if (UtilityFunctions.prototype.testUserHasRoleTypeKindName(window.AppLaunchParams.loginUser, [this.adminRole]) || UtilityFunctions.prototype.testUserHasRole(window.AppLaunchParams.loginUser, [window.conf.roles.acas.adminRole])) {
          return this.updateProjectRoles();
        } else {
          return this.model.save(null, {
            success: (function(_this) {
              return function(model, response) {
                if (response === "update lsThing failed") {
                  return _this.model.trigger('saveFailed');
                } else {
                  return _this.syncRoles();
                }
              };
            })(this),
            error: (function(_this) {
              return function(err) {
                return _this.model.trigger('saveFailed');
              };
            })(this)
          });
        }
      }
    };

    ProjectController.prototype.prepareToSaveAttachedFiles = function() {
      return this.attachFileListController.collection.each((function(_this) {
        return function(file) {
          var newFile, value;
          if (file.isNew()) {
            if (!(file.get('ignored') === true || file.get('fileType') === "unassigned")) {
              newFile = _this.model.get('lsStates').createValueByTypeAndKind("metadata", "project metadata", "fileValue", file.get('fileType'));
              return newFile.set({
                fileValue: file.get('fileValue'),
                comments: file.get('comments')
              });
            }
          } else {
            if (file.get('ignored') === true) {
              value = _this.model.get('lsStates').getValueById("metadata", "project metadata", file.get('id'));
              return value[0].set("ignored", true);
            }
          }
        };
      })(this));
    };

    ProjectController.prototype.prepareToSaveProjectLeaders = function() {
      return this.projectLeaderListController.collection.each((function(_this) {
        return function(leader) {
          var newLeader, value;
          if (leader.isNew()) {
            if (!(leader.get('ignored') === true || leader.get('scientist') === "unassigned")) {
              newLeader = _this.model.get('lsStates').createValueByTypeAndKind("metadata", "project metadata", "codeValue", "project leader");
              return newLeader.set({
                codeValue: leader.get('scientist')
              });
            }
          } else {
            if (leader.get('ignored') === true) {
              value = _this.model.get('lsStates').getValueById("metadata", "project metadata", leader.get('id'));
              return value[0].set("ignored", true);
            }
          }
        };
      })(this));
    };

    ProjectController.prototype.prepareToSaveAuthorRoles = function() {
      var adminsToDelete, adminsToPost, authorRolesToDelete, newAuthorRoles, usersToDelete, usersToPost;
      newAuthorRoles = [];
      usersToPost = this.projectUserListController.collection.filter(function(user) {
        return !user.get('saved') && user.get('user') !== "unassigned" && !user.get('ignored');
      });
      _.each(usersToPost, (function(_this) {
        return function(user) {
          var newAuthor;
          newAuthor = {
            roleType: "Project",
            roleKind: _this.model.get('codeName'),
            roleName: "User",
            userName: user.get('user')
          };
          return newAuthorRoles.push(newAuthor);
        };
      })(this));
      adminsToPost = this.projectAdminListController.collection.filter(function(admin) {
        return !admin.get('saved') && admin.get('admin') !== "unassigned" && !admin.get('ignored');
      });
      _.each(adminsToPost, (function(_this) {
        return function(admin) {
          var newAuthor;
          newAuthor = {
            roleType: "Project",
            roleKind: _this.model.get('codeName'),
            roleName: "Administrator",
            userName: admin.get('admin')
          };
          return newAuthorRoles.push(newAuthor);
        };
      })(this));
      authorRolesToDelete = [];
      usersToDelete = this.projectUserListController.collection.filter(function(user) {
        return user.get('saved') && user.get('ignored');
      });
      _.each(usersToDelete, (function(_this) {
        return function(user) {
          var author;
          author = {
            roleType: "Project",
            roleKind: _this.model.get('codeName'),
            roleName: "User",
            userName: user.get('user')
          };
          return authorRolesToDelete.push(author);
        };
      })(this));
      adminsToDelete = this.projectAdminListController.collection.filter(function(admin) {
        return admin.get('saved') && admin.get('ignored');
      });
      _.each(adminsToDelete, (function(_this) {
        return function(admin) {
          var author;
          author = {
            roleType: "Project",
            roleKind: _this.model.get('codeName'),
            roleName: "Administrator",
            userName: admin.get('admin')
          };
          return authorRolesToDelete.push(author);
        };
      })(this));
      return [newAuthorRoles, authorRolesToDelete];
    };

    ProjectController.prototype.createRoleKindAndName = function() {
      var dataToPost;
      dataToPost = {
        rolekind: [
          {
            typeName: "Project",
            kindName: this.model.get('codeName')
          }
        ],
        lsroles: [
          {
            lsType: "Project",
            lsKind: this.model.get('codeName'),
            roleName: "User"
          }, {
            lsType: "Project",
            lsKind: this.model.get('codeName'),
            roleName: "Administrator"
          }
        ]
      };
      return $.ajax({
        type: 'POST',
        url: '/api/projects/createRoleKindAndName',
        data: dataToPost,
        dataType: 'json',
        success: (function(_this) {
          return function(response) {
            return _this.syncRoles();
          };
        })(this),
        error: (function(_this) {
          return function(err) {
            _this.serviceReturn = null;
            if (err.responseText.indexOf("saveFailed") > -1) {
              return alert('An error occurred saving the projectt role kind and name. Please contact an administrator.');
            }
          };
        })(this)
      });
    };

    ProjectController.prototype.updateProjectRoles = function() {
      var authorRoles, dataToPost;
      authorRoles = this.prepareToSaveAuthorRoles();
      dataToPost = {
        newAuthorRoles: JSON.stringify(authorRoles[0]),
        authorRolesToDelete: JSON.stringify(authorRoles[1])
      };
      return $.ajax({
        type: 'POST',
        url: '/api/projects/updateProjectRoles',
        data: dataToPost,
        dataType: 'json',
        success: (function(_this) {
          return function(response) {
            return _this.model.save(null, {
              success: function(model, response) {
                if (response === "update lsThing failed") {
                  return _this.model.trigger('saveFailed');
                } else {
                  return _this.syncRoles();
                }
              },
              error: function(err) {
                _this.serviceReturn = null;
                if (err.responseText.indexOf("saveFailed") > -1) {
                  alert('An error occurred saving the project.');
                  return _this.model.trigger('saveFailed');
                }
              }
            });
          };
        })(this),
        error: (function(_this) {
          return function(err) {
            alert('An error occurred saving the project roles');
            return _this.model.trigger('saveFailed');
          };
        })(this)
      });
    };

    ProjectController.prototype.syncRoles = function() {
      return $.ajax({
        type: 'GET',
        url: "/api/syncLiveDesignProjectsUsers",
        error: (function(_this) {
          return function(err) {
            _this.$('.bv_syncProjectUsersErrorMessage').html(err.responseText);
            _this.$('.bv_syncProjectUsersError').modal('show');
            return _this.model.trigger('saveFailed');
          };
        })(this),
        success: (function(_this) {
          return function(json) {
            return console.log('successfully synced live design project users');
          };
        })(this)
      });
    };

    ProjectController.prototype.validationError = function() {
      ProjectController.__super__.validationError.call(this);
      return this.$('.bv_save').attr('disabled', 'disabled');
    };

    ProjectController.prototype.clearValidationErrorStyles = function() {
      ProjectController.__super__.clearValidationErrorStyles.call(this);
      return this.$('.bv_save').removeAttr('disabled');
    };

    ProjectController.prototype.checkDisplayMode = function() {
      if (this.readOnly === true) {
        return this.displayInReadOnlyMode();
      }
    };

    ProjectController.prototype.displayInReadOnlyMode = function() {
      this.$(".bv_save").hide();
      this.$('button').attr('disabled', 'disabled');
      this.$(".bv_startDateIcon").addClass("uneditable-input");
      this.$(".bv_startDateIcon").on("click", function() {
        return false;
      });
      return this.disableAllInputs();
    };

    ProjectController.prototype.checkFormValid = function() {
      if (this.isValid()) {
        return this.$('.bv_save').removeAttr('disabled');
      } else {
        return this.$('.bv_save').attr('disabled', 'disabled');
      }
    };

    ProjectController.prototype.isValid = function() {
      var validCheck;
      validCheck = ProjectController.__super__.isValid.call(this);
      if (this.attachFileListController != null) {
        if (this.attachFileListController.isValid() === false) {
          validCheck = false;
        }
      }
      if (this.projectLeaderListController != null) {
        if (this.projectLeaderListController.isValid() === false) {
          validCheck = false;
        }
      }
      if (this.projectUserListController != null) {
        if (this.projectUserListController.isValid() === false) {
          validCheck = false;
        }
      }
      if (this.projectAdminListController != null) {
        if (this.projectAdminListController.isValid() === false) {
          validCheck = false;
        }
      }
      return validCheck;
    };

    return ProjectController;

  })(AbstractFormController);

}).call(this);
