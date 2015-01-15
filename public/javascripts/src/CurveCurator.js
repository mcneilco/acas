(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.DoseResponseKnockoutPanelController = (function(_super) {
    __extends(DoseResponseKnockoutPanelController, _super);

    function DoseResponseKnockoutPanelController() {
      this.handleDoseResponseKnockoutPanelHidden = __bind(this.handleDoseResponseKnockoutPanelHidden, this);
      this.setupKnockoutReasonPicklist = __bind(this.setupKnockoutReasonPicklist, this);
      this.show = __bind(this.show, this);
      this.render = __bind(this.render, this);
      return DoseResponseKnockoutPanelController.__super__.constructor.apply(this, arguments);
    }

    DoseResponseKnockoutPanelController.prototype.template = _.template($("#DoseResponseKnockoutPanelView").html());

    DoseResponseKnockoutPanelController.prototype.render = function() {
      this.$el.empty();
      this.$el.html(this.template());
      this.setupKnockoutReasonPicklist();
      this.$('.bv_doseResponseKnockoutPanel').on("show", (function(_this) {
        return function() {
          return _this.$('.bv_dataDictPicklist').focus();
        };
      })(this));
      this.$('.bv_doseResponseKnockoutPanel').on("keypress", (function(_this) {
        return function(key) {
          if (key.keyCode === 13) {
            return _this.$('.bv_doseResponseKnockoutPanelOKBtn').click();
          }
        };
      })(this));
      this.$('.bv_doseResponseKnockoutPanel').on("hidden", (function(_this) {
        return function() {
          return _this.handleDoseResponseKnockoutPanelHidden();
        };
      })(this));
      return this;
    };

    DoseResponseKnockoutPanelController.prototype.show = function() {
      this.$('.bv_doseResponseKnockoutPanel').modal({
        backdrop: "static"
      });
      return this.$('.bv_doseResponseKnockoutPanel').modal("show");
    };

    DoseResponseKnockoutPanelController.prototype.setupKnockoutReasonPicklist = function() {
      this.knockoutReasonList = new PickListList();
      this.knockoutReasonList.url = "/api/codetables/user well flags/flag observation";
      return this.knockoutReasonListController = new PickListSelectController({
        el: this.$('.bv_dataDictPicklist'),
        collection: this.knockoutReasonList
      });
    };

    DoseResponseKnockoutPanelController.prototype.handleDoseResponseKnockoutPanelHidden = function() {
      var comment, observation, reason, status;
      status = "knocked out";
      reason = this.knockoutReasonListController.getSelectedCode();
      observation = reason;
      comment = this.knockoutReasonListController.getSelectedModel().get('name');
      return this.trigger('reasonSelected', status, observation, reason, comment);
    };

    return DoseResponseKnockoutPanelController;

  })(Backbone.View);

  window.DoseResponsePlotController = (function(_super) {
    __extends(DoseResponsePlotController, _super);

    function DoseResponsePlotController() {
      this.initJSXGraph = __bind(this.initJSXGraph, this);
      this.knockoutPoints = __bind(this.knockoutPoints, this);
      this.showDoseResponseKnockoutPanel = __bind(this.showDoseResponseKnockoutPanel, this);
      this.render = __bind(this.render, this);
      return DoseResponsePlotController.__super__.constructor.apply(this, arguments);
    }

    DoseResponsePlotController.prototype.template = _.template($("#DoseResponsePlotView").html());

    DoseResponsePlotController.prototype.initialize = function() {
      return this.pointList = [];
    };

    DoseResponsePlotController.prototype.render = function() {
      this.$el.empty();
      this.$el.html(this.template());
      if (this.model != null) {
        this.$('.bv_plotWindow').attr('id', "bvID_plotWindow_" + this.model.cid);
        this.doseResponseKnockoutPanelController = new DoseResponseKnockoutPanelController({
          el: this.$('.bv_doseResponseKnockoutPanel')
        });
        this.doseResponseKnockoutPanelController.render();
        this.initJSXGraph(this.model.get('points'), this.model.get('curve'), this.model.get('plotWindow'), this.$('.bv_plotWindow').attr('id'));
        return this;
      } else {
        return this.$el.html("Plot data not loaded");
      }
    };

    DoseResponsePlotController.prototype.showDoseResponseKnockoutPanel = function(selectedPoints) {
      this.doseResponseKnockoutPanelController.show();
      this.doseResponseKnockoutPanelController.on('reasonSelected', (function(_this) {
        return function(status, observation, reason, comment) {
          return _this.knockoutPoints(selectedPoints, status, observation, reason, comment);
        };
      })(this));
    };

    DoseResponsePlotController.prototype.knockoutPoints = function(selectedPoints, status, observation, reason, comment) {
      selectedPoints.forEach((function(_this) {
        return function(selectedPoint) {
          _this.points[selectedPoint.idx].algorithmFlagStatus = "";
          _this.points[selectedPoint.idx].algorithmFlagObservation = "";
          _this.points[selectedPoint.idx].algorithmFlagReason = "";
          _this.points[selectedPoint.idx].algorithmFlagComment = "";
          _this.points[selectedPoint.idx].preprocessFlagStatus = "";
          _this.points[selectedPoint.idx].preprocessFlagObservation = "";
          _this.points[selectedPoint.idx].preprocessFlagReason = "";
          _this.points[selectedPoint.idx].preprocessFlagComment = "";
          _this.points[selectedPoint.idx].userFlagStatus = status;
          _this.points[selectedPoint.idx].userFlagObservation = observation;
          _this.points[selectedPoint.idx].userFlagReason = reason;
          _this.points[selectedPoint.idx].userFlagComment = comment;
          return selectedPoint.drawAsKnockedOut();
        };
      })(this));
      this.model.set({
        points: this.points
      });
      this.model.trigger('change');
    };

    DoseResponsePlotController.prototype.initJSXGraph = function(points, curve, plotWindow, divID) {
      var algorithmFlagComment, algorithmFlagStatus, brd, color, createSelection, fct, getMouseCoords, ii, includePoints, intersect, log10, p1, preprocessFlagComment, preprocessFlagStatus, promptForKnockout, t, userFlagComment, userFlagStatus, x, y;
      this.points = points;
      log10 = function(val) {
        return Math.log(val) / Math.LN10;
      };
      if (typeof brd === "undefined") {
        brd = JXG.JSXGraph.initBoard(divID, {
          boundingbox: plotWindow,
          axis: false,
          showCopyright: false,
          zoom: {
            wheel: false
          }
        });
        promptForKnockout = (function(_this) {
          return function(selectedPoints) {
            return _this.showDoseResponseKnockoutPanel(selectedPoints);
          };
        })(this);
        includePoints = (function(_this) {
          return function(selectedPoints) {
            selectedPoints.forEach(function(selectedPoint) {
              _this.points[selectedPoint.idx].algorithmFlagObservation = "";
              _this.points[selectedPoint.idx].algorithmFlagReason = "";
              _this.points[selectedPoint.idx].algorithmFlagComment = "";
              _this.points[selectedPoint.idx].preprocessFlagStatus = "";
              _this.points[selectedPoint.idx].preprocessFlagObservation = "";
              _this.points[selectedPoint.idx].preprocessFlagReason = "";
              _this.points[selectedPoint.idx].preprocessFlagComment = "";
              _this.points[selectedPoint.idx].userFlagStatus = "";
              _this.points[selectedPoint.idx].userFlagObservation = "";
              _this.points[selectedPoint.idx].userFlagReason = "";
              _this.points[selectedPoint.idx].userFlagComment = "";
              return selectedPoint.drawAsIncluded();
            });
            _this.model.set({
              points: _this.points
            });
            _this.model.trigger('change');
          };
        })(this);
        ii = 0;
        while (ii < points.length) {
          x = log10(points[ii].dose);
          y = points[ii].response;
          userFlagStatus = points[ii].userFlagStatus;
          preprocessFlagStatus = points[ii].preprocessFlagStatus;
          algorithmFlagStatus = points[ii].algorithmFlagStatus;
          userFlagComment = points[ii].userFlagComment;
          preprocessFlagComment = points[ii].preprocessFlagReason;
          algorithmFlagComment = points[ii].algorithmFlagComment;
          if (userFlagStatus === "knocked out" || preprocessFlagStatus === "knocked out" || algorithmFlagStatus === "knocked out") {
            color = (function() {
              switch (false) {
                case userFlagStatus !== "knocked out":
                  return 'red';
                case preprocessFlagStatus !== "knocked out":
                  return 'gray';
                case algorithmFlagStatus !== "knocked out":
                  return 'blue';
              }
            })();
            p1 = brd.create("point", [x, y], {
              name: points[ii].response_sv_id,
              fixed: true,
              size: 4,
              face: "cross",
              strokecolor: color,
              withLabel: false
            });
            p1.knockedOut = true;
          } else {
            p1 = brd.create("point", [x, y], {
              name: points[ii].response_sv_id,
              fixed: true,
              size: 4,
              face: "circle",
              strokecolor: "blue",
              withLabel: false
            });
            p1.knockedOut = false;
          }
          p1.idx = ii;
          p1.isDoseResponsePoint = true;
          p1.isSelected = false;
          p1.drawAsKnockedOut = function() {
            return this.setAttribute({
              strokecolor: "red",
              face: "cross",
              knockedOut: true
            });
          };
          p1.drawAsIncluded = function() {
            return this.setAttribute({
              strokecolor: "blue",
              face: "circle",
              knockedOut: false
            });
          };
          p1.handlePointClicked = function() {
            if (!this.knockedOut) {
              promptForKnockout([this]);
            } else {
              includePoints([this]);
            }
          };
          p1.on("up", p1.handlePointClicked, p1);
          p1.flagLabel = (function() {
            switch (false) {
              case userFlagStatus !== "knocked out":
                return userFlagComment;
              case preprocessFlagStatus !== "knocked out":
                return preprocessFlagComment;
              case algorithmFlagStatus !== "knocked out":
                return algorithmFlagComment;
              default:
                return '';
            }
          })();
          p1.xLabel = JXG.trunc(points[ii].dose, 4);
          this.pointList.push(p1);
          brd.highlightInfobox = function(x, y, el) {
            brd.infobox.setText("(" + el.xLabel + ", " + y + ", " + el.flagLabel + ")");
            brd.infobox.setProperty({
              strokeColor: 'black'
            });
          };
          ii++;
        }
        x = brd.create("line", [[0, 0], [1, 0]], {
          strokeColor: "#888888"
        });
        y = brd.create("axis", [[plotWindow[0], 0], [plotWindow[0], 1]]);
        x.isDraggable = false;
        t = brd.create("ticks", [x, 1], {
          drawLabels: true,
          drawZero: true,
          generateLabelValue: function(tick) {
            p1 = this.line.point1;
            return Math.pow(10, tick.usrCoords[1] - p1.coords.usrCoords[1]);
          }
        });
      } else {
        if (typeof window.curve !== "undefined") {
          brd.removeObject(window.curve);
        }
      }
      if (curve != null) {
        if (curve.type === "4 parameter D-R") {
          fct = function(x) {
            return curve.min + (curve.max - curve.min) / (1 + Math.exp(curve.slope * Math.log(Math.pow(10, x) / curve.ec50)));
          };
          brd.create('functiongraph', [fct, plotWindow[0], plotWindow[2]], {
            strokeWidth: 2
          });
          if (curve.reported_ec50 != null) {
            intersect = fct(log10(curve.reported_ec50));
            if (curve.reported_operator != null) {
              color = '#ff0000';
            } else {
              color = '#808080';
            }
            brd.create('line', [[plotWindow[0], intersect], [log10(curve.reported_ec50), intersect]], {
              fixed: true,
              straightFirst: false,
              straightLast: false,
              strokeWidth: 2,
              dash: 3,
              strokeColor: color
            });
            brd.create('line', [[log10(curve.reported_ec50), intersect], [log10(curve.reported_ec50), 0]], {
              fixed: true,
              straightFirst: false,
              straightLast: false,
              strokeWidth: 2,
              dash: 3,
              strokeColor: color
            });
          }
        }
        if (curve.type === "Ki Fit") {
          fct = function(x) {
            return curve.max + (curve.min - curve.max) / (1 + Math.pow(10, x - log10(curve.ki * (1 + curve.ligandConc / curve.kd))));
          };
          brd.create('functiongraph', [fct, plotWindow[0], plotWindow[2]], {
            strokeWidth: 2
          });
          if (curve.reported_ki != null) {
            intersect = fct(log10(curve.reported_ki));
            if (curve.reported_operator != null) {
              color = '#ff0000';
            } else {
              color = '#808080';
            }
            brd.create('line', [[plotWindow[0], intersect], [log10(curve.reported_ki), intersect]], {
              fixed: true,
              straightFirst: false,
              straightLast: false,
              strokeWidth: 2,
              dash: 3,
              strokeColor: color
            });
            brd.create('line', [[log10(curve.reported_ki), intersect], [log10(curve.reported_ki), 0]], {
              fixed: true,
              straightFirst: false,
              straightLast: false,
              strokeWidth: 2,
              dash: 3,
              strokeColor: color
            });
          }
        }
      }
      getMouseCoords = function(e) {
        var absPos, cPos, dx, dy;
        cPos = brd.getCoordsTopLeftCorner(e);
        absPos = JXG.getPosition(e);
        dx = absPos[0] - cPos[0];
        dy = absPos[1] - cPos[1];
        return new JXG.Coords(JXG.COORDS_BY_SCREEN, [dx, dy], brd);
      };
      createSelection = function(e) {
        var a, b, c, coords, d, selection;
        if (brd.elementsByName.selection == null) {
          coords = getMouseCoords(e);
          a = brd.create('point', [coords.usrCoords[1], coords.usrCoords[2]], {
            name: 'selectionA',
            withLabel: false,
            visible: false,
            fixed: false
          });
          b = brd.create('point', [coords.usrCoords[1], coords.usrCoords[2]], {
            name: 'selectionB',
            visible: false,
            fixed: true
          });
          c = brd.create('point', ["X(selectionA)", coords.usrCoords[2]], {
            name: 'selectionC',
            visible: false
          });
          d = brd.create('point', [coords.usrCoords[1], "Y(selectionA)"], {
            name: 'selectionD',
            visible: false
          });
          selection = brd.create('polygon', [b, c, a, d], {
            name: 'selection',
            hasInnerPoints: true
          });
          selection.update = function() {
            if (brd.elementsByName.selectionA.coords.usrCoords[2] < brd.elementsByName.selectionB.coords.usrCoords[2]) {
              this.setAttribute({
                fillcolor: 'red'
              });
              return selection.knockoutMode = true;
            } else {
              this.setAttribute({
                fillcolor: '#00FF00'
              });
              return selection.knockoutMode = false;
            }
          };
          selection.on('update', selection.update, selection);
          brd.mouseUp = function() {
            var knockoutMode, selected;
            selection = brd.elementsByName.selection;
            if (selection != null) {
              knockoutMode = selection.knockoutMode;
              brd.removeObject(selection);
              brd.removeObject(brd.elementsByName.selectionC);
              brd.removeObject(brd.elementsByName.selectionD);
              brd.removeObject(brd.elementsByName.selectionB);
              brd.removeObject(brd.elementsByName.selectionA);
              selected = selection.selected;
              if (selected != null) {
                if (selected.length > 0) {
                  if (knockoutMode) {
                    return promptForKnockout(selected);
                  } else {
                    return includePoints(selected);
                  }
                }
              }
            }
          };
          brd.on('up', brd.mouseUp, brd);
          brd.followSelection = function(e) {
            var doseResponsePoints, north, northEast, northWest, selected, selectionCoords, sorted, south, southEast, southWest;
            if (brd.elementsByName.selection) {
              coords = getMouseCoords(e);
              brd.elementsByName.selectionA.setPosition(JXG.COORDS_BY_USER, coords.usrCoords);
              selection = brd.elementsByName.selection;
              selection.update();
              selectionCoords = [selection.vertices[0].coords.usrCoords, selection.vertices[1].coords.usrCoords, selection.vertices[2].coords.usrCoords, selection.vertices[3].coords.usrCoords];
              sorted = _.sortBy(selection.vertices.slice(0, 4), function(vertex) {
                return vertex.coords.usrCoords[2];
              });
              south = _.sortBy(sorted.slice(0, 2), function(vertex) {
                return vertex.coords.usrCoords[1];
              });
              north = _.sortBy(sorted.slice(2, 4), function(vertex) {
                return vertex.coords.usrCoords[1];
              });
              northWest = north[0].coords.usrCoords;
              northEast = north[1].coords.usrCoords;
              southWest = south[0].coords.usrCoords;
              southEast = south[1].coords.usrCoords;
              selected = [];
              doseResponsePoints = _.where(brd.elementsByName, {
                isDoseResponsePoint: true,
                isSelected: false
              });
              doseResponsePoints.forEach(function(point) {
                if (point.coords.usrCoords[1] > northWest[1] & point.coords.usrCoords[2] < northWest[2] & point.coords.usrCoords[1] < northEast[1] & point.coords.usrCoords[2] < northEast[2] & point.coords.usrCoords[1] > southWest[1] & point.coords.usrCoords[1] > southWest[1] & point.coords.usrCoords[2] > southWest[2] & point.coords.usrCoords[1] < southEast[1] & point.coords.usrCoords[2] > southWest[2]) {
                  return selected.push(point);
                }
              });
              return selection.selected = selected;
            }
          };
          brd.on('move', brd.followSelection, brd);
        }
      };
      brd.on("down", createSelection);
    };

    return DoseResponsePlotController;

  })(AbstractFormController);

  window.CurveDetail = (function(_super) {
    __extends(CurveDetail, _super);

    function CurveDetail() {
      this.parse = __bind(this.parse, this);
      this.fixCompositeClasses = __bind(this.fixCompositeClasses, this);
      return CurveDetail.__super__.constructor.apply(this, arguments);
    }

    CurveDetail.prototype.url = function() {
      return "/api/curve/detail/" + this.id;
    };

    CurveDetail.prototype.initialize = function() {
      return this.fixCompositeClasses();
    };

    CurveDetail.prototype.fixCompositeClasses = function() {
      if (!(this.get('fitSettings') instanceof DoseResponseKiAnalysisParameters)) {
        return this.set({
          fitSettings: new DoseResponseKiAnalysisParameters(this.get('fitSettings'))
        });
      }
    };

    CurveDetail.prototype.parse = function(resp) {
      if (!(resp.fitSettings instanceof DoseResponseKiAnalysisParameters)) {
        resp.fitSettings = new DoseResponseKiAnalysisParameters(resp.fitSettings);
      }
      return resp;
    };

    return CurveDetail;

  })(Backbone.Model);

  window.CurveEditorController = (function(_super) {
    __extends(CurveEditorController, _super);

    function CurveEditorController() {
      this.deleteRsession = __bind(this.deleteRsession, this);
      this.handleUpdateSuccess = __bind(this.handleUpdateSuccess, this);
      this.handleSaveSuccess = __bind(this.handleSaveSuccess, this);
      this.handleUpdateError = __bind(this.handleUpdateError, this);
      this.handleSaveError = __bind(this.handleSaveError, this);
      this.handleResetError = __bind(this.handleResetError, this);
      this.handleRejectClicked = __bind(this.handleRejectClicked, this);
      this.handleApproveClicked = __bind(this.handleApproveClicked, this);
      this.handleUpdateClicked = __bind(this.handleUpdateClicked, this);
      this.handleResetClicked = __bind(this.handleResetClicked, this);
      this.handleParametersChanged = __bind(this.handleParametersChanged, this);
      this.handlePointsChanged = __bind(this.handlePointsChanged, this);
      this.handleModelSync = __bind(this.handleModelSync, this);
      this.render = __bind(this.render, this);
      return CurveEditorController.__super__.constructor.apply(this, arguments);
    }

    CurveEditorController.prototype.template = _.template($("#CurveEditorView").html());

    CurveEditorController.prototype.events = {
      'click .bv_reset': 'handleResetClicked',
      'click .bv_update': 'handleUpdateClicked',
      'click .bv_approve': 'handleApproveClicked',
      'click .bv_reject': 'handleRejectClicked'
    };

    CurveEditorController.prototype.render = function() {
      var drapcType;
      this.$el.empty();
      if (this.model != null) {
        this.$el.html(this.template());
        drapcType = (function() {
          switch (this.model.get('renderingHint')) {
            case "4 parameter D-R":
              return DoseResponseAnalysisParametersController;
            case "Ki Fit":
              return DoseResponseKiAnalysisParametersController;
          }
        }).call(this);
        this.drapc = new drapcType({
          model: this.model.get('fitSettings'),
          el: this.$('.bv_analysisParameterForm')
        });
        this.drapc.setFormTitle("Fit Criteria");
        this.drapc.render();
        this.stopListening(this.drapc.model, 'change');
        this.listenTo(this.drapc.model, 'change', this.handleParametersChanged);
        this.drpc = new DoseResponsePlotController({
          model: new Backbone.Model(this.model.get('plotData')),
          el: this.$('.bv_plotWindowWrapper')
        });
        this.drpc.render();
        this.stopListening(this.drpc.model, 'change');
        this.listenTo(this.drpc.model, 'change', this.handlePointsChanged);
        this.$('.bv_reportedValues').html(this.model.get('reportedValues'));
        this.$('.bv_fitSummary').html(this.model.get('fitSummary'));
        this.$('.bv_parameterStdErrors').html(this.model.get('parameterStdErrors'));
        this.$('.bv_curveErrors').html(this.model.get('curveErrors'));
        this.$('.bv_category').html(this.model.get('category'));
        if (this.model.get('algorithmFlagStatus') === '') {
          this.$('.bv_pass').show();
          this.$('.bv_fail').hide();
        } else {
          this.$('.bv_pass').hide();
          this.$('.bv_fail').show();
        }
        if (this.model.get('userFlagStatus') === '') {
          this.$('.bv_na').show();
          this.$('.bv_thumbsUp').hide();
          return this.$('.bv_thumbsDown').hide();
        } else {
          if (this.model.get('userFlagStatus') === 'approved') {
            this.$('.bv_na').hide();
            this.$('.bv_thumbsUp').show();
            return this.$('.bv_thumbsDown').hide();
          } else {
            this.$('.bv_na').hide();
            this.$('.bv_thumbsUp').hide();
            return this.$('.bv_thumbsDown').show();
          }
        }
      } else {
        return this.$el.html("No curve selected");
      }
    };

    CurveEditorController.prototype.setModel = function(model) {
      if (this.model != null) {
        this.deleteRsession();
      }
      this.model = model;
      this.render();
      UtilityFunctions.prototype.showProgressModal(this.$('.bv_statusDropDown'));
      return this.model.on('sync', this.handleModelSync);
    };

    CurveEditorController.prototype.handleModelSync = function() {
      UtilityFunctions.prototype.hideProgressModal(this.$('.bv_statusDropDown'));
      return this.render();
    };

    CurveEditorController.prototype.handlePointsChanged = function() {
      UtilityFunctions.prototype.showProgressModal(this.$('.bv_statusDropDown'));
      return this.model.save({
        action: 'pointsChanged',
        user: window.AppLaunchParams.loginUserName
      }, {
        success: this.handleUpdateSuccess,
        error: this.handleUpdateError
      });
    };

    CurveEditorController.prototype.handleParametersChanged = function() {
      if (this.drapc.model.isValid()) {
        UtilityFunctions.prototype.showProgressModal(this.$('.bv_statusDropDown'));
        return this.model.save({
          action: 'parametersChanged',
          user: window.AppLaunchParams.loginUserName
        }, {
          success: this.handleUpdateSuccess,
          error: this.handleUpdateError
        });
      }
    };

    CurveEditorController.prototype.handleResetClicked = function() {
      UtilityFunctions.prototype.showProgressModal(this.$('.bv_statusDropDown'));
      this.deleteRsession();
      return this.model.fetch({
        success: this.handleUpdateSuccess,
        error: this.handleUpdateError
      });
    };

    CurveEditorController.prototype.handleUpdateClicked = function() {
      UtilityFunctions.prototype.showProgressModal(this.$('.bv_statusDropDown'));
      this.oldID = this.model.get('curveid');
      return this.model.save({
        action: 'save',
        user: window.AppLaunchParams.loginUserName
      }, {
        success: this.handleSaveSuccess,
        error: this.handleSaveError
      });
    };

    CurveEditorController.prototype.handleApproveClicked = function() {
      UtilityFunctions.prototype.showProgressModal(this.$('.bv_statusDropDown'));
      return this.model.save({
        action: 'userFlagStatus',
        userFlagStatus: 'approved',
        user: window.AppLaunchParams.loginUserName
      }, {
        success: this.handleUpdateSuccess,
        error: this.handleUpdateError
      });
    };

    CurveEditorController.prototype.handleRejectClicked = function() {
      UtilityFunctions.prototype.showProgressModal(this.$('.bv_statusDropDown'));
      return this.model.save({
        action: 'userFlagStatus',
        userFlagStatus: 'rejected',
        user: window.AppLaunchParams.loginUserName
      }, {
        success: this.handleUpdateSuccess,
        error: this.handleUpdateError
      });
    };

    CurveEditorController.prototype.handleResetError = function() {
      UtilityFunctions.prototype.hideProgressModal(this.$('.bv_statusDropDown'));
      return this.trigger('curveUpdateError');
    };

    CurveEditorController.prototype.handleSaveError = function() {
      UtilityFunctions.prototype.hideProgressModal(this.$('.bv_statusDropDown'));
      return this.trigger('curveUpdateError');
    };

    CurveEditorController.prototype.handleUpdateError = function() {
      UtilityFunctions.prototype.hideProgressModal(this.$('.bv_statusDropDown'));
      return this.trigger('curveUpdateError');
    };

    CurveEditorController.prototype.handleSaveSuccess = function() {
      var algorithmFlagStatus, category, dirty, newID, userFlagStatus;
      this.handleModelSync();
      newID = this.model.get('curveid');
      dirty = this.model.get('dirty');
      category = this.model.get('category');
      userFlagStatus = this.model.get('userFlagStatus');
      algorithmFlagStatus = this.model.get('algorithmFlagStatus');
      return this.trigger('curveDetailSaved', this.oldID, newID, dirty, category, userFlagStatus, algorithmFlagStatus);
    };

    CurveEditorController.prototype.handleUpdateSuccess = function() {
      var curveid, dirty;
      this.handleModelSync();
      curveid = this.model.get('curveid');
      dirty = this.model.get('dirty');
      return this.trigger('curveDetailUpdated', curveid, dirty);
    };

    CurveEditorController.prototype.deleteRsession = function() {
      return this.model.save({
        action: 'deleteSession',
        user: window.AppLaunchParams.loginUserName
      });
    };

    return CurveEditorController;

  })(Backbone.View);

  window.Curve = (function(_super) {
    __extends(Curve, _super);

    function Curve() {
      return Curve.__super__.constructor.apply(this, arguments);
    }

    return Curve;

  })(Backbone.Model);

  window.CurveList = (function(_super) {
    __extends(CurveList, _super);

    function CurveList() {
      this.updateUserFlagStatus = __bind(this.updateUserFlagStatus, this);
      this.updateDirtyFlag = __bind(this.updateDirtyFlag, this);
      this.updateCurveSummary = __bind(this.updateCurveSummary, this);
      this.getIndexByCurveID = __bind(this.getIndexByCurveID, this);
      this.getCurveByID = __bind(this.getCurveByID, this);
      return CurveList.__super__.constructor.apply(this, arguments);
    }

    CurveList.prototype.model = Curve;

    CurveList.prototype.getCategories = function() {
      var catList, cats;
      cats = _.unique(this.pluck('category'));
      catList = new Backbone.Collection();
      _.each(cats, function(cat) {
        return catList.add({
          code: cat,
          name: cat
        });
      });
      return catList;
    };

    CurveList.prototype.getCurveByID = function(curveID) {
      var curve;
      curve = this.findWhere({
        curveid: curveID
      });
      return curve;
    };

    CurveList.prototype.getIndexByCurveID = function(curveID) {
      var curve, index;
      curve = this.getCurveByID(curveID);
      index = this.indexOf(curve);
      return index;
    };

    CurveList.prototype.updateCurveSummary = function(oldID, newCurveID, dirty, category, userFlagStatus, algorithmFlagStatus) {
      var curve;
      curve = this.getCurveByID(oldID);
      return curve.set({
        curveid: newCurveID,
        dirty: dirty,
        userFlagStatus: userFlagStatus,
        algorithmFlagStatus: algorithmFlagStatus,
        category: category
      });
    };

    CurveList.prototype.updateDirtyFlag = function(curveid, dirty) {
      var curve;
      curve = this.getCurveByID(curveid);
      return curve.set({
        dirty: dirty
      });
    };

    CurveList.prototype.updateUserFlagStatus = function(curveid, userFlagStatus) {
      var curve;
      curve = this.getCurveByID(curveid);
      return curve.set({
        userFlagStatus: userFlagStatus
      });
    };

    return CurveList;

  })(Backbone.Collection);

  window.CurveCurationSet = (function(_super) {
    __extends(CurveCurationSet, _super);

    function CurveCurationSet() {
      this.parse = __bind(this.parse, this);
      return CurveCurationSet.__super__.constructor.apply(this, arguments);
    }

    CurveCurationSet.prototype.defaults = {
      sortOptions: new Backbone.Collection(),
      curves: new CurveList()
    };

    CurveCurationSet.prototype.setExperimentCode = function(exptCode) {
      return this.url = "/api/curves/stubs/" + exptCode;
    };

    CurveCurationSet.prototype.parse = function(resp) {
      if (resp.curves != null) {
        if (!(resp.curves instanceof CurveList)) {
          resp.curves = new CurveList(resp.curves);
          resp.curves.on('change', (function(_this) {
            return function() {
              return _this.trigger('change');
            };
          })(this));
        }
      }
      if (resp.sortOptions != null) {
        if (!(resp.sortOptions instanceof Backbone.Collection)) {
          resp.sortOptions = new Backbone.Collection(resp.sortOptions);
          resp.sortOptions.on('change', (function(_this) {
            return function() {
              return _this.trigger('change');
            };
          })(this));
        }
      }
      return resp;
    };

    return CurveCurationSet;

  })(Backbone.Model);

  window.CurveEditorDirtyPanelController = (function(_super) {
    __extends(CurveEditorDirtyPanelController, _super);

    function CurveEditorDirtyPanelController() {
      this.hide = __bind(this.hide, this);
      this.show = __bind(this.show, this);
      this.render = __bind(this.render, this);
      return CurveEditorDirtyPanelController.__super__.constructor.apply(this, arguments);
    }

    CurveEditorDirtyPanelController.prototype.template = _.template($("#CurveEditorDirtyPanelView").html());

    CurveEditorDirtyPanelController.prototype.render = function() {
      this.$el.empty();
      this.$el.html(this.template());
      this.$('.bv_curveEditorDirtyPanel').on("show", (function(_this) {
        return function() {
          return _this.$('.bv_curveEditorDirtyPanelOKBtn').focus();
        };
      })(this));
      this.$('.bv_curveEditorDirtyPanel').on("keypress", (function(_this) {
        return function(key) {
          if (key.keyCode === 13) {
            return _this.$('.bv_curveEditorDirtyPanelOKBtn').click();
          }
        };
      })(this));
      this.$('.bv_doseResponseKnockoutPanel').on("hidden", (function(_this) {
        return function() {};
      })(this));
      return this;
    };

    CurveEditorDirtyPanelController.prototype.show = function() {
      this.$('.bv_curveEditorDirtyPanel').modal({
        backdrop: "static"
      });
      return this.$('.bv_curveEditorDirtyPanel').modal("show");
    };

    CurveEditorDirtyPanelController.prototype.hide = function() {
      var comment, observation, reason, status;
      status = "knocked out";
      reason = this.knockoutReasonListController.getSelectedCode();
      observation = reason;
      comment = this.knockoutReasonListController.getSelectedModel().get('name');
      return this.trigger('reasonSelected', status, observation, reason(comment));
    };

    return CurveEditorDirtyPanelController;

  })(Backbone.View);

  window.CurveSummaryController = (function(_super) {
    __extends(CurveSummaryController, _super);

    function CurveSummaryController() {
      this.clearSelected = __bind(this.clearSelected, this);
      this.setSelected = __bind(this.setSelected, this);
      this.setUserFlagStatus = __bind(this.setUserFlagStatus, this);
      this.render = __bind(this.render, this);
      return CurveSummaryController.__super__.constructor.apply(this, arguments);
    }

    CurveSummaryController.prototype.template = _.template($("#CurveSummaryView").html());

    CurveSummaryController.prototype.tagName = 'div';

    CurveSummaryController.prototype.className = 'bv_curveSummary';

    CurveSummaryController.prototype.events = {
      'click .bv_group_thumbnail': 'setSelected',
      'click .bv_userApprove': 'userApprove',
      'click .bv_userReject': 'userReject',
      'click .bv_userNA': 'userNA'
    };

    CurveSummaryController.prototype.initialize = function() {
      return this.model.on('change', this.render);
    };

    CurveSummaryController.prototype.render = function() {
      var curveUrl;
      this.$el.empty();
      this.model.url = '/api/curve/stub/' + this.model.get('curveid');
      if (window.AppLaunchParams.testMode) {
        curveUrl = "/src/modules/curveAnalysis/spec/testFixtures/testThumbs/";
        curveUrl += this.model.get('curveid') + ".png";
      } else {
        curveUrl = window.conf.service.rapache.fullpath + "curve/render/dr/?legend=false&showGrid=false&height=120&width=250&curveIds=";
        curveUrl += this.model.get('curveid') + "&showAxes=false&labelAxes=false";
      }
      this.$el.html(this.template({
        curveUrl: curveUrl
      }));
      if (this.model.get('algorithmFlagStatus') === 'no fit') {
        this.$('.bv_pass').hide();
        this.$('.bv_fail').show();
      } else {
        this.$('.bv_pass').show();
        this.$('.bv_fail').hide();
      }
      if (this.model.get('userFlagStatus') === '') {
        this.$('.bv_na').show();
        this.$('.bv_thumbsUp').hide();
        this.$('.bv_thumbsDown').hide();
        this.$('.bv_flagUser').removeClass('btn-success');
        this.$('.bv_flagUser').removeClass('btn-danger');
        this.$('.bv_flagUser').addClass('btn-grey');
      } else {
        if (this.model.get('userFlagStatus') === 'approved') {
          this.$('.bv_na').hide();
          this.$('.bv_thumbsUp').show();
          this.$('.bv_thumbsDown').hide();
          this.$('.bv_flagUser').addClass('btn-success');
          this.$('.bv_flagUser').removeClass('btn-danger');
          this.$('.bv_flagUser').removeClass('btn-grey');
        } else {
          this.$('.bv_na').hide();
          this.$('.bv_thumbsUp').hide();
          this.$('.bv_thumbsDown').show();
          this.$('.bv_flagUser').removeClass('btn-success');
          this.$('.bv_flagUser').addClass('btn-danger');
          this.$('.bv_flagUser').removeClass('btn-grey');
        }
      }
      if (this.model.get('dirty')) {
        this.$('.bv_dirty').show();
      } else {
        this.$('.bv_dirty').hide();
      }
      this.$('.bv_compoundCode').html(this.model.get('curveAttributes').compoundCode);
      return this;
    };

    CurveSummaryController.prototype.userApprove = function() {
      return this.approveReject("approved");
    };

    CurveSummaryController.prototype.userReject = function() {
      return this.approveReject("rejected");
    };

    CurveSummaryController.prototype.userNA = function() {
      return this.approveReject("");
    };

    CurveSummaryController.prototype.approveReject = function(decision) {
      if (!this.model.get('dirty')) {
        return this.setUserFlagStatus(decision);
      } else {
        return this.trigger('showCurveEditorDirtyPanel');
      }
    };

    CurveSummaryController.prototype.setUserFlagStatus = function(userFlagStatus) {
      this.disableSummary();
      return this.model.save({
        userFlagStatus: userFlagStatus,
        user: window.AppLaunchParams.loginUserName
      }, {
        wait: true,
        success: (function(_this) {
          return function() {
            _this.enableSummary();
            if (_this.$el.hasClass('selected')) {
              return _this.trigger('selected', _this);
            }
          };
        })(this),
        error: (function(_this) {
          return function() {
            $('.bv_badCurveUpdate').modal({
              backdrop: "static"
            });
            return $('.bv_badCurveUpdate').modal("show");
          };
        })(this)
      });
    };

    CurveSummaryController.prototype.disableSummary = function() {
      this.undelegateEvents();
      return this.$el.fadeTo(100, 0.2);
    };

    CurveSummaryController.prototype.enableSummary = function() {
      this.delegateEvents();
      return this.$el.fadeTo(100, 1);
    };

    CurveSummaryController.prototype.setSelected = function() {
      if (!this.$el.hasClass('selected')) {
        this.$el.addClass('selected');
        return this.trigger('selected', this);
      }
    };

    CurveSummaryController.prototype.styleSelected = function() {
      if (!this.$el.hasClass('selected')) {
        return this.$el.addClass('selected');
      }
    };

    CurveSummaryController.prototype.clearSelected = function(who) {
      if (who != null) {
        if (who.model.cid === this.model.cid) {
          return;
        }
      }
      return this.$el.removeClass('selected');
    };

    return CurveSummaryController;

  })(Backbone.View);

  window.CurveSummaryListController = (function(_super) {
    __extends(CurveSummaryListController, _super);

    function CurveSummaryListController() {
      this.showCurveEditorDirtyPanel = __bind(this.showCurveEditorDirtyPanel, this);
      this.selectionUpdated = __bind(this.selectionUpdated, this);
      this.anyDirty = __bind(this.anyDirty, this);
      this.render = __bind(this.render, this);
      return CurveSummaryListController.__super__.constructor.apply(this, arguments);
    }

    CurveSummaryListController.prototype.template = _.template($("#CurveSummaryListView").html());

    CurveSummaryListController.prototype.initialize = function() {
      this.filterKey = 'all';
      this.sortKey = 'none';
      this.sortAscending = true;
      this.firstRun = true;
      if (this.options.selectedCurve != null) {
        return this.initiallySelectedCurveID = this.options.selectedCurve;
      } else {
        return this.initiallySelectedCurveID = "NA";
      }
    };

    CurveSummaryListController.prototype.render = function() {
      var i;
      this.$el.empty();
      this.$el.html(this.template());
      this.curveEditorDirtyPanel = new CurveEditorDirtyPanelController({
        el: this.$('.bv_curveEditorDirtyPanel')
      });
      this.curveEditorDirtyPanel.render();
      if (this.filterKey !== 'all') {
        this.toRender = new Backbone.Collection(this.collection.filter((function(_this) {
          return function(cs) {
            return cs.get('category') === _this.filterKey;
          };
        })(this)));
      } else {
        this.toRender = this.collection;
      }
      if (this.sortKey !== 'none') {
        this.toRender = this.toRender.sortBy((function(_this) {
          return function(curve) {
            var attributes;
            attributes = curve.get('curveAttributes');
            return attributes[_this.sortKey];
          };
        })(this));
        if (!this.sortAscending) {
          this.toRender = this.toRender.reverse();
        }
        this.toRender = new Backbone.Collection(this.toRender);
      }
      i = 1;
      this.toRender.each((function(_this) {
        return function(cs) {
          var csController;
          csController = new CurveSummaryController({
            model: cs
          });
          _this.$('.bv_curveSummaries').append(csController.render().el);
          csController.on('selected', _this.selectionUpdated);
          csController.on('showCurveEditorDirtyPanel', _this.showCurveEditorDirtyPanel);
          _this.on('clearSelected', csController.clearSelected);
          if (_this.firstRun && (_this.initiallySelectedCurveID != null)) {
            if (_this.initiallySelectedCurveID === cs.get('curveid')) {
              _this.selectedcid = cs.cid;
            }
          }
          if (_this.selectedcid != null) {
            if (csController.model.cid === _this.selectedcid) {
              if (!_this.firstRun) {
                csController.styleSelected();
              } else {
                csController.setSelected();
              }
            }
          } else {
            if (_this.firstRun && i === 1) {
              _this.selectedcid = cs.id;
              csController.setSelected();
            }
          }
          return i = 2;
        };
      })(this));
      this.firstRun = false;
      return this;
    };

    CurveSummaryListController.prototype.anyDirty = function() {
      var collection, dirty;
      collection = this.toRender;
      dirty = collection.findWhere({
        dirty: true
      });
      return dirty != null;
    };

    CurveSummaryListController.prototype.selectionUpdated = function(who) {
      if (!this.anyDirty()) {
        this.selectedcid = who.model.cid;
        this.trigger('clearSelected', who);
        return this.trigger('selectionUpdated', who);
      } else {
        who.clearSelected();
        return this.showCurveEditorDirtyPanel();
      }
    };

    CurveSummaryListController.prototype.showCurveEditorDirtyPanel = function() {
      return this.curveEditorDirtyPanel.show();
    };

    CurveSummaryListController.prototype.filter = function(key) {
      this.filterKey = key;
      return this.render();
    };

    CurveSummaryListController.prototype.sort = function(key, ascending) {
      this.sortKey = key;
      this.sortAscending = ascending;
      return this.render();
    };

    return CurveSummaryListController;

  })(Backbone.View);

  window.CurveCuratorController = (function(_super) {
    __extends(CurveCuratorController, _super);

    function CurveCuratorController() {
      this.handleSortChanged = __bind(this.handleSortChanged, this);
      this.handleFilterChanged = __bind(this.handleFilterChanged, this);
      this.handleGetCurveDetailReturn = __bind(this.handleGetCurveDetailReturn, this);
      this.curveSelectionUpdated = __bind(this.curveSelectionUpdated, this);
      this.handleCurveUpdateError = __bind(this.handleCurveUpdateError, this);
      this.handleCurveDetailUpdated = __bind(this.handleCurveDetailUpdated, this);
      this.handleCurveDetailSaved = __bind(this.handleCurveDetailSaved, this);
      this.render = __bind(this.render, this);
      return CurveCuratorController.__super__.constructor.apply(this, arguments);
    }

    CurveCuratorController.prototype.template = _.template($("#CurveCuratorView").html());

    CurveCuratorController.prototype.events = {
      'change .bv_filterBy': 'handleFilterChanged',
      'change .bv_sortBy': 'handleSortChanged',
      'click .bv_sortDirection_ascending': 'handleSortChanged',
      'click .bv_sortDirection_descending': 'handleSortChanged'
    };

    CurveCuratorController.prototype.render = function() {
      this.$el.empty();
      this.$el.html(this.template());
      if (this.model != null) {
        this.curveListController = new CurveSummaryListController({
          el: this.$('.bv_curveList'),
          collection: this.model.get('curves'),
          selectedCurve: this.initiallySelectedCurveID
        });
        this.curveListController.on('selectionUpdated', this.curveSelectionUpdated);
        this.curveEditorController = new CurveEditorController({
          el: this.$('.bv_curveEditor')
        });
        this.curveEditorController.on('curveDetailSaved', this.handleCurveDetailSaved);
        this.curveEditorController.on('curveDetailUpdated', this.handleCurveDetailUpdated);
        this.curveEditorController.on('curveUpdateError', this.handleCurveUpdateError);
        if (this.model.get('sortOptions').length > 0) {
          this.sortBySelect = new PickListSelectController({
            collection: this.model.get('sortOptions'),
            el: this.$('.bv_sortBy'),
            selectedCode: (this.model.get('sortOptions'))[0],
            autoFetch: false
          });
        } else {
          this.sortBySelect = new PickListSelectController({
            collection: this.model.get('sortOptions'),
            el: this.$('.bv_sortBy'),
            insertFirstOption: new PickList({
              code: "none",
              name: "No Sort"
            }),
            selectedCode: "none",
            autoFetch: false
          });
        }
        this.sortBySelect.render();
        this.filterBySelect = new PickListSelectController({
          collection: this.model.get('curves').getCategories(),
          el: this.$('.bv_filterBy'),
          insertFirstOption: new PickList({
            code: "all",
            name: "Show All"
          }),
          selectedCode: "all",
          autoFetch: false
        });
        this.filterBySelect.render();
        if (this.curveListController.sortAscending) {
          this.$('.bv_sortDirection_ascending').attr("checked", true);
        } else {
          this.$('.bv_sortDirection_descending').attr("checked", true);
        }
        this.handleSortChanged();
      }
      return this;
    };

    CurveCuratorController.prototype.handleCurveDetailSaved = function(oldID, newID, dirty, category, userFlagStatus, algorithmFlagStatus) {
      return this.curveListController.collection.updateCurveSummary(oldID, newID, dirty, category, userFlagStatus, algorithmFlagStatus);
    };

    CurveCuratorController.prototype.handleCurveDetailUpdated = function(curveid, dirty) {
      return this.curveListController.collection.updateDirtyFlag(curveid, dirty);
    };

    CurveCuratorController.prototype.handleCurveUpdateError = function() {
      this.$('.bv_badCurveUpdate').modal({
        backdrop: "static"
      });
      return this.$('.bv_badCurveUpdate').modal("show");
    };

    CurveCuratorController.prototype.getCurvesFromExperimentCode = function(exptCode, curveID) {
      this.initiallySelectedCurveID = curveID;
      this.model = new CurveCurationSet;
      this.model.setExperimentCode(exptCode);
      return this.model.fetch({
        success: (function(_this) {
          return function() {
            return _this.render();
          };
        })(this),
        error: (function(_this) {
          return function() {
            _this.$('.bv_badExperimentCode').modal({
              backdrop: "static"
            });
            return _this.$('.bv_badExperimentCode').modal("show");
          };
        })(this)
      });
    };

    CurveCuratorController.prototype.curveSelectionUpdated = function(who) {
      var curveDetail;
      UtilityFunctions.prototype.showProgressModal(this.$('.bv_curveCuratorDropDown'));
      curveDetail = new CurveDetail({
        id: who.model.get('curveid')
      });
      return curveDetail.fetch({
        success: (function(_this) {
          return function() {
            UtilityFunctions.prototype.hideProgressModal(_this.$('.bv_curveCuratorDropDown'));
            return _this.curveEditorController.setModel(curveDetail);
          };
        })(this),
        error: (function(_this) {
          return function() {
            UtilityFunctions.prototype.hideProgressModal(_this.$('.bv_curveCuratorDropDown'));
            _this.$('.bv_badCurveID').modal({
              backdrop: "static"
            });
            return _this.$('.bv_badCurveID').modal("show");
          };
        })(this)
      });
    };

    CurveCuratorController.prototype.handleGetCurveDetailReturn = function(json) {
      return this.curveEditorController.setModel(new CurveDetail(json));
    };

    CurveCuratorController.prototype.handleFilterChanged = function() {
      return this.curveListController.filter(this.$('.bv_filterBy').val());
    };

    CurveCuratorController.prototype.handleSortChanged = function() {
      var sortBy, sortDirection;
      sortBy = this.$('.bv_sortBy').val();
      if (sortBy === "none") {
        this.$("input[name='bv_sortDirection']").prop('disabled', true);
      } else {
        this.$("input[name='bv_sortDirection']").prop('disabled', false);
      }
      sortDirection = this.$("input[name='bv_sortDirection']:checked").val() === "descending" ? false : true;
      return this.curveListController.sort(sortBy, sortDirection);
    };

    return CurveCuratorController;

  })(Backbone.View);

}).call(this);
