############################################################################
# models
############################################################################
class Vendor extends AbstractCodeTable
	codeType: 'cmpdRegAdmin'
	codeKind: 'vendor'

	initialize: ->
		options = 
			urlRoot: "/api/cmpdRegAdmin/vendors"
			deleteUrlRoot: "/api/cmpdRegAdmin/vendors"
		super(options)

############################################################################
# controllers
############################################################################

class VendorController extends AbstractCodeTablesAdminController
	htmlViewId: "#VendorView"
	htmlDivSelector: '.bv_vendorControllerDiv'
	modelClass: "Vendor"


class VendorBrowserController extends AbstractCodeTablesAdminBrowserController
	htmlViewId: "#VendorBrowserView"
	entityClass: "Vendor"
	entityControllerClass: "VendorController"
	moduleLaunchName: "vendor_browser"
	showIgnore: false