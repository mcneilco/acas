<script type="text/template" id="SearchFormView_template">

    <div class="StructureMain">
		<h2><label class="QueryStructure">Query Structure:</label></h2>
		<div class="marvinContainer">
			<iframe src="/src/modules/CmpdReg/src/marvinjs/editorws.html" id="searchMarvinSketch" class="sketcher-frame" data-toolbars="search"></iframe>
		</div>
	    <div class="registrationSearchMarvinSize"></div>
	</div>

	<div class="CSfields">
		<div>
			<label class="FormLabel corpNameLabel">Corporate Name</label>
			<input type="text" class="FormInput corpNameFrom"/>
			<label class="FormLabel"></label>to
			<input type="text" class="FormInput corpNameTo" />
		</div>
		<div>
			<label class="FormLabel">Alias</label>
			<select class="FormInput aliasContSelect" >
				<option value="contains">contains</option>
				<option value="exact">exact</option>
			 </select>
				<label class="FormLabel"></label><font color="white">to</font>
				<input type="text" class="FormInput alias" />
		</div>
		<div>
			<label class="FormLabel">Synthesis date range</label>
			<input type="text" class="FormInput dateFrom" />
			<label class="FormLabel"></label>to
			<input type="text" class="FormInput dateTo" />
		</div>
		<div>
			<label class="FormLabel">Chemist</label>
			<select class="FormInput chemist" >
				<option value="anybody">anybody</option>
			</select>
		</div>
		<div>
			<label class="FormLabel maxResultsLabel">Max. No. of Search Results</label>
			<input type="text" class="FormInput maxResults"/>
		</div>
	</div>
	
	<div class="StructureMainOpt">
		<div>
			<input type="radio" class="searchType" name="searchType" value="substructure"  checked="checked"/>
			<label class="FormLabel2">Substructure</label>
		</div>
		<div>
			<input type="radio" class="searchType" name="searchType" value="exact" />
			<label class="FormLabel2">Exact</label>
		</div>
		<div>
			<input type="radio" class="searchType" name="searchType" value="similarity" />
			<label class="FormLabel2">Similarity</label>
		</div>
		<div>
			<input type="text" class="FormInput percentSimilarity" value="90"/>
			<label class="FormLabel2">% Similarity</label>
		</div>
	</div>

	<div class="buttons">
		<a class="searchButton" href="#" onclick="this.blur(); return false;"></a>
		<a class="cancelButton" href="#" onclick="this.blur(); return false;"></a>
	</div>

</script>
