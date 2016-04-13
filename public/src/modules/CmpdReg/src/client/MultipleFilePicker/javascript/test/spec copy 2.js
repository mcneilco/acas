$(function () {	
	describe('when first saved', function () {
			
		it('is should be correctly updated', function () {
			var fileName = 'fileName';
			var fileContent = 'filecontent';
			var fileSize = 0;
			var fileType = 'filetype';
				
			var file = new BackboneFile({
				name: fileName,
				content: fileContent,
				size: fileSize,
				type: fileType
			});
			
			var flag = false;
			
			expect(file.get('id')).toBeUndefined();
			expect(file.get('uploaded')).toBeFalsy();
				
			runs(function () {
				file.save({}, { error: function (model, response) {
					flag = true;
				}, success: function (model, response) {
					flag = true;
				}});
			});
				
			waits(500);
				
			runs(function () {
				expect(flag).toBeTruthy();
				expect(file.get('id')).toBeDefined();
				expect(file.get('url')).toBeDefined();
				expect(file.get('uploaded')).toBeTruthy();
				
				// The file size should be updated to the
				// real size on the server
				expect(file.get('size')).not.toEqual(fileSize);
				
				// The file mimetype should be updated to
				// the real mimetype on the server
				expect(file.get('type')).not.toEqual(fileType);
				console.log(file);
			});
		});		
	});
});