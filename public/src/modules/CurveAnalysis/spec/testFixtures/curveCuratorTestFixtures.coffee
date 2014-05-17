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
			curveid: "AG-00001743_472"
			reportedValues: "<TABLE >\n  <TR> <TD> min </TD> <TD align=\"right\"> 17.16 </TD> </TR>\n  <TR> <TD> max </TD> <TD align=\"right\"> 94.09 </TD> </TR>\n  <TR> <TD> slope </TD> <TD align=\"right\"> 0.87 </TD> </TR>\n  <TR> <TD> ec50 </TD> <TD align=\"right\"> 0.73 </TD> </TR>\n   </TABLE>\n"
			fitSummary: "<br>Model fitted: Log-logistic (ED50 as parameter) (4 parms)<br><br>Parameter estimates:<br><br>                  Estimate Std. Error  t-value p-value<br>slope:(Intercept) -0.87274    0.30120 -2.89752  0.0089<br>min:(Intercept)   17.16475    8.06424  2.12850  0.0459<br>max:(Intercept)   94.09304    6.31208 14.90682  0.0000<br>ec50:(Intercept)   0.73444    0.20070  3.65935  0.0016<br><br>Residual standard error:<br><br> 5.684466 (20 degrees of freedom)"
			parameterStdErrors: "<TABLE >\n<TR> <TH> name </TH> <TH> pValue </TH> <TH> stdErr </TH> <TH> tValue </TH>  </TR>\n  <TR> <TD> ec50 </TD> <TD align=\"right\"> 0.00 </TD> <TD align=\"right\"> 0.20 </TD> <TD align=\"right\"> 3.66 </TD> </TR>\n  <TR> <TD> max </TD> <TD align=\"right\"> 0.00 </TD> <TD align=\"right\"> 6.31 </TD> <TD align=\"right\"> 14.91 </TD> </TR>\n  <TR> <TD> min </TD> <TD align=\"right\"> 0.05 </TD> <TD align=\"right\"> 8.06 </TD> <TD align=\"right\"> 2.13 </TD> </TR>\n  <TR> <TD> slope </TD> <TD align=\"right\"> 0.01 </TD> <TD align=\"right\"> 0.30 </TD> <TD align=\"right\"> -2.90 </TD> </TR>\n   </TABLE>\n"
			curveErrors: "<TABLE >\n  <TR> <TD> SSE </TD> <TD align=\"right\"> 646.26 </TD> </TR>\n  <TR> <TD> SST </TD> <TD align=\"right\"> 21152.22 </TD> </TR>\n  <TR> <TD> rSquared </TD> <TD align=\"right\"> 0.97 </TD> </TR>\n   </TABLE>\n"
			category: "sigmoid"
			algorithmApproved: null
			curveAttributes:
				EC50: 0.73
				Operator: null
				SST: 21152.22
				SSE: 646.26
				rSquared: 0.97
				compoundCode: "CMPD-0000002-01A"

			plotData:
				plotWindow: [
					-2
					96.26925
					2
					-4.1785
				]
				points: [
					{
						response_sv_id: 480440
						dose: 20
						doseunits: "uM"
						response: 88.72
						responseunits: "efficacy"
						flag: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 480445
						dose: 20
						doseunits: "uM"
						response: 86.93
						responseunits: "efficacy"
						flag: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 480446
						dose: 20
						doseunits: "uM"
						response: 94.18
						responseunits: "efficacy"
						flag: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 480453
						dose: 0.31
						doseunits: "uM"
						response: 22.2
						responseunits: "efficacy"
						flag: "Outlier"
						flagchanged: false
					}
					{
						response_sv_id: 480454
						dose: 0.31
						doseunits: "uM"
						response: 38.42
						responseunits: "efficacy"
						flag: "Outlier"
						flagchanged: false
					}
					{
						response_sv_id: 480459
						dose: 0.31
						doseunits: "uM"
						response: 38.2
						responseunits: "efficacy"
						flag: "Outlier"
						flagchanged: false
					}
					{
						response_sv_id: 480462
						dose: 10
						doseunits: "uM"
						response: 84.16
						responseunits: "efficacy"
						flag: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 480465
						dose: 10
						doseunits: "uM"
						response: 85.21
						responseunits: "efficacy"
						flag: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 480470
						dose: 10
						doseunits: "uM"
						response: 91.26
						responseunits: "efficacy"
						flag: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 480473
						dose: 5
						doseunits: "uM"
						response: 80.95
						responseunits: "efficacy"
						flag: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 480478
						dose: 5
						doseunits: "uM"
						response: 80.13
						responseunits: "efficacy"
						flag: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 480481
						dose: 5
						doseunits: "uM"
						response: 83.71
						responseunits: "efficacy"
						flag: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 480486
						dose: 0.04
						doseunits: "uM"
						response: 29.3
						responseunits: "efficacy"
						flag: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 480487
						dose: 0.04
						doseunits: "uM"
						response: 10.61
						responseunits: "efficacy"
						flag: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 480490
						dose: 0.04
						doseunits: "uM"
						response: 26.91
						responseunits: "efficacy"
						flag: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 480497
						dose: 1.25
						doseunits: "uM"
						response: 63.91
						responseunits: "efficacy"
						flag: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 480498
						dose: 1.25
						doseunits: "uM"
						response: 67.94
						responseunits: "efficacy"
						flag: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 480503
						dose: 1.25
						doseunits: "uM"
						response: 57.7
						responseunits: "efficacy"
						flag: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 480508
						dose: 2.5
						doseunits: "uM"
						response: 68.54
						responseunits: "efficacy"
						flag: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 480509
						dose: 2.5
						doseunits: "uM"
						response: 80.05
						responseunits: "efficacy"
						flag: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 480512
						dose: 2.5
						doseunits: "uM"
						response: 79.01
						responseunits: "efficacy"
						flag: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 480519
						dose: 0.08
						doseunits: "uM"
						response: 22.72
						responseunits: "efficacy"
						flag: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 480522
						dose: 0.08
						doseunits: "uM"
						response: 20.93
						responseunits: "efficacy"
						flag: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 480525
						dose: 0.08
						doseunits: "uM"
						response: 38.94
						responseunits: "efficacy"
						flag: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 480530
						dose: 0.16
						doseunits: "uM"
						response: 17.27
						responseunits: "efficacy"
						flag: "Outlier"
						flagchanged: false
					}
					{
						response_sv_id: 480531
						dose: 0.16
						doseunits: "uM"
						response: 34.31
						responseunits: "efficacy"
						flag: "Outlier"
						flagchanged: false
					}
					{
						response_sv_id: 480536
						dose: 0.16
						doseunits: "uM"
						response: 20.03
						responseunits: "efficacy"
						flag: "Outlier"
						flagchanged: false
					}
					{
						response_sv_id: 480541
						dose: 0.63
						doseunits: "uM"
						response: 56.58
						responseunits: "efficacy"
						flag: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 480542
						dose: 0.63
						doseunits: "uM"
						response: 54.04
						responseunits: "efficacy"
						flag: "NA"
						flagchanged: false
					}
					{
						response_sv_id: 480547
						dose: 0.63
						doseunits: "uM"
						response: 48.96
						responseunits: "efficacy"
						flag: "NA"
						flagchanged: false
					}
				]
				curve:
					type: "LL.4"
					slope: -0.87
					ec50: 0.73
					min: 17.16
					max: 94.09

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

				inactiveThreshold: 25
				inverseAgonistMode: true

			sessionID: "/var/folders/5b/s62pqy655kx6929zhxrml5c80000gn/T//rSe-8b36628951e0"

	exports.updateCurveUserApproval =
		userApproval: true

) (if (typeof process is "undefined" or not process.versions) then window.curveCuratorTestJSON = window.curveCuratorTestJSON or {} else exports)


#remember to keep requested and actual/overriden by algorithm#