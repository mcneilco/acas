$(function () {
/*
	describe('Async test', function () {
		
		it('should pass', function () {
			var flag = false;
		
			runs(function () {
				this.callback = function () {
					console.log(flag);
					flag = true;
				};
				
				spyOn(this, 'callback').andCallThrough();
		
				var asyncMethod = function (callback) {
					$.ajax({
						url: 'http://localhost:8888/MultiYPlotMAMP/async.php',
						success: function (data, textStatus, jqXHR) {
							callback();
						}
					});
				};
		
				asyncMethod(this.callback);
		
				expect(this.callback).not.toHaveBeenCalled();
			});
			
			waitsFor(function () { return flag == true }, 'flag has not be set to true', '500');
			
			runs(function () {
				expect(this.callback).toHaveBeenCalled();
			});
		});
	});
*/
	

	describe('BackboneFile Model', function () {
		
		describe('when instantiated without File object', function () {
		
			it('should should throw a MissingArgumentError', function () {
				expect(function () {new BackboneFile()})
					.toThrow('MissingArgumentError');
			});
		});
		
		describe('when instantiated with a wrong object', function () {
		
			it('should throw an IllegalArgumentError', function () {
				expect(function () {
					new BackboneFile({file: 'illegal file'})
				}).toThrow('MissingArgumentError');
				
				expect(function () {
					new BackboneFile({name: 'name', content: 'content', size: 'should be number', type: 'type'})
				}).toThrow('IllegalArgumentError');
				
				expect(function () {
					new BackboneFile({name: 4567, content: 233345, size: 45643, type: 43567})
				}).toThrow('IllegalArgumentError');
			});
		});
		
		describe('when instantiated with a file object', function () {
			it ('should pass', function () {
				var fileName = 'filename';
				var fileSize = 678;
				var fileType = 'filetype';
			
				fileobj = {name: fileName, size: fileSize, type: fileType};
			
				var file = new BackboneFile({file: fileobj});
			
				expect(file.get('name')).toEqual(fileName);
				expect(file.get('size')).toEqual(fileSize);
				expect(file.get('type')).toEqual(fileType);
				expect(file.get('uploaded')).toEqual(false);
			});
		});
		
		describe('when instantiated with a literal object', function () {
			
			it('should exhibit the correct attributes', function () {
				var fileName = 'fileName';
				var fileSize = 600;
				var fileType = 'filetype';
				
				var file = new BackboneFile({name: fileName, size: fileSize, type: fileType});
				
				expect(file.get('name')).toEqual(fileName);
				expect(file.get('size')).toEqual(fileSize);
				expect(file.get('type')).toEqual(fileType);
			});
		});

/****** Those tests are obsolete since we are not handling the backbone save operation ******/

//		describe('File async operations', function () {
//			beforeEach(function () {
//				this.fileName = 'fileName.html';
//				this.fileContent = '<!DOCTYPE html><html><head><title>test</title></head><body><div>this is the body</div></body></html>';
//				this.fileSize = 0;
//				this.fileType = 'filetype';
//					
//				this.file = new BackboneFile({
//					name: this.fileName,
//					content: this.fileContent,
//					size: this.fileSize,
//					type: this.fileType
//				});
//			});
//			
//			describe('when first saved', function () {
//				it('is should be correctly updated', function () {
//					var flag = false;
//			
//					expect(this.file.get('id')).toBeUndefined();
//					expect(this.file.get('uploaded')).toBeFalsy();
//				
//					runs(function () {
//						this.file.save({}, {error: function (model, response) {
//							flag = true;
//						}, success: function (model, response) {
//							flag = true;
//						}});
//					});
//				
//					waitsFor(function () {return flag == true}, 'flag has not be set to true', '500');
//				
//					runs(function () {
//						expect(flag).toBeTruthy();
//						expect(this.file.get('id')).toBeDefined();
//						expect(this.file.get('url')).toBeDefined();
//						expect(this.file.get('uploaded')).toBeTruthy();
//					
//						// Just to keep the db not too big
//						this.file.destroy();
//					});
//				});
//			});
//		
//			describe('When saved with the wrong type and size', function () {
//				it('Should come back with the right type and size', function () {
//					runs(function () {
//						this.file.save();
//					});
//				
//					waitsFor(function () {return this.file.get('uploaded');}, 'file could not be uploaded', '500');
//				
//					runs(function () {
//						expect(this.file.get('type')).toEqual('text/html');
//						expect(this.file.get('size')).not.toEqual(0);
//						this.file.destroy();
//					});
//				});
//			});
//			
//			describe('when destroyed', function () {
//				it('should not be marked as uploaded anymore', function () {
//					runs(function () {
//						this.file.save();
//					});
//				
//					waitsFor(function () {return this.file.get('uploaded');}, 'file could not be uploaded', '500');
//				
//					runs(function () {
//						expect(this.file.get('uploaded')).toBeTruthy();
//						this.file.destroy();
//					});
//					
//					waits(50);
//					
//					runs(function () {
//						expect(this.file.get('uploaded')).toBeFalsy();						
//					});
//				});
//			});
//		});		
	});
    
    describe('FileDescriptionModel', function () {
        
        describe('when instantiated', function () {
            it('should have empty description by default', function () {
                var fileName = 'fileName.html';
                var fileSize = 0;
                var fileType = 'filetype';

                var file = new BackboneFileDesc({
                    name: fileName,
                    size: fileSize,
                    type: fileType
                });
                
                expect(file.get('description')).toEqual('');
            });
        });
        
    });
	
	describe('FileView', function () {
		beforeEach(function () {
			var fileName = 'fileName.html';
			var fileSize = 0;
			var fileType = 'filetype';
					
			this.file = new BackboneFile({
				name: fileName,
				size: fileSize,
				type: fileType
			});
			
			this.template = _.template($('#file-template').html());
			
			this.fileView = new FileView({model: this.file});
		});
	
		describe('when instantiated', function () {
			it('should have proper tag name and id', function () {
				expect(this.fileView.tagName).toEqual('div');
				expect(this.fileView.className).toEqual('file-view');
			});
			
			it('should have the right template', function () {
				expect(this.fileView.template(this.file.toJSON())).toEqual(
                    this.template(this.file.toJSON()));
			});
		});
		
		describe('when templating', function () {
			it('should exhibit the appropriate markup', function () {
				var markup = $(this.fileView.template(this.file.toJSON()));
                console.log(markup);
				expect(markup.length).toEqual(7);
				expect(markup.siblings(':nth-child(1)').text()).toEqual('fileName.html');
				expect(markup.siblings(':nth-child(1)').hasClass('name')).toBeTruthy();
				
				expect(markup.siblings(':nth-child(2)').text()).toEqual('0 bytes');
				expect(markup.siblings(':nth-child(2)').hasClass('size')).toBeTruthy();
				
				expect(markup.siblings(':nth-child(3)').hasClass('delete')).toBeTruthy();				
			});
		});
		
		describe('when it renders', function () {
			it('should return the view object', function () {
				expect(this.fileView.render()).toBe(this.fileView);
			});
			
			it('should set its el attribute to be the result of the template function',
            function () {
				runs(function () {
					expect($(this.fileView.el).children().length).toEqual(0);
				});
				
				// If we don't wait, the view renders before
				// the creation of the JQuery object above
				waits(50);
				
				runs(function () {
					this.fileView.render();
					expect($(this.fileView.el).children().length).toEqual(4);
					expect($(this.fileView.el).html()).toEqual(
                        this.template(this.file.toJSON()));
				});
			});
		});
		
		describe('when clicked on the delete span', function () {
			it('should destroy the object', function () {
			
				var i = 0;
				
                this.fileView.render();
                this.file.bind('destroy', function () {i++;});
                //console.log(this.fileView.$('.delete'));
				
                this.fileView.$('.delete').click();
				
                expect(i).toEqual(1);
			});
		});
	});
    
    describe('FileViewDesc', function () {
        
        beforeEach(function () {
			var fileName = 'fileName.html';
			var fileSize = 0;
			var fileType = 'filetype';
            var desc = 'description'
					
			this.file = new BackboneFileDesc({
				name: fileName,
				size: fileSize,
				type: fileType,
                description: desc
			});
			
			this.template = _.template($('#file-template-desc').html());
			
			this.fileView = new FileViewDesc({model: this.file});
		});
        
        describe('when instantiated', function () {
            it('should have the appropriate template', function () {
				expect(this.fileView.template(this.file.toJSON())).toEqual(
                    this.template(this.file.toJSON()));
            });
            
//            it('should have an additional text input with the right class', function () {
//                var markup = $(this.fileView.template(this.file.toJSON()));
//                var input = markup.siblings('.description');
//                expect(input.attr('class')).toEqual('description');
//                console.log(input);
//                expect(input[0].tagName).toEqual('SELECT');
//            });
        });
        
        describe('when typing text in the description input', function () {
            it('should update the model when pressing enter', function () {
                var markup = $(this.fileView.template(this.file.toJSON()));
                var input = markup.siblings('input.file-description');
                input.val('test');
                var e = $.Event('keypress');
//                e.which = 13;
                e.keyCode = 13;
                input.trigger(e);
                
//                expect(this.file.get('description')).toEqual('test');
            });
        });
    });
	
	describe('FileList Collection', function () {
		
		describe('when instantiated', function () {
		
			it('should exhibit appropriate attributes', function () {
				var fileList = new BackboneFileList();
				
				expect(fileList.model).toEqual(BackboneFile);
			});
		});
		
		describe('when uploading files', function () {
			beforeEach(function () {
				this.file1 = new BackboneFile({
					name: 'file1',
					content: 'this is file 1',
					size: 0,
					type: 'text/plain'
				});
				
				this.file2 = new BackboneFile({
					name: 'file2',
					content: 'this is file 2',
					size: 0,
					type: 'text/plain'
				});
			
				this.fileList = new BackboneFileList([
					this.file1,
					this.file2
				]);
			});
		
			it('should upload all the files from the collection', function () {
                
				runs(function () {
					this.fileList.upload('../../file_upload.php');
				});
				
				waitsFor(function () {return this.file2.get('uploaded');}, 'file could not be uploaded', '500');
				
				runs(function () {
					this.fileList.each(function (file) {
						expect(file.get('uploaded')).toBeTruthy();
						file.destroy();
					});
				});
			});
		});
        
        describe('when adding invalid file type', function () {
            
            it('should throw an InvalidFileType exception', function () {
                file = new BackboneFile({
					name: 'file1',
					content: 'this is file 1',
					size: 0,
					type: 'text/plain'
				});
			
				fileList = new BackboneFileList();
                fileList.validMimeTypes = ['text/html'];
                
                expect(function () { fileList.add(file); }).toThrow('InvalidFileType');
            });
        });
	});
	
	describe('DropView - Non IE', function () {
        
        describe('when instantiated', function () {
            
            it('should have appropriate default attributes', function () {
                var dropView = new DropView();
                
                expect(dropView.id).toEqual('drop-view');
                expect($(dropView.el).attr('ondragenter')).toEqual('return false');
                expect($(dropView.el).attr('ondragover')).toEqual('return false');
                expect(dropView.fileList instanceof Backbone.Collection).toBeTruthy();
            });
        });
        
        describe('drop event', function () {
            beforeEach(function () {
                this.dropView = new DropView();
                
                this.dropEvent = $.Event('drop', {
                    originalEvent: {
                        dataTransfer: {
                            files: [
                                {
                                    name: 'dropfile1',
                                    size: '12',
                                    type: 'text/plain',
                                    content: 'fake drop file1'
                                }, {
                                    name: 'dropfile2',
                                    size: '10',
                                    type: 'text/plain',
                                    content: 'fake dropfile2'
                                }, {
                                    name: 'dropfile3',
                                    size: '21',
                                    type: 'text/plain',
                                    content: 'fake drop file3'
                                }
                            ]
                        }
                    }
                });
            });
            
            describe('when files are dropped', function () {
                it('should append them to the view and add them to the file list', function () {
                    $(this.dropView.el).trigger(this.dropEvent);
                    expect($(this.dropView.el).children('.file-view').length).toEqual(3);
                    expect(this.dropView.fileList.length).toEqual(3);
                });
            });
        });
	});
    
    describe('DropView - IE compatibility', function () {
        
        describe('When instantiated', function () {
            
            it ('should produce the appropriate markup', function () {
                var dropView = new DropView({
                    compatibilityMode: true,
                    target: '../../file_upload.php'
                });
                
                var form = dropView.$('form');
                expect(form.get(0).tagName).toEqual('FORM');
                // This one is defined by our test
                expect(form.attr('target')).toEqual('../../file_upload.php');
                
                var divInput = form.children();
                expect(divInput[0].tagName).toEqual('TABLE');
                // Should have only one input element at first
                expect(divInput.length).toEqual(1);
                
                var input = divInput.children();
                expect(input[0].tagName).toEqual('TBODY');
                //expect(input.attr('type')).toEqual('file');
            });
        });
        
        // Any way to simulate the user picking a file
        // from javascript?
        // When triggering click on the file input
        // the popup shows up in the test runner
    });
    
    describe('UploadAppView', function () {
        
        describe('when instantiated', function () {
            
            it('should have appropriate default attributes', function () {
                var appView = new UploadAppView();
                expect(appView.id).toEqual('upload-app');
                expect(appView.dropView instanceof Backbone.View).toBeTruthy();
                expect(appView.$('#drop-view').get(0)).toBe(appView.dropView.el);
                expect(appView.$('.upload').length).toEqual(1);
            });
        });
        
        describe('when instantiated with a fileList', function () {
            beforeEach(function () {
                this.file1 = new BackboneFile({
					name: 'file1',
					content: 'this is file 1',
					size: 0,
					type: 'text/plain'
				});
				
				this.file2 = new BackboneFile({
					name: 'file2',
					content: 'this is file 2',
					size: 0,
					type: 'text/plain'
				});
			
				this.fileList = new BackboneFileList([
					this.file1,
					this.file2
				]);
                
                this.appView = new UploadAppView({fileList: this.fileList});
            });
            
            describe('when checking the underlying file list', function () {
                it('should be the one we provided', function () {
                    expect(this.fileList).toBe(this.appView.dropView.fileList);
                });
            })
        });
        
        describe('when upload button is pressed', function () {
            
            beforeEach(function () {
                this.appView = new UploadAppView({target: '../../file_upload.php'});
                
                this.file1 = new BackboneFile({
					name: 'uploadfile1',
					content: 'this is file 1',
					size: 0,
					type: 'text/plain'
				});
				
				this.file2 = new BackboneFile({
					name: 'uploadfile2',
					content: 'this is file 2',
					size: 0,
					type: 'text/plain'
				});
                
                this.appView.dropView.fileList.add(this.file1);
                this.appView.dropView.fileList.add(this.file2);
            });
            
            it('should upload the files', function () {
                
                runs(function () {
                    expect(this.appView.getNotUploadedFiles().length).toEqual(2);
                    expect(this.appView.getUploadedFiles().length).toEqual(0);
                    this.appView.$('.upload').click();
                });
                
                waitsFor(function () {
                    return this.file1.get('uploaded') && this.file2.get('uploaded');
                }, 'The files have not been uploaded', 500);
                
                runs(function () {
                    expect(this.file1.get('uploaded')).toBeTruthy();
                    expect(this.file2.get('uploaded')).toBeTruthy();
                    expect(this.appView.getUploadedFiles().length).toEqual(2);
                    expect(this.appView.getNotUploadedFiles().length).toEqual(0);
                });
            });
        });
    });
    
    describe('FileViewRenderer', function () {
        
        beforeEach(function () {
            this.file = new BackboneFileDesc({
                name: 'file1',
                content: 'this is file 1',
                size: 0,
                type: 'text/plain',
                description: 'desc file 1',
                url: 'localhost/somedir',
                uploaded: true
            });

            this.fileViewRenderer = new FileViewRenderer({ model: this.file });
            
            this.template = _.template($('#file-template-renderer').html());
        });
        
        describe('when instantiated', function () {
            it('should have the appropriate template', function () {
                expect(this.fileViewRenderer.template(this.file.toJSON())).toEqual(this.template(this.file.toJSON()));
            });
        });
        
        describe('when the model is updated', function () {
            it('should update the view', function () {
                this.fileViewRenderer.render();
                expect(this.fileViewRenderer.$('.name').text()).toEqual('file1');

                this.file.set({ name: 'new'});
                expect(this.fileViewRenderer.$('.name').text()).toEqual('new');
            });
        });
    });
    
    describe('FileRenderer', function () {
        beforeEach(function () {
            this.file1 = new BackboneFileDesc({
                name: 'file1',
                content: 'this is file 1',
                size: 0,
                type: 'text/plain',
                description: 'desc file 1',
                url: 'localhost/somedir',
                uploaded: true
            });

            this.file2 = new BackboneFileDesc({
                name: 'file2',
                content: 'this is file 2',
                size: 0,
                type: 'text/plain',
                description: 'desc file 2',
                uploaded: false
            });

            this.fileList = new BackboneFileList([
                this.file1,
                this.file2
            ]);

            this.appView = new UploadAppView({fileList: this.fileList});
        });
        
        describe('when instantiated', function () {
            it('should accept a BackboneFileList and render its elements', function () {
                var fileRenderer = new FileRenderer(this.fileList);
            });
            
            it('should set its file list as the provided one', function () {
                var fileRenderer = new FileRenderer(this.fileList);
                expect(fileRenderer.fileList).toBe(this.fileList);
            });
            
            it('should only render uploaded files', function () {
                var fileRenderer = new FileRenderer(this.fileList);
                expect(fileRenderer.$('div').length).toEqual(1);
            });
        });
        
        describe('when the collection is updated', function () {
            it('should update its view accordingly', function () {
                var fileRenderer = new FileRenderer(this.fileList);
                var file = new BackboneFileDesc({
                    name: 'file3',
                    content: 'this is file 3',
                    size: 0,
                    type: 'text/plain',
                    description: 'desc file 3',
                    url: 'localhost/somedir',
                    uploaded: true
                });
                this.fileList.add(file);
                expect(fileRenderer.$('div').length).toEqual(2);
                
                this.fileList.remove(file);
                expect(fileRenderer.$('div').length).toEqual(1);
            });
        });
    });
});