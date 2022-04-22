############################################################################
# models
############################################################################
class CompoundScientist extends AbstractCodeTable
	codeType: "compound"
	codeKind: "scientist"

############################################################################
# controllers
############################################################################

class CompoundScientistController extends AbstractCodeTablesAdminController
	htmlViewId: "#CompoundScientistView"
	htmlDivSelector: '.bv_compoundCompoundScientistControllerDiv'
	modelClass: "CompoundScientist"

class CompoundScientistBrowserController extends AbstractCodeTablesAdminBrowserController
	htmlViewId: "#CompoundScientistBrowserView"
	entityClass: "CompoundScientist"
	entityControllerClass: "CompoundScientistController"
