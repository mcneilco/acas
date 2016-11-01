class window.UtilityFunctions
	getFileServiceURL: ->
		"/uploads"


	testUserHasRole: (user, roleNames) ->
		if not user.roles? then return true
		if not roleNames? || roleNames.length == 0 then return true
		match = false
		for roleName in roleNames
			if !roleName?
				return true
			for role in user.roles
				if role.roleEntry.roleName == roleName then match = true

		match

	testUserHasRoleTypeKindName: (user, roleInfo) ->
		#roleInfo = list of objects with role type, kind, and name
		if not user.roles? then return true
		if not roleInfo? || roleNames.length == 0 then return true
		match = false
		for role in roleInfo
			for userRole in user.roles
				if userRole.roleEntry.lsType == role.lsType and userRole.roleEntry.lsKind == role.lsKind and userRole.roleEntry.roleName == role.roleName
					match = true

		match

	showProgressModal: (node) ->
		node.modal
			backdrop: "static"
		node.modal "show"

	hideProgressModal: (node) ->
		node.modal "hide"

	getTrimmedInput: (selector) ->
		$.trim(selector.val())

	convertYMDDateToMs: (inStr) ->
		dateParts = inStr.split('-')
		new Date(dateParts[0], dateParts[1]-1, dateParts[2]).getTime()

	convertMSToYMDDate: (ms) ->
		date = new Date ms
		monthNum = date.getMonth()+1
		date.getFullYear()+'-'+("0" + monthNum).slice(-2)+'-'+("0" + date.getDate()).slice(-2)

	convertTextAreaToDiv: (controller) =>
		for textarea in controller.$('textarea')
			text = $(textarea).val().replace(/\r?\n/g,'<br/>')
			$(textarea).after '<div style="width:650px; border:1px solid #cccccc; padding:6px;margin-bottom:20px;">'+text+'</div>'
			$(textarea).hide()

	showInactiveTabsInfoToPrint: (controller) =>
		for tab in controller.$('.tab-pane')
			for tabHeader in controller.$('.nav-tabs li a')
				#find tab header
				if $(tabHeader).attr("href") is "#"+$(tab).attr('id')
					if $(tab).hasClass "active"
						controller.$('.tab-pane.active').prepend '<div class="span12" style="margin-left:0px;"><h3>'+$(tabHeader).html()+'</h3></div>'
					else
						controller.$('.tab-pane.active').append '<hr class="span12" style="margin-left:0px;"/>'
						controller.$('.tab-pane.active').append '<div class="span12" style="margin-left:0px;"><h3>'+$(tabHeader).html()+'</h3></div>'
						controller.$('.tab-pane.active').append $(tab).html()
		controller.$('.nav.nav-tabs').hide()
