(function() {
  beforeEach(function() {
    return this.fixture = $("#fixture");
  });

  afterEach(function() {
    $(".modal-backdrop").remove();
    $("#fixture").remove();
    return $("body").append('<div id="fixture"></div>');
  });

  describe("Gene Data Queries Module Testing", function() {
    describe("Gene ID Query Input Controller", function() {
      return describe('when instantiated', function() {
        beforeEach(function() {
          this.gidqic = new GeneIDQueryInputController({
            el: $('#fixture')
          });
          return this.gidqic.render();
        });
        describe("basic existance tests", function() {
          it('should exist', function() {
            return expect(this.gidqic).toBeDefined();
          });
          return it('should load a template', function() {
            return expect(this.gidqic.$('.bv_gidListString').length).toEqual(1);
          });
        });
        describe("search button enabling behavior", function() {
          it("should have search button disabled when nothing in field", function() {
            return expect(this.gidqic.$('.bv_search').attr('disabled')).toEqual('disabled');
          });
          it("should have search button enabled when someting added to field", function() {
            this.gidqic.$('.bv_gidListString').val("555, 3466621,777, 888 , 999");
            this.gidqic.$('.bv_gidListString').keyup();
            return expect(this.gidqic.$('.bv_search').attr('disabled')).toBeUndefined();
          });
          return it("should have search button disabled when field is emptied", function() {
            this.gidqic.$('.bv_gidListString').val("");
            this.gidqic.$('.bv_gidListString').keyup();
            return expect(this.gidqic.$('.bv_search').attr('disabled')).toEqual('disabled');
          });
        });
        describe("search button behavior", function() {
          return it("should trigger a search request when search button pressed", function() {
            runs(function() {
              this.gidqic.$('.bv_gidListString').val("555, 3466621,777, 888 , 999");
              this.gidqic.$('.bv_gidListString').keyup();
              this.gotTrigger = false;
              this.gidqic.on('search-requested', (function(_this) {
                return function() {
                  return _this.gotTrigger = true;
                };
              })(this));
              return this.gidqic.$('.bv_search').click();
            });
            waitsFor((function(_this) {
              return function() {
                return _this.gotTrigger;
              };
            })(this), 1000);
            return runs((function(_this) {
              return function() {
                return expect(_this.gotTrigger).toBeTruthy();
              };
            })(this));
          });
        });
        return describe("when advanced mode pressed", function() {
          beforeEach(function() {
            return runs(function() {
              this.advanceTriggered = false;
              this.gidqic.on('requestAdvancedMode', (function(_this) {
                return function() {
                  return _this.advanceTriggered = true;
                };
              })(this));
              return this.gidqic.$('.bv_gidNavAdvancedSearchButton').click();
            });
          });
          return it("should request enable button disabled when an experiment selected", function() {
            waitsFor((function(_this) {
              return function() {
                return _this.advanceTriggered;
              };
            })(this), 100);
            return runs(function() {
              return expect(this.advanceTriggered).toBeTruthy();
            });
          });
        });
      });
    });
    describe("Gene ID Query Result Controller", function() {
      describe('when instantiated', function() {
        beforeEach(function() {
          this.gidqrc = new GeneIDQueryResultController({
            model: new Backbone.Model(window.geneDataQueriesTestJSON.geneIDQueryResults),
            el: $('#fixture')
          });
          return this.gidqrc.render();
        });
        describe("basic existance tests", function() {
          it('should exist', function() {
            return expect(this.gidqrc).toBeDefined();
          });
          return it('should load a template', function() {
            return expect(this.gidqrc.$('.bv_resultTable').length).toEqual(1);
          });
        });
        describe("data display", function() {
          it("should setup DOM in prep to load datatable module", function() {
            return expect(this.gidqrc.$('thead tr').length).toEqual(2);
          });
          it("should render the rest of the table", function() {
            return expect(this.gidqrc.$('tbody tr').length).toEqual(4);
          });
          return it("should not show the no results message", function() {
            return expect(this.gidqrc.$('.bv_noResultsFound')).toBeHidden();
          });
        });
        return describe("request results as CSV", function() {
          return it("should trigger search format csv request", function() {
            runs((function(_this) {
              return function() {
                _this.downLoadCSVRequested = false;
                _this.gidqrc.on('downLoadCSVRequested', function() {
                  return _this.downLoadCSVRequested = true;
                });
                return _this.gidqrc.$('.bv_downloadCSV').click();
              };
            })(this));
            waitsFor((function(_this) {
              return function() {
                return _this.downLoadCSVRequested;
              };
            })(this), 200);
            return runs((function(_this) {
              return function() {
                return expect(_this.downLoadCSVRequested).toBeTruthy();
              };
            })(this));
          });
        });
      });
      return describe('when instantiated with empty result set', function() {
        beforeEach(function() {
          this.gidqrc = new GeneIDQueryResultController({
            model: new Backbone.Model(window.geneDataQueriesTestJSON.geneIDQueryResultsNoneFound),
            el: $('#fixture')
          });
          return this.gidqrc.render();
        });
        return describe("data display", function() {
          it("should hide the data table", function() {
            return expect(this.gidqrc.$('.bv_resultTable')).toBeHidden();
          });
          it("should show no results message", function() {
            return expect(this.gidqrc.$('.bv_noResultsFound')).toBeVisible();
          });
          return it("should hide the download CSV option", function() {
            return expect(this.gidqrc.$('.bv_gidDownloadCSV')).toBeHidden();
          });
        });
      });
    });
    describe("Gene ID Query Search Controller", function() {
      return describe('when instantiated', function() {
        beforeEach(function() {
          this.gidqsc = new GeneIDQuerySearchController({
            el: $('#fixture')
          });
          return this.gidqsc.render();
        });
        describe("basic existance tests", function() {
          it('should exist', function() {
            return expect(this.gidqsc).toBeDefined();
          });
          return it('should load a template', function() {
            return expect(this.gidqsc.$('.bv_inputView').length).toEqual(1);
          });
        });
        describe("on startup", function() {
          it('should load and show the input controller', function() {
            return expect(this.gidqsc.$('.bv_gidListString').length).toEqual(1);
          });
          it("should hide result table", function() {
            return expect(this.gidqsc.$('.bv_resultsView')).toBeHidden();
          });
          it("should show search in center at start", function() {
            return expect(this.gidqsc.$('.bv_gidSearchStart .bv_searchForm').length).toEqual(1);
          });
          it("should show gidSearchStart", function() {
            return expect(this.gidqsc.$('.bv_gidSearchStart')).toBeVisible();
          });
          it("should show ACAS badge at start", function() {
            return expect(this.gidqsc.$('.bv_gidACASBadge')).toBeVisible();
          });
          it("should hide ACAS inline badge at start", function() {
            return expect(this.gidqsc.$('.bv_gidACASBadgeTop')).toBeHidden();
          });
          it("should have the gidNavAdvancedSearchButton start class", function() {
            return expect(this.gidqsc.$('.bv_gidNavAdvancedSearchButton').hasClass('gidAdvancedNavSearchButtonStart')).toBeTruthy();
          });
          it("should not have the gidNavAdvancedSearchButton end class", function() {
            return expect(this.gidqsc.$('.bv_gidNavAdvancedSearchButton').hasClass('gidAdvancedNavSearchButtonTop')).toBeFalsy();
          });
          return it("should hide the bv_searchNavbar at start", function() {
            return expect(this.gidqsc.$('.bv_searchNavbar')).toBeHidden();
          });
        });
        return describe("search return handling", function() {
          beforeEach(function() {
            return this.gidqsc.handleSearchReturn({
              results: window.geneDataQueriesTestJSON.geneIDQueryResults
            });
          });
          it("should have a function to call when search returns", function() {
            return expect(this.gidqsc.handleSearchReturn).toBeDefined();
          });
          it("should show result view", function() {
            return expect(this.gidqsc.$('.bv_resultsView')).toBeVisible();
          });
          it("should move search to top navbar", function() {
            return expect(this.gidqsc.$('.bv_searchNavbar .bv_searchForm').length).toEqual(1);
          });
          it("should hide gidSearchStart", function() {
            return expect(this.gidqsc.$('.bv_gidSearchStart')).toBeHidden();
          });
          it("should hide ACAS badge", function() {
            return expect(this.gidqsc.$('.bv_gidACASBadge')).toBeHidden();
          });
          it("should show ACAS inline badge", function() {
            return expect(this.gidqsc.$('.bv_gidACASBadgeTop')).toBeVisible();
          });
          it("should not have the gidNavAdvancedSearchButton start class", function() {
            return expect(this.gidqsc.$('.bv_gidNavAdvancedSearchButton').hasClass('gidAdvancedNavSearchButtonStart')).toBeFalsy();
          });
          it("should have the gidNavAdvancedSearchButton end class", function() {
            return expect(this.gidqsc.$('.bv_gidNavAdvancedSearchButton').hasClass('gidAdvancedNavSearchButtonTop')).toBeTruthy();
          });
          return it("should show the bv_searchNavbar", function() {
            return expect(this.gidqsc.$('.bv_searchNavbar')).toBeVisible();
          });
        });
      });
    });
    describe("Advanced search modules", function() {
      describe("Protocol and experiment display", function() {
        return describe('when instantiated', function() {
          beforeEach(function() {
            this.etc = new ExperimentTreeController({
              el: $('#fixture'),
              model: new Backbone.Model(window.geneDataQueriesTestJSON.getGeneExperimentsReturn)
            });
            return this.etc.render();
          });
          describe("basic existance tests", function() {
            it('should exist', function() {
              return expect(this.etc).toBeDefined();
            });
            return it('should load a template', function() {
              return expect(this.etc.$('.bv_tree').length).toEqual(1);
            });
          });
          describe("rendering", function() {
            return it("should load tree and display root node", function() {
              return expect(this.etc.$('.bv_tree').html()).toContain("Protocols");
            });
          });
          describe("search field management", function() {
            it("should clear search field on request", function() {
              this.etc.$('.bv_searchVal').val("search text");
              expect(this.etc.$('.bv_searchVal').val()).toEqual("search text");
              this.etc.$('.bv_searchClear').click();
              return expect(this.etc.$('.bv_searchVal').val()).toEqual("");
            });
            return it("should show an experiment on search", function() {
              expect(this.etc.$('.bv_tree').html()).toNotContain("EXPT-00000397");
              this.etc.$('.bv_searchVal').val("397");
              this.etc.$(".bv_tree").jstree(true).search(this.etc.$('.bv_searchVal').val());
              return expect(this.etc.$('.bv_tree').html()).toContain("EXPT-00000397");
            });
          });
          describe("getting selected", function() {
            return it("should get selected experiments", function() {
              this.etc.$(".bv_tree").jstree(true).search("EXPT-00000398");
              expect(this.etc.$('.bv_tree').html()).toContain("EXPT-00000398");
              this.etc.$('.jstree-checkbox:eq(4)').click();
              this.etc.$('.jstree-checkbox:eq(5)').click();
              return expect(this.etc.getSelectedExperiments()).toEqual(["EXPT-00000398", "EXPT-00000396"]);
            });
          });
          return describe("when none selected", function() {
            beforeEach(function() {
              return runs(function() {
                this.nextEnableRequested = false;
                this.etc.on('enableNext', (function(_this) {
                  return function() {
                    return _this.nextEnableRequested = true;
                  };
                })(this));
                this.nextDisableRequested = false;
                this.etc.on('disableNext', (function(_this) {
                  return function() {
                    return _this.nextDisableRequested = true;
                  };
                })(this));
                this.etc.$(".bv_tree").jstree(true).search("EXPT-00000398");
                expect(this.etc.$('.bv_tree').html()).toContain("EXPT-00000398");
                return this.etc.$('.jstree-checkbox:eq(4)').click();
              });
            });
            it("should request enable button disabled when an experiment selected", function() {
              waitsFor((function(_this) {
                return function() {
                  return _this.nextEnableRequested;
                };
              })(this), 100);
              return runs(function() {
                return expect(this.nextEnableRequested).toBeTruthy();
              });
            });
            return it("should request next button disabled when all experiments de-selected", function() {
              runs(function() {
                return this.etc.$('.jstree-checkbox:eq(4)').click();
              });
              waitsFor((function(_this) {
                return function() {
                  return _this.nextDisableRequested;
                };
              })(this), 100);
              return runs(function() {
                return expect(this.nextDisableRequested).toBeTruthy();
              });
            });
          });
        });
      });
      describe("Experiment attribute filtering panel", function() {
        describe("filter term controller", function() {
          return describe('when instantiated', function() {
            beforeEach(function() {
              this.erftc = new ExperimentResultFilterTermController({
                el: $('#fixture'),
                model: new Backbone.Model(),
                filterOptions: new Backbone.Collection(window.geneDataQueriesTestJSON.experimentSearchOptions.experiments),
                termName: "Q1"
              });
              return this.erftc.render();
            });
            describe("basic existance tests", function() {
              it('should exist', function() {
                return expect(this.erftc).toBeDefined();
              });
              return it('should load a template', function() {
                return expect(this.erftc.$('.bv_experiment').length).toEqual(1);
              });
            });
            describe("rendering", function() {
              it("should show termName", function() {
                return expect(this.erftc.$('.bv_termName').html()).toEqual("Q1");
              });
              return it("should show experiment options", function() {
                expect(this.erftc.$('.bv_experiment option').length).toEqual(3);
                expect(this.erftc.$('.bv_experiment option:eq(0)').val()).toEqual("EXPT-00000396");
                return expect(this.erftc.$('.bv_experiment option:eq(0)').html()).toEqual("Experiment Name 1");
              });
            });
            describe("show attribute list based on experiment picked", function() {
              it("should show correct attributes for first experiment", function() {
                this.erftc.$('.bv_experiment').val("EXPT-00000396");
                this.erftc.$('.bv_experiment').change();
                expect(this.erftc.$('.bv_kind option').length).toEqual(3);
                return expect(this.erftc.$('.bv_kind option:eq(0)').val()).toEqual("EC50");
              });
              return it("should show correct attributes for second experiment", function() {
                this.erftc.$('.bv_experiment').val("EXPT-00000398");
                this.erftc.$('.bv_experiment').change();
                expect(this.erftc.$('.bv_kind option').length).toEqual(3);
                return expect(this.erftc.$('.bv_kind option:eq(0)').val()).toEqual("KD");
              });
            });
            describe("show operator choices based on attribute type picked", function() {
              it("should show correct choice for first experiment and number type", function() {
                this.erftc.$('.bv_experiment').val("EXPT-00000396");
                this.erftc.$('.bv_experiment').change();
                this.erftc.$('.bv_kind').val("EC50");
                this.erftc.$('.bv_kind').change();
                expect(this.erftc.$('.bv_operator option').length).toEqual(3);
                return expect(this.erftc.$('.bv_operator option:eq(0)').val()).toEqual("=");
              });
              it("should show correct choice for first experiment and string type", function() {
                this.erftc.$('.bv_experiment').val("EXPT-00000396");
                this.erftc.$('.bv_experiment').change();
                this.erftc.$('.bv_kind').val("category");
                this.erftc.$('.bv_kind').change();
                expect(this.erftc.$('.bv_operator option').length).toEqual(2);
                return expect(this.erftc.$('.bv_operator option:eq(0)').val()).toEqual("equals");
              });
              it("should show correct choice for first experiment and bool type", function() {
                this.erftc.$('.bv_experiment').val("EXPT-00000396");
                this.erftc.$('.bv_experiment').change();
                this.erftc.$('.bv_kind').val("hit");
                this.erftc.$('.bv_kind').change();
                expect(this.erftc.$('.bv_operator option').length).toEqual(2);
                return expect(this.erftc.$('.bv_operator option:eq(0)').val()).toEqual("true");
              });
              return it("should show correct operator options on first load", function() {
                this.erftc.$('.bv_experiment').val("EXPT-00000397");
                this.erftc.$('.bv_experiment').change();
                expect(this.erftc.$('.bv_operator option').length).toEqual(2);
                return expect(this.erftc.$('.bv_operator option:eq(0)').val()).toEqual("equals");
              });
            });
            describe("show or hide filterValue based on attribute type picked", function() {
              it("should hide value field for first experiment and bool type", function() {
                this.erftc.$('.bv_experiment').val("EXPT-00000396");
                this.erftc.$('.bv_experiment').change();
                this.erftc.$('.bv_kind').val("hit");
                this.erftc.$('.bv_kind').change();
                expect(this.erftc.$('.bv_operator option').length).toEqual(2);
                return expect(this.erftc.$('.bv_filterValue')).toBeHidden();
              });
              return it("should show value field for first experiment and number type", function() {
                this.erftc.$('.bv_experiment').val("EXPT-00000396");
                this.erftc.$('.bv_experiment').change();
                this.erftc.$('.bv_kind').val("EC50");
                this.erftc.$('.bv_kind').change();
                expect(this.erftc.$('.bv_operator option').length).toEqual(3);
                return expect(this.erftc.$('.bv_filterValue')).toBeVisible();
              });
            });
            return describe("get filter term", function() {
              return it("should return hash of user selections", function() {
                this.erftc.$('.bv_experiment').val("EXPT-00000396");
                this.erftc.$('.bv_experiment').change();
                this.erftc.$('.bv_kind').val("category");
                this.erftc.$('.bv_kind').change();
                this.erftc.$('.bv_operator').val("contains");
                this.erftc.$('.bv_filterValue').val(" search string ");
                this.erftc.updateModel();
                expect(this.erftc.model.get('experimentCode')).toEqual("EXPT-00000396");
                expect(this.erftc.model.get('lsKind')).toEqual("category");
                expect(this.erftc.model.get('lsType')).toEqual("stringValue");
                expect(this.erftc.model.get('operator')).toEqual("contains");
                return expect(this.erftc.model.get('filterValue')).toEqual("search string");
              });
            });
          });
        });
        describe("filter term list controller", function() {
          return describe('when instantiated', function() {
            beforeEach(function() {
              this.erftlc = new ExperimentResultFilterTermListController({
                el: $('#fixture'),
                collection: new Backbone.Collection(),
                filterOptions: new Backbone.Collection(window.geneDataQueriesTestJSON.experimentSearchOptions.experiments)
              });
              return this.erftlc.render();
            });
            describe("basic existance tests", function() {
              it('should exist', function() {
                return expect(this.erftlc).toBeDefined();
              });
              return it('should load a template', function() {
                return expect(this.erftlc.$('.bv_addTerm').length).toEqual(1);
              });
            });
            describe("rendering", function() {
              it("should show no terms", function() {
                return expect(this.erftlc.$('.bv_termName').length).toEqual(0);
              });
              it("should show one experiment term with term name", function() {
                this.erftlc.$('.bv_addTerm').click();
                return expect(this.erftlc.$('.bv_termName').html()).toEqual("Q1");
              });
              return it("should show one experiment term with experiment options", function() {
                this.erftlc.$('.bv_addTerm').click();
                expect(this.erftlc.$('.bv_filterTerms .bv_experiment').length).toEqual(1);
                expect(this.erftlc.$('.bv_filterTerms .bv_experiment option').length).toEqual(3);
                return expect(this.erftlc.$('.bv_filterTerms .bv_experiment option:eq(0)').val()).toEqual("EXPT-00000396");
              });
            });
            describe("adding and removing", function() {
              it("should have two experiment terms when add is clicked", function() {
                this.erftlc.$('.bv_addTerm').click();
                this.erftlc.$('.bv_addTerm').click();
                expect(this.erftlc.$('.bv_filterTerms .bv_experiment').length).toEqual(2);
                return expect(this.erftlc.collection.length).toEqual(2);
              });
              it("should show 2nd term with incremented termName", function() {
                this.erftlc.$('.bv_addTerm').click();
                this.erftlc.$('.bv_addTerm').click();
                return expect(this.erftlc.$('.bv_termName:eq(1)').html()).toEqual("Q2");
              });
              return it("should one experiment terms when remove is clicked", function() {
                this.erftlc.$('.bv_addTerm').click();
                this.erftlc.$('.bv_addTerm').click();
                expect(this.erftlc.$('.bv_filterTerms .bv_experiment').length).toEqual(2);
                this.erftlc.$('.bv_delete:eq(0)').click();
                expect(this.erftlc.collection.length).toEqual(1);
                return expect(this.erftlc.$('.bv_filterTerms .bv_experiment').length).toEqual(1);
              });
            });
            return describe("update collection", function() {
              return it("should update the collection wehn requested", function() {
                var tmodel;
                this.erftlc.$('.bv_addTerm').click();
                this.erftlc.$('.bv_addTerm').click();
                this.erftlc.$('.bv_experiment:eq(1)').val("EXPT-00000396");
                this.erftlc.$('.bv_experiment:eq(1)').change();
                this.erftlc.$('.bv_kind:eq(1)').val("category");
                this.erftlc.$('.bv_kind:eq(1)').change();
                this.erftlc.$('.bv_operator:eq(1)').val("contains");
                this.erftlc.$('.bv_filterValue:eq(1)').val(" search string ");
                this.erftlc.updateCollection();
                expect(this.erftlc.collection.length).toEqual(2);
                tmodel = this.erftlc.collection.at(1);
                expect(tmodel.get('termName')).toEqual("Q2");
                expect(tmodel.get('experimentCode')).toEqual("EXPT-00000396");
                expect(tmodel.get('lsKind')).toEqual("category");
                expect(tmodel.get('lsType')).toEqual("stringValue");
                expect(tmodel.get('operator')).toEqual("contains");
                return expect(tmodel.get('filterValue')).toEqual("search string");
              });
            });
          });
        });
        return describe("ExperimentResultFilter Controller", function() {
          return describe('when instantiated', function() {
            beforeEach(function() {
              this.erfc = new ExperimentResultFilterController({
                el: $('#fixture'),
                filterOptions: new Backbone.Collection(window.geneDataQueriesTestJSON.experimentSearchOptions.experiments)
              });
              return this.erfc.render();
            });
            describe("basic existance tests", function() {
              it('should exist', function() {
                return expect(this.erfc).toBeDefined();
              });
              return it('should load a template', function() {
                return expect(this.erfc.$('.bv_advancedBooleanFilter').length).toEqual(1);
              });
            });
            describe("rendering", function() {
              return it("should show an experiment term list with experiment options", function() {
                this.erfc.$('.bv_addTerm').click();
                return expect(this.erfc.$('.bv_filterTerms .bv_experiment').length).toEqual(1);
              });
            });
            describe("boolean filter radio behavior", function() {
              it("should hide advanced filter input when radio set to and", function() {
                this.erfc.$('.bv_booleanFilter_and').attr('checked', 'checked');
                this.erfc.$('.bv_booleanFilter_and').click();
                return expect(this.erfc.$('.bv_advancedBoolContainer')).toBeHidden();
              });
              it("should hide advanced filter input when radio set to or", function() {
                this.erfc.$('.bv_booleanFilter_or').attr('checked', 'checked');
                this.erfc.$('.bv_booleanFilter_or').click();
                return expect(this.erfc.$('.bv_advancedBoolContainer')).toBeHidden();
              });
              return it("should show advanced filter input when radio set to advanced", function() {
                this.erfc.$('.bv_booleanFilter_advanced').attr('checked', 'checked');
                this.erfc.$('.bv_booleanFilter_advanced').click();
                return expect(this.erfc.$('.bv_advancedBoolContainer')).toBeVisible();
              });
            });
            return describe("get filter params", function() {
              return it("should update the collection wehn requested", function() {
                var attrs;
                this.erfc.$('.bv_addTerm').click();
                this.erfc.$('.bv_addTerm').click();
                this.erfc.$('.bv_experiment:eq(1)').val("EXPT-00000396");
                this.erfc.$('.bv_experiment:eq(1)').change();
                this.erfc.$('.bv_kind:eq(1)').val("category");
                this.erfc.$('.bv_kind:eq(1)').change();
                this.erfc.$('.bv_operator:eq(1)').val("contains");
                this.erfc.$('.bv_filterValue:eq(1)').val(" search string ");
                this.erfc.$('.bv_booleanFilter_advanced').attr('checked', 'checked');
                this.erfc.$('.bv_advancedBooleanFilter').val(" (Q1 AND Q2) OR Q3 ");
                attrs = this.erfc.getSearchFilters();
                expect(attrs.booleanFilter).toEqual("advanced");
                expect(attrs.advancedFilter).toEqual("(Q1 AND Q2) OR Q3");
                expect(attrs.filters[1].termName).toEqual("Q2");
                expect(attrs.filters[1].experimentCode).toEqual("EXPT-00000396");
                expect(attrs.filters[1].lsKind).toEqual("category");
                expect(attrs.filters[1].lsType).toEqual("stringValue");
                expect(attrs.filters[1].operator).toEqual("contains");
                return expect(attrs.filters[1].filterValue).toEqual("search string");
              });
            });
          });
        });
      });
      return describe("Advanced search wizard", function() {
        return describe('when instantiated', function() {
          beforeEach(function() {
            this.aerqc = new AdvancedExperimentResultsQueryController({
              el: $('#fixture')
            });
            return this.aerqc.render();
          });
          describe("basic existance tests", function() {
            it('should exist', function() {
              return expect(this.aerqc).toBeDefined();
            });
            return it('should load a template', function() {
              return expect(this.aerqc.$('.bv_getCodesView').length).toEqual(1);
            });
          });
          describe("start with get codes step", function() {
            return it("should show only getCodes", function() {
              expect(this.aerqc.$('.bv_getCodesView')).toBeVisible();
              expect(this.aerqc.$('.bv_getExperimentsView')).toBeHidden();
              expect(this.aerqc.$('.bv_getFiltersView')).toBeHidden();
              expect(this.aerqc.$('.bv_advResultsView')).toBeHidden();
              return expect(this.aerqc.$('.bv_noExperimentsFound')).toBeHidden();
            });
          });
          describe("when valid codes enter and next pressed", function() {
            beforeEach(function() {
              return runs(function() {
                this.aerqc.$('.bv_codesField').val("12345, 6789");
                return this.aerqc.handleNextClicked();
              });
            });
            return describe("experiment tree display from stub service", function() {
              beforeEach(function() {
                return waitsFor((function(_this) {
                  return function() {
                    return _this.aerqc.$('.bv_tree').length === 1;
                  };
                })(this), 500);
              });
              describe("tree view display", function() {
                it("should show only getExperiments", function() {
                  return runs(function() {
                    expect(this.aerqc.$('.bv_getCodesView')).toBeHidden();
                    expect(this.aerqc.$('.bv_getExperimentsView')).toBeVisible();
                    expect(this.aerqc.$('.bv_getFiltersView')).toBeHidden();
                    return expect(this.aerqc.$('.bv_advResultsView')).toBeHidden();
                  });
                });
                return it("should load tree and display root node", function() {
                  return runs(function() {
                    return expect(this.aerqc.$('.bv_tree').html()).toContain("Protocols");
                  });
                });
              });
              return describe("to filter select from experiment tree", function() {
                beforeEach(function() {
                  return runs(function() {
                    this.aerqc.$(".bv_tree").jstree(true).search("EXPT-00000398");
                    this.aerqc.$('.jstree-checkbox:eq(4)').click();
                    this.aerqc.$('.jstree-checkbox:eq(5)').click();
                    return this.aerqc.handleNextClicked();
                  });
                });
                return describe("should show only filters", function() {
                  beforeEach(function() {
                    return waitsFor((function(_this) {
                      return function() {
                        return _this.aerqc.$('.bv_addTerm').length === 1;
                      };
                    })(this), 500);
                  });
                  describe("filter view display", function() {
                    return it("should show one experiment term with experiment options", function() {
                      return runs(function() {
                        this.aerqc.$('.bv_addTerm').click();
                        expect(this.aerqc.$('.bv_filterTerms .bv_experiment').length).toEqual(1);
                        expect(this.aerqc.$('.bv_filterTerms .bv_experiment option').length).toEqual(3);
                        return expect(this.aerqc.$('.bv_filterTerms .bv_experiment option:eq(0)').val()).toEqual("EXPT-00000396");
                      });
                    });
                  });
                  return describe("from filter to results", function() {
                    beforeEach(function() {
                      return runs(function() {
                        this.requestNextToNewQuery = false;
                        this.aerqc.on('requestNextChangeToNewQuery', (function(_this) {
                          return function() {
                            return _this.requestNextToNewQuery = true;
                          };
                        })(this));
                        return this.aerqc.handleNextClicked();
                      });
                    });
                    return describe("result display", function() {
                      beforeEach(function() {
                        return waitsFor((function(_this) {
                          return function() {
                            return _this.aerqc.$('.bv_resultTable').length === 1;
                          };
                        })(this), 500);
                      });
                      return describe("show results", function() {
                        it("should setup DOM in prep to load datatable module", function() {
                          return runs(function() {
                            return expect(this.aerqc.$('thead tr').length).toEqual(2);
                          });
                        });
                        return it("should render the rest of the table", function() {
                          return runs(function() {
                            return expect(this.aerqc.$('tbody tr').length).toEqual(4);
                          });
                        });
                      });
                    });
                  });
                });
              });
            });
          });
          return describe("when invalid codes entered and next pressed (no experiments returned)", function() {
            beforeEach(function() {
              return runs(function() {
                this.aerqc.$('.bv_codesField').val("fiona");
                return this.aerqc.handleNextClicked();
              });
            });
            return describe("stay at step one and show message", function() {
              beforeEach(function() {
                return waits(200);
              });
              return it("should show only getExperiments", function() {
                return runs(function() {
                  return expect(this.aerqc.$('.bv_noExperimentsFound')).toBeVisible();
                });
              });
            });
          });
        });
      });
    });
    return describe("Gene ID Query App Controller", function() {
      return describe('when instantiated', function() {
        beforeEach(function() {
          this.gidqac = new GeneIDQueryAppController({
            el: $('#fixture')
          });
          return this.gidqac.render();
        });
        describe("basic existance tests", function() {
          it('should exist', function() {
            return expect(this.gidqac).toBeDefined();
          });
          return it('should load a template', function() {
            return expect(this.gidqac.$('.bv_basicQueryView').length).toEqual(1);
          });
        });
        describe("Launch basic mode by default", function() {
          it('should load a basic query controller', function() {
            return expect(this.gidqac.$('.bv_inputView').length).toEqual(1);
          });
          it('should hide advanced query view', function() {
            return expect(this.gidqac.$('.bv_advancedQueryContainer')).toBeHidden();
          });
          return it("should hide advanced query navbar during basic mode", function() {
            return expect(this.gidqac.$('.bv_advancedQueryNavbar')).toBeHidden();
          });
        });
        describe("Launch advanced mode when requested", function() {
          beforeEach(function() {
            return this.gidqac.$('.bv_gidNavAdvancedSearchButton').click();
          });
          it('should load advanced query controller', function() {
            expect(this.gidqac.$('.bv_getCodesView').length).toEqual(1);
            return expect(this.gidqac.$('.bv_advancedQueryContainer')).toBeVisible();
          });
          it('should hide basic query controller', function() {
            return expect(this.gidqac.$('.bv_basicQueryView')).toBeHidden();
          });
          return it("should show advanced query navbar during advanced mode", function() {
            return expect(this.gidqac.$('.bv_advancedQueryNavbar')).toBeVisible();
          });
        });
        return describe("Rre-launch basic mode on cancel", function() {
          return it('should load basic query controller', function() {
            this.gidqac.$('.bv_gidNavAdvancedSearchButton').click();
            expect(this.gidqac.$('.bv_getCodesView').length).toEqual(1);
            this.gidqac.$('.bv_cancel').click();
            expect(this.gidqac.$('.bv_inputView').length).toEqual(1);
            expect(this.gidqac.$('.bv_basicQueryView')).toBeVisible();
            return expect(this.gidqac.$('.bv_advancedQueryContainer')).toBeHidden();
          });
        });
      });
    });
  });

}).call(this);
