# Abstract model for any DDict CodeTable
class AbstractCodeTable extends Backbone.Model
	# Class attributes to be set when extending this class
	codeType: null
	codeKind: null
	codeOrigin: 'ACAS DDict'
	# Required attributes for every instance
	defaults:
		name: null
		code: null
		id: null
		ignored: false
	
	titleCase: (str) ->
		return str.replace(/\w\S*/g, (txt) -> txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase())
	
	initialize: (options) ->
		# Default values format the codeType and codeKind into display names and assume "s" for plural
		codeType = @codeType
		codeKind = @codeKind
		@urlRoot = "/api/codeTablesAdmin/#{codeType}/#{codeKind}"
		@displayName = codeKind
		@pluralDisplayName = codeKind + "s"
		@upperDisplayName = @titleCase(codeKind)
		@upperPluralDisplayName = @titleCase(codeKind) + "s"
		# In case any of the defaults are wrong for a use case, allow overrides
		if options?.urlRoot?
			@urlRoot = options.urlRoot
		if options?.displayName?
			@displayName = options.displayName
		if options?.pluralDisplayName?
			@pluralDisplayName = options.pluralDisplayName
		if options?.upperDisplayName?
			@upperDisplayName = options.upperDisplayName
	
	validate: (attrs) ->
		errors = []
		if attrs.code? and @isNew()
			validChars = attrs.code.match(/[a-zA-Z0-9 _\-+]/g)
			if !validChars? || validChars.length != attrs.code.length
				errors.push
					attribute: 'codeTablesAdminCode'
					message: "#{@upperDisplayName} Code can not contain special characters"
		if !attrs.code? or attrs.code is ""
			errors.push
				attribute: 'codeTablesAdminCode'
				message: "#{@upperDisplayName} Code must be set and unique"
		if !attrs.name? or attrs.name is ""
			errors.push
				attribute: 'codeTablesAdminName'
				message: "#{@upperDisplayName} Name must be set and unique"
		if errors.length > 0
			return errors
		else
			return null