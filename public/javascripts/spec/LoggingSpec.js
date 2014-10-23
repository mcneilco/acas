(function() {
  beforeEach(function() {
    return this.fixture = $("#fixture");
  });

  afterEach(function() {
    $("#fixture").remove();
    return $("body").append('<div id="fixture"></div>');
  });

}).call(this);
