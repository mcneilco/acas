<script type="text/template" id="EditParentSearchResultsView_template">

	<div><h1>Edit Parent Step 2: Review Structure Matches</h1></div>
	<div class="ReqStruc">
		<div>
			<h2>Requested Structure:</h2>
			<div class="asDrawnStructure">
			</div>
		</div>
		<!-- <div class="row2">
			<input type="radio" name="regPick" class="regPick" value="new"  checked="checked" />
			<label class="FormLabel">Continue with update</label>
		</div>
		<div class="row1 isVirtualContainer">
			<input type="checkbox" class="isVirtual" />
			<label class="FormLabel">Virtual</label>
		</div> -->
		<div class="row3">
			<label class="FormLabel">Mol. Wt.</label>
			<input type="text" class="asDrawnMolWeight" disabled="true"/>
		</div>
		<div class="row3-1">
			<label class="FormLabel">Mol. Formula</label>
			<input type="text" class="asDrawnMolFormula" disabled="true"/>
		</div>
	</div>

	<div class="EditParentSearchResultsWarning">
		<div class="errorNotification_warning">
			<span>The following matching structures were found. To be unique, the parent compound you are editing must be saved with a distinct Stereo Category/Stereo Comment combination.</span>
		</div>
		<div class="errorNotification_warning">
			<span>Or if you want to move this Lot onto one of the parents below, toggle the "Reparent lot to" radio on the desired parent structure below.</span>
		</div>

	</div>

	<div class="EditParentSearchResults_ParentListView"></div>

	<div class="buttons">
	<a class="nextButton" href="#" onclick="this.blur(); return false;"></a>
	<a class="cancelEditButton" href="#" onclick="this.blur(); return false;"></a>
	<a class="backToSearchButton" href="#" onclick="this.blur(); return false;"></a>
	</div>

</script>
