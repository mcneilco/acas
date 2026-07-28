assert = require 'assert'
fs = require 'fs'
path = require 'path'

acasHome = path.resolve __dirname, '../../../..'
configExamplePath = path.join acasHome, 'conf/config.properties.example'
liveDesignRoleMapping = require "#{acasHome}/src/javascripts/ServerAPI/LiveDesignRoleMapping.js"

describe 'LiveDesign SSO role mapping configuration', ->
	it 'keeps IdP roles as the default source', ->
		configExample = fs.readFileSync configExamplePath, 'utf8'
		assert.ok configExample.includes('server.security.saml.roles.source=idp')

	it 'documents an opt-in mapping for all ACAS roles LiveDesign can manage', ->
		configExample = fs.readFileSync configExamplePath, 'utf8'
		expectedMapping = '[{"liveDesignRole":"ACAS_USER","lsKind":"ACAS","roleName":"ROLE_ACAS-USERS"},{"liveDesignRole":"ACAS_ADMINISTRATOR","lsKind":"ACAS","roleName":"ROLE_ACAS-ADMINS"},{"liveDesignRole":"CREG_USER","lsKind":"CmpdReg","roleName":"ROLE_CMPDREG-USERS"},{"liveDesignRole":"CREG_ADMINISTRATOR","lsKind":"CmpdReg","roleName":"ROLE_CMPDREG-ADMINS"},{"liveDesignRole":"CREG_READ_ONLY","lsKind":"CmpdReg","roleName":"ROLE_CMPDREG-READONLY"},{"liveDesignRole":"ACAS_CROSS_PROJECT_LOADER","lsKind":"ACAS","roleName":"ROLE_ACAS-CROSS-PROJECT-LOADER"}]'

		assert.ok configExample.includes("server.security.saml.liveDesignRoleToSystemRoles=#{expectedMapping}")

	it 'maps configured LiveDesign roles without adding unmapped roles', ->
		mapping = JSON.parse '[{"liveDesignRole":"ACAS_USER","lsKind":"ACAS","roleName":"ROLE_ACAS-USERS"},{"liveDesignRole":"CREG_READ_ONLY","lsKind":"CmpdReg","roleName":"ROLE_CMPDREG-READONLY"},{"liveDesignRole":"ACAS_CROSS_PROJECT_LOADER","lsKind":"ACAS","roleName":"ROLE_ACAS-CROSS-PROJECT-LOADER"}]'

		assert.deepEqual liveDesignRoleMapping.formatSystemRolesFromLiveDesignRoles(['ACAS_USER', 'CREG_READ_ONLY', 'UnknownRole'], mapping), [
			lsType: 'System'
			lsKind: 'ACAS'
			roleName: 'ROLE_ACAS-USERS'
		,
			lsType: 'System'
			lsKind: 'CmpdReg'
			roleName: 'ROLE_CMPDREG-READONLY'
		]

	it 'builds the LiveDesign role API URL for a base installation URL', ->
		assert.equal liveDesignRoleMapping.getLiveDesignRoleApiUrl('https://ld.example', 'sam+user'), 'https://ld.example/livedesign/api/roles/user/sam%2Buser'
