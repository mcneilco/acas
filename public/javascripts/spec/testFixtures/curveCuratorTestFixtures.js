(function() {
  (function(exports) {
    exports.curveCuratorThumbs = {
      sortOptions: [
        {
          code: "EC50",
          name: "EC50"
        }, {
          code: "SST",
          name: "SST"
        }, {
          code: "SSE",
          name: "SSE"
        }, {
          code: "rsquare",
          name: "R^2"
        }, {
          code: "compoundCode",
          name: "Compound Name"
        }
      ],
      curves: [
        {
          curveid: "90807_AG-00000026",
          compoundCode: "CMPD-0000008",
          algorithmApproved: true,
          userApproved: true,
          category: "active",
          curveAttritbutes: {
            EC50: .05,
            SST: 9,
            SSE: .8,
            rsquare: .95
          }
        }, {
          curveid: "126925_AG-00000237",
          compoundCode: "CMPD-0000002",
          algorithmApproved: true,
          userApproved: false,
          category: "active",
          curveAttritbutes: {
            EC50: .06,
            SST: 10,
            SSE: .9,
            rsquare: .96
          }
        }, {
          curveid: "126869_AG-00000231",
          compoundCode: "CMPD-0000003",
          algorithmApproved: true,
          userApproved: true,
          category: "active",
          curveAttritbutes: {
            EC50: .07,
            SST: 11,
            SSE: .1,
            rsquare: .97
          }
        }, {
          curveid: "126907_AG-00000232",
          compoundCode: "CMPD-0000004",
          algorithmApproved: false,
          category: "inactive",
          curveAttritbutes: {
            EC50: .08,
            SST: 12,
            SSE: .11,
            rsquare: .98
          }
        }, {
          curveid: "126907_AG-00000233",
          compoundCode: "CMPD-0000005",
          algorithmApproved: true,
          category: "inactive",
          curveAttritbutes: {
            EC50: .05,
            SST: 9,
            SSE: .8,
            rsquare: .95
          }
        }, {
          curveid: "126907_AG-00000234",
          compoundCode: "CMPD-0000006",
          algorithmApproved: true,
          category: "inactive",
          curveAttritbutes: {
            EC50: .03,
            SST: 9,
            SSE: .8,
            rsquare: .95
          }
        }, {
          curveid: "126907_AG-00000235",
          compoundCode: "CMPD-0000007",
          algorithmApproved: true,
          category: "sigmoid",
          curveAttritbutes: {
            EC50: .02,
            SST: 9,
            SSE: .8,
            rsquare: .95
          }
        }, {
          curveid: "126907_AG-00000236",
          compoundCode: "CMPD-0000001",
          algorithmApproved: true,
          category: "sigmoid",
          curveAttritbutes: {
            EC50: .01,
            SST: 9,
            SSE: .8,
            rsquare: .95
          }
        }, {
          curveid: "126907_AG-00000239",
          compoundCode: "CMPD-0000009",
          algorithmApproved: true,
          userApproved: null,
          category: "sigmoid",
          curveAttritbutes: {
            EC50: .005,
            SST: 9,
            SSE: .8,
            rsquare: .95
          }
        }
      ]
    };
    return exports.curveStubs = [
      {
        curveid: "90807_AG-00000026",
        status: "pass",
        category: "active"
      }, {
        curveid: "126925_AG-00000233",
        status: "pass",
        category: "active"
      }, {
        curveid: "126869_AG-00000231",
        status: "fail",
        category: "active"
      }, {
        curveid: "126907_AG-00000232",
        status: "pass",
        category: "inactive"
      }
    ];
  })((typeof process === "undefined" || !process.versions ? window.curveCuratorTestJSON = window.curveCuratorTestJSON || {} : exports));

}).call(this);
