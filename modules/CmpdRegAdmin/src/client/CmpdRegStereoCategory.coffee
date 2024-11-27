############################################################################
# models
############################################################################
class StereoCategory extends AbstractCodeTable
	codeType: 'cmpdRegAdmin'
	codeKind: 'stereoCategory'

	initialize: (options) ->
		@options = options
		options = 
			urlRoot: "/api/cmpdRegAdmin/stereoCategories"
			deleteUrlRoot: "/api/cmpdRegAdmin/stereoCategories"
			displayName: 'stereo category'
			pluralDisplayName: 'stereo categories'
		super(options)

############################################################################
# controllers
############################################################################

class StereoCategoryController extends AbstractCodeTablesAdminController
	htmlViewId: "#StereoCategoryView"
	htmlDivSelector: '.bv_stereoCategoryControllerDiv'
	modelClass: "StereoCategory"
	showIgnore: false


class StereoCategoryBrowserController extends AbstractCodeTablesAdminBrowserController
	htmlViewId: "#StereoCategoryBrowserView"
	entityClass: "StereoCategory"
	entityControllerClass: "StereoCategoryController"
	moduleLaunchName: "stereo_category_browser"
	showIgnore: false