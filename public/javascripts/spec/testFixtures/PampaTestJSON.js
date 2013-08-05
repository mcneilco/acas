(function() {
  (function(exports) {
    exports.validPampa = {
      protocolName: "uSol Protocol 1",
      scientist: "jmcneil",
      notebook: "dnsNB1",
      project: "proj1"
    };
    return exports.csvDataToLoad = "Corporate Batch ID,solubility (ug/mL),Assay Comment (-)\nDNS123456789::12,11.4,good\nDNS123456790::01,6.9,ok\n";
  })((typeof process === "undefined" || !process.versions ? window.PampaTestJSON = window.PampaTestJSON || {} : exports));

}).call(this);
