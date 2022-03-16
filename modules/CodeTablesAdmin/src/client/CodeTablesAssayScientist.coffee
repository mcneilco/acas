############################################################################
# models
############################################################################
class AssayScientist extends Backbone.Model
	urlRoot: "/api/codeTablesAdmin/assay/scientist"
	defaults:
		name: null
		code: null
		id: null
		ignored: false

	validate: (attrs) ->
		errors = []
		if attrs.code? and @isNew()
			validChars = attrs.code.match(/[a-zA-Z0-9 _\-+]/g)
			if !validChars? || validChars.length != attrs.code.length
				errors.push
					attribute: 'codeTablesAdminCode'
					message: "Assay Scientist code can not contain special characters"
		if !attrs.code? or attrs.code is ""
			errors.push
				attribute: 'codeTablesAdminCode'
				message: "Assay Scientist code must be set and unique"
		if !attrs.name? or attrs.name is ""
			errors.push
				attribute: 'codeTablesAdminName'
				message: "Assay Scientist name must be set"
		if errors.length > 0
			return errors
		else
			return null

############################################################################
# controllers
############################################################################

class AssayScientistController extends AbstractCodeTablesAdminController
	wrapperTemplate: _.template($("#AssayScientistView").html())
	moduleLaunchName: "scientist"
	codeType: "assay"
	codeKind: "scientist"
	displayName: "assay scientist"
	pluralDisplayName: "assay scientists"
	upperDisplayName: "Assay Scientist"
	upperPluralDisplayName: "Scientists"
	modelClass: "AssayScientist"
	showIgnore: true

	completeInitialization: =>
		@errorOwnerName = 'AssayScientistController'
		$(@el).empty()
		$(@el).html @wrapperTemplate()
		console.log @$('.bv_assayAssayScientistControllerDiv')
		console.log "completing initialization of AssayScientistController"
		@$('.bv_assayAssayScientistControllerDiv').html super()


class AssayScientistBrowserController extends AbstractCodeTablesAdminBrowserController
	wrapperTemplate: _.template($("#AssayScientistBrowserView").html())
	codeType: "assay"
	codeKind: "scientist"
	displayName: "assay scientist"
	pluralDisplayName: "assay scientists"
	upperDisplayName: "Assay Scientist"
	upperPluralDisplayName: "Assay Scientists"
	entityClass: "AssayScientist"
	entityControllerClass: "AssayScientistController"
	moduleLaunchName: "assay_scientist_browser"
	showIgnore: true
