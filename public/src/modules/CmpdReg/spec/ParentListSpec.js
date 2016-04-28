$(function () {
	describe('ParentList Unit Testing', function () {
		
		beforeEach(function () {
			this.fixture = $.clone($('#fixture').get(0));
		});
		
		afterEach(function () {
			$('#fixture').remove();
			$('body').append($(this.fixture));
		});
		
		/***********************************************/
		
		describe('ParentListController ', function() {
            beforeEach(function () {
                this.parentList = window.step2JSON.parents;
                this.parentListCont = new ParentListController({
                    json: this.parentList
                });
                $("#ParentListControllerView").append(this.parentListCont.render().el);
            });
            
            describe('when rendered with populated list', function() {
                it('It should show parents',function() {
                    expect(this.parentListCont.$('.RegSearchResults_ParentView').length).toEqual(2);
                });
                it('the first parent should show two saltForms', function() {
                    if (window.configuration.metaLot.saltBeforeLot) {
                        expect(this.parentListCont.$('.saltFormCorpNames:eq(0) option').length).toEqual(3);
                    }
                });
            });
            describe('when parent selected with new salt', function() {
                it('should return selected metalot', function() {
                    this.parentListCont.$('.RegSearchResults_ParentView:eq(1) .regPick').attr('checked', true);;
                    var ml = this.parentListCont.getSelectedMetaLot();
                    expect(ml.get('parent').get('corpName')).toEqual('SGD-0002');
                });
            });
        });
    });
});
