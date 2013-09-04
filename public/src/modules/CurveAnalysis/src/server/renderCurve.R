
PlotCurve <- function(curveData,params, outFile = NA, ymin, ymax, xmin = NA, xmax, height, width, showLegend, axes = axes) {
	
	#Input:
		#curveData: the raw data points
		#params: the set of calculated parameters from condoseo used to draw and enumerate the curve
		#outFile: The folder where the image will be saved
	#Output:
		#A PNG
	
	#Plotting log data so check to make sure xmax,xmin are ok
	if(!is.na(xmin)) {
		if(xmin <= 0) {
			xmin = 0.001
		}
	}
	if(!is.na(xmax) && !is.na(xmin)) {
		if(xmax <= xmin) {
			xmin = NA
			xmax = NA
		}
	}
	
	
	#Assign Colors
	plotColors <- rep(c("black","green","red", "blue", "orange","purple", "cyan"),100, replace = TRUE)
	params$color <- plotColors[1:nrow(params)]
	curveData$color <- plotColors[match(curveData$curveid,params$curveid)]

	#Gets the Curve Intercept at the AC50
	maxDose <- max(curveData$dose)
	minDose <- min(curveData$dose)
	maxResponse <- max(curveData$response)
	minResponse <- min(curveData$response)
	range <- abs(maxResponse-minResponse)
	if(is.na(ymin)) {
		ymin <- (minResponse - 0.01*range)
	}
	if(is.na(ymax)) {
		ymax <- (maxResponse + 0.01*range)
	}
	if(is.na(xmax)) {
		xmax <- maxDose + maxDose/2
	}
	if(is.na(xmin)) {
		xmin <- minDose - minDose/2
	}
	xrn <- c(xmin,xmax)
	yrn <- c(ymin,ymax)
	
	##Seperate FLAGed and good points for plotting different point shapes
	flaggedPoints <- subset(curveData,curveData$flag)
	goodPoints <- subset(curveData,!curveData$flag)

	##Caldulate Means and SDs
	sds <- aggregate(goodPoints$response,list(dose=goodPoints$dose,curveid=goodPoints$curveid),sd)
	names(sds)[2] <- "SD"
	means <- aggregate(goodPoints$dose,list(dose=goodPoints$dose,curveid=goodPoints$curveid),mean)
	names(means)[2] <- "MEAN"
	
	###Begin Drawing the Plot
	if(!is.na(outFile)) {
		png(file=outFile,height=height,width=width)
	}
		#showLegend is the signal to put curve ids in the legend, for this push the image to be bigger on right and then put legend
		if(showLegend==TRUE) {
			#Increase right margin for legend
			#par(mar=c(2.1,3,0.1,6))
			#Set Par for no legend
			drawLegend <- TRUE
			if(axes) {
				par(mar=c(2.1,3,0.1,16)) #Set margin to east to fit legend
			} else {
				par(mar=c(0,0,0.1,16)) #Set margin to east to fit legend
			}
		} else {
			drawLegend <- FALSE
			if(axes) {
				par(mar=c(2.1,3,0.1,0.1)) #Set margin to east to fit legend
			} else {
				par(mar=c(0,0,0.1,0.1)) #Set margin to east to fit legend
			}
		}
		

		#First Plot Good Points so we that can see the flagged points if they are overlayed
		plot(goodPoints$dose,goodPoints$response,log="x",col=goodPoints$color, xlab="", ylab="dose", xlim=xrn, ylim=yrn, xaxt="n",family="sans", axes=FALSE)
		grid(lwd=1.7)
		#Now Plot Flagged Points
		points(x=flaggedPoints$dose,y=flaggedPoints$response,log="x",col=flaggedPoints$color,pch=4)
		#Draw Error Bars and Means
		#plotCI(x=means$dose,y=means$MEAN,uiw=sds$SD,add=TRUE,err="y",pch="-")
		#Curve Drawing Function
		drawCurve <- function(cid) {
			curveID <- params$curveid[cid]
			curveParams <- subset(params,params$curveid==curveID)
			if(is.na(curveParams$fittedec50)) {
				drawEC50 <- curveParams$ec50
			} else {
				drawEC50 <- curveParams$fittedec50
			}	
			if(is.na(curveParams$fittedmax)) {
				drawMax <- curveParams$max
			} else {
				drawMax <- curveParams$fittedmax
			}	
			if(is.na(curveParams$fittedmin)) {
				drawMin <- curveParams$min
			} else {
				drawMin <- curveParams$fittedmin
			}	
			if(is.na(curveParams$fittedhillslope)) {
				drawHill <- curveParams$hill
			} else {
				drawHill <- curveParams$fittedhillslope
			}
			if(!is.na(drawEC50) && !is.na(drawMax) && !is.na(drawMin) && !is.na(drawHill) ) {
				LL4 <- function(x) drawMin + (drawMax - drawMin)/((1 + exp(-drawHill * (log(x/drawEC50))))^1)
				curve(LL4,from=xrn[1],to=xrn[2],add=TRUE,col=curveParams$color)	
			}
		}
		#Actually Draw Curves
		null <- lapply(1:length(params$curveid),drawCurve)
		##DO axes and Grid
		box()
		if(axes) {
			axis(2,las=1)
			xTickRange <- par("xaxp")[1:2]
			log10Range <- log10(abs(xTickRange[2]/xTickRange[1]))+1
			major.ticks <- unlist(lapply(1:log10Range,ten <- function(x) {xTickRange[1]*10^(x-1)}))
			axis(1,at=major.ticks,labels=formatC(major.ticks),tcl=par("tcl")*1.8)
			intervals <- c(major.ticks/10,major.ticks[-1],major.ticks*10)
			minor.ticks <- 1:9 * rep(intervals / 10, each = 9)
			axis(1, at= minor.ticks, tcl = -0.5, labels = FALSE, tcl=par("tcl")*0.7) 
		}
		##If only one curve then draw ac50 lines
		#Get coordinates to draw lines through curve at AC50
		#Vertical
		if(nrow(params) == 1) {
			if(is.na(params$fittedec50)) {
				drawEC50 <- params$ec50
			} else {
				drawEC50 <- params$fittedec50
			}	
			if(is.na(params$fittedmax)) {
				drawMax <- params$max
			} else {
				drawMax <- params$fittedmax
			}	
			if(is.na(params$fittedmin)) {
				drawMin <- params$min
			} else {
				drawMin <- params$fittedmin
			}	
			if(is.na(params$fittedhillslope)) {
				drawHill <- params$hill
			} else {
				drawHill <- params$fittedhillslope
			}
			LL4 <- function(x) drawMin + (drawMax - drawMin)/((1 + exp(-drawHill * (log(x/drawEC50))))^1)
			curveAC50Intercept <- LL4(params$ec50)
			ylin <- c()
			ylin$x <- c(params$ec50,params$ec50)
			ylin$y <- c(par("usr")[3],curveAC50Intercept)
			#Horizontal
			xlin <- c()
			xlin$x <- c(0.0000000000000001,params$ec50)
			xlin$y <- c(curveAC50Intercept,curveAC50Intercept)
			#Draw AC50 Lines
			lines(ylin,lwd=0.7,col="red")
			lines(xlin,lwd=0.7,col="red")
		}
		#Draw Legend if specified
		if(drawLegend) {
			par(xpd=TRUE) # allows legends to be printed outside plot area
			legendYPosition <- 10 ^ par("usr")[2]
			legendXPosition <- par("usr")[4]
			legendText <- params$curveid
			legendTextColor <- params$color
			legendLineWidth <- 1
			legend(legendYPosition,legendXPosition,legendText,legendTextColor,legendLineWidth)
		}
		if(!is.na(outFile)) {
			dev.off()
		}
}
##Main
renderCurve <- function(getParams) {
	# Get data
	if(is.null(getParams$ymin)) {
		yMin <- -20
	} else {
		yMin <- as.numeric(getParams$ymin)
	}
	if(!is.null(getParams$yNormMin)) {
		yMin <- as.numeric(getParams$yNormMin)
	}
	if(is.null(getParams$ymax)) {
		yMax <- 120
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
	if(is.null(getParams$format)) {
		format <- "png"
	} else {
		format <- as.character(getParams$format)
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
		axes <- TRUE
	} else {
		if(getParams$axes=="true") {
			axes <- TRUE
		} else {
			axes <- FALSE
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
	
	data <- getCurveData(curveIds, globalConnect=TRUE)
	
	setContentType("image/png")
	setHeader(header="Cache-Control",value="max-age=1000000000000"); 
	setHeader(header="Expires",value="Thu, 31 Dec 2099 24:24:24 GMT");
	t <- tempfile()
	PlotCurve(curveData = data$points, params = data$parameters, fitFunction = LL4, paramNames = c("ec50", "min", "max", "hill"), drawCurve = TRUE, logDose = TRUE, logResponse = FALSE, outFile = t, ymin=yMin, ymax=yMax, xmin=xMin, xmax=xMax, height=height, width=width, showGrid = TRUE, labelAxes = TRUE, showLegend=legend, axes = axes)
	sendBin(readBin(t,'raw',n=file.info(t)$size))
	unlink(t) 
	DONE
}

renderCurve(getParams = GET)
