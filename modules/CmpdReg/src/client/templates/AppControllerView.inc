
<script type="text/template" id="AppControllerView_template">

	<div id="header">
		<h1 class="applicationName">New Compound Registration</h1>
		<div class="userLabel">Welcome:</div>
		<div class="loggedInUser"></div>
		<div class="logout"><a class="logoutLink">logout<a/></div>
	</div>
	<div id="content">

		<hr>
		<div class="regAndSearchButtons">

			<div class="regAndSearchButtonsInner">
				<a class="searchButton applicationPage" href="#" onclick="this.blur(); return false;"></a>
				<a class="registerButton applicationPage" href="#" onclick="this.blur(); return false;"></a>
			</div>
		</div>

		<div class="RegistrationView"></div>
		<div class="SearchView"></div>
		<div class="MetaLotView"></div>
        <div class="bottomPad"></div>

		<div class="ErrrorNotificationListView"></div>

		<div class="GetCmpdError hide" style="text-align: center;">
			<h1>Compound does not exist.</h1>
		</div>

	</div>

	<div id="footer"><p>&#169; 2011-2018 John McNeil & Co., Inc.</p></div>


</script>
