(function() {
  var exec;

  exec = require('child_process').exec;

  exports.runPrimaryAnalysis = function(request, response) {
    var child, command;
    console.log(request.body);
    command = 'Rscript public/modules/PrimaryAnalysis/src/server/PrimaryAnalysis.R';
    return child = exec(command, function(error, stdout, stderr) {
      var result;
      response.writeHead(200, {
        'Content-Type': 'application/json'
      });
      if (stderr !== null) {
        console.log(stderr);
        result = {
          error: true,
          errorMessages: ["Problem running R script: " + stderr],
          transactionId: null,
          experimentId: null,
          results: null
        };
        return response.end(JSON.stringify(result));
      } else {
        return response.end(stdout);
      }
    });
  };

}).call(this);
