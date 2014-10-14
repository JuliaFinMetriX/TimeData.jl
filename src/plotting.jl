import Gadfly.plot
function plot(tm::Timematr, settings...)
    ## plot Timematr object
    ## - multi-line plot
    ## - index must be dates convertible to strings
    ## - plot only some maximum number of randomly picked paths
    ## - plot some statistics
    
    dats = datsAsStrings(tm)
    (nObs, nAss) = size(tm)
    
    ## maximum number of paths plotted
    maxPaths = 10

    ## get values for paths
    if nAss > maxPaths
        ## get randomly drawn paths

        chosenAssets = randperm(nAss)[1:maxPaths]
        randPaths = core(tm)[:, chosenAssets]
        nams = names(tm)[chosenAssets]

        ## get statistics
        allVals = core(tm)
        averagePath = mean(allVals, 2)
        lowestEndingPath = indmin(allVals[end, :])
        lowPath = allVals[:, lowestEndingPath]
        highestEndingPath = indmax(allVals[end, :])
        highPath = allVals[:, highestEndingPath]

        vals = [averagePath lowPath highPath randPaths]
        valsDf = composeDataFrame(vals,
                                  [:mean, :low, :high,
                                   nams])  
    else
        valsDf = copy(tm.vals)
    end

    nams = names(valsDf)
    valsDf[:Idx] = dats
    
    stackedData = stack(valsDf, nams)

    plot(stackedData, x="Idx", y="value",
         color="variable", Geom.line, settings...)
end


##################################
## plotting numeric time series ##
##################################

import Winston.plot
function plotWst(tm::Timematr)
    plot(core(tm))
end
