<!DOCTYPE html>
<html>

  <head>
    <title>Compound Manager</title>
    <link href="css/NewCmpdReg.css" media="all" rel="stylesheet" type="text/css"/>
    <link href="lib/JQuery_theme_redmond/jquery-ui-1.8.20.custom.css" media="all" rel="stylesheet" type="text/css"/>
<!--
    <link href="lib/JQuery_theme_redmond/jquery.ui.datepicker.css" media="all" rel="stylesheet" type="text/css"/>
    <link href="lib/JQuery_theme_redmond/jquery.ui.dialog.css" media="all" rel="stylesheet" type="text/css"/>
-->

    <link href="MultipleFilePicker/css/style.css" media="all" rel="stylesheet" type="text/css"/>
    
    <link href="custom/customStyles.css" media="all" rel="stylesheet" type="text/css"/>

    <script type="text/javascript" src="lib/json2.js"></script>
    <script type="text/javascript" src="lib/jquery-1.7.2.min.js"></script>
    <script type="text/javascript" src="lib/jquery.form.js"></script>
  <script type="text/javascript" src="lib/jquery-ui-1.8.20.custom.min.js"></script>
<!--
  <script type="text/javascript" src="lib/jquery_ui/jquery.ui.core.min.js"></script>
  <script type="text/javascript" src="lib/jquery_ui/jquery.ui.widget.min.js"></script>
  <script type="text/javascript" src="lib/jquery_ui/jquery.ui.datepicker.min.js"></script>
  <script type="text/javascript" src="lib/jquery_ui/jquery.ui.dialog.min.js"></script>
-->
    <script type="text/javascript" src="lib/underscore-1.1.6.js"></script>
    <script type="text/javascript" src="lib/backbone.js"></script>
<!--  <script type="text/javascript" src="lib/backbone-localstorage.js"></script>-->
  <script type="text/javascript" src="lib/amplify.store.js"></script>
  <script type="text/javascript" src="lib/backbone.amplify.js"></script>
<!--    <script LANGUAGE="JavaScript1.1" SRC="marvin/marvin.js"></script> -->

<!-- for marvin js -->
 	<link type="text/css" rel="stylesheet" href="marvinjs/js/lib/rainbow/github.css" />
 	<script src="marvinjs/js/lib/rainbow/rainbow-custom.min.js"></script>
 	<script src="marvinjs/gui/lib/promise-1.0.0.min.js"></script>
 	<script src="marvinjs/js/marvinjslauncher.js"></script>
 	<script src="custom/marvinStructureTemplate.js"></script>



    <script type="text/javascript" src="src/AppController.js"></script>
    <script type="text/javascript" src="src/Isotope.js"></script>
    <script type="text/javascript" src="src/Salt.js"></script>
    <script type="text/javascript" src="src/ErrorNotification.js"></script>
	<script type="text/javascript" src="src/IsoSaltEquiv.js"></script>
  	<script type="text/javascript" src="src/SaltForm.js"></script>
    <script type="text/javascript" src="src/Lot.js"></script>
    <script type="text/javascript" src="src/PickList.js"></script>
    <script type="text/javascript" src="src/StructureImage.js"></script>
    <script type="text/javascript" src="MultipleFilePicker/javascript/src/file.js"></script>
    <script type="text/javascript" src="MultipleFilePicker/javascript/src/file_renderer.js"></script>
    <script type="text/javascript" src="src/Parent.js"></script>
    <script type="text/javascript" src="src/MetaLot.js"></script>
    <script type="text/javascript" src="src/RegistrationSearch.js"></script>
    <script type="text/javascript" src="src/SaltFormList.js"></script>
    <script type="text/javascript" src="src/ParentList.js"></script>
    <script type="text/javascript" src="src/RegSearchResults.js"></script>
    <script type="text/javascript" src="src/Registration.js"></script>
    <script type="text/javascript" src="src/SearchForm.js"></script>
    <script type="text/javascript" src="src/Search.js"></script>
    <script type="text/javascript" src="src/SearchResults.js"></script>
    <script type="text/javascript" src="src/NewLotSuccess.js"></script>
    <script type="text/javascript" src="src/AddAlias.js"></script>
    <script type="text/javascript" src="src/EditParent.js"></script>

    <script type="text/javascript" src="spec/testData/TestJSON.js"></script>

    <script type="text/javascript" src="custom/Lot_Custom.js"></script>

    
  	</head>

  <body>
    <script type="text/javascript">
		$(function () {
            
            window.configuration = <?php include 'custom/configuration.json' ?> ;
            window.testMode = false;
            window.configuration.serverConnection.connectToServer = false; // need to override true in the configuration file

            var currentWindowOnload = window.onload;

	      window.onload = function() {
	        if (currentWindowOnload) {
	          currentWindowOnload();
	        }
	        window.appController = new AppController({
                el: '#AppControllerView',
                user: new Backbone.Model(window.testJSON.chemistUser)
            });
	      };

		});
    </script>


	<!-- Templates -->
	
    <?php
    	include 'templates/StructureImageView.inc';
    	include 'templates/LotForm/NewIsotopeView.inc';
    	include 'templates/LotForm/NewSaltView.inc';
    	include 'templates/LotForm/SaltFormView.inc';
    	include 'templates/LotForm/SaltForm_IsoSaltEquivView.inc';
      	include 'templates/LotForm/ParentView.inc';
    	include 'templates/LotForm/MetaLotView.inc';
    	include 'MultipleFilePicker/templates/DropView.inc';
    	include 'MultipleFilePicker/templates/file_template.inc';
    	include 'MultipleFilePicker/templates/file_template_desc.inc';
    	include 'MultipleFilePicker/templates/file_template_renderer.inc';
        include 'templates/RegistrationSearchView.inc';
        include 'templates/RegSearchResults/RegSearchResultsView.inc';
        include 'templates/RegistrationView.inc';
        include 'templates/Search/SearchFormView.inc';
        include 'templates/Search/SearchView.inc';
        include 'templates/Search/SearchResultsView.inc';
        include 'templates/Search/SearchResultView.inc';
        include 'templates/AppControllerView.inc';
        include 'templates/LotForm/NewLotSuccessView.inc';
        include 'templates/ErrorNotificationView.inc';
        include 'templates/AddAliasView.inc';
        include 'templates/EditParentView.inc';
        include 'templates/EditParentSearchView.inc';
        include 'templates/EditParentSearchResultsView.inc';
		$lvTemplate = file_get_contents('custom/LotView_Custom.inc');
		echo str_replace('<\%','<%', $lvTemplate);

    ?>

    <div id="AppControllerView"></div>
    

  </body>

</html>
