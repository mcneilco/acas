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
		inTable <- as.logical(getParams$inTable)
	}
	if(is.null(getParams$showAxes)) {
		showAxes <- TRUE
	} else {
		showAxes <- as.logical(getParams$showAxes)
	}
	if(is.null(getParams$labelAxes)) {
		labelAxes <- TRUE
	} else {
		labelAxes <- as.logical(getParams$labelAxes)
	}
	if(is.null(getParams$legend)) {
		legend <- !inTable
	} else {
		legend <- as.logical(getParams$legend)
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
	
	data <- getCurveData(curveIds, globalConnect=TRUE)
	
	setContentType("image/png")
	t <- tempfile()
	plotCurve(curveData = data$points, params = data$parameters, fitFunction = LL4, paramNames = c("ec50", "min", "max", "slope"), drawCurve = TRUE, logDose = TRUE, logResponse = FALSE, outFile = t, ymin=yMin, ymax=yMax, xmin=xMin, xmax=xMax, height=height, width=width, showGrid = TRUE, showAxes = showAxes, labelAxes = labelAxes, showLegend=legend)
	sendBin(readBin(t,'raw',n=file.info(t)$size))
	unlink(t) 
	DONE
}
#dput(GET)
renderCurve(getParams = GET)
