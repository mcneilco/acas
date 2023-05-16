$(function() {

	window.Lot_Abstract = Backbone.Model.extend({
		
		getModelForSave: function() {
			var mts = new Backbone.Model(this.attributes);
			mts.set({fileList: this.get('fileList').getUploadedFiles()});
			mts.set({chemist: this.get('chemist').get('code')});
			mts.set({project: this.get('project').get('code')});
            mts.unset('json');
			return mts;
		
		}
	});
	
	window.LotController_Abstract = Backbone.View.extend({
		events: {
			'click .editAnalyticalFiles': 'showFileUploadController'
		},

		initialize: function() {
			_.bindAll(this, 'showFileUploadController', 'validationError');
			this.model.bind('error',  this.validationError);
			this.valid = true;
            
            if(this.model.isNew()) {
                serverDestDir = ''; // upload disabled, don't have subdir
            } else {
				if (window.configuration.metaLot.fileSaveDirNamedForBatchName) {
					serverDestDir = this.model.get('corpName');
				}
				else {
					serverDestDir = this.model.get('notebookPage');
				}
            }

			if(window.configuration.serverConnection.connectToServer) {
                var uploadTarget = window.configuration.serverConnection.baseServerURL+"filesave";
            } else {
                var uploadTarget = "MultipleFilePicker/file_upload.php";
            }

			this.fileUploadController = new UploadAppView({
				fileList: this.model.get('fileList'),
				descriptions: true,
				compatibilityMode: true,
				target: uploadTarget,
                serverDestDir: serverDestDir,
				baseDirectory: window.configuration.serverSettings.notebookSavePath
			});
			this.fileUploadController.hide();

            if (this.options.errorNotifList!=null) {
				var eNoti = this.options.errorNotifList;
                this.bind('notifyError', eNoti.add);
                this.bind('clearErrors', eNoti.removeMessagesForOwner);
			}

		},
        
        setupCodeController: function(elClass, type, attribute) {
            var tcode = '';
            if(this.model.get(attribute)) {
				if(this.model.get(attribute).get("code")) {
					tcode = this.model.get(attribute).get('code');
				} else {
					if(this.model.get(attribute).get("selectedCode")) {
						tcode = this.model.get(attribute).get("selectedCode");
					}
				}
            }
			return new PickListSelectController({
				el: this.$('.'+elClass),
				type: type,
                selectedCode: tcode
			})
        },
		
		isValid: function() {
			return this.valid;
		},
		
		validationError: function(model, errors) {
			this.clearValidationErrors();
			var self = this;
			_.each(errors, function(err) {
				self.$('.'+err.attribute).addClass('input_error');
				self.trigger('notifyError', {owner: "LotController", errorLevel: 'error', message: err.message});
				self.valid = false;
			});
		},
		
		clearValidationErrors: function() {
			var errorElms = this.$('.input_error');
			this.trigger('clearErrors', "LotController");
			this.valid = true;
			
			_.each(errorElms, function(ee) {
				$(ee).removeClass('input_error');
			});
		},

        showFileUploadController: function() {
			this.fileUploadController.fadeIn(100);
		},
        
        disableAll: function() {
            this.$('input').attr('disabled', true);
            this.$('select').attr('disabled', true);
            this.$('.editAnalyticalFiles').hide();
        }
	
	});
	
	
});