$(function () {

  window.Lot = Lot_Abstract.extend({
    defaults: {
      corpName: '',
      asDrawnStruct: null,
      lotMolWeight: null,
      synthesisDate: '',
      color: '',
      physicalState: null,
      notebookPage: '',
      amount: null,
      amountUnits: null,
      supplier: '',
      supplierID: '',
      purity: null,
      purityMeasuredBy: null,
      purityOperator: null,
      percentEE: null,
      comments: '',
      chemist: null,
      project: null,
      supplierLot: null,
      meltingPoint: null,
      boilingPoint: null,
      buid: null,
      barcode: null,
      isVirtual: false,
      lotNumber: null,
      retain: null,
      retainUnits: null,
      solutionAmount: null,
      solutionAmountUnits: null,
      tareWeight: null,
      tareWeightUnits: null,
      totalAmountStored: null,
      totalAmountStoredUnits: null,
      vendor: null,
      vendorID: null,
      parent: null,
      lotNumbers: null,
      allowManualLotNumber: false,
      nextAutoLot: null
    },

    initialize: function (options) {
      this.options = options;
      this.maxAutoLotNumber = window.configuration.metaLot.maxAutoLotNumber;
      this.requireLotNumber = false
      this.autoPopulateNextLotNumber = false
      this.allowManualLotNumber = false
      if (typeof window.configuration.metaLot.requireLotNumber !== "undefined" && window.configuration.metaLot.requireLotNumber !== null) {
        this.requireLotNumber = window.configuration.metaLot.requireLotNumber
      }
      if (typeof window.configuration.metaLot.autoPopulateNextLotNumber !== "undefined" && window.configuration.metaLot.autoPopulateNextLotNumber !== null) {
        this.autoPopulateNextLotNumber = window.configuration.metaLot.autoPopulateNextLotNumber
      }
      if (typeof window.configuration.metaLot.allowManualLotNumber !== "undefined" && window.configuration.metaLot.allowManualLotNumber !== null) {
        this.allowManualLotNumber = window.configuration.metaLot.allowManualLotNumber
      }
      if (this.requireLotNumber && !this.autoPopulateNextLotNumber && !this.allowManualLotNumber) {
        alert("Server configuration error, metaLot.requireLotNumber is true but both metaLot.autoPopulateNextLotNumber and metaLot.allowManualLotNumber are set to false.  Either set metaLot.requireLotNumber to false or set one of the other properties to true")
      }
      
      if (this.has('json')) {
        var js = this.get('json');
        // set all attributes, realizing that some need to be replaced by real objcts
        this.set(js, { silent: true });
        this.set({
          physicalState: new PickList(js.physicalState),
          amountUnits: new PickList(js.amountUnits),
          retainUnits: new PickList(js.retainUnits),
          solutionAmountUnits: new PickList(js.solutionAmountUnits),
          tareWeightUnits: new PickList(js.tareWeightUnits),
          totalAmountStoredUnits: new PickList(js.totalAmountStoredUnits),
          purityMeasuredBy: new PickList(js.purityMeasuredBy),
          purityOperator: new PickList(js.purityOperator),
          chemist: new PickList({ selectedCode: js.chemist }),
          project: new PickList({ selectedCode: js.project }),
          vendor: new PickList(js.vendor)
        })
        // replace composite object pointers with real objects
        this.set({ fileList: new BackboneFileList() }, { silent: true });
        this.get('fileList').model = BackboneFileDesc;
        this.get('fileList').add(js.fileList);

      } else if (this.isNew()) {
        this.set({
          fileList: new BackboneFileList()
        }, { silent: true });
        this.get('fileList').model = BackboneFileDesc;
      }
    },

    validate: function (attr) {

      var errors = new Array();

      var nbAndDateReq = true;
      if (attr.isVirtual != null) {
        if (attr.isVirtual) {
          nbAndDateReq = false;
        }
      } else if (this.get('isVirtual')) {
        nbAndDateReq = false;
      }


      if (attr.notebookPage != null) {
        if (nbAndDateReq || (!nbAndDateReq && attr.notebookPage != '')) {

          if (!(/.+/.test(attr.notebookPage))) {
            errors.push({ attribute: 'notebookPage', message: "Notebook Page must be provided" });
          }
        } else if (attr.notebookPage == '') {
          attr.notebookPage = null;
        }
      }
      if (attr.synthesisDate != null) {
        if (nbAndDateReq || (!nbAndDateReq && attr.synthesisDate != '')) {
          if (!(/^[0-1][0-9]\/[0-3][0-9]\/[0-9]{4}$/.test(attr.synthesisDate))) {
            errors.push({ attribute: 'synthesisDate', message: "Synthesis Date must be provided and formatted like mm/dd/yyyy" });
          }
        } else if (attr.synthesisDate == '') {
          attr.synthesisDate = null;
        }
      }

      if (attr.percentEE != null) {
        if (isNaN(attr.percentEE) && attr.percentEE != '') {
          errors.push({ 'attribute': 'percentEE', 'message': "%e.e. must be a number if provided" });
        }
      }
      if (attr.amount != null) {
        if (isNaN(attr.amount) && attr.amount != '') {
          errors.push({ 'attribute': 'amount', 'message': "Amount must be a number if provided" });
        }
      }
      if (attr.amount != null && attr.amount != '') {
        if (attr.amountUnits == null || attr.amountUnits == 'unassigned') {
          errors.push({ 'attribute': 'amountUnits', 'message': "Amount units must be set if amount set" });
        }
      }
      if (attr.retain != null) {
        if (isNaN(attr.retain) && attr.retain != '') {
          errors.push({ 'attribute': 'retain', 'message': "Retain must be a number if provided" });
        }
      }
      if (attr.solutionAmount != null) {
        if (isNaN(attr.solutionAmount) && attr.solutionAmount != '') {
          errors.push({ 'attribute': 'solutionAmount', 'message': "Solution Amount must be a number if provided" });
        }
      }
      if (attr.solutionAmount != null && attr.solutionAmount != '') {
        if (attr.solutionAmountUnits == null || attr.solutionAmountUnits == 'unassigned') {
          errors.push({ 'attribute': 'solutionAmountUnits', 'message': "Solution amount units must be set if amount set" });
        }
      }
      if (attr.tareWeight != null) {
        if (isNaN(attr.tareWeight) && attr.tareWeight != '') {
          errors.push({ 'attribute': 'tareWeight', 'message': "Tare weight must be a number if provided" });
        }
      }
      if (attr.totalAmountStored != null) {
        if (isNaN(attr.totalAmountStored) && attr.totalAmountStored != '') {
          errors.push({ 'attribute': 'totalAmountStored', 'message': "Total amount stored must be a number if provided" });
        }
      }
      if (attr.purity != null) {
        if (isNaN(attr.purity) && attr.purity != '') {
          errors.push({ 'attribute': 'purity', 'message': "Purity must be a number if provided" });
        }
      }
      if (attr.purity != null && attr.purity != '') {
        if (attr.purityOperator == null || attr.purityOperator == 'unassigned') {
          errors.push({ 'attribute': 'purityOperator', 'message': "Purity operator must be set if purity set" });
        }
      }
      if (attr.meltingPoint != null) {
        if (isNaN(attr.meltingPoint) && attr.meltingPoint != '') {
          errors.push({ 'attribute': 'meltingPoint', 'message': "MP must be a number if provided" });
        }
      }
      if (attr.boilingPoint != null) {
        if (isNaN(attr.boilingPoint) && attr.boilingPoint != '') {
          errors.push({ 'attribute': 'boilingPoint', 'message': "BP must be a number if provided" });
        }
      }
      if (attr.project != null && typeof (attr.project) == 'undefined') {
        errors.push({ 'attribute': 'project', 'message': "Project must be provided" });
      }
      if (this.isNew() & !this.get('isVirtual')) {
        if ("lotNumber" in attr) {
          if (window.configuration.metaLot.requireLotNumber && attr.lotNumber == null) {
            errors.push({ 'attribute': 'lotNumber', 'message': "Please fill in Lot Number" });
          }
          if (attr.lotNumber != null) {
            if (isNaN(attr.lotNumber) && attr.lotNumber != '') {
              errors.push({ 'attribute': 'lotNumber', 'message': "Lot Number must be an integer" });
            } else {
              if (attr.lotNumber == 0) {
                errors.push({ 'attribute': 'lotNumber', 'message': "Lot Number 0 is reserved for virtual lots" });
              } else {
                lotNumbers = this.get('lotNumbers');
                if (lotNumbers.includes(attr.lotNumber)) {
                  errors.push({ 'attribute': 'lotNumber', 'message': "This lot number is already taken by one of the lots for this compound " + lotNumbers.join(',') });
                } else {
                // Validation for maximum maxAutoLotNumber set on the model (see Lot model above and LotController.getNextAutoLot)
                  nextAutoLot = this.get('nextAutoLot');
                  if(nextAutoLot != null && attr.lotNumber != nextAutoLot) {
                    maxAutoLotNumber = this.maxAutoLotNumber;
                    if(attr.lotNumber <= maxAutoLotNumber) {
                      errors.push({'attribute': 'lotNumber', 'message':  "Lot Number must be the next lot number ("+nextAutoLot+") or be greater than "+maxAutoLotNumber+" if manually set."});
                    }
                  }
                }
              }
            }
          }
        }
      }
      if (errors.length > 0) { return errors; }
    }
  });

  window.LotController = LotController_Abstract.extend({
    template: _.template($('#LotForm_LotView_Labsynch_template').html()),

    defaults: {
      readyForRender: false
    },
    events: function () {
      return _.extend({}, LotController_Abstract.prototype.events, {
        'click .insertNextAutoLotNumberButton': 'handleInsertNextAutoLotNumberButtonClicked'
      })
    },
    initialize: function (options) {
      this.options = options;
      LotController_Abstract.prototype.initialize.apply(this, arguments);
      this.maxAutoLotNumber = window.configuration.metaLot.maxAutoLotNumber;
      this.requireLotNumber = false
      this.autoPopulateNextLotNumber = false
      this.allowManualLotNumber = false
      if (typeof window.configuration.metaLot.requireLotNumber !== "undefined" && window.configuration.metaLot.requireLotNumber !== null) {
        this.requireLotNumber = window.configuration.metaLot.requireLotNumber
      }
      if (typeof window.configuration.metaLot.autoPopulateNextLotNumber !== "undefined" && window.configuration.metaLot.autoPopulateNextLotNumber !== null) {
        this.autoPopulateNextLotNumber = window.configuration.metaLot.autoPopulateNextLotNumber
      }
      if (typeof window.configuration.metaLot.allowManualLotNumber !== "undefined" && window.configuration.metaLot.allowManualLotNumber !== null) {
        this.allowManualLotNumber = window.configuration.metaLot.allowManualLotNumber
      }
      if (this.requireLotNumber && !this.autoPopulateNextLotNumber && !this.allowManualLotNumber) {
        alert("Server configuration error, metaLot.requireLotNumber is true but both metaLot.autoPopulateNextLotNumber and metaLot.allowManualLotNumber are set to false.  Either set metaLot.requireLotNumber to false or set one of the other properties to true")
      }

      if (this.model.isNew()) {
        if (this.autoPopulateNextLotNumber | this.allowManualLotNumber | this.requireLotNumber) {
          _.bindAll(this, 'handleLotNumbersPopulated');
          this.model.bind('change:lotNumbers', this.handleLotNumbersPopulated);
          this.model.set({'allowManualLotNumber': this.allowManualLotNumber}, { silent: true });
          this.populateModelWithCurrentLotNumbers();

        } else {
          this.triggerReadyForRender()
        }
      } else {
        this.triggerReadyForRender()
      }
    },
    render: function () {
      this.model.set({
        saved: !this.model.isNew()
      }, { silent: true });
      $(this.el).html(this.template(this.model.toJSON()));
      this.model.unset('saved', { silent: true });

      if (this.model.get('lotMolWeight') != null) {
        this.$('.lotMolWeight').val(
          parseFloat(this.model.get('lotMolWeight')).toFixed(2)
        );
      }

      this.chemistCodeController =
        this.setupCodeController('chemist', 'scientists', 'chemist');
      this.projectCodeController =
        this.setupCodeController('project', 'projects', 'project');

      if (!this.model.get('isVirtual')) {
        // setup selects
        this.physicalStateCodeController =
          this.setupCodeController('physicalStateCode', 'physicalStates', 'physicalState');
        this.physicalStateCodeController.insertFirstOption = new PickList({
          code: "unassigned",
          name: "Select State"
        })
        this.vendorCodeController =
          this.setupCodeController('vendorCode', 'vendors', 'vendor');
        this.vendorCodeController.insertFirstOption = new PickList({
          code: "unassigned",
          name: "Select Vendor"
        })
        this.operatorCodeController =
          this.setupCodeController('purityOperatorCode', 'operators', 'purityOperator');
        this.operatorCodeController.insertFirstOption = new PickList({
          code: "unassigned",
          name: "Select Units"
        })
        this.amountUnitsCodeController =
          this.setupCodeController('amountUnitsCode', 'units', 'amountUnits');
        this.amountUnitsCodeController.insertFirstOption = new PickList({
          code: "unassigned",
          name: "Select Units"
        })
        this.retainUnitsCodeController =
          this.setupCodeController('retainUnitsCode', 'units', 'retainUnits');
        this.retainUnitsCodeController.insertFirstOption = new PickList({
          code: "unassigned",
          name: "Select Units"
        })
        this.solutionAmountUnitsCodeController =
          this.setupCodeController('solutionAmountUnitsCode', 'solutionUnits', 'solutionAmountUnits');
        this.solutionAmountUnitsCodeController.insertFirstOption = new PickList({
          code: "unassigned",
          name: "Select Units"
        })
        this.tareWeightUnitsCodeController =
          this.setupCodeController('tareWeightUnitsCode', 'units', 'tareWeightUnits');
        this.tareWeightUnitsCodeController.insertFirstOption = new PickList({
          code: "unassigned",
          name: "Select Units"
        })
        this.totalAmountStoredUnitsCodeController =
          this.setupCodeController('totalAmountStoredUnitsCode', 'units', 'totalAmountStoredUnits');
        this.totalAmountStoredUnitsCodeController.insertFirstOption = new PickList({
          code: "unassigned",
          name: "Select Units"
        })
        this.purityMeasuredByCodeController =
          this.setupCodeController('purityMeasuredByCode', 'purityMeasuredBys', 'purityMeasuredBy');
        this.purityMeasuredByCodeController.insertFirstOption = new PickList({
          code: "unassigned",
          name: "Select Method"
        })

        if (window.configuration.metaLot.showTareWeight) {
          this.$('.bv_tareWeightContainer').show();
        } else {
          this.$('.bv_tareWeightContainer').hide();
        }
        if (window.configuration.metaLot.showTotalAmountStored) {
          this.$('.bv_totalAmountStoredContainer').show();
        } else {
          this.$('.bv_totalAmountStoredContainer').hide();
        }

        this.fileListRenderer = new FileRenderer(this.model.get('fileList'));
        this.$('.analyticalFiles').append(this.fileListRenderer.el);
        $(this.el).append(this.fileUploadController.el);
      } else {
        this.$('.notForVirtual').hide();
        //                this.$('.notForVirtual2').hide();
        //                this.$('.notForVirtual3').hide();
      }

      this.$('.synthesisDate').datepicker();
      this.$('.synthesisDate').datepicker("option", "dateFormat", "mm/dd/yy");

      if (this.model.isNew()) {
        this.$('.editAnalyticalFiles').hide();
        this.$('.analyticalFiles').html('Add analytical files by editing lot after it is saved');
        if (!this.model.get('isVirtual') && this.autoPopulateNextLotNumber) {
          this.fillNextAutoLot();
        }
      } else {
        if (window.configuration.metaLot.showLotInventory) {
          this.$('.amountWrapper').hide();
          this.$('.barcodeWrapper').hide();
        }
      }
      return this;
    },
    triggerReadyForRender: function () {
      this.readyForRender = true
      this.trigger('readyForRender')
    },
    fillNextAutoLot: function () {
      // Set the model
      this.model.set({ nextAutoLot: this.getNextAutoLot() });

      // Update the view
      this.$('.lotNumber').val(this.model.get('nextAutoLot'));
    },
    getNextAutoLot: function () {
      var nextAutoLot = 1
      // Only run through this if this is a saved parent, otherwise we want 1 as the first lot.
      if (this.model.get("parent") != null && this.model.get("parent").get("corpName") != null && this.model.get("parent").get("corpName") != "") {
        var lotNumbers = this.model.get('lotNumbers')
        // Set nextAutoLot by excluding numbers over maximum maxAutoLotNumber
        if(typeof(this.maxAutoLotNumber) != 'undefined' && this.maxAutoLotNumber != null) {
          var maxAutoLotNumber = this.maxAutoLotNumber
          lotNumbersLessThanMaxAuto = lotNumbers.filter(function(x) {
            // If the lot number is less than the maxAutoLotNumber, return it
            return x <= maxAutoLotNumber
          })
        } else {
          // If max auto lot number is undefined, return all lot numbers
          lotNumbersLessThanMaxAuto = lotNumbers
        }
        if(lotNumbersLessThanMaxAuto.length > 0) {
          nextAutoLot = Math.max.apply(Math, lotNumbersLessThanMaxAuto)+1;
        }
      }
      return (nextAutoLot)
    },
    handleInsertNextAutoLotNumberButtonClicked: function () {
      this.fillNextAutoLot()
    },
    handleLotNumbersPopulated: function () {
      this.triggerReadyForRender();
    },
    populateModelWithCurrentLotNumbers: function () {
      lotNumbers = [];
      model = this.model
      if (this.model.get("parent") != null && this.model.get("parent").get("corpName") != null && this.model.get("parent").get("corpName") != "") {
        var url = window.configuration.serverConnection.baseServerURL + "parentLot/getLotsByParent?parentCorpName=" + this.model.get("parent").get("corpName") + "&with=fullobject";
        $.ajax({
          type: "GET",
          url: url,
          dataType: "json",
          success: function (response) {
            for (i = 0; i < response.length; i++) {
              lotNumbers.push(response[i].lotNumber)
            }
            model.set({
              lotNumbers: lotNumbers
            })
          },
          error: function (error) {
            model.set({
              lotNumbers: lotNumbers
            })
          }
        });
      } else {
        model.set({
          lotNumbers: lotNumbers
        })
      }
    },
    updateModel: function () {
      if (this.projectCodeController.collection.length == 0) {
        alert('System Configuration Error: There must be at least one project to proceed')
      }
      this.clearValidationErrors();

      if (this.model.isNew()) {
        this.model.set({
          lotNumber:
            (jQuery.trim(this.$('.lotNumber').val()) == '') ? null :
              parseInt(jQuery.trim(this.$('.lotNumber').val()))

        });
      }

      if (this.model.get('isVirtual')) {
        this.model.set({
          supplier: '',
          supplierID: '',
          percentEE: null,
          comments: '',
          color: '',
          amount: null,
          barcode: null,
          purity: null,
          vendorID: null,
          physicalState: null,
          purityOperator: null,
          amountUnits: null,
          purityMeasuredBy: null,
          project: this.projectCodeController.getSelectedModel(),
          supplierLot: '',
          meltingPoint: null,
          boilingPoint: null,
          retain: null,
          retainUnits: null,
          solutionAmount: null,
          solutionAmountUnits: null,
          tareWeight: null,
          tareWeightUnits: null,
          totalAmountStored: null,
          totalAmountStoredUnits: null,
          vendor: null,
          vendorID: null
        });
      } else {
        //set unselected properties to null

        var physicalState;
        if (this.physicalStateCodeController.getSelectedModel().isNew()) physicalState = null;
        else physicalState = this.physicalStateCodeController.getSelectedModel();
        var amountUnits;
        if (this.amountUnitsCodeController.getSelectedModel().isNew()) amountUnits = null;
        else amountUnits = this.amountUnitsCodeController.getSelectedModel();
        var retainUnits;
        if (this.retainUnitsCodeController.getSelectedModel().isNew()) retainUnits = null;
        else retainUnits = this.retainUnitsCodeController.getSelectedModel();
        var solutionAmountUnits;
        if (this.solutionAmountUnitsCodeController.getSelectedModel().isNew()) solutionAmountUnits = null;
        else solutionAmountUnits = this.solutionAmountUnitsCodeController.getSelectedModel();
        var tareWeightUnits;
        if (this.tareWeightUnitsCodeController.getSelectedModel().isNew()) tareWeightUnits = null;
        else tareWeightUnits = this.tareWeightUnitsCodeController.getSelectedModel();
        var totalAmountStoredUnits;
        if (this.totalAmountStoredUnitsCodeController.getSelectedModel().isNew()) totalAmountStoredUnits = null;
        else totalAmountStoredUnits = this.totalAmountStoredUnitsCodeController.getSelectedModel();
        var purityMeasuredBy;
        if (this.purityMeasuredByCodeController.getSelectedModel().isNew()) purityMeasuredBy = null;
        else purityMeasuredBy = this.purityMeasuredByCodeController.getSelectedModel();
        var vendor;
        var purityOperator;
        if (this.operatorCodeController.getSelectedModel().isNew()) purityOperator = null;
        else purityOperator = this.operatorCodeController.getSelectedModel();
        if (this.vendorCodeController.getSelectedModel().isNew()) vendor = null;
        else vendor = this.vendorCodeController.getSelectedModel();
        this.model.set({
          notebookPage: jQuery.trim(this.$('.notebookPage').val()),
          synthesisDate: jQuery.trim(this.$('.synthesisDate').val()),
          supplier: jQuery.trim(this.$('.supplier').val()),
          supplierID: jQuery.trim(this.$('.supplierID').val()),
          percentEE:
            (jQuery.trim(this.$('.percentEE').val()) == '') ? null :
              parseFloat(jQuery.trim(this.$('.percentEE').val())),
          comments: jQuery.trim(this.$('.comments').val()),
          color: jQuery.trim(this.$('.color').val()),
          amount:
            (jQuery.trim(this.$('.amount').val()) == '') ? null :
              parseFloat(jQuery.trim(this.$('.amount').val())),
          barcode: (jQuery.trim(this.$('.barcode').val()) == '') ? null : jQuery.trim(this.$('.barcode').val()),
          retain:
            (jQuery.trim(this.$('.retain').val()) == '') ? null :
              parseFloat(jQuery.trim(this.$('.retain').val())),
          solutionAmount:
            (jQuery.trim(this.$('.solutionAmount').val()) == '') ? null :
              parseFloat(jQuery.trim(this.$('.solutionAmount').val())),
          tareWeight:
            (jQuery.trim(this.$('.tareWeight').val()) == '') ? null :
              parseFloat(jQuery.trim(this.$('.tareWeight').val())),
          totalAmountStored:
            (jQuery.trim(this.$('.totalAmountStored').val()) == '') ? null :
              parseFloat(jQuery.trim(this.$('.totalAmountStored').val())),
          purity:
            (jQuery.trim(this.$('.purity').val()) == '') ? null :
              parseFloat(jQuery.trim(this.$('.purity').val())),
          vendorID: jQuery.trim(this.$('.vendorID').val()),
          physicalState: physicalState,
          purityOperator: purityOperator,
          amountUnits: amountUnits,
          retainUnits: retainUnits,
          solutionAmountUnits: solutionAmountUnits,
          tareWeightUnits: tareWeightUnits,
          totalAmountStoredUnits: totalAmountStoredUnits,
          purityMeasuredBy: purityMeasuredBy,
          chemist: this.chemistCodeController.getSelectedModel(),
          project: this.projectCodeController.getSelectedModel(),
          vendor: vendor,
          supplierLot: jQuery.trim(this.$('.supplierLot').val()),
          meltingPoint:
            (jQuery.trim(this.$('.meltingPoint').val()) == '') ? null :
              parseFloat(jQuery.trim(this.$('.meltingPoint').val())),
          boilingPoint:
            (jQuery.trim(this.$('.boilingPoint').val()) == '') ? null :
              parseFloat(jQuery.trim(this.$('.boilingPoint').val()))
        });
      }
    }

  });


});