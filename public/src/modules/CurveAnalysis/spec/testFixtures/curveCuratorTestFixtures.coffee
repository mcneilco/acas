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
		reportedValues: "<TABLE >\n  <TR> <TD> min </TD> <TD align=\"right\"> 12.19 </TD> </TR>\n  <TR> <TD> max </TD> <TD align=\"right\"> 98.23 </TD> </TR>\n  <TR> <TD> slope </TD> <TD align=\"right\"> 1.34 </TD> </TR>\n  <TR> <TD> ec50 </TD> <TD align=\"right\"> 0.70 </TD> </TR>\n   </TABLE>\n"
		fitSummary: "\nModel fitted: Log-logistic (ED50 as parameter) (4 parms)\n\nParameter estimates:\n\n                  Estimate Std. Error  t-value p-value\nslope:(Intercept) -1.33855    0.30402 -4.40280  0.0001\nmin:(Intercept)   12.18840    5.08812  2.39546  0.0219\nmax:(Intercept)   98.23208    4.34752 22.59497  0.0000\nec50:(Intercept)   0.70171    0.11964  5.86500  0.0000\n\nResidual standard error:\n\n 10.15455 (36 degrees of freedom)"
		parameterStdErrors: "<TABLE >\n<TR> <TH> name </TH> <TH> pValue </TH> <TH> stdErr </TH> <TH> tValue </TH>  </TR>\n  <TR> <TD> ec50 </TD> <TD align=\"right\"> 0.00 </TD> <TD align=\"right\"> 0.12 </TD> <TD align=\"right\"> 5.87 </TD> </TR>\n  <TR> <TD> max </TD> <TD align=\"right\"> 0.00 </TD> <TD align=\"right\"> 4.35 </TD> <TD align=\"right\"> 22.59 </TD> </TR>\n  <TR> <TD> min </TD> <TD align=\"right\"> 0.02 </TD> <TD align=\"right\"> 5.09 </TD> <TD align=\"right\"> 2.40 </TD> </TR>\n  <TR> <TD> slope </TD> <TD align=\"right\"> 0.00 </TD> <TD align=\"right\"> 0.30 </TD> <TD align=\"right\"> -4.40 </TD> </TR>\n   </TABLE>\n"
		curveErrors: "<TABLE >\n<TR> <TH> name </TH> <TH> V1 </TH>  </TR>\n  <TR> <TD> SSE </TD> <TD align=\"right\"> 3712.14 </TD> </TR>\n  <TR> <TD> SST </TD> <TD align=\"right\"> 46131.01 </TD> </TR>\n  <TR> <TD> rSquared </TD> <TD align=\"right\"> 0.92 </TD> </TR>\n   </TABLE>\n"
		category: "sigmoid"
		approved: true
		sessionID: "/var/folders/5b/s62pqy655kx6929zhxrml5c80000gn/T//rSe-f51b60961d32"
		curveAttributes:
			EC50: 0.70170549529582
			Operator: null
			SST: 46131.007824064
			SSE: 3712.13914471145
			rSquared: 0.919530499769939
			compoundCode: "CMPD-0000001-01"
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
				-3.93572673212738
				104.14772
				3.40119738166216
				-24.04072
			]
			points:
				response_sv_id: [
					1692797
					1692817
					1692801
					1692899
					1692848
					1692856
					1692826
					1692809
					1692842
					1692798
					1692772
					1692904
					1692832
					1692876
					1692804
					1692831
					1692890
					1692814
					1692778
					1692881
					1692787
					1692781
					1692884
					1692843
					1692790
					1692868
					1692825
					1692820
					1692896
					1692887
					1692769
					1692859
					1692853
					1692837
					1692773
					1692873
					1692865
					1692893
					1692860
					1692786
				]
				dose: [
					0.15625
					5
					0.15625
					20
					0.039063
					2.5
					0.3125
					5
					0.039063
					0.15625
					1.25
					20
					0.3125
					0.078125
					0.15625
					0.3125
					0.625
					5
					1.25
					0.625
					10
					10
					0.625
					0.039063
					10
					0.078125
					0.3125
					5
					20
					0.625
					1.25
					2.5
					2.5
					0.039063
					1.25
					0.078125
					0.078125
					20
					2.5
					10
				]
				doseUnits: [
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
					"uM"
				]
				response: [
					37.441
					89.907
					23.342
					98.052
					20.871
					80.638
					38.79
					92.827
					-19.293
					8.625
					75.302
					95.58
					25.533
					14.86
					37.217
					32.386
					69.628
					96.928
					70.246
					47.946
					94.737
					99.4
					37.048
					37.947
					93.67
					16.882
					23.342
					92.153
					95.973
					63.393
					69.46
					83.278
					80.863
					25.533
					69.404
					3.3448
					12.838
					98.613
					87.491
					98.669
				]
				responseUnits: [
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
					"efficacy"
				]
				flag: [
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
					"NA"
				]

			curve:
				dose: [
					0.039063
					0.291733088607595
					0.54440317721519
					0.797073265822785
					1.04974335443038
					1.30241344303797
					1.55508353164557
					1.80775362025316
					2.06042370886076
					2.31309379746835
					2.56576388607595
					2.81843397468354
					3.07110406329114
					3.32377415189873
					3.57644424050633
					3.82911432911392
					4.08178441772152
					4.33445450632911
					4.58712459493671
					4.8397946835443
					5.0924647721519
					5.34513486075949
					5.59780494936709
					5.85047503797468
					6.10314512658228
					6.35581521518987
					6.60848530379747
					6.86115539240506
					7.11382548101266
					7.36649556962025
					7.61916565822785
					7.87183574683544
					8.12450583544304
					8.37717592405063
					8.62984601265823
					8.88251610126582
					9.13518618987342
					9.38785627848101
					9.64052636708861
					9.8931964556962
					10.1458665443038
					10.3985366329114
					10.651206721519
					10.9038768101266
					11.1565468987342
					11.4092169873418
					11.6618870759494
					11.914557164557
					12.1672272531646
					12.4198973417722
					12.6725674303797
					12.9252375189873
					13.1779076075949
					13.4305776962025
					13.6832477848101
					13.9359178734177
					14.1885879620253
					14.4412580506329
					14.6939281392405
					14.9465982278481
					15.1992683164557
					15.4519384050633
					15.7046084936709
					15.9572785822785
					16.2099486708861
					16.4626187594937
					16.7152888481013
					16.9679589367089
					17.2206290253165
					17.473299113924
					17.7259692025316
					17.9786392911392
					18.2313093797468
					18.4839794683544
					18.736649556962
					18.9893196455696
					19.2419897341772
					19.4946598227848
					19.7473299113924
					20
				]
				response: [
					13.9530236317583
					32.4934846992683
					47.9712640800868
					58.8706144416877
					66.5349060608051
					72.066086581199
					76.1773404422901
					79.3178721682434
					81.7751624831634
					83.7381710907868
					85.3346546200288
					86.6533344041794
					87.7573500336985
					88.6926371795535
					89.4932823153498
					90.1850312854329
					90.7876419497972
					91.3164956174688
					91.7837224790311
					92.1990017268489
					92.5701397345621
					92.9034941394707
					93.2042891888626
					93.4768532057817
					93.7247995002425
					93.9511656852091
					94.1585220358437
					94.3490565550316
					94.5246423310173
					94.6868913043574
					94.8371975105887
					94.9767721047252
					95.1066719178235
					95.2278228854187
					95.3410393817597
					95.4470402638327
					95.5464622548678
					95.6398711638796
					95.7277713353326
					95.8106136436163
					95.8888022850737
					95.9627005716947
					96.0326358921847
					96.0989039756079
					96.1617725684476
					96.2214846163644
					96.2782610261558
					96.3323030706285
					96.3837944886781
					96.4329033243555
					96.4797835416956
					96.5245764463216
					96.5674119400568
					96.6084096308106
					96.6476798166948
					96.6853243605598
					96.7214374688134
					96.7561063864322
					96.7894120184173
					96.8214294865499
					96.8522286291093
					96.8818744502035
					96.9104275244954
					96.9379443623671
					96.9644777399261
					96.9900769977094
					97.0147883114699
					97.0386549380182
					97.0617174387392
					97.0840138830963
					97.1055800341664
					97.1264495180146
					97.1466539785172
					97.1662232190564
					97.1851853323612
					97.2035668196231
					97.2213926999004
					97.2386866107152
					97.2554709006521
					97.2717667146856
				]

) (if (typeof process is "undefined" or not process.versions) then window.curveCuratorTestJSON = window.curveCuratorTestJSON or {} else exports)


#remember to keep requested and actual/overriden by algorithm#