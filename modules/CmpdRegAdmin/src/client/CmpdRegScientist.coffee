############################################################################
# models
############################################################################
class window.Scientist extends Backbone.Model
	urlRoot: "/api/cmpdRegAdmin/scientists"
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
					message: "Scientist code can not contain special characters"
		if !attrs.name? or attrs.name is ""
			errors.push
				attribute: 'scientistName'
				message: "Scientist name must be set and unique"
		if errors.length > 0
			return errors
		else
			return null

############################################################################
class window.Scientists extends Backbone.Collection
	model: Scientist
############################################################################

############################################################################
# controllers
############################################################################

class window.ScientistController extends AbstractCmpdRegAdminController
	wrapperTemplate: _.template($("#ScientistView").html())
	moduleLaunchName: "scientist"
	entityType: "scientist"
	entityTypePlural: "scientists"
	entityTypeUpper: "Scientist"
	entityTypeUpperPlural: "Scientists"
	modelClass: "Scientist"
	showIgnore: true

	completeInitialization: =>
		@errorOwnerName = 'ScientistController'
		$(@el).empty()
		$(@el).html @wrapperTemplate()
#		@$('.bv_scientistControllerDiv').html
		console.log @$('.bv_scientistControllerDiv')
		console.log "completing initialization of ScientistController"
		@$('.bv_scientistControllerDiv').html super()


class window.ScientistBrowserController extends AbstractCmpdRegAdminBrowserController
	wrapperTemplate: _.template($("#ScientistBrowserView").html())
	entityType: "scientist"
	entityTypePlural: "scientists"
	entityTypeUpper: "Scientist"
	entityTypeUpperPlural: "Scientists"
	entityClass: "Scientist"
	entityControllerClass: "ScientistController"
	moduleLaunchName: "scientist_browser"
	showIgnore: true
