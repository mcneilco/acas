(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe("Gene Data Queries Module Testing", function() {
    describe("Gene ID model testing", function() {
      return describe("When loaded from new", function() {
        beforeEach(function() {
          return this.gid = new GeneID();
        });
        return describe("Existence and Defaults", function() {
          it("should be defined", function() {
            return expect(this.gid).toBeDefined();
          });
          return it("should have a default gid", function() {
            return expect(this.gid.get('gid')).toBeNull();
          });
        });
      });
    });
    describe("Gene ID List model testing", function() {
      return describe("When loaded from new", function() {
        beforeEach(function() {
          return this.gidl = new GeneIDList();
        });
        describe("Existence and Defaults", function() {
          return it("should be defined", function() {
            return expect(this.gidl).toBeDefined();
          });
        });
        return describe("Parsing functions", function() {
          beforeEach(function() {
            return this.gidl.addGIDsFromString("1234, 3421,1111, 2222 , 3333");
          });
          it("should be accept a string of comma seperated gene IDs", function() {
            return expect(this.gidl.length).toEqual(5);
          });
          it("should strip spaces", function() {
            expect(this.gidl.at(1).get('gid')).toEqual('3421');
            return expect(this.gidl.at(3).get('gid')).toEqual('2222');
          });
          it("should add to the existing set when called again", function() {
            this.gidl.addGIDsFromString("555, 3466621,777, 888 , 999");
            return expect(this.gidl.length).toEqual(10);
          });
          return it("should have zero length when given an empty string", function() {
            this.gidl.reset();
            this.gidl.addGIDsFromString("");
            return expect(this.gidl.length).toEqual(0);
          });
        });
      });
    });
    describe("Gene ID Query Input Controller", function() {
      return describe('when instantiated', function() {
        beforeEach(function() {
          this.gidqic = new GeneIDQueryInputController({
            collection: new GeneIDList(),
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
        describe("update the model", function() {
          beforeEach(function() {
            this.gidqic.$('.bv_gidListString').val("1234, 3421,1111, 2222 , 3333");
            return this.gidqic.updateGIDsFromField();
          });
          it("should get 5 entries", function() {
            return expect(this.gidqic.collection.length).toEqual(5);
          });
          it("should strip spaces", function() {
            expect(this.gidqic.collection.at(1).get('gid')).toEqual('3421');
            return expect(this.gidqic.collection.at(3).get('gid')).toEqual('2222');
          });
          return it("should empty the collection before adding gids from the text field", function() {
            this.gidqic.$('.bv_gidListString').val("555, 3466621,777, 888 , 999");
            this.gidqic.updateGIDsFromField();
            return expect(this.gidqic.collection.length).toEqual(5);
          });
        });
        describe("search button enabling behavior", function() {
          it("should have search button disabled when nothing in field", function() {
            return expect(this.gidqic.$('.bv_search').attr('disabled')).toEqual('disabled');
          });
          it("should have search button enabled when someting added to field", function() {
            this.gidqic.$('.bv_gidListString').val("555, 3466621,777, 888 , 999");
            this.gidqic.$('.bv_gidListString').change();
            return expect(this.gidqic.$('.bv_search').attr('disabled')).toBeUndefined();
          });
          return it("should have search button disabled when field is emptied", function() {
            this.gidqic.$('.bv_gidListString').val("");
            this.gidqic.$('.bv_gidListString').change();
            return expect(this.gidqic.$('.bv_search').attr('disabled')).toEqual('disabled');
          });
        });
        return describe("search button behavior", function() {
          return it("should trigger a search request when search button pressed", function() {
            runs(function() {
              this.gidqic.$('.bv_gidListString').val("555, 3466621,777, 888 , 999");
              this.gidqic.$('.bv_gidListString').change();
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
        return describe("data display", function() {
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
          return it("should show no results message", function() {
            return expect(this.gidqrc.$('.bv_noResultsFound')).toBeVisible();
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
            return expect(this.gidqsc.$('.bv_gidNavAdvancedSearchButton').hasClass('gidNavAdvancedSearchButtonBottom')).toBeTruthy();
          });
          it("should not have the gidNavHelpButton pull-right class", function() {
            return expect(this.gidqsc.$('.bv_gidNavHelpButton').hasClass('pull-right')).toBeFalsy();
          });
          it("should add the gidNavAdvancedSearchButton end class", function() {
            return expect(this.gidqsc.$('.bv_gidNavAdvancedSearchButton').hasClass('gidNavAdvancedSearchButtonTop')).toBeFalsy();
          });
          it("should have the gidNavWellBottom class at start", function() {
            return expect(this.gidqsc.$('.bv_toolbar').hasClass('gidNavWellBottom')).toBeTruthy();
          });
          it("should not have the gidNavWellTop class at start", function() {
            return expect(this.gidqsc.$('.bv_toolbar').hasClass('gidNavWellTop')).toBeFalsy();
          });
          it("should have the toolbar fixed bottom class at start", function() {
            return expect(this.gidqsc.$('.bv_group_toolbar').hasClass('navbar-fixed-bottom')).toBeTruthy();
          });
          return it("should not have the toolbar fixed top class at start", function() {
            return expect(this.gidqsc.$('.bv_group_toolbar').hasClass('navbar-fixed-top')).toBeFalsy();
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
            return expect(this.gidqsc.$('.bv_toolbar .bv_searchForm').length).toEqual(1);
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
          it("should remove the gidNavAdvancedSearchButton start class", function() {
            return expect(this.gidqsc.$('.bv_gidNavAdvancedSearchButton').hasClass('gidNavAdvancedSearchButtonBottom')).toBeFalsy();
          });
          it("should add the gidNavHelpButton pull-right class", function() {
            return expect(this.gidqsc.$('.bv_gidNavHelpButton').hasClass('pull-right')).toBeTruthy();
          });
          it("should add the gidNavAdvancedSearchButton end class", function() {
            return expect(this.gidqsc.$('.bv_gidNavAdvancedSearchButton').hasClass('gidNavAdvancedSearchButtonTop')).toBeTruthy();
          });
          it("should remove the gidNavWellBottom class", function() {
            return expect(this.gidqsc.$('.bv_toolbar').hasClass('gidNavWellBottom')).toBeFalsy();
          });
          it("should add the gidNavWellTop class", function() {
            return expect(this.gidqsc.$('.bv_toolbar').hasClass('gidNavWellTop')).toBeTruthy();
          });
          it("should remove the toolbar fixed bottom class", function() {
            return expect(this.gidqsc.$('.bv_group_toolbar').hasClass('navbar-fixed-bottom')).toBeFalsy();
          });
          return it("should add the toolbar fixed top class", function() {
            return expect(this.gidqsc.$('.bv_group_toolbar').hasClass('navbar-fixed-top')).toBeTruthy();
          });
        });
      });
    });
    describe("Advanced search modules", function() {
      return describe("Protocol and experiment display", function() {
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
          return describe("getting selected", function() {
            return it("should get selected experiments", function() {
              this.etc.$(".bv_tree").jstree(true).search("EXPT-00000398");
              expect(this.etc.$('.bv_tree').html()).toContain("EXPT-00000398");
              this.etc.$('.jstree-checkbox:eq(4)').click();
              this.etc.$('.jstree-checkbox:eq(5)').click();
              return expect(this.etc.getSelectedExperiments()).toEqual(["EXPT-00000398", "EXPT-00000396"]);
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
        return describe("basic existance tests", function() {
          it('should exist', function() {
            return expect(this.gidqac).toBeDefined();
          });
          it('should load a template', function() {
            return expect(this.gidqac.$('.bv_queryView').length).toEqual(1);
          });
          return it('should load a query controller', function() {
            return expect(this.gidqac.$('.bv_inputView').length).toEqual(1);
          });
        });
      });
    });
  });

}).call(this);
