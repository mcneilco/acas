(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe("Custom Experiment Metadata testing", function() {
    describe("Custom Experiment Metadata List Controller testing", function() {
      return describe("When created from a saved experiment", function() {
        beforeEach(function() {
          this.exp = new Experiment(window.experimentServiceTestJSON.fullExperimentFromServer);
          this.cemlc = new CustomExperimentMetadataListController({
            el: $('#fixture'),
            model: this.exp
          });
          return this.cemlc.render();
        });
        describe("property display", function() {
          it("should show clob values", function() {
            waitsFor(function() {
              return this.cemlc.$('.bv_clob_value').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.cemlc.$('.bv_clob_value').val()).toEqual("background text");
            });
          });
          it("should show code values", function() {
            waitsFor(function() {
              return this.cemlc.$('.bv_code_value').val() !== null;
            }, 1000);
            return runs(function() {
              expect(this.cemlc.$('.bv_code_value option').length).toBeGreaterThan(0);
              return expect(this.cemlc.$('.bv_code_value').val()).toEqual("mrna");
            });
          });
          it("should show numeric values", function() {
            waitsFor(function() {
              return this.cemlc.$('.bv_numeric_value').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.cemlc.$('.bv_numeric_value').val()).toEqual("5");
            });
          });
          it("should show string values", function() {
            waitsFor(function() {
              return this.cemlc.$('.bv_string_value').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.cemlc.$('.bv_string_value').val()).toEqual("rationale text");
            });
          });
          return it("should show url values", function() {
            waitsFor(function() {
              return this.cemlc.$('.bv_url_value').length > 0;
            }, 1000);
            return runs(function() {
              return expect(this.cemlc.$('.bv_url_value').val()).toEqual("http://www.rcsb.org");
            });
          });
        });
        return describe("gui descriptor", function() {
          return it("should sort values by gui descriptor", function() {
            var guiDescriptorOrder, guiDescriptorValue, toRenderOrder;
            guiDescriptorValue = this.cemlc.getGuiDescriptor();
            guiDescriptorOrder = guiDescriptorValue.pluck("lsKind");
            toRenderOrder = this.cemlc.toRender.pluck("lsKind");
            return expect(guiDescriptorOrder).toEqual(toRenderOrder);
          });
        });
      });
    });
    return describe("Custom Experiment Metadata Value Controller testing", function() {
      return describe("When created from a saved experiment", function() {
        describe("Clob Value testing (serves as non-subclass testing)", function() {
          beforeEach(function() {
            this.exp = new Experiment(window.experimentServiceTestJSON.fullExperimentFromServer);
            this.model = this.exp.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "custom experiment metadata", "clobValue", "Background");
            this.cmvc = new CustomMetadataClobValueController({
              el: $('#fixture'),
              model: this.model,
              experiment: this.exp
            });
            return this.cmvc.render();
          });
          describe("property display", function() {
            it("should have a label", function() {
              waitsFor(function() {
                return this.cmvc.$('.bv_label').length > 0;
              }, 1000);
              return runs(function() {
                return expect(this.cmvc.$('.bv_label').text()).toEqual("Background");
              });
            });
            return it("should show clob values", function() {
              waitsFor(function() {
                return this.cmvc.$('.bv_value').length > 0;
              }, 1000);
              return runs(function() {
                return expect(this.cmvc.$('.bv_value').val()).toEqual("background text");
              });
            });
          });
          return describe("model updates", function() {
            return it("should ignore old value when first changed and add a new value", function() {
              waitsFor(function() {
                return this.cmvc.$('.bv_value').length > 0;
              }, 1000);
              return runs(function() {
                var newLength, newValue, oldValue, originalLength, state, values;
                state = this.cmvc.experiment.get('lsStates').getOrCreateStateByTypeAndKind("metadata", "custom experiment metadata");
                values = state.get('lsValues');
                originalLength = values.length;
                this.cmvc.$('.bv_value').val("testing this out");
                this.cmvc.$('.bv_value').change();
                newValue = state.getValuesByTypeAndKind(this.model.get('lsType'), this.model.get('lsKind'));
                oldValue = values.filter((function(_this) {
                  return function(value) {
                    return (value.get('ignored')) && (value.get('lsType') === _this.model.get('lsType')) && (value.get('lsKind') === _this.model.get('lsKind'));
                  };
                })(this));
                newLength = values.length;
                expect(newLength).toEqual(originalLength + 1);
                expect(oldValue[0].get('lsKind')).toEqual(this.model.get('lsKind'));
                return expect(newValue[0].get('lsKind')).toEqual(this.model.get('lsKind'));
              });
            });
          });
        });
        describe("Code Value testing", function() {
          beforeEach(function() {
            this.exp = new Experiment(window.experimentServiceTestJSON.fullExperimentFromServer);
            this.model = this.exp.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "custom experiment metadata", "codeValue", "Original Data Level");
            this.cmvc = new CustomMetadataCodeValueController({
              el: $('#fixture'),
              model: this.model,
              experiment: this.exp
            });
            return this.cmvc.render();
          });
          return describe("property display", function() {
            it("should have a label", function() {
              waitsFor(function() {
                return this.cmvc.$('.bv_label').length > 0;
              }, 1000);
              return runs(function() {
                return expect(this.cmvc.$('.bv_label').text()).toEqual("Original Data Level");
              });
            });
            return it("should show code option picklist", function() {
              waitsFor(function() {
                return this.cmvc.$('.bv_value option').length > 0;
              }, 1000);
              return runs(function() {
                return expect(this.cmvc.$('.bv_value option').val()).toEqual('mrna');
              });
            });
          });
        });
        describe("Numeric Value testing", function() {
          beforeEach(function() {
            this.exp = new Experiment(window.experimentServiceTestJSON.fullExperimentFromServer);
            this.model = this.exp.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "custom experiment metadata", "numericValue", "Weight");
            this.cmvc = new CustomMetadataNumericValueController({
              el: $('#fixture'),
              model: this.model,
              experiment: this.exp
            });
            return this.cmvc.render();
          });
          return describe("property display", function() {
            it("should have a label", function() {
              waitsFor(function() {
                return this.cmvc.$('.bv_label').length > 0;
              }, 1000);
              return runs(function() {
                return expect(this.cmvc.$('.bv_label').text()).toEqual("Weight");
              });
            });
            return it("should show numeric value", function() {
              waitsFor(function() {
                return this.cmvc.$('.bv_value').length > 0;
              }, 1000);
              return runs(function() {
                return expect(this.cmvc.$('.bv_value').val()).toEqual('5');
              });
            });
          });
        });
        describe("String Value testing", function() {
          beforeEach(function() {
            this.exp = new Experiment(window.experimentServiceTestJSON.fullExperimentFromServer);
            this.model = this.exp.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "custom experiment metadata", "stringValue", "Scoring Category Rationale");
            this.cmvc = new CustomMetadataStringValueController({
              el: $('#fixture'),
              model: this.model,
              experiment: this.exp
            });
            return this.cmvc.render();
          });
          return describe("property display", function() {
            it("should have a label", function() {
              waitsFor(function() {
                return this.cmvc.$('.bv_label').length > 0;
              }, 1000);
              return runs(function() {
                return expect(this.cmvc.$('.bv_label').text()).toEqual("Scoring Category Rationale");
              });
            });
            return it("should show string value", function() {
              waitsFor(function() {
                return this.cmvc.$('.bv_value').length > 0;
              }, 1000);
              return runs(function() {
                return expect(this.cmvc.$('.bv_value').val()).toEqual('rationale text');
              });
            });
          });
        });
        return describe("URL Value testing", function() {
          beforeEach(function() {
            this.exp = new Experiment(window.experimentServiceTestJSON.fullExperimentFromServer);
            this.model = this.exp.get('lsStates').getOrCreateValueByTypeAndKind("metadata", "custom experiment metadata", "urlValue", "Experiment URL");
            this.cmvc = new CustomMetadataURLValueController({
              el: $('#fixture'),
              model: this.model,
              experiment: this.exp
            });
            return this.cmvc.render();
          });
          return describe("property display", function() {
            it("should have a label", function() {
              waitsFor(function() {
                return this.cmvc.$('.bv_label').length > 0;
              }, 1000);
              return runs(function() {
                return expect(this.cmvc.$('.bv_label').text()).toEqual("Experiment URL");
              });
            });
            it("should show string value", function() {
              waitsFor(function() {
                return this.cmvc.$('.bv_value').length > 0;
              }, 1000);
              return runs(function() {
                return expect(this.cmvc.$('.bv_value').val()).toEqual('http://www.rcsb.org');
              });
            });
            it("should call handle button clicked when clicked", function() {
              spyOn(this.cmvc, 'handleLinkButtonClicked');
              this.cmvc.delegateEvents();
              waitsFor(function() {
                return this.cmvc.$('.bv_value').length > 0;
              }, 1000);
              return runs(function() {
                this.cmvc.$('.bv_link_btn').click();
                return expect(this.cmvc.handleLinkButtonClicked).toHaveBeenCalled();
              });
            });
            return it("open the url when clicked", function() {
              spyOn(window, 'open');
              waitsFor(function() {
                return this.cmvc.$('.bv_value').length > 0;
              }, 1000);
              return runs(function() {
                this.cmvc.$('.bv_link_btn').click();
                return expect(window.open).toHaveBeenCalledWith('http://www.rcsb.org');
              });
            });
          });
        });
      });
    });
  });

}).call(this);
