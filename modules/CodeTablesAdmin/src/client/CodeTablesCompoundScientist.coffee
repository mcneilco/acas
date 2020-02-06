############################################################################
# models
############################################################################
class window.CompoundScientist extends Backbone.Model
	urlRoot: "/api/codeTablesAdmin/compound/scientist"
	defaults:
		name: null
		code: null
		id: null
		ignored: false

	validate: (attrs) ->
		errors = []
		if attrs.code? and @isNew()
			validChars = attrs.code.match(/[a-zA-Z0-9 _\-+]/g)
			unless validChars.length is attrs.code.length
				errors.push
					attribute: 'scientistCode'
					message: "Compound Scientist code can not contain special characters"
		if !attrs.code? or attrs.code is ""
			errors.push
				attribute: 'scientistCode'
				message: "Compound Scientist code must be set and unique"
		if !attrs.name? or attrs.name is ""
			errors.push
				attribute: 'scientistName'
				message: "Compound Scientist name must be set and unique"
		if errors.length > 0
			return errors
		else
			return null

############################################################################
# controllers
############################################################################

class window.CompoundScientistController extends AbstractCodeTablesAdminController
	wrapperTemplate: _.template($("#CompoundScientistView").html())
	moduleLaunchName: "scientist"
	codeType: "compound"
	codeKind: "scientist"
	displayName: "compound scientist"
	pluralDisplayName: "compound scientists"
	upperDisplayName: "Compound Scientist"
	upperPluralDisplayName: "Scientists"
	modelClass: "CompoundScientist"
	showIgnore: true

	completeInitialization: =>
		@errorOwnerName = 'CompoundScientistController'
		$(@el).empty()
		$(@el).html @wrapperTemplate()
		console.log @$('.bv_compoundCompoundScientistControllerDiv')
		console.log "completing initialization of CompoundScientistController"
		@$('.bv_compoundCompoundScientistControllerDiv').html super()


class window.CompoundScientistBrowserController extends AbstractCodeTablesAdminBrowserController
	wrapperTemplate: _.template($("#CompoundScientistBrowserView").html())
	codeType: "compound"
	codeKind: "scientist"
	displayName: "compound scientist"
	pluralDisplayName: "compound scientists"
	upperDisplayName: "Compound Scientist"
	upperPluralDisplayName: "Compound Scientists"
	entityClass: "CompoundScientist"
	entityControllerClass: "CompoundScientistController"
	moduleLaunchName: "compound_scientist_browser"
	showIgnore: true
