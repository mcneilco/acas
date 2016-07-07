<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
  "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
  <title>CmpdReg Spec Runner</title>

  <link rel="shortcut icon" type="image/png" href="lib/jasmine-1.1.0/jasmine_favicon.png">

  <link rel="stylesheet" type="text/css" href="lib/jasmine-1.1.0/jasmine_nocompile.css">
<!--  <link rel="stylesheet" type="text/css" href="css/NewCmpdReg.css">-->
  <script type="text/javascript" src="lib/jasmine-1.1.0/jasmine.js"></script>
  <script type="text/javascript" src="lib/jasmine-1.1.0/jasmine-html.js"></script>

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
<!--  <script LANGUAGE="JavaScript1.1" SRC="marvin/marvin.js"></script> -->
<!-- for marvin js -->
 	<link type="text/css" rel="stylesheet" href="../marvinjs/js/lib/rainbow/github.css" />
 	<script src="../marvinjs/js/lib/rainbow/rainbow-custom.min.js"></script>
 	<script src="../marvinjs/gui/lib/promise-1.0.0.min.js"></script>
 	<script src="../marvinjs/js/marvinjslauncher.js"></script>

  <!-- include source files here... -->
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
  <script type="text/javascript" src="src/SearchForm.js"></script>
  <script type="text/javascript" src="src/Search.js"></script>
  <script type="text/javascript" src="src/SearchResults.js"></script>
  <script type="text/javascript" src="src/NewLotSuccess.js"></script>
  <script type="text/javascript" src="src/AddAlias.js"></script>

  <script type="text/javascript" src="custom/Lot_Custom.js"></script>


  <!-- include spec files here... -->
  <script type="text/javascript" src="spec/NewCmpdRegSpec.js"></script>
  <script type="text/javascript" src="spec/IsoptopeSpec.js"></script>
  <script type="text/javascript" src="spec/SaltSpec.js"></script>
  <script type="text/javascript" src="spec/ErrorNotificationSpec.js"></script>
  <script type="text/javascript" src="spec/Isotope_ErrorNotificationIntegrationSpec.js"></script>
  <script type="text/javascript" src="spec/IsoSaltEquivSpec.js"></script>
  <script type="text/javascript" src="spec/SaltFormSpec.js"></script>
  <script type="text/javascript" src="spec/testData/TestJSON.js"></script>
  <script type="text/javascript" src="spec/PickListSpec.js"></script>
  <script type="text/javascript" src="spec/StructureImageSpec.js"></script>
  <script type="text/javascript" src="spec/ParentSpec.js"></script>
  <script type="text/javascript" src="spec/MetaLotSpec.js"></script>
  <script type="text/javascript" src="spec/RegistrationSearchSpec.js"></script>
  <script type="text/javascript" src="spec/SaltFormListSpec.js"></script>
  <script type="text/javascript" src="spec/ParentListSpec.js"></script>
  <script type="text/javascript" src="spec/RegSearchResultsSpec.js"></script>
  <script type="text/javascript" src="spec/SearchFormSpec.js"></script>
  <script type="text/javascript" src="spec/SearchResultsSpec.js"></script>
  <script type="text/javascript" src="spec/NewLotSuccessSpec.js"></script>
  <script type="text/javascript" src="spec/AddAliasSpec.js"></script>

  <script type="text/javascript" src="custom/LotSpec_Custom.js"></script>


  <script type="text/javascript">
    $(function() {

     // constants for the application

      window.configuration = <?php include 'custom/configurationSpec.json' ?> ;

     //constants for testing

      window.testMode = true;
      window.appController = null;
      window.configuration.serverConnection.connectToServer = false; // need to override true in the configuration file

      var jasmineEnv = jasmine.getEnv();
      jasmineEnv.updateInterval = 1000;

      var trivialReporter = new jasmine.TrivialReporter();

      jasmineEnv.addReporter(trivialReporter);

      jasmineEnv.specFilter = function(spec) {
        return trivialReporter.specFilter(spec);
      };

      var currentWindowOnload = window.onload;

      window.onload = function() {
        if (currentWindowOnload) {
          currentWindowOnload();
        }
        execJasmine();
      };

      function execJasmine() {
        jasmineEnv.execute();
      }

        window.waitIfServer= function() {
            if(window.configuration.serverConnection.connectToServer) {
                waits(500);
            } else {
                waits(100);
            }
        }
    });
  </script>

</head>

<body>
	<div id="fixture"></div>
	<!-- Todo App Interface -->

	<?php include 'templates/AppControllerView.inc'; ?>

	<!-- Templates -->

    <?php
    	include 'templates/StructureImageView.inc';
    	include 'templates/LotForm/NewIsotopeView.inc';
    	include 'templates/LotForm/NewSaltView.inc';
    	include 'templates/LotForm/SaltForm_IsoSaltEquivView.inc';
    	include 'templates/LotForm/SaltFormView.inc';
    	include 'templates/LotForm/ParentView.inc';
    	include 'templates/LotForm/MetaLotView.inc';
    	include 'MultipleFilePicker/templates/DropView.inc';
    	include 'MultipleFilePicker/templates/file_template.inc';
    	include 'MultipleFilePicker/templates/file_template_desc.inc';
    	include 'MultipleFilePicker/templates/file_template_renderer.inc';
        include 'templates/RegistrationSearchView.inc';
        include 'templates/RegSearchResults/RegSearchResultsView.inc';
        include 'templates/Search/SearchView.inc';
        include 'templates/Search/SearchFormView.inc';
        include 'templates/Search/SearchResultsView.inc';
        include 'templates/Search/SearchResultView.inc';
        include 'templates/LotForm/NewLotSuccessView.inc';
        include 'templates/ErrorNotificationView.inc';
        include 'templates/AddAliasView.inc';

		$lvTemplate = file_get_contents('custom/LotView_Custom.inc');
		echo str_replace('<\%','<%', $lvTemplate);

    ?>
<!-- Isotope system test elements -->
    		Isotope 1:<select id="LotForm_SaltFormIsotopeSelect-1View"><option value=''>none</option></select>
    		Isotope 2:<select id="LotForm_SaltFormIsotopeSelect-2View"><option value=''>none</option></select>
    		<div id="NewIsotopeView"></div>

<!-- Salt test elements -->
    		Salt 1:<select id="LotForm_SaltFormSaltSelect-1View"><option value=''>none</option></select>
    		Salt 2:<select id="LotForm_SaltFormSaltSelect-2View"><option value=''>none</option></select>
     		<div id="NewSaltView"></div>

<!-- Error notification test elements -->
   		<div id="ErrrorNotificationListView"></div>

<!-- IsoSaltEquiv tests -->
		<div id="testIsoSaltEquivController"></div>
		<div id="testIsoSaltEquivListController"></div>

<!-- LotForm_SaltFormView tests -->
		<div id="LotForm_SaltFormView"></div>


<!-- LotForm tests -->
		<div id="LotForm_LotView"</div>
<!-- PickList tests -->
		<select id="pickListTestView"></select>
<!-- StructureImage tests -->
		<div id="structImageTestView"></div>

<!-- Parent tests -->
        <div id="LotForm_ParentView"></div>
<!-- MetaLot tests -->
        <div id="MetaLotView"></div>
<!-- RegistrationSearch tests -->
        <div id="RegistrationSearchView"></div>

<!-- SaltFormListController tests -->
        <select id="SaltFormListControllerView"></select>
<!-- ParentListController tests -->
        <div id="ParentListControllerView"></div>
<!-- RegSearchResultsController tests -->
        <div id="RegSearchResultsView"></div>
<!-- SearchFormController tests -->
        <div class="SearchFormView"></div>
<!-- SearchResultController tests -->
        <div class="SearchResView"></div>
<!-- SearchResultListController tests -->
        <div class="SearchResultListView"></div>
<!-- SearchResultsController tests -->
        <div class="SearchResultsView"></div>

<!-- NewLotSuccessController tests -->

        <div class="NewLotSuccessView"></div>

    </div>
</body>
</html>
