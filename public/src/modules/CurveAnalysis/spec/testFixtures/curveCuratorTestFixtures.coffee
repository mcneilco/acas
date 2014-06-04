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

	exports.curveDetail =
			curveid: "AG-00104866_796"
			reportedValues: "<TABLE >\n  <TR> <TD> min </TD> <TD align=\"right\"> 12.04 </TD> </TR>\n  <TR> <TD> max </TD> <TD align=\"right\"> 98.23 </TD> </TR>\n  <TR> <TD> slope </TD> <TD align=\"right\"> 1.34 </TD> </TR>\n  <TR> <TD> ec50 </TD> <TD align=\"right\"> 0.70 </TD> </TR>\n   </TABLE>\n"
			fitSummary: "<br>Model fitted: Log-logistic (ED50 as parameter) (4 parms)<br><br>Parameter estimates:<br><br>                  Estimate Std. Error  t-value p-value<br>slope:(Intercept) -1.33846    0.30222 -4.42881  0.0001<br>min:(Intercept)   12.04285    5.13460  2.34543  0.0246<br>max:(Intercept)   98.23250    4.32905 22.69149  0.0000<br>ec50:(Intercept)   0.70085    0.11958  5.86116  0.0000<br><br>Residual standard error:<br><br> 10.13257 (36 degrees of freedom)"
			parameterStdErrors: "<TABLE >\n<TR> <TH> name </TH> <TH> pValue </TH> <TH> stdErr </TH> <TH> tValue </TH>  </TR>\n  <TR> <TD> ec50 </TD> <TD align=\"right\"> 0.00 </TD> <TD align=\"right\"> 0.12 </TD> <TD align=\"right\"> 5.86 </TD> </TR>\n  <TR> <TD> max </TD> <TD align=\"right\"> 0.00 </TD> <TD align=\"right\"> 4.33 </TD> <TD align=\"right\"> 22.69 </TD> </TR>\n  <TR> <TD> min </TD> <TD align=\"right\"> 0.02 </TD> <TD align=\"right\"> 5.13 </TD> <TD align=\"right\"> 2.35 </TD> </TR>\n  <TR> <TD> slope </TD> <TD align=\"right\"> 0.00 </TD> <TD align=\"right\"> 0.30 </TD> <TD align=\"right\"> -4.43 </TD> </TR>\n   </TABLE>\n"
			curveErrors: "<TABLE >\n  <TR> <TD> SSE </TD> <TD align=\"right\"> 3696.08 </TD> </TR>\n  <TR> <TD> SST </TD> <TD align=\"right\"> 46130.70 </TD> </TR>\n  <TR> <TD> rSquared </TD> <TD align=\"right\"> 0.92 </TD> </TR>\n   </TABLE>\n"
			category: "sigmoid"
			algorithmApproved: true
			userApproved: "NA"
			curveAttributes:
				EC50: 0.7
				Operator: null
				SST: 46130.7
				SSE: 3696.08
				rSquared: 0.92
				compoundCode: "CMPD-0000001-01A"

			plotData:
				plotWindow: [
					-2
					102.36725
					2
					-22.25725
				]
				points: [
					{
						response_sv_id: 958496
						dose: 1.25
						doseunits: "uM"
						response: 70.25
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958499
						dose: 1.25
						doseunits: "uM"
						response: 69.46
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958500
						dose: 1.25
						doseunits: "uM"
						response: 69.4
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958503
						dose: 1.25
						doseunits: "uM"
						response: 75.3
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958510
						dose: 0.16
						doseunits: "uM"
						response: 8.63
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958511
						dose: 0.16
						doseunits: "uM"
						response: 37.22
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958514
						dose: 0.16
						doseunits: "uM"
						response: 23.34
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958517
						dose: 0.16
						doseunits: "uM"
						response: 37.44
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958524
						dose: 0.04
						doseunits: "uM"
						response: 20.87
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958527
						dose: 0.04
						doseunits: "uM"
						response: 25.53
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958528
						dose: 0.04
						doseunits: "uM"
						response: -19.29
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958531
						dose: 0.04
						doseunits: "uM"
						response: 37.95
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958538
						dose: 0.31
						doseunits: "uM"
						response: 23.34
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958539
						dose: 0.31
						doseunits: "uM"
						response: 25.53
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958544
						dose: 0.31
						doseunits: "uM"
						response: 32.39
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958547
						dose: 0.31
						doseunits: "uM"
						response: 38.79
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958550
						dose: 2.5
						doseunits: "uM"
						response: 80.64
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958553
						dose: 2.5
						doseunits: "uM"
						response: 80.86
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958558
						dose: 2.5
						doseunits: "uM"
						response: 87.49
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958561
						dose: 2.5
						doseunits: "uM"
						response: 83.28
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958564
						dose: 20
						doseunits: "uM"
						response: 95.97
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958569
						dose: 20
						doseunits: "uM"
						response: 98.61
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958570
						dose: 20
						doseunits: "uM"
						response: 95.58
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958573
						dose: 20
						doseunits: "uM"
						response: 98.05
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958580
						dose: 5
						doseunits: "uM"
						response: 89.91
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958581
						dose: 5
						doseunits: "uM"
						response: 96.93
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958584
						dose: 5
						doseunits: "uM"
						response: 92.15
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958589
						dose: 5
						doseunits: "uM"
						response: 92.83
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958594
						dose: 10
						doseunits: "uM"
						response: 98.67
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958595
						dose: 10
						doseunits: "uM"
						response: 99.4
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958600
						dose: 10
						doseunits: "uM"
						response: 93.67
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958601
						dose: 10
						doseunits: "uM"
						response: 94.74
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958608
						dose: 0.08
						doseunits: "uM"
						response: 12.84
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958611
						dose: 0.08
						doseunits: "uM"
						response: 14.86
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958614
						dose: 0.08
						doseunits: "uM"
						response: 3.34
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958615
						dose: 0.08
						doseunits: "uM"
						response: 16.88
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958622
						dose: 0.63
						doseunits: "uM"
						response: 69.63
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958625
						dose: 0.63
						doseunits: "uM"
						response: 47.95
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958628
						dose: 0.63
						doseunits: "uM"
						response: 37.05
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 958629
						dose: 0.63
						doseunits: "uM"
						response: 63.39
						responseunits: "efficacy"
						flag_user: "NA"
						"flag_on.load": "NA"
						flag_algorithm: "NA"
						flagchanged: false
					}
				]
				curve:
					type: "LL.4"
					ec50: 0.7
					min: 12.04
					slope: -1.34
					max: 98.23

			fitSettings:
				max:
					limitType: "none"
					value: 101

				min:
					limitType: "none"
					value: 0

				slope:
					limitType: "none"
					value: 0.6

				inactiveThreshold: 20
				inverseAgonistMode: true

			sessionID: "/var/folders/5b/s62pqy655kx6929zhxrml5c80000gn/T//rSe-1bf048a9588"

	exports.updateCurveUserApproval =
		userApproval: true

) (if (typeof process is "undefined" or not process.versions) then window.curveCuratorTestJSON = window.curveCuratorTestJSON or {} else exports)


#remember to keep requested and actual/overriden by algorithm#