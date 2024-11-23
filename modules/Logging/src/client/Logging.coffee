class Logging extends Backbone.Model

class LoggingController1 extends Backbone.View
	template: _.template($("#LoggingView").html())

	initialize: (options) ->
		@options = options
		@errorOwnerName = 'LoggingController'
		unless @model?
			@model = new Logging()


	render: =>
		$(@el).empty()
		$(@el).html @template @model.attributes

		@

class LoggingController extends Backbone.View
	initialize: (options) ->
		@options = options
		if AppLaunchParams.loggingToMongo
			@loggingApp = new MongoLoggingController()
		else
			@loggingApp = new FileLoggingController()

	render: =>
		$(@el).empty()
		$(@el).html(@loggingApp.render().el)

class FileLoggingController extends Backbone.View

	render: =>
		$(@el).empty()
		$(@el).html("<textarea class='bv_logs' style='width: 100%;'rows='30'></textarea><br /><a href='/api/logFile'>Download Logs</a>")
		$.get("/api/logFile", (data) =>
			@$(".bv_logs").val data
		)
		@

	updateLogFiltering: =>
		filter = @filterMenuController.getFilters()
		@logs.url = "/api/logger/" + filter
		@logs.fetch()

class MongoLoggingController extends Backbone.View
	template: $("#app-view").html()
	initialize: (options) ->
		@options = options
		@logs = new LogList()

	render: =>
		$(@el).empty()
		$(@el).html(@template)
		@logsController = new LogListController({el: ".bv_logTable", collection: @logs})
		@filterMenuController = new LogFilterMenu({el: ".bv_filtersMenu"})
		@filterMenuController.render()
		@filterMenuController.bind "filterChanged", @updateLogFiltering
		#@graphLogStats = new GraphLogStats({el: ".bv_logStats", collection: @logs})
		@logs.fetch()

		@

	updateLogFiltering: =>
		filter = @filterMenuController.getFilters()
		@logs.url = "/api/logger/" + filter
		@logs.fetch()

class LogEntry extends Backbone.Model
	url: "/api/logger/"

	defaults:
		level: "na"
		sourceApp: "na"
		action: "na"
		user: "na"
		data: "na"
		timestamp: "na"

	initialize: (options) ->
		@options = options
		@set "sourceApp", @attributes.meta.sourceApp
		@set "action", @attributes.meta.action
		@set "user", @attributes.meta.user
		@set "data", @attributes.meta.data


class LogList extends Backbone.Collection
	url: "/api/logger/"
	model: LogEntry

	getLogTypeStats: =>
		stats = {info: 0, warn: 0, error: 0}
		@models.forEach (model) ->
			if model.get("level")
				stats[model.get("level")]++
		statsArray = []
		for key, value of stats
			statsArray.push([key, value])
		statsArray


class LogListController extends Backbone.View
	template: $("#log-list-view").html()
	initialize: (options) ->
		@options = options
		@collection.bind "fetch", @render
		@collection.bind "change", @render
		@collection.bind "add", @render

	render: =>

		$(@el).empty()
		$(@el).html(@template)

		@addAllItems()

	addAllItems: =>
		@collection.each (item) =>
			@addItem item

	addItem: (item) =>
		log = new LogEntryController model: item
		@$('.bv_logListBody').append(log.render().el)

class LogEntryController extends Backbone.View
	tagName: 'tr'
	template: $("#log-entry-item").html()
	render: =>
		@$el.empty()
		template = _.template( @template, @model.toJSON())
		@$el.html(template)
		styleName = ""

		if @model.get("level") is "warn"
			styleName = "warning"
		else if @model.get("level") is "error"
			styleName = "danger"
		else if @model.get("level") is "info"
			styleName = "active"
		$(@el).addClass(styleName)
		# always return @ (reference to this objects 'this') to allow method chaining
		@

class LogFilterMenu extends Backbone.View
	template: $("#log-filters-menu").html()

	initialize: (options) ->
		@options = options
		@usersList = new UsersList()
		@appSourcesList = new ApplicationSourcesList()


	events:
		"change .bv_logLevel": "filterChanged"
		"change .bv_application": "filterChanged"
		"change .bv_user": "filterChanged"

	filterChanged: =>
		@trigger "filterChanged"

	getFilters: =>
		"#{@$(".bv_logLevel").val()}/#{@$(".bv_application select").val()}/#{@$(".bv_user select").val()}"

	render: =>
		$(@el).empty()
		$(@el).html(@template)

		@usersPickList = new PickList({el: ".bv_user", collection: @usersList})
		@usersList.fetch()
		@appSourcesPickList = new PickList({el: ".bv_application", collection: @appSourcesList})
		@appSourcesList.fetch()

		@

class ApplicationSourcesList extends Backbone.Collection
	url: '/api/logger/applicationSources'

class UsersList extends Backbone.Collection
	url: '/api/logger/users'

class GraphLogStats extends Backbone.View
	template: $("#log-stats-view").html()
	initialize: (options) ->
		@options = options
		@collection.bind "fetch", @render
		@collection.bind "change", @render
		@collection.bind "add", @render
	render: =>
		$(@el).empty()
		$(@el).html(@template)
		data = @collection.getLogTypeStats()
		plot1 = jQuery.jqplot("chart1", [data],
			seriesDefaults:
				renderer: jQuery.jqplot.PieRenderer
				rendererOptions:
					showDataLabels: true
			legend:
				show: true
				location: "e"
		)


