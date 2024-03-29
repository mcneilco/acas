<script type="text/template" id="LotForm_ParentView_template">

	<div class="radioWrapper">
		<label><input id="newLot" type="radio" name="regPick" class="regPick" ></input>New <span class="lotOrBatch"></span> <span class="corpName"></span></label>
		
		<select class="FormInput saltFormCorpNames"></select>
	</div>

	<div class="reparentLotWrapper hide">
		<label><input id="reparentLot" type="radio" name="reparentLotPick" class="reparentLotPick" ></input>Reparent <span class="lotOrBatch"></span> to <span class="corpName"></span></label>
	</div>

	<div><h2>Parent Structure:</h2></div>

  <div class="parentImageWrapper">
  </div>

	<div class="editParentButtonWrapper">
		<a class="editParentButton" href="#" onclick="this.blur(); return false;"></a>
		<span class="editParentButtonDisabled"></span>
		<div class="disableCmpdRegistrationMessage hide"></div>
	</div>

	<div class="marvinWrapper hide">
	</div>

  <div class="parentStructureForm">
	  <div class="bv_aliasesContainer">

	  </div>
		<div>
			<input type="checkbox" class="isMixture"/>
			Is Mixture
		</div>

		<div class="row3 bv_labelPrefix">
					<label class="FormLabel2">*Prefix:</label>
					<select class="FormInput labelPrefix"></select>
		</div>

	 	<div class="row4">
			<label class="FormLabel2">*Stereo Category:</label>
			<select class="FormInput stereoCategoryCode"></select>
		</div>

		<div class="row4">
			<label class="FormLabel2">Stereo Comments:</label>
			<input type="textfield" class="FormInput stereoComment"></input>
		</div>

	 	<div class="row5 bv_compoundTypeContainer">
			<label class="FormLabel2">*Compound Type:</label>
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

	<div class="ReparentLotButtons buttons hide">
		<a class="button bv_saveReparentLotButton saveReparentLotButtonOn" href="#" onclick="this.blur(); return false;"></a>
		<a class="button bv_cancelReparentLotButton cancelReparentLotButtonOn" href="#" onclick="this.blur(); return false;"></a>
		<a class="button bv_backReparentLotButton backReparentLotButtonOn" href="#" onclick="this.blur(); return false;"></a>
	</div>

	<div class="ValidateParentErrorsPanel hide"></div>
	<div class="ConfirmEditParentPanel hide"></div>
	<div class="ParentUpdatedPanel hide"></div>

</script>

<script type="text/template" id="ValidateParentErrorsPanel_template">
	<div class="floatingPanel ">
		<h2 class="form_title">Invalid Parent Compound</h2>
		<hr />
		<h3 class="validateParentErrorsMsg">The parent is invalid due to the following reasons. Please fix the errors before attempting to update the parent again.</h3>
		<div class="parentErrors"></div>
		<div class="closeValidateParentErrors"></div>
	</div>
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
