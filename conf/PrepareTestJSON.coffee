fs = require 'fs'
glob = require 'glob'

allFiles = glob.sync "../public/javascripts/spec/testFixtures/*.js"
for fileName in allFiles
	data = require fileName
	jsonfilestring = JSON.stringify data
	newFileName = fileName.replace "testFixtures","TestJSON"
	newFileName = newFileName.replace ".js", ".json"
	fs.writeFileSync newFileName, jsonfilestring



