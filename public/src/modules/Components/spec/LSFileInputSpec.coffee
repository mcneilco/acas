describe 'LS File Input Behavior Testing', ->
	beforeEach ->
		@fixture = $.clone($('#fixture').get(0));

	afterEach ->
		$('#fixture').remove();
		$('body').append($(@fixture));

	describe 'LSFileInput Controller', ->
		describe 'when instantiated', ->
			beforeEach ->
				@echoFileController = new LSFileInputController
						el: '#fixture',
						inputTitle: 'Test File'
						url: "http://"+window.conf.host+":"+window.conf.service.file.port
						fieldIsRequired: true
				@echoFileController.render()

			it 'should load template', ->
				expect(@echoFileController.$('.bv_container').prop("tagName")).toEqual "DIV"
				expect(@echoFileController.$('.bv_fileChooserContainer').prop("tagName")).toEqual "DIV"
			it 'should show the correct title', ->
				expect(@echoFileController.$('.bv_fileInputTitle h4').html()).toContain "Test File"
			it 'should show that file is required', ->
				expect(@echoFileController.$('.bv_fileInputTitle h4').html()).toContain "*"

