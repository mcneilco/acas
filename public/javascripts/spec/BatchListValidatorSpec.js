(function() {
  describe("Batch List Validator Behavior Testing", function() {
    beforeEach(function() {
      return this.fixture = $.clone($("#fixture").get(0));
    });
    afterEach(function() {
      $("#fixture").remove();
      return $("body").append($(this.fixture));
    });
    describe("BatchName Model", function() {
      return describe("when instantiated", function() {
        beforeEach(function() {
          return this.bn = new BatchName();
        });
        it("should have defaults", function() {
          expect(this.bn.get("requestName")).toEqual("");
          expect(this.bn.get("preferredName")).toEqual("");
          return expect(this.bn.get("comment")).toEqual("");
        });
        it("should return a display name", function() {
          this.bn.set({
            requestName: "batchName",
            preferredName: "batchName"
          });
          expect(this.bn.getDisplayName()).toEqual("batchName");
          this.bn.set({
            requestName: "batchName",
            preferredName: "aliasName"
          });
          expect(this.bn.getDisplayName()).toEqual("aliasName");
          this.bn.set({
            requestName: "batchName",
            preferredName: ""
          });
          return expect(this.bn.getDisplayName()).toEqual("batchName");
        });
        it("should have test for valid comment", function() {
          this.bn.set({
            preferredName: "cmpd_123:1",
            comment: "my comment"
          });
          expect(this.bn.hasValidComment()).toBeTruthy();
          this.bn.set({
            comment: ""
          });
          return expect(this.bn.hasValidComment()).toBeFalsy();
        });
        it("should tell if two are the same", function() {
          var bn1, bn2, bn3, bn4, bn5;

          bn1 = new BatchName({
            requestName: "reqName1",
            preferredName: "reqName1"
          });
          bn2 = new BatchName({
            requestName: "reqName2",
            preferredName: "reqName2"
          });
          bn3 = new BatchName({
            requestName: "reqName3",
            preferredName: "reqName1"
          });
          bn4 = new BatchName({
            requestName: "reqName4",
            preferredName: ""
          });
          bn5 = new BatchName({
            requestName: "reqName5",
            preferredName: ""
          });
          expect(bn1.isSame(bn2)).toBeFalsy;
          expect(bn1.isSame(bn3)).toBeTruthy;
          return expect(bn4.isSame(bn5)).toBeFalsy;
        });
        it("should return isValid true when it is valid", function() {
          var bn1;

          bn1 = new BatchName({
            requestName: "reqName1",
            preferredName: "reqName1",
            comment: "comment"
          });
          return expect(bn1.isValid()).toBeTruthy();
        });
        return it("should return isValid false when preferredName missing", function() {
          var bn1;

          bn1 = new BatchName({
            requestName: "reqName1",
            preferredName: "",
            comment: "comment"
          });
          return expect(bn1.isValid()).toBeFalsy();
        });
      });
    });
    describe("BatchNameList Model", function() {
      return describe("when instantiated", function() {
        beforeEach(function() {
          return this.bnl = new BatchNameList([
            {
              requestName: "reqName1",
              preferredName: "batchName1",
              comment: "comment 1"
            }, {
              requestName: "reqName2",
              preferredName: "aliasName2",
              comment: "comment 2"
            }, {
              requestName: "reqName3",
              preferredName: "",
              comment: "comment 3"
            }
          ]);
        });
        it("should have three batches when instantiated with 3 models", function() {
          return expect(this.bnl.length).toEqual(3);
        });
        it("should return set list of valid models", function() {
          return expect(this.bnl.getValidBatchNames().length).toEqual(2);
        });
        it("should be invalid when has any invalid batchnames", function() {
          return expect(this.bnl.isValid()).toBeFalsy();
        });
        it("should not add models that are the same", function() {
          expect(this.bnl.length).toEqual(3);
          this.bnl.add({
            requestName: "reqName2",
            preferredName: "aliasName2"
          });
          this.bnl.add({
            requestName: "reqName2other",
            preferredName: "aliasName2"
          });
          return expect(this.bnl.length).toEqual(3);
        });
        return it("should be valid when all batchnames valid", function() {
          this.bnl.pop();
          return expect(this.bnl.isValid()).toBeTruthy();
        });
      });
    });
    describe("BatchName Controller", function() {
      return describe("when instantiated", function() {
        beforeEach(function() {
          this.bnc = new BatchNameController({
            model: new BatchName({
              requestName: "reqName1",
              preferredName: "batchName1",
              comment: "myComment"
            }),
            el: this.fixture
          });
          return this.bnc.render();
        });
        it("should show the batch name", function() {
          return expect(this.bnc.$(".bv_preferredName").html()).toEqual("batchName1");
        });
        it("if alias set should show the alias name", function() {
          this.bnc.model.set({
            requestName: "reqName1",
            preferredName: "aliasName1"
          });
          this.bnc.render();
          return expect(this.bnc.$(".bv_preferredName").html()).toEqual("aliasName1");
        });
        it("should show the comment", function() {
          return expect(this.bnc.$(".bv_comment").val()).toEqual("myComment");
        });
        it("Should have alias substituted style if is alias name", function() {
          this.bnc.model.set({
            requestName: "reqName1",
            preferredName: "aliasName"
          });
          this.bnc.render();
          return expect(this.bnc.$('.bv_preferredName').hasClass("warning")).toBeTruthy();
        });
        it("Should have name not found style if no name or alias in model", function() {
          this.bnc.model.set({
            requestName: "reqName1",
            preferredName: ""
          });
          this.bnc.render();
          return expect(this.bnc.$('.bv_preferredName').hasClass("error")).toBeTruthy();
        });
        it("should show an error if comment is not set", function() {
          this.bnc.$('.bv_comment').val("");
          this.bnc.$('.bv_comment').change();
          return expect(this.bnc.$('.bv_comment').hasClass('error')).toBeTruthy();
        });
        return it("should not show an error if comment is set", function() {
          this.bnc.$('.bv_comment').val("");
          this.bnc.$('.bv_comment').change();
          this.bnc.$('.bv_comment').val(" my comment ");
          this.bnc.$('.bv_comment').change();
          return expect(this.bnc.$('.bv_comment').hasClass('error')).toBeFalsy();
        });
      });
    });
    describe("BatchNameList Controller", function() {
      return describe("when instantiated", function() {
        beforeEach(function() {
          this.bnl = new BatchNameList([
            {
              requestName: "reqName1",
              preferredName: "batchName1",
              comment: "comment 1"
            }, {
              requestName: "reqName2",
              preferredName: "aliasName2",
              comment: "comment 2"
            }, {
              requestName: "reqName3",
              preferredName: "",
              comment: "comment 3"
            }
          ]);
          this.bnlc = new BatchNameListController({
            collection: this.bnl,
            el: this.fixture
          });
          return this.bnlc.render();
        });
        it("should have as many batch divs as in collection", function() {
          expect(this.bnlc.$("tr").length).toEqual(3);
          return expect(this.bnlc.$(".bv_preferredName:eq(1)").html()).toEqual("aliasName2");
        });
        it("should remove list entry when a remove button clicked", function() {
          this.bnlc.$(".batchNameView:eq(1) .bv_removeBatch").click();
          expect(this.bnlc.$("tr").length).toEqual(2);
          return expect(this.bnlc.collection.length).toEqual(2);
        });
        it("should show new batchnames when new added to existing list", function() {
          expect(this.bnlc.$("tr").length).toEqual(3);
          this.bnlc.collection.add([
            {
              requestName: "reqName4",
              preferredName: "batchName4"
            }, {
              requestName: "reqName5",
              preferredName: "aliasName5"
            }
          ]);
          return expect(this.bnlc.$("tr").length).toEqual(5);
        });
        it("should update view if a members preferred name is changed", function() {
          expect(this.bnlc.$(".bv_preferredName:eq(1)").html()).toEqual("aliasName2");
          this.bnlc.collection.at(1).set({
            preferredName: "fred"
          });
          return expect(this.bnlc.$(".bv_preferredName:eq(1)").html()).toEqual("fred");
        });
        return it("should update view if a members preferred name is changed", function() {
          expect(this.bnlc.$(".bv_comment:eq(1)").val()).toEqual("comment 2");
          this.bnlc.collection.at(1).set({
            comment: "fred"
          });
          return expect(this.bnlc.$(".bv_comment:eq(1)").val()).toEqual("fred");
        });
      });
    });
    return describe("BatchListValidator Controller", function() {
      describe("when instantiated with empty collection list", function() {
        beforeEach(function() {
          this.origConfig = window.DocForBatchesConfiguration;
          this.blvc = new BatchListValidatorController({
            el: this.fixture,
            collection: new BatchNameList()
          });
          return this.blvc.render();
        });
        afterEach(function() {
          return window.DocForBatchesConfiguration = this.origConfig;
        });
        describe('after it is rendered', function() {
          it('should have a paste list area', function() {
            return expect(this.blvc.$('.bv_pasteListArea').prop("tagName")).toEqual("TEXTAREA");
          });
          it('should have a batchListContainer', function() {
            return expect(this.blvc.$('.batchListContainer').prop("tagName")).toEqual("DIV");
          });
          it('should have a set the batch column head to Lot if configured that way', function() {
            window.DocForBatchesConfiguration.lotCalledBatch = true;
            this.blvc.render();
            expect(this.blvc.$('.bv_batchHeader').html()).toEqual("Batch");
            window.DocForBatchesConfiguration.lotCalledBatch = false;
            this.blvc.render();
            return expect(this.blvc.$('.bv_batchHeader').html()).toEqual("Lot");
          });
          return it("should start with an empty batchname list", function() {
            return expect(this.blvc.$(".batchListContainer .batchList tr").length).toEqual(0);
          });
        });
        it("should show valid batchNames when valid entries added to text input and add is clicked", function() {
          runs(function() {
            this.blvc.$(".bv_pasteListArea").val("norm_1234\nnorm_1236\nnorm_1238\n");
            this.blvc.$(".bv_pasteListArea").change();
            return this.blvc.$(".bv_addButton").click();
          });
          waitsFor(function() {
            return this.blvc.ischeckAndAddBatchesComplete();
          });
          return runs(function() {
            return expect(this.blvc.$(".batchListContainer .batchList tr").length).toEqual(3);
          });
        });
        it("should empty paste input area after batches are added", function() {
          this.blvc.$(".bv_pasteListArea").val("norm_1234\nnorm_1236\nnorm_1238");
          this.blvc.$(".bv_pasteListArea").change();
          this.blvc.$(".bv_addButton").click();
          waitsFor(function() {
            return this.blvc.ischeckAndAddBatchesComplete();
          });
          return runs(function() {
            return expect(this.blvc.$(".bv_pasteListArea").val()).toEqual("");
          });
        });
        it("should set error class if batch returns no valid name", function() {
          this.blvc.$(".bv_pasteListArea").val("norm_1234\nnone_1236\nnorm_1238");
          this.blvc.$(".bv_pasteListArea").change();
          this.blvc.$(".bv_addButton").click();
          waitsFor(function() {
            return this.blvc.ischeckAndAddBatchesComplete();
          });
          return runs(function() {
            expect(this.blvc.$(".batchListContainer .batchList tr").length).toEqual(3);
            return expect(this.blvc.$(".batchList .batchNameView:eq(1) .bv_preferredName").hasClass("error")).toBeTruthy();
          });
        });
        it("should set alias class if batch returns no valid name", function() {
          this.blvc.$(".bv_pasteListArea").val("norm_1234\nalias_1236\nnorm_1238");
          this.blvc.$(".bv_pasteListArea").change();
          this.blvc.$(".bv_addButton").click();
          waitsFor(function() {
            return this.blvc.ischeckAndAddBatchesComplete();
          });
          return runs(function() {
            expect(this.blvc.$(".batchListContainer .batchList tr").length).toEqual(3);
            return expect(this.blvc.$(".batchList .batchNameView:eq(1) .bv_preferredName").hasClass("warning")).toBeTruthy();
          });
        });
        it("should show the correct number of valid batche names", function() {
          this.blvc.$(".bv_pasteListArea").val("norm_1234\nalias_1236\nnorm_1238\nnone_445");
          this.blvc.$(".bv_pasteListArea").change();
          this.blvc.$(".bv_addButton").click();
          waitsFor(function() {
            return this.blvc.ischeckAndAddBatchesComplete();
          });
          return runs(function() {
            expect(this.blvc.$(".batchListContainer .batchList tr").length).toEqual(4);
            expect(this.blvc.$(".bv_preferredName.error").length).toEqual(1);
            return expect(this.blvc.$(".bv_preferredName.warning").length).toEqual(1);
          });
        });
        it("should update valid batch count when items are removed", function() {
          this.blvc.$(".bv_pasteListArea").val("norm_1234\nalias_1236\nalias_1238");
          this.blvc.$(".bv_pasteListArea").change();
          this.blvc.$(".bv_addButton").click();
          waitsFor(function() {
            return this.blvc.ischeckAndAddBatchesComplete();
          });
          return runs(function() {
            expect(this.blvc.$(".batchListContainer .batchList tr").length).toEqual(3);
            expect(this.blvc.$(".bv_preferredName.warning").length).toEqual(2);
            this.blvc.$(".bv_removeBatch:eq(1)").click();
            expect(this.blvc.$(".batchListContainer .batchList tr").length).toEqual(2);
            return expect(this.blvc.$(".bv_preferredName.warning").length).toEqual(1);
          });
        });
        return it("should disable the add button while the update is running", function() {
          this.blvc.$(".bv_pasteListArea").val("norm_1234\nalias_1236\nalias_1238");
          this.blvc.$(".bv_pasteListArea").change();
          this.blvc.$(".bv_addButton").click();
          expect(this.blvc.$(".bv_addButton").attr("disabled")).toEqual("disabled");
          waitsFor(function() {
            return this.blvc.ischeckAndAddBatchesComplete();
          });
          return runs(function() {
            return expect(this.blvc.$(".bv_addButton").attr("disabled")).toBeUndefined();
          });
        });
      });
      return describe("when instantiated with existing collection", function() {
        beforeEach(function() {
          this.blvc = new BatchListValidatorController({
            el: this.fixture,
            collection: new BatchNameList(window.testJSON.batchNameList)
          });
          return this.blvc.render();
        });
        describe('when rendered', function() {
          it('should show the proper count', function() {
            return expect(this.blvc.$(".validBatchCount").html()).toEqual("3");
          });
          return it('should show filled in batchName', function() {
            return expect(this.blvc.$('.batchList tr :eq(1) .bv_preferredName').html()).toEqual('CMPD_1112');
          });
        });
        return describe("when invalid batches added but there are valid bathes in list, should trigger invalid", function() {
          return it("should trigger activation request", function() {
            var _this = this;

            runs(function() {
              var _this = this;

              expect(this.blvc.$(".validBatchCount").html()).toEqual("3");
              this.blvc.bind('invalid', function() {
                return _this.gotTrigger = true;
              });
              this.blvc.$('.batchList tr :eq(1) .bv_comment').val("");
              this.blvc.$('.batchList tr :eq(1) .bv_comment').change();
              return expect(this.blvc.$(".validBatchCount").html()).toEqual("2");
            });
            waitsFor(function() {
              return _this.gotTrigger;
            });
            return runs(function() {
              return expect(this.gotTrigger).toBeTruthy();
            });
          });
        });
      });
    });
  });

}).call(this);
