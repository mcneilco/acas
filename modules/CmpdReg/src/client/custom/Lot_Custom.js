$(function() {

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
            isVirtual: false,
            lotNumber: null,
            retain: null,
            retainUnits: null,
            solutionAmount: null,
            solutionAmountUnits: null,
            vendor: null
		},
		
		initialize: function(){
			if (this.has('json') ) {
				var js = this.get('json');
				// set all attributes, realizing that some need to be replaced by real objcts
				this.set(js,{silent: true});
                this.set({
                    physicalState: new PickList(js.physicalState),
                    amountUnits: new PickList(js.amountUnits),
                    retainUnits: new PickList(js.retainUnits),
                    solutionAmountUnits: new PickList(js.solutionAmountUnits),
                    purityMeasuredBy: new PickList(js.purityMeasuredBy),
                    purityOperator: new PickList(js.purityOperator),
                    chemist: new PickList(js.chemist),
                    project: new PickList(js.project),
                    vendor: new PickList(js.vendor)
                })
				// replace composite object pointers with real objects
				this.set({fileList: new BackboneFileList()});
				this.get('fileList').model = BackboneFileDesc;
				this.get('fileList').add(js.fileList);

			} else if (this.isNew()){
				this.set({
					fileList: new BackboneFileList()
				});
				this.get('fileList').model = BackboneFileDesc;
			}
		},
		
		validate: function(attr) {
			var errors = new Array();
            
            var nbAndDateReq = true;
            if(attr.isVirtual !=null) {
                if(attr.isVirtual) {
                    nbAndDateReq = false;
                }
            } else if (this.get('isVirtual')) {
                nbAndDateReq = false;
            }
            
            
            if (attr.notebookPage != null) {
                if(nbAndDateReq || (!nbAndDateReq && attr.notebookPage != '')) {
                
                    if(!(/.+/.test(attr.notebookPage))) {
                        errors.push({attribute: 'notebookPage', message: "Notebook Page must be provided"});
                    }
                 } else if (attr.notebookPage == '') {
                    attr.notebookPage = null;
                }
            }
            if (attr.synthesisDate != null) {
                if(nbAndDateReq || (!nbAndDateReq && attr.synthesisDate != '')) {
                    if(!(/^[0-1][0-9]\/[0-3][0-9]\/[0-9]{4}$/.test(attr.synthesisDate))) {
                        errors.push({attribute: 'synthesisDate', message: "Synthesis Date must be provided and formatted like mm/dd/yyyy"});
                    }
                } else if (attr.synthesisDate == '') {
                    attr.synthesisDate = null;
                }
            }

			if (attr.percentEE!=null) {
				if(isNaN(attr.percentEE) && attr.percentEE!='') { 
					errors.push({'attribute': 'percentEE', 'message':  "%e.e. must be a number if provided"});
				}
			}
			if (attr.amount!=null) {
				if(isNaN(attr.amount) && attr.amount!='') { 
					errors.push({'attribute': 'amount', 'message':  "Amount must be a number if provided"});
				}
			}
			if (attr.retain!=null) {
				if(isNaN(attr.retain) && attr.retain!='') {
					errors.push({'attribute': 'retain', 'message':  "Retain must be a number if provided"});
				}
			}
			if (attr.solutionAmount!=null) {
				if(isNaN(attr.solutionAmount) && attr.solutionAmount!='') {
					errors.push({'attribute': 'solutionAmount', 'message':  "Solution Amount must be a number if provided"});
				}
			}
			if (attr.purity!=null) {
				if(isNaN(attr.purity) && attr.purity!='') { 
					errors.push({'attribute': 'purity', 'message':  "Purity must be a number if provided"});
				}
			}
			if (attr.meltingPoint!=null) {
				if(isNaN(attr.meltingPoint) && attr.meltingPoint!='') { 
					errors.push({'attribute': 'meltingPoint', 'message':  "MP must be a number if provided"});
				}
			}
			if (attr.boilingPoint!=null) {
				if(isNaN(attr.boilingPoint) && attr.boilingPoint!='') { 
					errors.push({'attribute': 'boilingPoint', 'message':  "BP must be a number if provided"});
				}
			}
			if (errors.length > 0) {return errors;}
		}
	});
	
	window.LotController = LotController_Abstract.extend({
		template: _.template($('#LotForm_LotView_Labsynch_template').html()),
		
		render: function() {
			this.model.set({
                saved: !this.model.isNew()
            });
			$(this.el).html(this.template(this.model.toJSON()));
			this.model.unset('saved');

            if (this.model.get('lotMolWeight') != null) {
                this.$('.lotMolWeight').val(
                    parseFloat(this.model.get('lotMolWeight')).toFixed(2)
                );
            }

            this.chemistCodeController = 
                this.setupCodeController('chemist', 'scientists', 'chemist');
            this.projectCodeController = 
                this.setupCodeController('project', 'projects', 'project');

            if(!this.model.get('isVirtual')) {
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
                this.purityMeasuredByCodeController =
                    this.setupCodeController('purityMeasuredByCode', 'purityMeasuredBys', 'purityMeasuredBy');
                this.purityMeasuredByCodeController.insertFirstOption = new PickList({
                    code: "unassigned",
                    name: "Select Method"
                  })

                this.fileListRenderer = new FileRenderer(this.model.get('fileList'));
                this.$('.analyticalFiles').append(this.fileListRenderer.el);
                $(this.el).append(this.fileUploadController.el);
            } else {
                this.$('.notForVirtual').hide();
//                this.$('.notForVirtual2').hide();
//                this.$('.notForVirtual3').hide();
            }
            
            if(this.model.isNew()) {
                this.$('.synthesisDate').datepicker( );
                this.$('.synthesisDate').datepicker( "option", "dateFormat", "mm/dd/yy" );
                this.$('.editAnalyticalFiles').hide();
                this.$('.analyticalFiles').html('Add analytical files by editing lot after it is saved');
            }
			return this;
		},
        
		updateModel: function() {
			this.clearValidationErrors();
            
            if (this.model.isNew() ) {
                this.model.set({
                    notebookPage: jQuery.trim(this.$('.notebookPage').val()),
                    synthesisDate: jQuery.trim(this.$('.synthesisDate').val()),
                    chemist: this.chemistCodeController.getSelectedModel()
                });
            }
 
            if(this.model.get('isVirtual')) {
                this.model.set({
                    supplier: '',
                    supplierID: '',
                    percentEE: null,
                    comments: '',
                    color: '',
                    amount: null,
                    purity: null,
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
                    vendor: null
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
                var purityMeasuredBy; 
            	if (this.purityMeasuredByCodeController.getSelectedModel().isNew()) purityMeasuredBy = null;
            	else purityMeasuredBy = this.purityMeasuredByCodeController.getSelectedModel();
                var vendor;
            	if (this.vendorCodeController.getSelectedModel().isNew()) vendor = null;
            	else vendor = this.vendorCodeController.getSelectedModel();
                this.model.set({
                    supplier: jQuery.trim(this.$('.supplier').val()),
                    supplierID: jQuery.trim(this.$('.supplierID').val()),
                    percentEE: 
                        (jQuery.trim(this.$('.percentEE').val())=='') ? null :
                        parseFloat(jQuery.trim(this.$('.percentEE').val())),
                    comments: jQuery.trim(this.$('.comments').val()),
                    color: jQuery.trim(this.$('.color').val()),
                    amount: 
                        (jQuery.trim(this.$('.amount').val())=='') ? null :
                        parseFloat(jQuery.trim(this.$('.amount').val())),
                    retain:
                        (jQuery.trim(this.$('.retain').val())=='') ? null :
                        parseFloat(jQuery.trim(this.$('.retain').val())),
                    solutionAmount:
                        (jQuery.trim(this.$('.solutionAmount').val())=='') ? null :
                        parseFloat(jQuery.trim(this.$('.solutionAmount').val())),
                    purity:
                        (jQuery.trim(this.$('.purity').val())=='') ? null :
                        parseFloat(jQuery.trim(this.$('.purity').val())),
                    physicalState: physicalState,
                    purityOperator: this.operatorCodeController.getSelectedModel(),
                    amountUnits: amountUnits,
                    retainUnits: retainUnits,
                    solutionAmountUnits: solutionAmountUnits,
                    purityMeasuredBy: purityMeasuredBy,
                    project: this.projectCodeController.getSelectedModel(),
                    vendor: vendor,
                    supplierLot: jQuery.trim(this.$('.supplierLot').val()),
                    meltingPoint: 
                        (jQuery.trim(this.$('.meltingPoint').val())=='') ? null :
                        parseFloat(jQuery.trim(this.$('.meltingPoint').val())),
                    boilingPoint: 
                        (jQuery.trim(this.$('.boilingPoint').val())=='') ? null :
                        parseFloat(jQuery.trim(this.$('.boilingPoint').val())),
                    lotNumber:
                    	(jQuery.trim(this.$('.lotNumber').val())=='') ? null :
                            parseInt(jQuery.trim(this.$('.lotNumber').val())),
                });
            }
		}
			
	});
	
	
});