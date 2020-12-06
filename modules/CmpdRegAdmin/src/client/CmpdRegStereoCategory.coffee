############################################################################
# models
############################################################################
class window.StereoCategory extends Backbone.Model
	urlRoot: "/api/cmpdRegAdmin/stereoCategories"
	defaults:
		name: null
		code: null
		id: null

	validate: (attrs) ->
		errors = []
		if attrs.code? and @isNew()
			validChars = attrs.code.match(/[a-zA-Z0-9 _\-+]/g)
			unless validChars.length is attrs.code.length
				errors.push
					attribute: 'code'
					message: "Stereo Category code can not contain special characters"
		if !attrs.name? or attrs.name is ""
			errors.push
				attribute: 'name'
				message: "Stereo Category name must be set and unique"
		if errors.length > 0
			return errors
		else
			return null

############################################################################
class window.StereoCategories extends Backbone.Collection
	model: StereoCategory
############################################################################

############################################################################
# controllers
############################################################################

class window.StereoCategoryController extends AbstractCmpdRegAdminController
	wrapperTemplate: _.template($("#StereoCategoryView").html())
	moduleLaunchName: "stereo_category"
	entityType: "stereoCategory"
	entityTypePlural: "stereoCategories"
	entityTypeToDisplay: "stereo category"
	entityTypePluralToDisplay: "stereo categories"
	entityTypeUpper: "Stereo Category"
	entityTypeUpperPlural: "Stereo Categories"
	modelClass: "StereoCategory"
	showIgnore: false

	completeInitialization: =>
		@errorOwnerName = 'StereoCategoryController'
		$(@el).empty()
		$(@el).html @wrapperTemplate()
		@$('.bv_stereoCategoryControllerDiv').html super()


class window.StereoCategoryBrowserController extends AbstractCmpdRegAdminBrowserController
	wrapperTemplate: _.template($("#StereoCategoryBrowserView").html())
	entityType: "stereoCategory"
	entityTypePlural: "stereoCategories"
	entityTypeToDisplay: "stereo category"
	entityTypePluralToDisplay: "stereo categories"
	entityTypeUpper: "Stereo Category"
	entityTypeUpperPlural: "Stereo Categories"
	entityClass: "StereoCategory"
	entityControllerClass: "StereoCategoryController"
	moduleLaunchName: "stereo_category_browser"
	showIgnore: false