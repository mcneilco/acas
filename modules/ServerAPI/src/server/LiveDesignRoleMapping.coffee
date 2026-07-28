###
  Maps LiveDesign API role names to ACAS system roles.

  This module is intentionally not used by the legacy SAML login path.  A future
  LiveDesign-authorized SSO mode can call it after retrieving roles from
  LiveDesign without changing the existing IdP-role behavior.
###

parseMapping = (mapping) ->
	if typeof mapping is 'string'
		JSON.parse mapping
	else if Array.isArray mapping
		mapping
	else
		[]

exports.getManagedSystemRoleKeys = (mapping) ->
	new Set parseMapping(mapping).map (roleMapping) ->
		"#{roleMapping.lsKind}/#{roleMapping.roleName}"

exports.formatSystemRolesFromLiveDesignRoles = (liveDesignRoles, mapping) ->
	roles = new Set(liveDesignRoles ? [])

	parseMapping(mapping)
		.filter (roleMapping) -> roles.has(roleMapping.liveDesignRole)
		.map (roleMapping) ->
			lsType: 'System'
			lsKind: roleMapping.lsKind
			roleName: roleMapping.roleName

exports.getLiveDesignRoleApiUrl = (baseUrl, username) ->
	normalizedBaseUrl = baseUrl.replace(/\/+$/, '')
	unless normalizedBaseUrl.endsWith('/livedesign/api')
		normalizedBaseUrl += if normalizedBaseUrl.endsWith('/livedesign') then '/api' else '/livedesign/api'
	"#{normalizedBaseUrl}/roles/user/#{encodeURIComponent(username)}"
