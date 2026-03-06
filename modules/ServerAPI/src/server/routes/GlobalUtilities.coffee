# Simple class to store acls
class Acls
	constructor: (read, write, del) ->
		this.read = read
		this.write = write
		this.delete = del

	getRead: ->
		return this.read

	getWrite: ->
		return this.write

	setRead: (read) ->
		this.read = read

	setWrite: (write) ->
		this.write = write

	getDelete: ->
		return this.delete
	
	setDelete: (del) ->
		this.delete = del

global.Acls = Acls;

global.loginRoutes = require("../routes/loginRoutes")


global.testUserHasRoleTypeKindName = (user, roleInfo) ->
	#roleInfo = list of objects with role type, kind, and name
	if not user.roles? then return false
	if not roleInfo? || roleInfo.length == 0 then return true
	match = false
	for role in roleInfo
		for userRole in user.roles
			if userRole.roleEntry.lsType == role.lsType and userRole.roleEntry.lsKind == role.lsKind and userRole.roleEntry.roleName == role.roleName
				match = true

	match