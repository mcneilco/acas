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
          return it("should hide result table", function() {
            return expect(this.gidqsc.$('.bv_resultsView')).toBeHidden();
          });
        });
        return describe("search return handling", function() {
          it("should have a function to call when search returns", function() {
            return expect(this.gidqsc.handleSearchReturn).toBeDefined();
          });
          return it("should show result view", function() {
            this.gidqsc.handleSearchReturn({
              results: window.geneDataQueriesTestJSON.geneIDQueryResults
            });
            return expect(this.gidqsc.$('.bv_resultsView')).toBeVisible();
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
