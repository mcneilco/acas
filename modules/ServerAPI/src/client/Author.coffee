
window.getAuthorModulePreferences = (userName, moduleName, callback) ->
	$.ajax
		type: 'GET'
		url: "/api/authorModulePreferences/#{userName}/#{moduleName}"
		dataType: 'json'
		cache: false
		error: (err) ->
			callback 'Could not get module preferences', 500
		success: (json, statusMessage, response) =>
				callback json, response.status

window.updateAuthorModulePreferences = (userName, moduleName, preferences, callback) ->
	$.ajax
		type: 'PUT'
		url: "/api/authorModulePreferences/#{userName}/#{moduleName}"
		data: preferences
		dataType: 'json'
		contentType: 'application/json'
		error: (err) ->
			callback 'Could not get module preferences', 500
		success: (json, statusMessage, response) =>
			callback json, response.status
