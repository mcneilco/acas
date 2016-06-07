<script type="text/template" id="NewSaltView_template">
	<h2 class="form_title">Register New Salt:</h2>
	<hr>
		<div class="marvinWrapper">
			<iframe src="/src/modules/CmpdReg/src/marvinjs/editorws.html" id="newSaltMarvinSketch" class="sketcher-frame"></iframe>
		</div>
		<div class="corpNameInput">
		<label class="FormLabel">Salt Name </label>
		<input type=text class="salt_name" />
	</div>
	<div>
		<label class="FormLabel">Salt Abbreviation </label>
		<input type=text class="salt_abbrev" />
	</div>
	<input type=button class="saveNewSaltButton" />
	<input type=button class="cancelNewSaltButton" />
</script>