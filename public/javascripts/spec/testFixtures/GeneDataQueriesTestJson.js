(function() {
  (function(exports) {
    exports.geneIDQueryResults = {
      htmlSummary: "HTML from service",
      data: {
        "iTotalRecords": 1000,
        "aoColumns": [
          {
            "sTitle": "Gene ID",
            "sType": "numeric",
            "sClass": "center"
          }, {
            "sTitle": "Results 1",
            "sType": "numeric",
            "sClass": "center"
          }, {
            "sTitle": "Results 2",
            "sType": "numeric",
            "sClass": "center"
          }, {
            "sTitle": "Results 3",
            "sType": "numeric",
            "sClass": "center"
          }, {
            "sTitle": "Results 1",
            "sType": "numeric",
            "sClass": "center"
          }, {
            "sTitle": "Results 2",
            "sType": "numeric",
            "sClass": "center"
          }, {
            "sTitle": "Results 5",
            "sType": "numeric",
            "sClass": "center"
          }, {
            "sTitle": "Results 7",
            "sType": "string",
            "sClass": "center"
          }
        ],
        "aaData": [["1", "12", "234", "564.65", "667", "345", "200", "apple"], ["2", "15", "23566", "342", "254", "206.64", "207.10", "pear"], ["3", "22", "12", "346", "456", "489.36", "196", "avocado"], ["4", "36", "453", "4235", "507", "395.01", "157", "melon"]],
        "groupHeaders": [
          {
            numberOfColumns: 1,
            titleText: ''
          }, {
            numberOfColumns: 2,
            titleText: 'Experiment 101'
          }, {
            numberOfColumns: 1,
            titleText: 'Experiment 102'
          }, {
            numberOfColumns: 2,
            titleText: 'Experiment 103'
          }, {
            numberOfColumns: 2,
            titleText: 'Experiment 104'
          }
        ]
      }
    };
    return exports.geneIDQueryResultsNoneFound = {
      htmlSummary: "HTML from service",
      data: {
        "iTotalRecords": 0,
        "aoColumns": [],
        "aaData": [],
        "groupHeaders": []
      }
    };
  })((typeof process === "undefined" || !process.versions ? window.geneDataQueriesTestJSON = window.geneDataQueriesTestJSON || {} : exports));

}).call(this);
