<script type="text/template" id="RegSearchResultsView_template">

	<div><h1>Registration Step 2: Review Structure Matches</h1></div>
	<div class="ReqStruc">
		<div>
            <h2>Requested Structure:</h2>
            <div class="asDrawnStructure">
            </div>
		</div>
        <div class="row2">
            <input type="radio" name="regPick" class="regPick" value="new"  checked="checked" />
            <label class="FormLabel">Register new structure</label>
        </div>
        <div class="row1 isVirtualContainer">
            <input type="checkbox" class="isVirtual" />
            <label class="FormLabel">Virtual</label>
        </div>
        <div class="row3">
            <label class="FormLabel">Mol. Wt.</label>
            <input type="text" class="asDrawnMolWeight" disabled="true"/>
        </div>
        <div class="row3-1">
            <label class="FormLabel">Mol. Formula</label>
            <input type="text" class="asDrawnMolFormula" disabled="true"/>
        </div>
	</div>

	<div class="RegSearchResults_ParentListView"></div>

	<div class="buttons">
	<a class="nextButton" href="#" onclick="this.blur(); return false;"></a>
	<a class="cancelButton" href="#" onclick="this.blur(); return false;"></a>
	<a class="backButton" href="#" onclick="this.blur(); return false;"></a>
	</div>
	
</script>
