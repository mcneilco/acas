$(function () {
	beforeEach(function () {
		this.fixture = $.clone($('#fixture').get(0));
	});
	
	afterEach(function () {
		$('#fixture').remove();
		$('body').append($(this.fixture));
	});
});