(function() {
  describe('Doc For Batches Behavior Testing', function() {
    beforeEach(function() {
      return this.fixture = $.clone($('#fixture').get(0));
    });
    afterEach(function() {
      $('#fixture').remove();
      return $('body').append($(this.fixture));
    });
    describe('DocForBatches model', function() {
      describe('New empty model', function() {
        beforeEach(function() {
          return this.docForBatches = new DocForBatches();
        });
        describe('Defaults', function() {
          it('should have an empty DocUpload', function() {
            expect(this.docForBatches.has('docUpload')).toBeTruthy();
            return expect(this.docForBatches.get('docUpload') instanceof DocUpload).toBeTruthy();
          });
          return it('should have an empty BatchNameList', function() {
            expect(this.docForBatches.has('batchNameList')).toBeTruthy();
            return expect(this.docForBatches.get('batchNameList') instanceof BatchNameList).toBeTruthy();
          });
        });
        return describe("Validation", function() {
          return it("should be invalid when new", function() {
            return expect(this.docForBatches.isValid()).toBeFalsy();
          });
        });
      });
      describe("create populated experiment when docForBatches is populated but unsaved", function() {
        beforeEach(function() {
          this.docUpload = new DocUpload(window.testJSON.docUploadWithFile);
          this.batchNameList = new BatchNameList(window.testJSON.batchNameList);
          return this.docForBatches = new DocForBatches({
            docUpload: this.docUpload,
            batchNameList: this.batchNameList
          });
        });
        describe("get required protocol", function() {
          it("this spec should setup a valid docForBatches", function() {
            return expect(this.docForBatches.isValid()).toBeTruthy();
          });
          return it("should be fetch the hard-wired protocol for docForBatches", function() {
            waitsFor(function() {
              return this.docForBatches.protocol !== null;
            }, 500);
            return runs(function() {
              return expect(this.docForBatches.protocol.get('codeName')).toContain("PROT");
            });
          });
        });
        return describe("when experiment update requested", function() {
          beforeEach(function() {
            waitsFor(function() {
              return this.docForBatches.protocol !== null;
            }, 500);
            return runs(function() {
              return this.exp = this.docForBatches.asExperiment();
            });
          });
          it("should return an Experimemnt object", function() {
            return runs(function() {
              return expect(this.exp instanceof Experiment).toBeTruthy();
            });
          });
          it("experiment should have protocol", function() {
            return runs(function() {
              return expect(this.exp.get('protocol').get('codeName')).toContain("PROT");
            });
          });
          it("experiment should have correct kind", function() {
            return runs(function() {
              return expect(this.exp.get('kind')).toEqual("ACAS doc for batches");
            });
          });
          it("experiment should have correct recordedBy", function() {
            return runs(function() {
              return expect(this.exp.get('recordedBy')).toEqual("jmcneil");
            });
          });
          it("experiment should have recordedDate", function() {
            return runs(function() {
              return expect(this.exp.get('recordedDate')).toBeGreaterThan(1);
            });
          });
          it("experiment should have shortDescription", function() {
            return runs(function() {
              return expect(this.exp.get('shortDescription')).toEqual("test description");
            });
          });
          it("experiment should have label equal to file name or URL", function() {
            return runs(function() {
              return expect(this.exp.get('lsLabels').pickBestName().get('labelText')).toEqual("exampleUploadedFile.txt");
            });
          });
          it("experiment should have analysisGroup in analysisGroupList", function() {
            return runs(function() {
              return expect(this.exp.get('analysisGroups').at(0) instanceof AnalysisGroup).toBeTruthy();
            });
          });
          it("experiment should have state in analysisGroup", function() {
            return runs(function() {
              return expect(this.exp.get('analysisGroups').at(0).get('analysisGroupStates') instanceof AnalysisGroupStateList).toBeTruthy();
            });
          });
          it("experiment should have state in state list", function() {
            return runs(function() {
              return expect(this.exp.get('analysisGroups').at(0).get('analysisGroupStates').length).toEqual(1);
            });
          });
          it("experiment should have statevalue list in state", function() {
            return runs(function() {
              return expect(this.exp.get('analysisGroups').at(0).get('analysisGroupStates').at(0).get('analysisGroupValues') instanceof AnalysisGroupValueList).toBeTruthy();
            });
          });
          it("experiment should have statevalues", function() {
            return runs(function() {
              return expect(this.exp.get('analysisGroups').at(0).get('analysisGroupStates').at(0).get('analysisGroupValues').length).toEqual(5);
            });
          });
          it("experiment should have statevalues", function() {
            return runs(function() {
              return expect(this.exp.get('analysisGroups').at(0).get('analysisGroupStates').at(0).get('analysisGroupValues').at(0) instanceof AnalysisGroupValue).toBeTruthy();
            });
          });
          it("experiment should have statevalues kind", function() {
            return runs(function() {
              return expect(this.exp.get('analysisGroups').at(0).get('analysisGroupStates').at(0).get('analysisGroupValues').at(0).get('valueKind')).toEqual('annotation');
            });
          });
          it("experiment should have statevalues type", function() {
            return runs(function() {
              return expect(this.exp.get('analysisGroups').at(0).get('analysisGroupStates').at(0).get('analysisGroupValues').at(0).get('valueType')).toEqual('fileValue');
            });
          });
          return it("state value should not be ignored", function() {
            return runs(function() {
              return expect(this.exp.get('analysisGroups').at(0).get('analysisGroupStates').at(0).get('analysisGroupValues').at(0).get('ignored')).toBeFalsy();
            });
          });
        });
      });
      describe("create a new docForBatches from experiment", function() {
        beforeEach(function() {
          this.exp = new Experiment(window.experimentServiceTestJSON.savedExperimentWithTreatmentGroup);
          return this.docForBatches = new DocForBatches({
            experiment: this.exp
          });
        });
        it("should have a experiment setup", function() {
          return expect(this.docForBatches.get('experiment') instanceof Experiment).toBeTruthy();
        });
        it("should setup a currentFileName from fileValue", function() {
          console.log(this.docForBatches);
          return expect(this.docForBatches.get('docUpload').get('currentFileName')).toEqual(window.experimentServiceTestJSON.savedExperimentWithTreatmentGroup.analysisGroups[0].analysisGroupStates[0].analysisGroupValues[0].fileValue);
        });
        it("should not setup a url from urlValue", function() {
          return expect(this.docForBatches.get('docUpload').get('url')).toEqual('');
        });
        it("should setup a documentKind from stringValue", function() {
          return expect(this.docForBatches.get('docUpload').get('documentKind')).toEqual('experiment');
        });
        it("should setup a banchNameList from analysisGroupValue", function() {
          return expect(this.docForBatches.get('batchNameList').length).toEqual(3);
        });
        return it("should setup a banchNameList from analysisGroupValue", function() {
          return expect(this.docForBatches.get('batchNameList').at(0).get('preferredName')).toEqual('CMPD_1112');
        });
      });
      return describe('New from JSON', function() {
        beforeEach(function() {
          return this.docForBatches = new DocForBatches({
            json: window.testJSON.docForBatches
          });
        });
        return describe('loaded JSON', function() {
          it('should have the id set', function() {
            return expect(this.docForBatches.id).toEqual(1235);
          });
          describe('has a populated DocUpload', function() {
            it('should have a DocUpload class', function() {});
            return it('should have a filled currentFileName', function() {
              return expect(this.docForBatches.get('docUpload').get('currentFileName')).toEqual("exampleUploadedFile.txt");
            });
          });
          return describe('has a populated BatchNameList', function() {
            it('should have a BatchNameList class', function() {});
            return it('should have a filled BatchNameList 0th element with preferredName: ', function() {
              return expect(this.docForBatches.get('batchNameList').at(0).get('preferredName')).toEqual("CMPD-0000007-01");
            });
          });
        });
      });
    });
    return describe('DocForBatches Controller', function() {
      describe('when launched with new model', function() {
        beforeEach(function() {
          this.docForBatchesController = new DocForBatchesController({
            el: $('#fixture'),
            model: new DocForBatches()
          });
          return this.docForBatchesController.render();
        });
        describe('after initial render', function() {
          it('should should show "New Document Annotations" in title', function() {
            return expect(this.docForBatchesController.$('.bv_title').html()).toEqual("New Document Annotations");
          });
          return it('should disable file button', function() {
            return expect(this.docForBatchesController.$(".bv_saveButton").attr("disabled")).toEqual("disabled");
          });
        });
        return describe('template should load', function() {
          it(' should have a save button', function() {
            return expect(this.docForBatchesController.$('.bv_saveButton').is('button')).toBeTruthy();
          });
          it(' should have a delete button', function() {
            return expect(this.docForBatchesController.$('.bv_deleteButton').is('button')).toBeTruthy();
          });
          it(' should have a cancel button', function() {
            return expect(this.docForBatchesController.$('.bv_cancelButton').is('button')).toBeTruthy();
          });
          it(' should have a div for a batchListValidator', function() {
            return expect(this.docForBatchesController.$('.bv_batchListValidator').is('div')).toBeTruthy();
          });
          it(' should have a div for a docUpload', function() {
            return expect(this.docForBatchesController.$('.bv_docUpload').is('div')).toBeTruthy();
          });
          describe('should show a DocUpload', function() {
            return it('should have a description field', function() {
              return expect(this.docForBatchesController.$(".bv_description").is('input')).toBeTruthy();
            });
          });
          describe('should show a batchListValidator', function() {
            it('should have a paste list area', function() {
              return expect(this.docForBatchesController.$('.bv_pasteListArea').is("textarea")).toBeTruthy();
            });
            return it('should have a batchListContainer', function() {
              return expect(this.docForBatchesController.$('.batchListContainer').is("div")).toBeTruthy();
            });
          });
          describe('because it is a new document', function() {
            it('should label save button "Save', function() {
              return expect(this.docForBatchesController.$(".bv_saveButton").html()).toEqual("Save");
            });
            return it('should hide delete button', function() {
              return expect(this.docForBatchesController.$(".bv_deleteButton")).toBeHidden();
            });
          });
          describe('invalid form state should disable save button', function() {
            it("should disable the submit button when there are zero valid batches", function() {
              runs(function() {
                expect(this.docForBatchesController.$(".bv_saveButton").attr("disabled")).toEqual("disabled");
                this.docForBatchesController.$(".bv_pasteListArea").val("norm_1234");
                this.docForBatchesController.$(".bv_pasteListArea").change();
                this.docForBatchesController.$(".bv_addButton").click();
                this.docForBatchesController.docUploadController.setNewFileName("fredFile");
                return this.docForBatchesController.$(".bv_newFileRadio").click();
              });
              waitsFor(function() {
                return this.docForBatchesController.batchListValidator.ischeckAndAddBatchesComplete();
              }, 500);
              return runs(function() {
                this.docForBatchesController.$(".bv_comment").val("my comment");
                this.docForBatchesController.$(".bv_comment").change();
                expect(this.docForBatchesController.$(".bv_saveButton").attr("disabled")).toBeUndefined();
                this.docForBatchesController.$(".batchNameView:eq(0) .bv_removeBatch").click();
                return expect(this.docForBatchesController.$(".bv_saveButton").attr("disabled")).toEqual("disabled");
              });
            });
            it('should disable save if URL is selected and URL field is empty', function() {
              expect(this.docForBatchesController.$(".bv_saveButton").attr("disabled")).toEqual("disabled");
              this.docForBatchesController.$(".bv_urlRadio").click();
              return expect(this.docForBatchesController.$(".bv_saveButton").attr("disabled")).toEqual("disabled");
            });
            it('should disable save if file is selected and file is not uplaoded', function() {
              expect(this.docForBatchesController.$(".bv_saveButton").attr("disabled")).toEqual("disabled");
              this.docForBatchesController.$(".bv_newFileRadio").click();
              return expect(this.docForBatchesController.$(".bv_saveButton").attr("disabled")).toEqual("disabled");
            });
            return it('should enable save if file is selected and file is uplaoded and there are valid batches', function() {
              runs(function() {
                expect(this.docForBatchesController.$(".bv_saveButton").attr("disabled")).toEqual("disabled");
                this.docForBatchesController.$(".bv_pasteListArea").val("norm_1234");
                this.docForBatchesController.$(".bv_pasteListArea").change();
                this.docForBatchesController.$(".bv_addButton").click();
                this.docForBatchesController.docUploadController.setNewFileName("fredFile");
                return this.docForBatchesController.$(".bv_newFileRadio").click();
              });
              waitsFor(function() {
                return this.docForBatchesController.batchListValidator.ischeckAndAddBatchesComplete();
              }, 500);
              return runs(function() {
                this.docForBatchesController.$(".bv_comment").val("my comment");
                this.docForBatchesController.$(".bv_comment").change();
                return expect(this.docForBatchesController.$(".bv_saveButton").attr("disabled")).toBeUndefined();
              });
            });
          });
          return describe('When some stuff entered and cancel button clicked', function() {
            beforeEach(function() {
              runs(function() {
                this.docForBatchesController.$(".bv_pasteListArea").val("norm_1234");
                this.docForBatchesController.$(".bv_pasteListArea").change();
                this.docForBatchesController.$(".bv_addButton").click();
                this.docForBatchesController.$(".bv_urlRadio").click();
                this.docForBatchesController.$(".bv_url").val("myURL");
                this.docForBatchesController.$(".bv_description").val("my description");
                return this.docForBatchesController.$(".bv_url").val("myURL");
              });
              return waitsFor(function() {
                return this.docForBatchesController.batchListValidator.ischeckAndAddBatchesComplete();
              }, 500);
            });
            return it('should replace the model with a new empty model and clear inputs', function() {
              return runs(function() {
                this.docForBatchesController.$(".bv_comment").val("my comment");
                this.docForBatchesController.$(".bv_comment").change();
                expect(this.docForBatchesController.$(".bv_saveButton").attr("disabled")).toEqual("disabled");
                expect(this.docForBatchesController.model.get('batchNameList').length).toEqual(1);
                this.docForBatchesController.$(".bv_cancelButton").click();
                expect(this.docForBatchesController.$(".bv_url").val()).toEqual("");
                expect(this.docForBatchesController.$(".bv_description").val()).toEqual("");
                return expect(this.docForBatchesController.model.get('batchNameList').length).toEqual(0);
              });
            });
          });
        });
      });
      return describe('when launched with existing model', function() {
        beforeEach(function() {
          this.docForBatchesController = new DocForBatchesController({
            el: $('#fixture'),
            model: new DocForBatches({
              json: window.testJSON.docForBatches
            })
          });
          return this.docForBatchesController.render();
        });
        describe('after initial render', function() {
          return it('should should show "Edit Document Annotations" in title', function() {
            return expect(this.docForBatchesController.$('.bv_title').html()).toEqual("Edit Document Annotations");
          });
        });
        return describe('because it is an existing document', function() {
          it('should label save button "Update', function() {
            return expect(this.docForBatchesController.$(".bv_saveButton").html()).toEqual("Update");
          });
          return it('should show delete button', function() {
            return expect(this.docForBatchesController.$(".bv_deleteButton")).toBeVisible();
          });
        });
      });
    });
  });

}).call(this);
