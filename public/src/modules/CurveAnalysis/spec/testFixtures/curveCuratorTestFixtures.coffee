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
			category: "Active"
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
			category: "Active"
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
			category: "Active"
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
			category: "Inactive"
			curveAttributes:
				EC50: .08
				SST: 12
				SSE: .11
				rsquare: .98
				compoundCode: "CMPD-0000004"
		,
			curveid: "126907_AG-00000233"
			algorithmApproved: true
			category: "Inactive"
			curveAttributes:
				EC50: .05
				SST: 9
				SSE: .8
				rsquare: .95
				compoundCode: "CMPD-0000005"
		,
			curveid: "126907_AG-00000234"
			algorithmApproved: true
			category: "Inactive"
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
			category: "Sigmoid"
			curveAttributes:
				EC50: .02
				SST: 9
				SSE: .8
				rsquare: .95
				compoundCode: "CMPD-0000007"
		,
			curveid: "126907_AG-00000236"
			algorithmApproved: true
			category: "Sigmoid"
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
			category: "Sigmoid"
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

	#	exports.curveDetail  =
	#		fiteParameters: "copy form experiment test jsons"
	#		div1
	#		div2
	#	  div3
	#		div4
	#	  plotParams
	#	  sessionID
	#		curveid: "126907_AG-00000239"
	#		algorithmApproved: true
	#		userApproved: null
	#		category: "Sigmoid"
	#		curveAttributes:
	#			EC50: .005
	#			SST: 9
	#			SSE: .8
	#			rsquare: .95
	#			compoundCode: "CMPD-0000009"

	exports.curveDetail =
			reportedValues: "<TABLE >\n<TR> <TH> name </TH> <TH> value </TH>  </TR>\n  <TR> <TD> min </TD> <TD align=\"right\"> 18.81 </TD> </TR>\n  <TR> <TD> max </TD> <TD align=\"right\"> 94.01 </TD> </TR>\n  <TR> <TD> slope </TD> <TD align=\"right\"> 1.20 </TD> </TR>\n  <TR> <TD> ec50 </TD> <TD align=\"right\"> 0.83 </TD> </TR>\n   </TABLE>\n"
			fitSummary: "Model fitted: Log-logistic (ED50 as parameter) (4 parms)Parameter estimates:                  Estimate Std. Error  t-value p-valueslope:(Intercept) -1.19582    0.26557 -4.50289  0.0001min:(Intercept)   18.80979    4.54464  4.13890  0.0003max:(Intercept)   94.01322    4.25224 22.10911  0.0000ec50:(Intercept)   0.83144    0.15510  5.36086  0.0000Residual standard error: 7.28876 (26 degrees of freedom)"
			parameterStdErrors: "<TABLE >\n<TR> <TH> name </TH> <TH> pValue </TH> <TH> stdErr </TH> <TH> tValue </TH>  </TR>\n  <TR> <TD> ec50 </TD> <TD align=\"right\"> 0.00 </TD> <TD align=\"right\"> 0.16 </TD> <TD align=\"right\"> 5.36 </TD> </TR>\n  <TR> <TD> max </TD> <TD align=\"right\"> 0.00 </TD> <TD align=\"right\"> 4.25 </TD> <TD align=\"right\"> 22.11 </TD> </TR>\n  <TR> <TD> min </TD> <TD align=\"right\"> 0.00 </TD> <TD align=\"right\"> 4.54 </TD> <TD align=\"right\"> 4.14 </TD> </TR>\n  <TR> <TD> slope </TD> <TD align=\"right\"> 0.00 </TD> <TD align=\"right\"> 0.27 </TD> <TD align=\"right\"> -4.50 </TD> </TR>\n   </TABLE>\n"
			curveErrors: "<TABLE >\n<TR> <TH> name </TH> <TH> V1 </TH>  </TR>\n  <TR> <TD> SSE </TD> <TD align=\"right\"> 1381.28 </TD> </TR>\n  <TR> <TD> SST </TD> <TD align=\"right\"> 23873.78 </TD> </TR>\n  <TR> <TD> rSquared </TD> <TD align=\"right\"> 0.94 </TD> </TR>\n   </TABLE>\n"
			category: "sigmoid"
			algorithmApproved: true
			curveAttributes:
				EC50: 0.831442174547675
				Operator: null
				SST: 23873.7817466667
				SSE: 1381.2764779215
				rSquared: 0.942142535582392
				compoundCode: "CMPD-0000005-01"
			fitSettings:
				max:
					limitType: "pin"# none, pin or limit
					value: 101
				min:
					limitType: "none"# none, pin or limit
					value: null
				slope:
					limitType: "limit"# none, pin or limit
					value: 1.5
				inactiveThreshold: 20
				inverseAgonistMode: true
			plotData:
				plotWindow: [
					-2
					100.65275
					2
					3.51725
				]
				points: [
					{
						response_sv_id: 14117
						dose: 2.5
						doseUnits: "uM"
						response: 78.83
						responseUnits: "efficacy"
						flag: "NA"
					}
					{
						response_sv_id: 14118
						dose: 2.5
						doseUnits: "uM"
						response: 79.3
						responseUnits: "efficacy"
						flag: "NA"
					}
					{
						response_sv_id: 14123
						dose: 2.5
						doseUnits: "uM"
						response: 81.19
						responseUnits: "efficacy"
						flag: "NA"
					}
					{
						response_sv_id: 14128
						dose: 0.31
						doseUnits: "uM"
						response: 46.66
						responseUnits: "efficacy"
						flag: "NA"
					}
					{
						response_sv_id: 14131
						dose: 0.31
						doseUnits: "uM"
						response: 30.53
						responseUnits: "efficacy"
						flag: "NA"
					}
					{
						response_sv_id: 14132
						dose: 0.31
						doseUnits: "uM"
						response: 38.4
						responseUnits: "efficacy"
						flag: "NA"
					}
					{
						response_sv_id: 14139
						dose: 10
						doseUnits: "uM"
						response: 97.55
						responseUnits: "efficacy"
						flag: "NA"
					}
					{
						response_sv_id: 14142
						dose: 10
						doseUnits: "uM"
						response: 83.63
						responseUnits: "efficacy"
						flag: "NA"
					}
					{
						response_sv_id: 14143
						dose: 10
						doseUnits: "uM"
						response: 85.67
						responseUnits: "efficacy"
						flag: "NA"
					}
					{
						response_sv_id: 14148
						dose: 5
						doseUnits: "uM"
						response: 88.27
						responseUnits: "efficacy"
						flag: "NA"
					}
					{
						response_sv_id: 14153
						dose: 5
						doseUnits: "uM"
						response: 81.19
						responseUnits: "efficacy"
						flag: "NA"
					}
					{
						response_sv_id: 14154
						dose: 5
						doseUnits: "uM"
						response: 92.28
						responseUnits: "efficacy"
						flag: "NA"
					}
					{
						response_sv_id: 14159
						dose: 0.08
						doseUnits: "uM"
						response: 22.82
						responseUnits: "efficacy"
						flag: "NA"
					}
					{
						response_sv_id: 14164
						dose: 0.08
						doseUnits: "uM"
						response: 33.84
						responseUnits: "efficacy"
						flag: "NA"
					}
					{
						response_sv_id: 14167
						dose: 0.08
						doseUnits: "uM"
						response: 21.96
						responseUnits: "efficacy"
						flag: "NA"
					}
					{
						response_sv_id: 14172
						dose: 0.04
						doseUnits: "uM"
						response: 5.83
						responseUnits: "efficacy"
						flag: "NA"
					}
					{
						response_sv_id: 14173
						dose: 0.04
						doseUnits: "uM"
						response: 24.4
						responseUnits: "efficacy"
						flag: "NA"
					}
					{
						response_sv_id: 14178
						dose: 0.04
						doseUnits: "uM"
						response: 30.06
						responseUnits: "efficacy"
						flag: "NA"
					}
					{
						response_sv_id: 14181
						dose: 1.25
						doseUnits: "uM"
						response: 65.3
						responseUnits: "efficacy"
						flag: "NA"
					}
					{
						response_sv_id: 14184
						dose: 1.25
						doseUnits: "uM"
						response: 59.95
						responseUnits: "efficacy"
						flag: "NA"
					}
					{
						response_sv_id: 14187
						dose: 1.25
						doseUnits: "uM"
						response: 60.58
						responseUnits: "efficacy"
						flag: "NA"
					}
					{
						response_sv_id: 14192
						dose: 0.16
						doseUnits: "uM"
						response: 36.2
						responseUnits: "efficacy"
						flag: "NA"
					}
					{
						response_sv_id: 14195
						dose: 0.16
						doseUnits: "uM"
						response: 19.76
						responseUnits: "efficacy"
						flag: "NA"
					}
					{
						response_sv_id: 14198
						dose: 0.16
						doseUnits: "uM"
						response: 14.25
						responseUnits: "efficacy"
						flag: "NA"
					}
					{
						response_sv_id: 14203
						dose: 0.63
						doseUnits: "uM"
						response: 62.23
						responseUnits: "efficacy"
						flag: "NA"
					}
					{
						response_sv_id: 14206
						dose: 0.63
						doseUnits: "uM"
						response: 44.85
						responseUnits: "efficacy"
						flag: "NA"
					}
					{
						response_sv_id: 14211
						dose: 0.63
						doseUnits: "uM"
						response: 49.41
						responseUnits: "efficacy"
						flag: "NA"
					}
					{
						response_sv_id: 14216
						dose: 20
						doseUnits: "uM"
						response: 98.34
						responseUnits: "efficacy"
						flag: "NA"
					}
					{
						response_sv_id: 14219
						dose: 20
						doseUnits: "uM"
						response: 88.58
						responseUnits: "efficacy"
						flag: "NA"
					}
					{
						response_sv_id: 14222
						dose: 20
						doseUnits: "uM"
						response: 91.1
						responseUnits: "efficacy"
						flag: "NA"
					}
				]
				curve:
					type: "LL.4"
					slope: -1.19582217731893
					min: 18.8097933106488
					max: 94.0132195096056
					ec50: 0.831442174547675
			sessionID: "/var/folders/5b/s62pqy655kx6929zhxrml5c80000gn/T//rSe-4d7736ec9f30"

) (if (typeof process is "undefined" or not process.versions) then window.curveCuratorTestJSON = window.curveCuratorTestJSON or {} else exports)


#remember to keep requested and actual/overriden by algorithm#