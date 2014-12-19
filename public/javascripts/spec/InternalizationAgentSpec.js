(function() {
  beforeEach(function() {
    return this.fixture = $.clone($("#fixture").get(0));
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append($(this.fixture));
  });

  describe('Internalization Agent testing', function() {
    describe("Internalization Agent Parent model testing", function() {
      return describe("when loaded from new", function() {
        beforeEach(function() {
          return this.iap = new InternalizationAgentParent();
        });
        return describe("Existence and Defaults", function() {
          it("should be defined", function() {
            return expect(this.iap).toBeDefined();
          });
          it("should have a type", function() {
            return expect(this.iap.get('lsType')).toEqual("parent");
          });
          it("should have a kind", function() {
            return expect(this.iap.get('lsKind')).toEqual("internalization agent");
          });
          it("should have an empty scientist", function() {
            return expect(this.iap.get('recordedBy')).toEqual("");
          });
          it("should have a recordedDate set to now", function() {
            return expect(new Date(this.iap.get('recordedDate')).getHours()).toEqual(new Date().getHours());
          });
          it("Should have an empty short description with a space as an oracle work-around", function() {
            return expect(this.iap.get('shortDescription')).toEqual(" ");
          });
          it("Should have a lsLabels with one label", function() {
            expect(this.iap.get('lsLabels')).toBeDefined();
            expect(this.iap.get("lsLabels").length).toEqual(1);
            return expect(this.iap.get("lsLabels").getLabelByTypeAndKind("name", "internalization agent name").length).toEqual(1);
          });
          it("Should have a model attribute for the label in defaultLabels", function() {
            return expect(this.iap.get("internalization agent name")).toBeDefined();
          });
          it("Should have a lsStates with the states in defaultStates", function() {
            expect(this.iap.get('lsStates')).toBeDefined();
            expect(this.iap.get("lsStates").length).toEqual(1);
            return expect(this.iap.get("lsStates").getStatesByTypeAndKind("parent attributes", "internalization agent parent attributes").length).toEqual(1);
          });
          return describe("model attributes for each value in defaultValues", function() {
            it("Should have a model attribute for internalization agent type", function() {
              return expect(this.iap.get("internalization agent type")).toBeDefined();
            });
            it("Should have a model attribute for conjugation type", function() {
              return expect(this.iap.get("conjugation type")).toBeDefined();
            });
            it("Should have a model attribute for conjugation site", function() {
              return expect(this.iap.get("conjugation site")).toBeDefined();
            });
            it("Should have a model attribute for protein aa sequence", function() {
              return expect(this.iap.get("protein aa sequence")).toBeDefined();
            });
            it("Should have a model attribute for scientist", function() {
              return expect(this.iap.get("scientist")).toBeDefined();
            });
            it("Should have a model attribute for notebook", function() {
              return expect(this.iap.get("notebook")).toBeDefined();
            });
            return it("Should have a model attribute for completion date", function() {
              return expect(this.iap.get("completion date")).toBeDefined();
            });
          });
        });
      });
    });
    return describe("When created from existing", function() {
      beforeEach(function() {
        return this.iap = new InternalizationAgentParent(JSON.parse(JSON.stringify(window.internalizationAgentTestJSON.internalizationAgentParent)));
      });
      return describe("after initial load", function() {
        it("should be defined", function() {
          return expect(this.iap).toBeDefined();
        });
        it("should have a type", function() {
          return expect(this.iap.get('lsType')).toEqual("parent");
        });
        it("should have a kind", function() {
          return expect(this.iap.get('lsKind')).toEqual("internalization agent");
        });
        it("should have a scientist set", function() {
          return expect(this.iap.get('recordedBy')).toEqual("egao");
        });
        it("should have a recordedDate set", function() {
          return expect(this.iap.get('recordedDate')).toEqual(1375141508000);
        });
        it("Should have a short description set", function() {
          return expect(this.iap.get('shortDescription')).toEqual("example short description");
        });
        it("Should have the label set", function() {
          var label;
          console.log(this.iap);
          expect(this.iap.get("internalization agent name").get("labelText")).toEqual("IA Example 1");
          label = this.iap.get("lsLabels").getLabelByTypeAndKind("name", "internalization agent name");
          console.log(label[0]);
          return expect(label[0].get('labelText')).toEqual("IA Example 1");
        });
        it("Should have a model attribute for the label in defaultLabels", function() {
          return expect(this.iap.get("internalization agent name")).toBeDefined();
        });
        it("Should have a lsStates with the states in defaultStates", function() {
          expect(this.iap.get('lsStates')).toBeDefined();
          expect(this.iap.get("lsStates").length).toEqual(1);
          return expect(this.iap.get("lsStates").getStatesByTypeAndKind("parent attributes", "internalization agent parent attributes").length).toEqual(1);
        });
        return describe("model attributes for each value in defaultValues", function() {
          it("Should have a model attribute for internalization agent type", function() {
            return expect(this.iap.get("internalization agent type")).toBeDefined();
          });
          it("Should have a model attribute for conjugation type", function() {
            return expect(this.iap.get("conjugation type")).toBeDefined();
          });
          it("Should have a model attribute for conjugation site", function() {
            return expect(this.iap.get("conjugation site")).toBeDefined();
          });
          it("Should have a model attribute for protein aa sequence", function() {
            return expect(this.iap.get("protein aa sequence")).toBeDefined();
          });
          it("Should have a model attribute for scientist", function() {
            return expect(this.iap.get("scientist")).toBeDefined();
          });
          it("Should have a model attribute for notebook", function() {
            return expect(this.iap.get("notebook")).toBeDefined();
          });
          return it("Should have a model attribute for completion date", function() {
            return expect(this.iap.get("completion date")).toBeDefined();
          });
        });
      });
    });
  });

}).call(this);
