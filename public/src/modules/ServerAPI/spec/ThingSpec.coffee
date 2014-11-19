# Here is example usage
describe 'Thing testing', ->
	beforeEach ->
		@aviditySiRNA = new AviditySiRNA()

	describe 'Instantiation - defaultLabels', ->
		it 'should create a list of lsLabels based on the defaultLabels defined in Child Object', ->
			lsLabels = @aviditySiRNA.get("lsLabels")
			expect(lsLabels).toBeDefined()
			expect(lsLabels.length).toEqual 3

		it 'should create model attributes for each element in defaultLabels', ->
			expect(@aviditySiRNA.get("corpName")).toBeDefined()

		it 'should reference the lsLabel model objects stored in lsLabels as top lever model attributes', ->
			@aviditySiRNA.get("corpName").set("labelText", "newCorpName")
			corpNameLabel = @aviditySiRNA.get("lsLabels").getLabelByTypeAndKind("name", "corpName")[0]
			expect(corpNameLabel.get("labelText")).toEqual @aviditySiRNA.get("corpName").get("labelText")

		it 'should remove the top level label references when sync() is called', ->
			expect(@aviditySiRNA.get("corpName")).toBeDefined()
			@aviditySiRNA.sync()
			expect(@aviditySiRNA.get("corpName")).toBeUndefined()

		it 'should create top level label references when parse() is called / when the object is re-hyrdrated', ->
			newLabelText = "this is a new label"
			@aviditySiRNA.get("corpName").set("labelText", newLabelText)
			expect(@aviditySiRNA.get("corpName")).toBeDefined()

			@aviditySiRNA.sync()
			expect(@aviditySiRNA.get("corpName")).toBeUndefined()
			@aviditySiRNA.parse()
			expect(@aviditySiRNA.get("corpName")).toBeDefined()
			expect(@aviditySiRNA.get("corpName").get("labelText")).toEqual newLabelText