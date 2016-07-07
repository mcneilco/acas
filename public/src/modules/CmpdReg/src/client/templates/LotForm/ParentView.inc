<script type="text/template" id="LotForm_ParentView_template">

    <div class="radioWrapper">
        <input type="radio" name="regPick" class="regPick" ></input>
        <label>New <span class="lotOrBatch"></span> <span class="corpName"></span></label>
        <select class="FormInput saltFormCorpNames"></select>
    </div>

	<div><h2>Parent Structure:</h2></div>

  <div class="parentImageWrapper">
  </div>

	<div class="editParentButtonWrapper">
		<a class="editParentButton" href="#" onclick="this.blur(); return false;"></a>
	</div>

	<div class="marvinWrapper hide"> <!--dependent? change name...-->
		<iframe src="/src/modules/CmpdReg/src/marvinjs/editorws.html" id="editParentMarvinSketch" class="sketcher-frame"></iframe>
	</div>

  <div class="parentStructureForm">
	  <div class="bv_aliasesContainer">

	  </div>

	 	<div class="row4">
			<label class="FormLabel2">Stereo Category:</label>
			<select class="FormInput stereoCategoryCode"></select>
		</div>

		<div class="row4">
			<label class="FormLabel2">Stereo Comments:</label>
			<input type="textfield" class="FormInput stereoComment"></input>
		</div>

	 	<div class="row5 bv_compoundTypeContainer">
			<label class="FormLabel2">Compound Type:</label>
			<select class="FormInput compoundTypeCode"></select>
		</div>

	 	<div class="row5 bv_parentAnnotationContainer">
			<label class="FormLabel2">High Value Annotation:</label>
			<select class="FormInput parentAnnotationCode"></select>
		</div>

		<div class="row5">
			<label class="FormLabel2">Parent Mol. Wt.:</label>
			<input type="textfield" class="FormInput molWeight" disabled=true></input>
		</div>

		<div class="row5">
			<label class="FormLabel2">Exact Mass:</label>
			<input type="textfield" class="FormInput exactMass" disabled=true></input>
		</div>

		<div class="row5">
			<label class="FormLabel2">Mol. Formula:</label>
			<input type="textfield" class="FormInput molFormula" disabled=true></input>
		</div>

		<div class="row5 parentComments">
			<label class="FormLabel2">Parent Comments:</label>
			<textarea rows="3" class="FormInput comment" style="resize:none; width:515px;"></textarea>
		</div>
		<div style="clear: both;">
		</div>
  </div>

	<div class="EditParentViewButtons buttons hide">
		<a class="button bv_saveUpdateParentButton saveUpdateParentButtonOn" href="#" onclick="this.blur(); return false;"></a>
		<a class="button bv_cancelUpdateParentButton cancelUpdateParentButtonOn" href="#" onclick="this.blur(); return false;"></a>
		<a class="button bv_backUpdateParentButton backUpdateParentButtonOn" href="#" onclick="this.blur(); return false;"></a>
	</div>

	<div class="ConfirmEditParentPanel hide"></div>
	<div class="ParentUpdatedPanel hide"></div>

</script>

<script type="text/template" id="ConfirmEditParentPanel_template">

    <div class="floatingPanel ">
        <h2 class="form_title">Confirm Update</h2>
        <hr />
        <h3 class="confirmUpdateParentMessage lotsAffected"></h3>
        <h3 class="confirmUpdateParentMessage">Are you sure you want to update this parent?</h3>
        <div class="confirmUpdateParent"></div>
        <div class="cancelUpdateParent"></div>
    </div>


</script>

<script type="text/template" id="ParentUpdatedPanel_template">

    <div class="floatingPanel ">
        <h2 class="form_title">Parent Updated Successfully</h2>
        <hr />
        <h3 class="updatedLotsMessage"></h3>
        <div class="closeParentUpdatedPanel"></div>
    </div>


</script>
