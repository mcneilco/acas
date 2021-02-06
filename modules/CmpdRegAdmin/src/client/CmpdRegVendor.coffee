############################################################################
# models
############################################################################
class Vendor extends Backbone.Model
	urlRoot: "/api/cmpdRegAdmin/vendors"
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
					attribute: 'vendorCode'
					message: "Vendor code can not contain special characters"
		if !attrs.name? or attrs.name is ""
			errors.push
				attribute: 'vendorName'
				message: "Vendor name must be set and unique"
		if errors.length > 0
			return errors
		else
			return null

############################################################################
class Vendors extends Backbone.Collection
	model: Vendor
############################################################################

############################################################################
# controllers
############################################################################

class VendorController extends AbstractCmpdRegAdminController
	wrapperTemplate: _.template($("#VendorView").html())
	moduleLaunchName: "vendor"
	entityType: "vendor"
	entityTypePlural: "vendors"
	entityTypeUpper: "Vendor"
	entityTypeUpperPlural: "Vendors"
	modelClass: "Vendor"
	showIgnore: false

	completeInitialization: =>
		@errorOwnerName = 'VendorController'
		$(@el).empty()
		$(@el).html @wrapperTemplate()
#		@$('.bv_vendorControllerDiv').html
		console.log @$('.bv_vendorControllerDiv')
		console.log "completing initialization of VendorController"
		@$('.bv_vendorControllerDiv').html super()


class VendorBrowserController extends AbstractCmpdRegAdminBrowserController
	wrapperTemplate: _.template($("#VendorBrowserView").html())
	entityType: "vendor"
	entityTypePlural: "vendors"
	entityTypeUpper: "Vendor"
	entityTypeUpperPlural: "Vendors"
	entityClass: "Vendor"
	entityControllerClass: "VendorController"
	moduleLaunchName: "vendor_browser"
	showIgnore: false
