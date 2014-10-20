## deferred loading
##-----------------

require("Gadfly")
require("Winston")

#####################
## Gadfly plotting ##
#####################

function gdfPlot(tn::AbstractTimenum)
    nams = names(tn)
    tn = narowrm(tn)
    vals = asArr(tn, Float64, NaN) # NA to NaN
    dats = dat2num(tn)
    df = composeDataFrame([dats vals], [:Idx; nams])
    stackedData = stack(df, nams)
    Gadfly.plot(stackedData, x="Idx", y="value",
         color="variable", Gadfly.Geom.line)
end

######################
## Winston plotting ##
######################

## no legend, but fast
function wstPlot(tn::AbstractTimenum; title::String = "",
                 xlabel::String = "time",
                 ylabel::String = "value")
    vals = asArr(tn, Float64, NaN) # transform to floating array
    dats = dat2num(idx(tn))
    Winston.plot(dats, vals)
    Winston.title(title)
    Winston.xlabel(xlabel)
    Winston.ylabel(ylabel)
end

###############
## histogram ##
###############


function wstHist(x::Vector, nBins::Int = 20; title = "", xlabel = "", ylabel = "")
    p = Winston.FramedPlot(title = title, xlabel = xlabel, ylabel = ylabel)
    Winston.add(p, Winston.Histogram(hist(x[!isnan(x)], nBins)...))
end

function wstHist(da::DataArray, nBins::Int = 20; title = "", xlabel = "", ylabel = "")
    x = asArr(da, Float64, NaN)
    wstHist(x, nBins, title = title, xlabel = xlabel, ylabel = ylabel)
end


## import Gadfly.plot
## function plot(tm::Timematr, settings...)
##     ## plot Timematr object
##     ## - multi-line plot
##     ## - index must be dates convertible to strings
##     ## - plot only some maximum number of randomly picked paths
##     ## - plot some statistics
    
##     dats = datsAsStrings(tm)
##     (nObs, nAss) = size(tm)
    
##     ## maximum number of paths plotted
##     maxPaths = 10

##     ## get values for paths
##     if nAss > maxPaths
##         ## get randomly drawn paths

##         chosenAssets = randperm(nAss)[1:maxPaths]
##         randPaths = core(tm)[:, chosenAssets]
##         nams = names(tm)[chosenAssets]

##         ## get statistics
##         allVals = core(tm)
##         averagePath = mean(allVals, 2)
##         lowestEndingPath = indmin(allVals[end, :])
##         lowPath = allVals[:, lowestEndingPath]
##         highestEndingPath = indmax(allVals[end, :])
##         highPath = allVals[:, highestEndingPath]

##         vals = [averagePath lowPath highPath randPaths]
##         valsDf = composeDataFrame(vals,
##                                   [:mean, :low, :high,
##                                    nams])  
##     else
##         valsDf = copy(tm.vals)
##     end

##     nams = names(valsDf)
##     valsDf[:Idx] = dats
    
##     stackedData = stack(valsDf, nams)

##     plot(stackedData, x="Idx", y="value",
##          color="variable", Geom.line, settings...)
## end
