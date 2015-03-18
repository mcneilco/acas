# The next line is used by PrepareConfigFiles to include this file as a route in rapache, do not modify unless you intend to modify rapache routes (it can be anywhere in the files though)
# ROUTE: /curve/render/dr-cache

renderCurve <- function(getParams) {
  # Redirect to Curator if inTable is false
  if(!is.null(getParams$inTable)) {
    if(!as.logical(getParams$inTable)) {
      if(length(curveIds == 1)) {
        experimentCode <- query(paste0("SELECT e.code_name
                                       FROM experiment e
                                       JOIN experiment_analysisgroup eag ON e.id = eag.experiment_id
                                       JOIN analysis_group ag ON ag.id = eag.analysis_group_id
                                       JOIN analysis_group_state ags on ags.analysis_group_id=ag.id
                                       JOIN analysis_group_value agv on agv.analysis_state_id=ags.id
                                       WHERE agv.string_value = ",sqliz(GET$curveIds),"
                                       AND agv.ls_kind        = 'curve id'"),globalConnect= TRUE)
        link <- paste(getSSLString(), racas::applicationSettings$client.host, ":",
                      racas::applicationSettings$client.port,
                      "/curveCurator/",experimentCode,"/",curveIds,
                      sep = "")
        setHeader("Location", link)
        return(HTTP_MOVED_TEMPORARILY)
        DONE
      }
    }
  }
  # Parse GET Parameters
  parsedParams <- racas::parse_params_curve_render_dr(getParams)

  # GET Cached Curve Data
  data <- racas::get_cached_fit_data_curve_id(parsedParams$curveIds, globalConnect = TRUE)
  data$parameters <- data$parameters[!is.null(category) && category %in% c("inactive","potent"), c("fittedmax", "fittedmin") := {
                      pts <- data$points[curveId == curveId]
                      responseMean <- mean(pts[userFlagStatus!="knocked out" & preprocessFlagStatus!="knocked out" & algorithmFlagStatus!="knocked out" & tempFlagStatus!="knocked out",]$response)
                      list("fittedmax" = responseMean, "fittedmin" = responseMean)
                    }, by = curveId]

  data$parameters <- as.data.frame(data$parameters)
  data$points <- as.data.frame(data$points)

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
    protocol_display_values <- list(ymax = data$parameters[1,]$curvedisplaymax, ymin = data$parameters[1,]$curvedisplaymin)
    plotWindow <- racas::get_plot_window(data$points)
    recommendedDisplayWindow <- list(ymax = max(protocol_display_values$ymax,plotWindow[2], na.rm = TRUE), ymin = min(protocol_display_values$ymin,plotWindow[4], na.rm = TRUE))
    if(is.na(parsedParams$yMin)) parsedParams$yMin <- recommendedDisplayWindow$ymin
    if(is.na(parsedParams$yMax)) parsedParams$yMax <- recommendedDisplayWindow$ymax
  }

  #Retrieve rendering hint parameters
  renderingOptions <- racas::get_rendering_hint_options(data$parameters[1,]$renderingHint)

  setContentType("image/png")
  setHeader("Content-Disposition", paste0("filename=",getParams$curveIds))
  t <- tempfile()
  racas::plotCurve(curveData = data$points, drawIntercept = renderingOptions$drawIntercept, params = data$parameters, fitFunction = renderingOptions$fct, paramNames = renderingOptions$paramNames, drawCurve = TRUE, logDose = TRUE, logResponse = FALSE, outFile = t, ymin=parsedParams$yMin, ymax=parsedParams$yMax, xmin=parsedParams$xMin, xmax=parsedParams$xMax, height=parsedParams$height, width=parsedParams$width, showGrid = parsedParams$showGrid, showAxes = parsedParams$showAxes, labelAxes = parsedParams$labelAxes, showLegend=parsedParams$legend)
  sendBin(readBin(t,'raw',n=file.info(t)$size))
  unlink(t)
  DONE
}

renderCurve(getParams = GET)



