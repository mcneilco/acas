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
		reportedValues: "<TABLE >\n<TR> <TH> name </TH> <TH> value </TH>  </TR>\n  <TR> <TD> min </TD> <TD align=\"right\"> 12.04 </TD> </TR>\n  <TR> <TD> max </TD> <TD align=\"right\"> 98.23 </TD> </TR>\n  <TR> <TD> slope </TD> <TD align=\"right\"> 1.34 </TD> </TR>\n  <TR> <TD> ec50 </TD> <TD align=\"right\"> 0.70 </TD> </TR>\n   </TABLE>\n"
		fitSummary: "Model fitted: Log-logistic (ED50 as parameter) (4 parms)Parameter estimates:                  Estimate Std. Error  t-value p-valueslope:(Intercept) -1.33846    0.30222 -4.42881  0.0001min:(Intercept)   12.04285    5.13460  2.34543  0.0246max:(Intercept)   98.23250    4.32905 22.69149  0.0000ec50:(Intercept)   0.70085    0.11958  5.86116  0.0000Residual standard error: 10.13257 (36 degrees of freedom)"
		parameterStdErrors: "<TABLE >\n<TR> <TH> name </TH> <TH> pValue </TH> <TH> stdErr </TH> <TH> tValue </TH>  </TR>\n  <TR> <TD> ec50 </TD> <TD align=\"right\"> 0.00 </TD> <TD align=\"right\"> 0.12 </TD> <TD align=\"right\"> 5.86 </TD> </TR>\n  <TR> <TD> max </TD> <TD align=\"right\"> 0.00 </TD> <TD align=\"right\"> 4.33 </TD> <TD align=\"right\"> 22.69 </TD> </TR>\n  <TR> <TD> min </TD> <TD align=\"right\"> 0.02 </TD> <TD align=\"right\"> 5.13 </TD> <TD align=\"right\"> 2.35 </TD> </TR>\n  <TR> <TD> slope </TD> <TD align=\"right\"> 0.00 </TD> <TD align=\"right\"> 0.30 </TD> <TD align=\"right\"> -4.43 </TD> </TR>\n   </TABLE>\n"
		curveErrors: "<TABLE >\n<TR> <TH> name </TH> <TH> V1 </TH>  </TR>\n  <TR> <TD> SSE </TD> <TD align=\"right\"> 3696.08 </TD> </TR>\n  <TR> <TD> SST </TD> <TD align=\"right\"> 46130.70 </TD> </TR>\n  <TR> <TD> rSquared </TD> <TD align=\"right\"> 0.92 </TD> </TR>\n   </TABLE>\n"
		category: "sigmoid"
		algorithmApproved: true
		curveAttributes:
			EC50: 0.700852529214898
			Operator: null
			SST: 46130.6953775
			SSE: 3696.08486540006
			rSquared: 0.919877972028083
			compoundCode: "CMPD-0000001-01"
		sessionID: "/var/folders/5b/s62pqy655kx6929zhxrml5c80000gn/T//rSe-34a423d5ace7"
		plotData:
			plotWindow: [
				-2
				104.1476
				3
				-24.0376
			]
			points:
				response_sv_id: [
					13688
					13633
					13747
					13748
					13638
					13744
					13683
					13719
					13621
					13741
					13618
					13629
					13615
					13700
					13644
					13678
					13692
					13650
					13641
					13706
					13661
					13720
					13733
					13736
					13669
					13711
					13632
					13657
					13714
					13674
					13699
					13666
					13689
					13705
					13622
					13660
					13727
					13647
					13677
					13728
				]
				dose: [
					20
					10
					0.63
					0.63
					10
					0.63
					20
					1.25
					0.08
					0.63
					0.08
					10
					0.08
					0.16
					0.04
					5
					20
					0.04
					0.04
					0.16
					2.5
					1.25
					0.31
					0.31
					5
					1.25
					10
					2.5
					1.25
					5
					0.16
					2.5
					20
					0.16
					0.08
					2.5
					0.31
					0.04
					5
					0.31
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
					98.61
					94.74
					47.95
					37.05
					98.67
					63.39
					98.05
					69.46
					12.84
					69.63
					14.86
					99.4
					16.88
					37.44
					20.87
					92.15
					95.97
					-19.29
					37.95
					23.34
					80.64
					75.3
					32.39
					38.79
					92.83
					70.25
					93.67
					80.86
					69.4
					96.93
					37.22
					87.49
					95.58
					8.63
					3.34
					83.28
					23.34
					25.53
					89.91
					25.53
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
					0.04
					0.207731092436975
					0.37546218487395
					0.543193277310924
					0.710924369747899
					0.878655462184874
					1.04638655462185
					1.21411764705882
					1.3818487394958
					1.54957983193277
					1.71731092436975
					1.88504201680672
					2.0527731092437
					2.22050420168067
					2.38823529411765
					2.55596638655462
					2.7236974789916
					2.89142857142857
					3.05915966386555
					3.22689075630252
					3.3946218487395
					3.56235294117647
					3.73008403361345
					3.89781512605042
					4.06554621848739
					4.23327731092437
					4.40100840336134
					4.56873949579832
					4.73647058823529
					4.90420168067227
					5.07193277310924
					5.23966386554622
					5.40739495798319
					5.57512605042017
					5.74285714285714
					5.91058823529412
					6.07831932773109
					6.24605042016807
					6.41378151260504
					6.58151260504202
					6.74924369747899
					6.91697478991597
					7.08470588235294
					7.25243697478992
					7.42016806722689
					7.58789915966387
					7.75563025210084
					7.92336134453782
					8.09109243697479
					8.25882352941176
					8.42655462184874
					8.59428571428571
					8.76201680672269
					8.92974789915966
					9.09747899159664
					9.26521008403361
					9.43294117647059
					9.60067226890756
					9.76840336134454
					9.93613445378151
					10.1038655462185
					10.2715966386555
					10.4393277310924
					10.6070588235294
					10.7747899159664
					10.9425210084034
					11.1102521008403
					11.2779831932773
					11.4457142857143
					11.6134453781513
					11.7811764705882
					11.9489075630252
					12.1166386554622
					12.2843697478992
					12.4521008403361
					12.6198319327731
					12.7875630252101
					12.9552941176471
					13.123025210084
					13.290756302521
					13.458487394958
					13.626218487395
					13.7939495798319
					13.9616806722689
					14.1294117647059
					14.2971428571429
					14.4648739495798
					14.6326050420168
					14.8003361344538
					14.9680672268908
					15.1357983193277
					15.3035294117647
					15.4712605042017
					15.6389915966387
					15.8067226890756
					15.9744537815126
					16.1421848739496
					16.3099159663866
					16.4776470588235
					16.6453781512605
					16.8131092436975
					16.9808403361345
					17.1485714285714
					17.3163025210084
					17.4840336134454
					17.6517647058824
					17.8194957983193
					17.9872268907563
					18.1549579831933
					18.3226890756303
					18.4904201680672
					18.6581512605042
					18.8258823529412
					18.9936134453781
					19.1613445378151
					19.3290756302521
					19.4968067226891
					19.664537815126
					19.832268907563
					20
				]
				response: [
					13.8696306831532
					26.1912292398829
					38.1158530095932
					47.8586531602686
					55.5491750627955
					61.6090383892556
					66.4274511726433
					70.3070864203437
					73.4723449881018
					76.0878581966494
					78.2748615221801
					80.123496478299
					81.7015891508491
					83.060820455948
					84.2410625216556
					85.2734466850831
					86.1825555714781
					86.9880069709468
					87.7056116454048
					88.3482295210967
					88.926409989538
					89.4488759384377
					89.9228934186893
					90.3545567205026
					90.7490102388757
					91.1106226427205
					91.4431247195579
					91.7497193124376
					92.0331696364145
					92.2958707129288
					92.5399075232093
					92.7671026395123
					92.9790554638439
					93.1771747300739
					93.362705565877
					93.5367521361702
					93.7002966782158
					93.8542155746728
					93.9992929830686
					94.1362324398864
					94.2656667783228
					94.3881666359659
					94.5042477785351
					94.6143774256455
					94.7189797321763
					94.8184405526085
					94.9131115943777
					95.0033140488721
					95.0893417744243
					95.1714640938836
					95.2499282596344
					95.3249616308595
					95.3967736011311
					95.4655573088018
					95.5314911579644
					95.5947401737927
					95.6554572127409
					95.7137840452559
					95.7698523262608
					95.8237844666327
					95.8756944171575
					95.9256883749574
					95.9738654211146
					96.0203180971155
					96.0651329267972
					96.1083908896624
					96.150167850723
					96.1905349514204
					96.229558965638
					96.2673026243585
					96.3038249121145
					96.3391813380255
					96.3734241839065
					96.4066027316604
					96.4387634719279
					96.4699502957569
					96.5002046708699
					96.5295658039407
					96.5580707901499
					96.5857547511561
					96.6126509625101
					96.6387909714319
					96.6642047057863
					96.6889205750066
					96.7129655636465
					96.7363653181779
					96.7591442275881
					96.7813254982873
					96.8029312237822
					96.8239824495361
					96.8444992333946
					96.8645007019249
					96.8840051029837
					96.9030298548039
					96.9215915918625
					96.9397062077724
					96.9573888954192
					96.9746541845443
					96.9915159769619
					97.00798757958
					97.0240817353811
					97.0398106525091
					97.055186031593
					97.0702190914313
					97.0849205931487
					97.0993008629303
					97.1133698134281
					97.1271369639297
					97.1406114593707
					97.1538020882671
					97.1667172996374
					97.1793652189808
					97.1917536633706
					97.2038901557195
					97.2157819382698
					97.2274359853551
					97.2388590154798
					97.2500575027582
					97.2610376877515
					97.2718055877395
				]

		sessionID: "/var/folders/5b/s62pqy655kx6929zhxrml5c80000gn/T//rSe-34a423d5ace7"

) (if (typeof process is "undefined" or not process.versions) then window.curveCuratorTestJSON = window.curveCuratorTestJSON or {} else exports)


#remember to keep requested and actual/overriden by algorithm#