$(function () {
	describe('SaltFormList Unit Testing', function () {
		
		/* 
		 * We have to take care manually of the DOM fixture
		 * This should be put in a separate file like SpecHelper.js
		 */ 
		 
		/* The styling for the fixture elements is in the NewCmpdReg.css */
		
		beforeEach(function () {
			this.fixture = $.clone($('#fixture').get(0));
		});
		
		afterEach(function () {
			$('#fixture').remove();
			$('body').append($(this.fixture));
		});
		
		/***********************************************/
        

		
		describe('SaltFormSelectController ', function() {
            beforeEach(function () {
                this.sfJSONList = window.step2JSON.parents[0].saltForms;
                this.sfList = new Backbone.Collection();
                var sfl = this.sfList;
                var self = this;
                _.each(this.sfJSONList, function(sfj) {
                    sfl.add( new SaltForm({json: sfj}));
                });
                this.sfListCont = new SaltFormSelectController({
                    el:"#SaltFormListControllerView",
                    collection: this.sfList
                });
                this.sfListCont.render();
            });
            
            describe('when rendered with populated list', function() {
                it('It should show salt forms',function() {
                    //console.log($('#SaltFormListControllerView option').length);
                    expect($('#SaltFormListControllerView option').length).toEqual(3);
                });
            });
            describe('when no salt selected', function() {
                it(' should return null', function() {
                    $('#SaltFormListControllerView option')[0].selected = true;
                    expect(this.sfListCont.getSelectedSaltForm()).toBeNull();
                });
            });
            describe('when salt selected', function() {
                it(' should return null', function() {
                    $('#SaltFormListControllerView option')[1].selected = true;
                    expect(this.sfListCont.getSelectedSaltForm().get('corpName')).toEqual('CMPD-0001-C14Na');
                });
            });
        });
    });
});
