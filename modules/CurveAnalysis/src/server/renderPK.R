# The next line is used by PrepareConfigFiles to include this file as a route in rapache, do not modify unless you intend to modify rapache routes (it can be anywhere in the files though)
# ROUTE: /curve/render/pk

renderCurve <- function(getParams) {
  # Get data
  if(is.null(getParams$ymin)) {
    yMin <- NA
  } else {
    yMin <- as.numeric(getParams$ymin)
  }
  if(!is.null(getParams$yNormMin)) {
    yMin <- as.numeric(getParams$yNormMin)
  }
  if(is.null(getParams$ymax)) {
    yMax <- NA
  } else {
    yMax <- as.numeric(getParams$ymax)
  }
  if(!is.null(getParams$yNormMax)) {
    yMax <- as.numeric(getParams$yNormMax)
  }
  if(is.null(getParams$xmin)) {
    xMin <- NA
  } else {
    xMin <- as.numeric(getParams$xmin)
  }
  if(!is.null(getParams$xNormMin)) {
    xMin <- as.numeric(getParams$xNormMin)
  }
  if(is.null(getParams$xmax)) {
    xMax <- NA
  } else {
    xMax <- as.numeric(getParams$xmax)
  }
  if(!is.null(getParams$xNormMax)) {
    xMax <- as.numeric(getParams$xNormMax)
  }
  if(is.null(getParams$height)) {
    height <- 500
  } else {
    height <- as.numeric(getParams$height)
  }
  if(!is.null(getParams$cellHeight)) {
    height <- as.numeric(getParams$cellHeight)
  }
  if(is.null(getParams$width)) {
    width <- 700
  } else {
    width <- as.numeric(getParams$width)
  }
  if(!is.null(getParams$cellWidth)) {
    width <- as.numeric(getParams$cellWidth)
  }
  if(is.null(getParams$inTable)) {
    inTable <- FALSE
  } else {
    if(getParams$inTable=="true") {
      inTable <- TRUE
    } else {
      inTable <- FALSE
    }
  }
  if(is.null(getParams$axes)) {
    axes <- c("x","y")
  } else {
    axes <- strsplit(getParams$axes,",")[[1]]
  }
  if(is.null(getParams$showAxes)) {
    showAxes <- TRUE
  } else {
    if(getParams$showAxes=="true") {
      showAxes <- TRUE
    } else {
      showAxes <- FALSE
    }
  }

  if(is.null(getParams$legend)) {
    legend <- !inTable
  } else {
    if(getParams$legend=="true") {
      legend <- TRUE
    } else {
      legend <- FALSE
    }
  }

  if(is.null(getParams$curveIds)) {
    stop("curveIds not provided, provide curveIds")
    DONE
  } else {
    curveIds <- getParams$curveIds
    curveIdsStrings <- strsplit(curveIds,",")[[1]]
    curveIds <- suppressWarnings(as.integer(curveIds))
    if(is.na(curveIds)) {
      curveIds <- curveIdsStrings
    }
  }

  data <- racas::getCurveData(curveIds, globalConnect=TRUE)

  setContentType("image/png")
  setHeader(header="Cache-Control",value="max-age=1000000000000");
  setHeader(header="Expires",value="Thu, 31 Dec 2099 24:24:24 GMT");
  t <- tempfile()
  plotCurve(curveData = data$points, params = data$parameters, paramNames = NA, outFile = t, ymin=yMin, logDose = FALSE, logResponse = TRUE, ymax=yMax, xmin=xMin, xmax=xMax, height=height, width=width, showGrid = FALSE, showLegend=legend, plotMeans = FALSE, connectPoints = TRUE, drawCurve = FALSE, showAxes = showAxes, axes = axes, addShapes = TRUE, labelAxes = TRUE, drawStdDevs = TRUE)
  sendBin(readBin(t,'raw',n=file.info(t)$size))
  unlink(t)
  DONE
}

renderCurve(getParams = GET)
