# The next line is used by PrepareConfigFiles to include this file as a route in rapache, do not modify unless you intend to modify rapache routes (it can be anywhere in the files though)
# ROUTE: /curve/render/dr
# MEMORY_LIMIT_EXEMPT

renderCurve <- function(getParams) {
  # Redirect to Curator if applicable
  redirectInfo <- racas::api_get_curve_curator_url(getParams$curveIds, getParams$inTable, globalConnect = TRUE)
  if(redirectInfo$shouldRedirect == TRUE) {
    setHeader("Location", redirectInfo$url)
    return(HTTP_MOVED_TEMPORARILY)
    DONE
  }
  # Parse GET Parameters
  parsedParams <- racas::parse_params_curve_render_dr(getParams)

  # GET FIT DATA
  #fitData <- racas::get_fit_data_curve_id(parsedParams$curveIds)
  fitData <- racas::get_fit_data_curve_id(parsedParams$curveIds, globalConnect = TRUE)
  fitData <- fitData[!is.null(category) & category %in% c("inactive","potent"), c("fittedMax", "fittedMin") := {
    responseMean <- mean(points[[1]][userFlagStatus!="knocked out" & preprocessFlagStatus!="knocked out" & algorithmFlagStatus!="knocked out" & tempFlagStatus!="knocked out",]$response)
    list("fittedMax" = responseMean, "fittedMin" = responseMean)
  }, by = curveId]
  
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
  
  
  #Get Protocol Curve Display Min and Max for first curve in list
  if(any(is.na(parsedParams$yMin),is.na(parsedParams$yMax))) {
    protocol_display_values <- racas::get_protocol_curve_display_min_and_max_by_curve_id(parsedParams$curveIds[[1]])
    plotWindowPoints <- fitData[1]$points[[1]][!userFlagStatus == "knocked out" & !preprocessFlagStatus == "knocked out" & !algorithmFlagStatus == "knocked out",]
    if(nrow(plotWindowPoints) == 0) {
      plotWindow <- racas::get_plot_window(fitData[1]$points[[1]])      
    } else {
      plotWindow <- racas::get_plot_window(plotWindowPoints)      
    }
    recommendedDisplayWindow <- list(ymax = max(protocol_display_values$ymax,plotWindow[2], na.rm = TRUE), ymin = min(protocol_display_values$ymin,plotWindow[4], na.rm = TRUE))
    if(is.na(parsedParams$yMin)) parsedParams$yMin <- recommendedDisplayWindow$ymin
    if(is.na(parsedParams$yMax)) parsedParams$yMax <- recommendedDisplayWindow$ymax
  }

  #Retrieve rendering hint parameters
  if(is.na(coalesce(fitData[1]$renderingHint))) {
    fitData[ , renderingHint := get_model_fit_classes()[1]$code]
  }
  renderingOptions <- racas::get_rendering_hint_options(fitData[1]$renderingHint)
  logDose <- TRUE
  if(fitData[1]$renderingHint %in% c("Michaelis-Menten", "Substrate Inhibition")) logDose <- FALSE
  setContentType("image/png")
  setHeader("Content-Disposition", paste0("filename=\"",getParams$curveIds,"\""))
  t <- tempfile()
  racas::plotCurve(curveData = data$points, drawIntercept = renderingOptions$drawIntercept, params = data$parameters, fitFunction = renderingOptions$fct, paramNames = renderingOptions$paramNames, drawCurve = TRUE, logDose = logDose, logResponse = FALSE, outFile = t, ymin=parsedParams$yMin, ymax=parsedParams$yMax, xmin=parsedParams$xMin, xmax=parsedParams$xMax, height=parsedParams$height, width=parsedParams$width, showGrid = parsedParams$showGrid, showAxes = parsedParams$showAxes, labelAxes = parsedParams$labelAxes, showLegend=parsedParams$legend, mostRecentCurveColor = "green", axes = parsedParams$axes)
  sendBin(readBin(t,'raw',n=file.info(t)$size))
  unlink(t)
  DONE
}

renderCurve(getParams = GET)



