# The next line is used by PrepareConfigFiles to include this file as a route in rapache, do not modify unless you intend to modify rapache routes (it can be anywhere in the files though)
# ROUTE: /curve/render/dr
# MEMORY_LIMIT_EXEMPT
library(data.table)


renderCurve <- function(getParams, postData) {

  # Redirect to Curator if applicable
  redirectInfo <- racas::api_get_curve_curator_url(getParams$curveIds, getParams$inTable, globalConnect = TRUE)
  if(redirectInfo$shouldRedirect == TRUE) {
    setHeader("Location", redirectInfo$url)
    return(HTTP_MOVED_TEMPORARILY)
    DONE
  }

  postParams <- NA
  if(!is.null(postData) && !is.na(postData) && postData != "") {
    postParams <- jsonlite::fromJSON(postData)
  }  
  # Parse GET Parameters
  parsedParams <- racas::parse_params_curve_render_dr(getParams, postParams)


  # GET FIT DATA
  fitData <- racas::get_curve_data(parsedParams$curveIds, raw_data = TRUE, globalConnect = TRUE)
  
  # Colors
  # plotColors <- c("black", "#0C5BB0FF", "#EE0011FF", "#15983DFF", "#EC579AFF", "#FA6B09FF", 
  #                 "#149BEDFF", "#A1C720FF", "#FEC10BFF", "#16A08CFF", "#9A703EFF")
  plotColors <- trimws(strsplit(racas::applicationSettings$server.curveRender.plotColors,",")[[1]])
  if(!is.na(parsedParams$colorBy)) {
    key <- switch(parsedParams$colorBy,
                "protocol" = "protocol_label",
                "experiment" = "experiment_label",
                "batch" = "batch_code"
    )
    uniqueKeys <- setkeyv(unique(fitData[ , key, with = FALSE]), key)
    colorCategories <- suppressWarnings(uniqueKeys[, color:=plotColors][ , name:=get(key)])
    fitData <- merge(fitData, colorCategories, by = key)
  }
  
  fitData <- fitData[exists("category") && (!is.null(category) & category %in% c("inactive","potent")), c("fittedMax", "fittedMin") := {
    responseMean <- mean(points[[1]][userFlagStatus!="knocked out" & preprocessFlagStatus!="knocked out" & algorithmFlagStatus!="knocked out" & tempFlagStatus!="knocked out",]$response)
    list("fittedMax" = responseMean, "fittedMin" = responseMean)
  }, by = curveId]

  fitData[ , renderingOptions := list(list(get_rendering_hint_options(renderingHint))), by = renderingHint]

  data <- list(parameters = as.data.frame(fitData), points = as.data.frame(rbindlist(fitData$points)))
  
  #To be backwards compatable with hill slope example files
  hillSlopes <- which(!is_null_or_na(data$parameters$hillslope))
  if(length(hillSlopes) > 0  ) {
    data$parameters$slope <- -data$parameters$hillslope[hillSlopes]
  }
  fittedHillSlopes <- which(!is_null_or_na(data$parameters$fitted_hillslope))
  if(length(fittedHillSlopes) > 0 ) {
    data$parameters$fitted_slope <- -data$parameters$fitted_hillslope[fittedHillSlopes]
  }
  
  if(!is.na(parsedParams$logDose)) {
    logDose <- parsedParams$logDose
  } else {
    logDose <- TRUE
    if(fitData[1]$renderingHint %in% c("Michaelis-Menten", "Substrate Inhibition", "Scatter", "Scatter Log-y")) logDose <- FALSE
  }

  if(!is.na(parsedParams$logResponse)) {
    logResponse <- parsedParams$logResponse
  } else {
    logResponse <- FALSE
    if(fitData[1]$renderingHint %in% c("Scatter Log-y","Scatter Log-x,y")) logResponse <- TRUE
  }

  #Get Protocol Curve Display Min and Max for first curve in list
  if(any(is.na(parsedParams$yMin),is.na(parsedParams$yMax))) {
    protocol_display_values <- racas::get_protocol_curve_display_min_and_max_by_curve_id(parsedParams$curveIds[[1]])
    plotWindowPoints <- rbindlist(fitData[ , points])[!userFlagStatus == "knocked out" & !preprocessFlagStatus == "knocked out" & !algorithmFlagStatus == "knocked out",]
    if(nrow(plotWindowPoints) == 0) {
      plotWindow <- racas::get_plot_window(fitData[1]$points[[1]], logDose = logDose, logResponse = logResponse)      
    } else {
      plotWindow <- racas::get_plot_window(plotWindowPoints, logDose = logDose, logResponse = logResponse)
    }
    recommendedDisplayWindow <- list(ymax = max(protocol_display_values$ymax,plotWindow[2], na.rm = TRUE), ymin = min(protocol_display_values$ymin,plotWindow[4], na.rm = TRUE))
    if(is.na(parsedParams$yMin)) parsedParams$yMin <- recommendedDisplayWindow$ymin
    if(is.na(parsedParams$yMax)) parsedParams$yMax <- recommendedDisplayWindow$ymax
  }

  #Retrieve rendering hint parameters
  if(is.na(coalesce(fitData[1]$renderingHint))) {
    fitData[ , renderingHint := get_model_fit_classes()[1]$code]
  }
  
  setContentType("image/png")
  setHeader("Content-Disposition", paste0("filename=\"",strtrim(getParams$curveIds,200),".png\""))
  t <- tempfile()
  racas::plotCurve(curveData = data$points, params = data$parameters, drawCurve = TRUE, logDose = logDose, logResponse = logResponse, outFile = t, ymin=parsedParams$yMin, ymax=parsedParams$yMax, xmin=parsedParams$xMin, xmax=parsedParams$xMax, height=parsedParams$height, width=parsedParams$width, showGrid = parsedParams$showGrid, showAxes = parsedParams$showAxes, labelAxes = parsedParams$labelAxes, showLegend=parsedParams$legend, mostRecentCurveColor = parsedParams$mostRecentCurveColor, axes = parsedParams$axes, plotColors = parsedParams$plotColors, curveLwd=parsedParams$curveLwd, plotPoints=parsedParams$plotPoints, xlabel = parsedParams$xLab, ylabel = parsedParams$yLab)
  sendBin(readBin(t,'raw',n=file.info(t)$size))
  unlink(t)
  DONE
}

postData <- rawToChar(receiveBin(-1))
renderCurve(getParams = GET, postData)



