describe 'Internalization Agent testing', ->
	describe "When created from existing", ->
		beforeEach ->
#			@iaParent = new InternalizationAgentParent()
			@iaParent = new InternalizationAgentParent JSON.parse(JSON.stringify(window.internalizationAgentTestJSON.internalizationAgentParent))
		describe "Existence and Defaults", ->
			it "should be defined", ->
				console.log @iaParent
				expect(@iaParent).toBeDefined()