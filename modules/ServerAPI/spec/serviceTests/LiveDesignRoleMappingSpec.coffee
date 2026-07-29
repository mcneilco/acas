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
		expectedMapping = '[{"liveDesignRole":"AcasUser","lsKind":"ACAS","roleName":"ROLE_ACAS-USERS"},{"liveDesignRole":"AcasAdministrator","lsKind":"ACAS","roleName":"ROLE_ACAS-ADMINS"},{"liveDesignRole":"AcasAdministrator","lsKind":"ACAS","roleName":"ROLE_ACAS-USERS"},{"liveDesignRole":"CregUser","lsKind":"CmpdReg","roleName":"ROLE_CMPDREG-USERS"},{"liveDesignRole":"CregAdministrator","lsKind":"CmpdReg","roleName":"ROLE_CMPDREG-ADMINS"},{"liveDesignRole":"CregAdministrator","lsKind":"CmpdReg","roleName":"ROLE_CMPDREG-USERS"},{"liveDesignRole":"CregReadOnly","lsKind":"CmpdReg","roleName":"ROLE_CMPDREG-READONLY"},{"liveDesignRole":"AcasCrossProjectLoader","lsKind":"ACAS","roleName":"ROLE_ACAS-CROSS-PROJECT-LOADER"}]'

		assert.ok configExample.includes("server.security.saml.liveDesignRoleToSystemRoles=#{expectedMapping}")

	it 'maps configured LiveDesign roles without adding unmapped roles', ->
		mapping = JSON.parse '[{"liveDesignRole":"AcasUser","lsKind":"ACAS","roleName":"ROLE_ACAS-USERS"},{"liveDesignRole":"CregReadOnly","lsKind":"CmpdReg","roleName":"ROLE_CMPDREG-READONLY"},{"liveDesignRole":"AcasCrossProjectLoader","lsKind":"ACAS","roleName":"ROLE_ACAS-CROSS-PROJECT-LOADER"}]'

		assert.deepEqual liveDesignRoleMapping.formatSystemRolesFromLiveDesignRoles(['AcasUser', 'CregReadOnly', 'UnknownRole'], mapping), [
			lsType: 'System'
			lsKind: 'ACAS'
			roleName: 'ROLE_ACAS-USERS'
		,
			lsType: 'System'
			lsKind: 'CmpdReg'
			roleName: 'ROLE_CMPDREG-READONLY'
		]

	it 'maps administrator roles to their required user roles without duplicates', ->
		mapping = JSON.parse '[{"liveDesignRole":"AcasUser","lsKind":"ACAS","roleName":"ROLE_ACAS-USERS"},{"liveDesignRole":"AcasAdministrator","lsKind":"ACAS","roleName":"ROLE_ACAS-ADMINS"},{"liveDesignRole":"AcasAdministrator","lsKind":"ACAS","roleName":"ROLE_ACAS-USERS"},{"liveDesignRole":"CregUser","lsKind":"CmpdReg","roleName":"ROLE_CMPDREG-USERS"},{"liveDesignRole":"CregAdministrator","lsKind":"CmpdReg","roleName":"ROLE_CMPDREG-ADMINS"},{"liveDesignRole":"CregAdministrator","lsKind":"CmpdReg","roleName":"ROLE_CMPDREG-USERS"}]'

		assert.deepEqual liveDesignRoleMapping.formatSystemRolesFromLiveDesignRoles(['AcasUser', 'AcasAdministrator', 'CregAdministrator'], mapping), [
			lsType: 'System'
			lsKind: 'ACAS'
			roleName: 'ROLE_ACAS-USERS'
		,
			lsType: 'System'
			lsKind: 'ACAS'
			roleName: 'ROLE_ACAS-ADMINS'
		,
			lsType: 'System'
			lsKind: 'CmpdReg'
			roleName: 'ROLE_CMPDREG-ADMINS'
		,
			lsType: 'System'
			lsKind: 'CmpdReg'
			roleName: 'ROLE_CMPDREG-USERS'
		]
