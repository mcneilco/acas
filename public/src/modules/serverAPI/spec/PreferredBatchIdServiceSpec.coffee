# PreferredBatchIdServiceSpec.coffee
#
#
# John McNeil
# john@mcneilco.com
#
#
# Copyright 2012 John McNeil & Co. Inc.
#########################################################################
# Spec for service that takes batch id (corporate batch names) and return
# the preferred id, or "" if there are none
#
# This will be implemented as a node service which is modified to query the
# the underlying compound registration system
#
# It is not an error in the service if the batch doesn't exist. Rather,
# the individual entry returns no preferred id
#########################################################################
describe 'PreferredBatchId Service testing', ->
	beforeEach ->
		@waitForServiceReturn = ->
			typeof @serviceReturn != 'undefined'

		serviceType = window.configurationNode.serverConfigurationParams.configuration.externalPreferredBatchIdServiceType
		if not window.AppLaunchParams.liveServiceTest
			# Test stub service
			@requestData =
				requests: [
					{requestName: "norm_1234:1"} # easter egg prefix in test service that returns same value
					{requestName: "alias_1111:1"} # easter egg prefix in test service that returns alias
					{requestName: "none_2222:1"} # easter egg prefix in test service that returns none
				]
			@expectedResponse =
				error: false
				errorMessages: []
				results: [
						requestName: "norm_1234:1"
						preferredName: "norm_1234:1"
					,
						requestName: "alias_1111:1"
						preferredName: "norm_1111:1A"
					,
						requestName: "none_2222:1"
						preferredName: ""
				]
		else if serviceType == "LabSynchCmpdReg"
			@requestData =
				requests: [
					{requestName: "CMPD-0000001-01"}
					{requestName: "none_2222:1"} # labsynch cmpd reg doesn't do aliases currently
				]
			@expectedResponse =
				error: false
				errorMessages: []
				results: [
					requestName: "CMPD-0000001-01"
					preferredName: "CMPD-0000001-01"
				,
					requestName: "none_2222:1"
					preferredName: ""
				]
		else if serviceType == "SingleBatchNameQueryString"
			@requestData =
				requests: [
					{requestName: "DNS000000001::1"} #normal
					{requestName: "DNS000673874::1"} #alias
					{requestName: "none_2222:1"} #none
				]
			@expectedResponse =
				error: false
				errorMessages: []
				results: [
					requestName: "DNS000000001::1"
					preferredName: "DNS000000001::1"
				,
					requestName: "DNS000673874::1"
					preferredName: "DNS000001234::7"
				,
					requestName: "none_2222:1"
					preferredName: ""
				]

	describe 'get preferred batch id service', ->
		describe 'when run with valid input', ->
			beforeEach ->
				runs ->
					$.ajax
						type: 'POST'
						url: "api/preferredBatchId"
						data: @requestData
						success: (json) =>
							@serviceReturn = json
						error: (err) =>
							console.log 'got ajax error'
							@serviceReturn = null
						dataType: 'json'
			it 'should return no error', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 2000)
				runs ->
					expect(@serviceReturn.error).toBeFalsy()
			it 'full response should match expectedResponse', ->
				waitsFor( @waitForServiceReturn, 'service did not return', 2000)
				runs ->
					expect(@serviceReturn).toEqual @expectedResponse
