<script type="text/template" id="LotForm_ParentView_template">

    <div class="radioWrapper">
        <input type="radio" name="regPick" class="regPick" ></input>
        <label>New <span class="lotOrBatch"></span> <span class="corpName"></span></label>
        <select class="FormInput saltFormCorpNames"></select>
    </div>

	<div><h2>Parent Structure:</h2></div>

  <div class="parentImageWrapper">
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

		<div class="row5">
			<label class="FormLabel2">Parent Comments:</label>
			<input type="textfield" class="FormInput comment"></input>
		</div>
		<div style="clear: both;">
		</div>
  </div>

</script>
