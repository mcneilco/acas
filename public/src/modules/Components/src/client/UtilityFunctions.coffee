class window.UtilityFunctions
	getFileServiceURL: ->
		"/uploads"


	testUserHasRole: (user, roleNames) ->
		if not user.roles? then return true

		match = false
		for roleName in roleNames
			for role in user.roles
				if role.roleEntry.roleName == roleName then match = true

		match


	showProgressModal: (node) ->
		node.modal
			backdrop: "static"
		node.modal "show"

	hideProgressModal: (node) ->
		node.modal "hide"