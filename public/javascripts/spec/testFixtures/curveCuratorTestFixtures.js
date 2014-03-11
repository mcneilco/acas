(function() {
  (function(exports) {
    exports.curveCuratorThumbs = [
      {
        curveid: "90807_AG-00000026",
        compoundCode: "CMPD-0000008",
        algorithmApproved: true,
        userApproved: true,
        category: "active"
      }, {
        curveid: "126925_AG-00000237",
        compoundCode: "CMPD-0000002",
        algorithmApproved: true,
        userApproved: false,
        category: "active"
      }, {
        curveid: "126869_AG-00000231",
        compoundCode: "CMPD-0000003",
        algorithmApproved: true,
        userApproved: true,
        category: "active"
      }, {
        curveid: "126907_AG-00000232",
        compoundCode: "CMPD-0000004",
        algorithmApproved: false,
        category: "inactive"
      }, {
        curveid: "126907_AG-00000233",
        compoundCode: "CMPD-0000005",
        algorithmApproved: true,
        category: "inactive"
      }, {
        curveid: "126907_AG-00000234",
        compoundCode: "CMPD-0000006",
        algorithmApproved: true,
        category: "inactive"
      }, {
        curveid: "126907_AG-00000235",
        compoundCode: "CMPD-0000007",
        algorithmApproved: true,
        category: "sigmoid"
      }, {
        curveid: "126907_AG-00000236",
        compoundCode: "CMPD-0000001",
        algorithmApproved: true,
        category: "sigmoid"
      }, {
        curveid: "126907_AG-00000239",
        compoundCode: "CMPD-0000009",
        algorithmApproved: true,
        category: "sigmoid"
      }
    ];
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
