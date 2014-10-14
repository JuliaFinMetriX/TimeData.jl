## ## this needs to be loaded !upfront!, if NAs should be dealt with
## directly by Gadfly
## import Base.convert
## convert(::Type{Float64}, obj::NAtype) = NaN


## deferred loading
##-----------------

require("Gadfly")
require("Winston")

#####################
## Gadfly plotting ##
#####################

function GdfPlot(tn::Timenum)
    nams = names(tn)
    df = floatDf(tn) # NA to NaN
    dats = datsAsFloats(tn)
    df[:Idx] = dats
    stackedData = stack(df, nams)
    Gadfly.plot(stackedData, x="Idx", y="value",
         color="variable", Gadfly.Geom.line)
end

## ## plot with NAs
## ##--------------


## function GdfPlot(tn::Timenum)
##     nams = names(tn)
##     df = copy(tn.vals)
##     dats = datsAsFloats(tn)
##     df[:Idx] = dats
##     stackedData = stack(df, nams)
##     Gadfly.plot(stackedData, x="Idx", y="value",
##                 color="variable", Gadfly.Geom.line)
## end

######################
## Winston plotting ##
######################

## no legend, but fast
function WstPlot(tn::Timenum; title::String = "",
                 xlabel::String = "time",
                 ylabel::String = "value")
    vals = floatcore(tn)
    dats = datsAsFloats(idx(tn))
    Winston.plot(dats, vals)
    Winston.title(title)
    Winston.xlabel(xlabel)
    Winston.ylabel(ylabel)
end
