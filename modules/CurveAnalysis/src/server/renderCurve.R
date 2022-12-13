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
  
  # Get protocol curve min and max
  protocol_display_values <- racas::get_protocol_curve_display_min_and_max_by_curve_id(parsedParams$curveIds[[1]])

  #Retrieve rendering hint parameters
  if(is.na(coalesce(fitData[1]$renderingHint))) {
    fitData[ , renderingHint := get_model_fit_classes()[1]$code]
  }
  
  # Get rendering for specific rendering hints
  fitData[ , renderingOptions := list(list(get_rendering_hint_options(renderingHint))), by = renderingHint]

  output <- applyParsedParametersToFitData(fitData, parsedParams, protocol_display_values)
  data <- output$data
  parsedParams <- output$parsedParams
  
  setContentType("image/png")
  setHeader("Content-Disposition", paste0("filename=\"",strtrim(getParams$curveIds,200),".png\""))
  t <- tempfile()
  racas::plotCurve(curveData = data$points, params = data$parameters, drawCurve = TRUE, logDose = parsedParams$logDose, logResponse = parsedParams$logResponse, outFile = t, ymin=parsedParams$yMin, ymax=parsedParams$yMax, xmin=parsedParams$xMin, xmax=parsedParams$xMax, height=parsedParams$height, width=parsedParams$width, showGrid = parsedParams$showGrid, showAxes = parsedParams$showAxes, labelAxes = parsedParams$labelAxes, showLegend=parsedParams$legend, mostRecentCurveColor = parsedParams$mostRecentCurveColor, axes = parsedParams$axes, plotColors = parsedParams$plotColors, curveLwd=parsedParams$curveLwd, plotPoints=parsedParams$plotPoints, xlabel = parsedParams$xLab, ylabel = parsedParams$yLab)
  sendBin(readBin(t,'raw',n=file.info(t)$size))
  unlink(t)
  DONE
}

postData <- rawToChar(receiveBin(-1))
renderCurve(getParams = GET, postData)



