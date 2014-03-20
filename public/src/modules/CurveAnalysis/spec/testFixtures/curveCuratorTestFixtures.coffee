((exports) ->

	exports.curveCuratorThumbs =
		sortOptions: [

			code: "compoundCode"
			name: "Compound Name"
		,
			code: "EC50"
			name: "EC50"
		,
			code: "SST"
			name: "SST"
		,
			code: "SSE"
			name: "SSE"
		,
			code: "rsquare"
			name: "R^2"
		]
		curves: [
			curveid: "90807_AG-00000026"
			algorithmApproved: true
			userApproved: true
			category: "active"
			curveAttributes:
				EC50: .05
				SST: 9
				SSE: .8
				rsquare: .95
				compoundCode: "CMPD-0000008"
		,
			curveid: "126925_AG-00000237"
			algorithmApproved: true
			userApproved: false
			category: "active"
			curveAttributes:
				EC50: .06
				SST: 10
				SSE: .9
				rsquare: .96
				compoundCode: "CMPD-0000002"
		,
			curveid: "126869_AG-00000231"
			algorithmApproved: true
			userApproved: true
			category: "active"
			curveAttributes:
				EC50: .07
				SST: 11
				SSE: .1
				rsquare: .97
				compoundCode: "CMPD-0000003"
		,
			curveid: "126907_AG-00000232"
			algorithmApproved: false
			#userApproved: if not user approved yet, don't send this variable
			category: "inactive"
			curveAttributes:
				EC50: .08
				SST: 12
				SSE: .11
				rsquare: .98
				compoundCode: "CMPD-0000004"
		,
			curveid: "126907_AG-00000233"
			algorithmApproved: true
			category: "inactive"
			curveAttributes:
				EC50: .05
				SST: 9
				SSE: .8
				rsquare: .95
				compoundCode: "CMPD-0000005"
		,
			curveid: "126907_AG-00000234"
			algorithmApproved: true
			category: "inactive"
			curveAttributes:
				EC50: .03
				SST: 9
				SSE: .8
				rsquare: .95
				compoundCode: "CMPD-0000006"
		,
			curveid: "126907_AG-00000235"
			compoundCode: "CMPD-0000007"
			algorithmApproved: true
			category: "sigmoid"
			curveAttributes:
				EC50: .02
				SST: 9
				SSE: .8
				rsquare: .95
				compoundCode: "CMPD-0000007"
		,
			curveid: "126907_AG-00000236"
			algorithmApproved: true
			category: "sigmoid"
			curveAttributes:
				EC50: .01
				SST: 9
				SSE: .8
				rsquare: .95
				compoundCode: "CMPD-0000001"
		,
			curveid: "126907_AG-00000239"
			algorithmApproved: true
			userApproved: null
			category: "sigmoid"
			curveAttributes:
				EC50: .005
				SST: 9
				SSE: .8
				rsquare: .95
				compoundCode: "CMPD-0000009"
		]


	exports.curveStubs = [
		curveid: "90807_AG-00000026"
		status: "pass"
		category: "active"
	,
		curveid: "126925_AG-00000233"
		status: "pass"
		category: "active"
	,
		curveid: "126869_AG-00000231"
		status: "fail"
		category: "active"
	,
		curveid: "126907_AG-00000232"
		status: "pass"
		category: "inactive"
	]


) (if (typeof process is "undefined" or not process.versions) then window.curveCuratorTestJSON = window.curveCuratorTestJSON or {} else exports)


#remember to keep requested and actual/overriden by algorithm#