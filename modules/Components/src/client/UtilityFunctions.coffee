class UtilityFunctions
	getFileServiceURL: ->
		"/uploads"


	testUserHasRole: (user, roleNames) ->
		if not user.roles? then return false
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
		if not user.roles? then return false
		if not roleInfo? || roleInfo.length == 0 then return true
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

	convertMSToYMDTimeDate: (ms, timeFormat) ->
		date = new Date ms
		monthNum = date.getMonth()+1
		formattedDate = date.getFullYear()+'-'+("0" + monthNum).slice(-2)+'-'+("0" + date.getDate()).slice(-2) + " "

		hours = date.getHours()
		hours = ("0"+hours).slice(-2)
		minutes = date.getMinutes()
		minutes = ("0"+minutes).slice(-2)
		unless timeFormat?
			#default time format = 24 hr clock
			timeFormat = "24hr"
		if timeFormat is "12hr"
			if parseInt(hours) > 12
				hours = hours-12
				hours = ("0"+hours).slice(-2)
				period = "PM"
			else
				period = "AM"
			formattedDate += "#{hours}:#{minutes} #{period}"
		else
			formattedDate += "#{hours}:#{minutes}"

		return formattedDate

	convertTextAreaToDiv: (controller) =>
		for textarea in controller.$('textarea')
			text = $(textarea).val().replace(/\r?\n/g,'<br/>')
			$(textarea).after '<div style="width:650px; border:1px solid #cccccc; padding:6px;margin-bottom:20px;">'+text+'</div>'
			$(textarea).hide()
		
	setInputsWidthToValue: (controller) =>
		# increase size of text boxes to fit data
		for node in controller.$('input[type="text"]')
			minWidth = parseInt(getComputedStyle(node).minWidth) or node.clientWidth
			node.style.overflowX = 'auto'
			node.style.width = minWidth + 'px'
			node.style.width = node.scrollWidth + 'px'

	showInactiveTabsInfoToPrint: (controller) =>
		for tab in controller.$('.tab-pane')
			for tabHeader in controller.$('.nav-tabs li a')
				#find tab header
				if $(tabHeader).attr("href") is "#"+$(tab).attr('id')
					if $(tab).hasClass "active"
						controller.$('.tab-pane.active').prepend '<div class="col-md-12" style="margin-left:0px;"><h3>'+$(tabHeader).html()+'</h3></div>'
					else
						controller.$('.tab-pane.active').append '<hr class="col-md-12" style="margin-left:0px;"/>'
						controller.$('.tab-pane.active').append '<div class="col-md-12" style="margin-left:0px;"><h3>'+$(tabHeader).html()+'</h3></div>'
						controller.$('.tab-pane.active').append $(tab).html()
		controller.$('.nav.nav-tabs').hide()

	roundTwoDecimalPlaces: (num) ->
		if isNaN(num) or num is null
			return null
		else
			return Math.round((num+0.00001)*100)/100

	roundThreeDecimalPlaces: (num) ->
		if isNaN(num)
			return 0
		else
			return Math.round((num+0.000001)*1000)/1000
	
	getNameForCode: (value, codeToLookup, pickLists) ->
		if pickLists[value.get('lsKind')]?
			code = pickLists[value.get('lsKind')].findWhere({code: codeToLookup})
			name = if code? then code.get 'name' else "not found"
			return name
		else
			console.log "can't find entry in pickLists hash for: "+value.get('lsKind')
			console.dir pickLists
			return "not found"

	openURL: (url) ->
		a = document.createElement 'a'
		a.style.display = 'none'
		a.target = '_blank'
		a.href = url;
		document.body.appendChild a
		a.click()
		document.body.removeChild a

	getNewSystemChemicalSketcherController: (sketcher) ->
		# Chemical Structure Controller Set by Sketcher Config Setting 
		chemicalStructureController = null
		if sketcher == 'marvin'
			chemicalStructureController = new MarvinJSChemicalStructureController
		else if  sketcher  == 'ketcher'
			chemicalStructureController = new KetcherChemicalStructureController 
		else if sketcher == 'maestro'
			chemicalStructureController = new MaestroChemicalStructureController
		else 
			console.log("No Chemical Sketcher Configured!")
			alert("Please contact your ACAS System Admin. There is no chemical sketcher configured.")
		return chemicalStructureController
