$(function () {
    describe('New Lot Succsss Controller Unit Testing', function () {
		
		
        beforeEach(function () {
            this.fixture = $.clone($('#fixture').get(0));
        });
		
        afterEach(function () {
            $('#fixture').remove();
            $('body').append($(this.fixture));
        });
		
        /***********************************************/
		        
        describe('New Lot Success controller tests', function(){
            beforeEach(function() {
                this.nlsc = new NewLotSuccessController({
                    el: '.NewLotSuccessView',
                    corpName: "test-corp-name"
                });
                this.nlsc.render();
            });
            describe('When new controller created', function(){
                it('should display the new corpName', function() {
                   expect(this.nlsc.$('.corpName').html()).toEqual("test-corp-name"); 
                });
            });
        });
    });
});
