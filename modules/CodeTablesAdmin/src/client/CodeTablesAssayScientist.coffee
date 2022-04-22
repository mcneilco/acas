############################################################################
# models
############################################################################
class AssayScientist extends AbstractCodeTable
	codeType: 'assay'
	codeKind: 'scientist'

############################################################################
# controllers
############################################################################

class AssayScientistController extends AbstractCodeTablesAdminController
	htmlViewId: "#AssayScientistView"
	htmlDivSelector: '.bv_assayAssayScientistControllerDiv'
	modelClass: "AssayScientist"


class AssayScientistBrowserController extends AbstractCodeTablesAdminBrowserController
	htmlViewId: "#AssayScientistBrowserView"
	entityClass: "AssayScientist"
	entityControllerClass: "AssayScientistController"
