/* To install this Module
1) Add these lines to app.coffee:
# ExperimentBrowser routes

2) Add this line to public/src/modules/ModuleMenus/src/client/ModuleMenusConfiguration.coffee
{isHeader: false, menuName: "Experiment Browser", mainControllerClassName: "ExperimentBrowserController"}

3) Add these lines to routes/index.coffee under applicationScripts = [
	# For ExperimentBrowser module
	'/javascripts/src/ExperimentBrowser.js'

4) Add these lines to routes/index.coffee under specScripts = [
	# For ExperimentBrowser module
	'/javascripts/spec/ExperimentBrowserSpec.js'

5) Add this in layout.jade
    // for ExperimentBrowser module
    include ../public/src/modules/ExperimentBrowser/src/client/ExperimentBrowserView.html
*/


(function() {


}).call(this);
