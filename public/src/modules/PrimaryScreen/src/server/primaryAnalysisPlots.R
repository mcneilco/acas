createDensityPlot <- function(values, wellTypes, threshold, margins = c(5,4,4,8)) {
  # Creates a density plot
  #
  # Args:
  #   values:           Numeric vector of values to plot
  #   wellTypes:     	  String vector of well types of values (above)
  #	  threshold:        A numeric of the efficacy threshold
  #
  # Returns:
  #   nothing
  
  require(Hmisc)
  
  # Set parameters to format the graph correctly
  par(mar=margins)
  
  # Create density data to graph
  NCdensity <- density(values[wellTypes == "NC"])
  PCdensity <- density(values[wellTypes == "PC"])
  testDensity <- density(values[wellTypes == "test"])
  yHeight <- max(NCdensity$y, PCdensity$y, testDensity$y)
  
  plot(NCdensity, 
       main = "Screen Histogram",
       xlim = c(-1,2),
       ylim = c(0,yHeight*1.04),
       xlab = "Normalized Activity (rfu)",
       ylab = "Number per bin",
       yaxs="i",
       type="n"
  )
  
  # draw the threshold
  if (!is.null(threshold)) {
    lines(x=rep(threshold,2),y=c(0,yHeight*1.5), col="red",lwd=2, lty=1)
  }
  
  # draw the density graphs
  polygon(PCdensity$x,PCdensity$y,col="green")
  polygon(NCdensity$x,NCdensity$y,col="blue")
  polygon(testDensity$x,testDensity$y,col="black",density=120,border="black")
  
  # legend
  #"xpd = TRUE" lets the legend go outside the plot
  legend(x=2.3, y=yHeight, fill=c("blue","black","green","red"), legend=c("- control","test","+ control","threshold"), xpd = TRUE)
}
createGGComparison <- function(graphTitle, yLimits = NULL, 
                               xColumn, wellType, dataRow, hits = NULL,
                               test = TRUE, PC = TRUE, NC = TRUE, xLabel, yLabel="Activity (rfu)", margins = c(1,1,1,1), 
                               rotateXLabel = FALSE, colourPalette = NA, threshold = NULL) {
  #error handling
  if (all(!PC,!NC,!test)) {
    print("needs to plot something")
    return()
  }
  
  require(ggplot2)
  
  # wellType is the test/PC/NC column
  # dataRow is the value column
  # xColumn is the x side
  graphDataFrame <- data.frame(xColumn=xColumn, wellType=wellType, dataRow=dataRow, stringsAsFactors = F)
  if (!is.null(hits)) {
    graphDataFrame$isHit=hits
    graphDataFrame$typeAndHit <- paste(graphDataFrame$wellType, "-", graphDataFrame$isHit)
  } else {
    graphDataFrame$typeAndHit <- graphDataFrame$wellType
  }
  
  plotList <- list(if(PC)"PC",if(NC)"NC",if(test)"test")
  
  limitedGraphDataFrame <- graphDataFrame[wellType %in% plotList,]
  
  well <- limitedGraphDataFrame$typeAndHit
  
  well[well=="NC - FALSE"] <- "NC"
  well[well=="PC - FALSE"] <- "PC"
  well[well=="test - FALSE"] <- "test - not hit"
  well[well=="test - TRUE"] <- "test - hit"
  limitedGraphDataFrame$well <- well
  
  # get rid of unused colors when there are no hits
  if (all(!(well=="test - hit")) && length(colourPalette) == 4) {
    colourPalette <- c(colourPalette[1:2], colourPalette[4])
  }
  
  g <- ggplot(limitedGraphDataFrame, aes(x=xColumn, y=dataRow, colour=well))
  #if (!is.null(hits)) g <- g + aes(shape=isHit)
  if (!is.null(threshold)) {
    g <- g + geom_hline(yintercept = threshold, color="red")
  }
  if (test) {
    #g <- g + (geom_point(data=limitedGraphDataFrame[limitedGraphDataFrame$wellType=="test",],colour="black"))
    g <- g + (geom_point(data=limitedGraphDataFrame))
  } else {
    g <- g + geom_point()
  }
  g <- g + xlab(xLabel) +
    ylab(yLabel) +
    ggtitle(graphTitle) +
    coord_cartesian(ylim=yLimits)
  theme(panel.margin = unit(0,"null"),
        plot.margin = unit(margins, "lines"),
        axis.text.x = element_text(size = rel(1)),
        axis.text.y = element_text(size = rel(1)))

  if(rotateXLabel) g <- g + theme(axis.text.x = element_text(angle = -90, vjust=0.5))
  
  if(all(!is.na(colourPalette))) g <- g + scale_colour_manual(values=colourPalette)
  
    
  return(g)
}  
  
createComparison <- function(title, ylim = NULL, norm = FALSE, 
                             resultColumn, resultTableCopy, 
                             test = TRUE, PC = TRUE, NC = TRUE, organizeBy, margins = c(8,4,4,2), labelLocation = 3) {
  par(mar=margins, ann = FALSE)
  #error handling
  if (all(!PC,!NC,!test)) {
    print("needs to plot something")
    return()
  }
  #finds which rows will be used
  resultRowsUsed <- ((resultTableCopy$wellType == "test" & test) | 
                       (resultTableCopy$wellType == "PC" & PC) | 
                       (resultTableCopy$wellType == "NC" & NC))
  resultColumnUsed <- resultColumn[resultRowsUsed]
  if (norm == TRUE) {
    yData <- resultTableCopy$normalized
  } else {
    yData <- resultTableCopy$transformed
  }
  #creates a blank plot with the correct limits
  plot(as.numeric(factor(resultColumnUsed)),
       yData[resultRowsUsed], 
       xaxt = 'n',
       ylim = ylim,
       type = 'n')
  # TODO
  tickLocations <- as.numeric(factor(unique(resultColumn[resultRowsUsed])))
  mgp.axis(side=1, #bottom
           at= tickLocations,
           labels=unique(resultColumn[resultRowsUsed]), 
           tick = TRUE,
           las=2, #perpedicular to the axis
           mgp=c(labelLocation,1,0),
           axistitle=organizeBy)
#   mgp.axis(side = 1, #bottom
#            +            tick = TRUE,
#            +            las=1,axistitle="X Label")

  xData <- as.numeric(factor(resultColumn))
  if (test) {
    points(xData[resultTableCopy$wellType == "test"],
           yData[resultTableCopy$wellType == "test"], 
           col = "black")
  }
  if (PC) {
    points(xData[resultTableCopy$wellType == "PC"],
           yData[resultTableCopy$wellType == "PC"], 
           col = "red")
  }
  if (NC) {
    points(xData[resultTableCopy$wellType == "NC"],
           yData[resultTableCopy$wellType == "NC"], 
           col = "green")
  }
  title(main = title, ylab = "Activity (rfu)") 
  legend(x=(max(tickLocations)-min(tickLocations))*.7+min(tickLocations), y=2, fill=c("green","red"), legend=c("positive control","negative control"), xpd = TRUE)
  
}

#TODO find out color scheme we are working with and make this look better
createHeatMap <- function(name, plate, margins=c(5,0,0,5)) {
  # Creates a heatmap
  #
  # Args:
  #   name:       The title of the plot
  #   plate:     	A data.frame of the values of a list of wells
  #
  # Returns:
  #   nothing
  #png(file = paste0("./results/plots/", name, ".png"),width=480*24/16,height=480)
  
  # order by number, then by letter
  orderedPlate <- plate[order(as.numeric(gsub("\\D", "", plate$well)), (gsub("\\d", "", plate$well))),]
  
  # place in correct shape
  plateShape <- array(orderedPlate$values, dim = c(16,24))
  shapeTest <- array(orderedPlate$well, dim = c(16,24))
  rownames(plateShape) <- lapply(as.raw(65:80), rawToChar)
  colnames(plateShape) <- 1:24
  
  # make the heatmap
  heatmapEdited(plateShape, 
                Rowv = NA, Colv = NA, revC = TRUE,
                labRow = LETTERS[1:16], 
                main = name, margins=margins[c(4,1)], otherMargins = margins[c(2,3)], col=colorRampPalette(rev(c("#D73027", "#FC8D59", "#FEE090", "#FFFFBF", "#E0F3F8", "#91BFDB", "#4575B4")))(100))
  # margins = c(0,0)
  #dev.off()
}
createGGHeatmap <- function(name, plate, margins=c(1,1,1,1)) {
  require(ggplot2)
  plate$x <- as.numeric(gsub("\\D*","",plate$well))
  plate$y <- as.character(gsub("\\d*","",plate$well))
  
  plateHeatmap <- ggplot(plate,aes(x=x,y=y,fill=normalizedValues)) +
    scale_x_continuous(expand=c(0,0),breaks=1:24) + 
    geom_tile() + scale_y_discrete(limits=rev(LETTERS[1:16])) +
    xlab("") +
    ylab("") +
    ggtitle(name) +
    coord_fixed() +
    #scale_fill_gradient2(limits=c(-1, 2)) +
    theme(legend.position = "right",
          panel.background = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.margin = unit(0,"null"),
          plot.margin = unit(margins, "lines"),
          axis.ticks = element_blank(),
          axis.text.x = element_text(size = rel(1)),
          axis.text.y = element_text(size = rel(1)),
          axis.title.x = element_blank(),
          axis.title.y = element_blank()) +
  scale_fill_continuous(name="Activity (rfu)")
  return(plateHeatmap)
}