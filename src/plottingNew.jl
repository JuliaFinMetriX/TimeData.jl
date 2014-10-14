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
    tn = rmDatesOnlyNAs(tn)
    df = floatDf(tn) # NA to NaN
    dats = datsAsFloats(tn)
    df[:Idx] = dats
    stackedData = stack(df, nams)
    Gadfly.plot(stackedData, x="Idx", y="value",
         color="variable", Gadfly.Geom.line)
end

function GdfPlotStrings(tn::Timenum)
    nams = names(tn)
    tn = rmDatesOnlyNAs(tn)
    df = floatDf(tn) # NA to NaN
    dats = datsAsStrings(tn)
    df[:Idx] = dats
    stackedData = stack(df, nams)
    Gadfly.plot(stackedData, x="Idx", y="value",
         color="variable", Gadfly.Geom.line)
end

## ## speed improvement through layers? doesn't seem so...
## function GdfPlotLayer(tn::Timenum)
##     namsSymb = names(tn)
##     tn = rmDatesOnlyNAs(tn)
##     nams = [string(namsSymb[ii]) for ii=1:size(tn, 2)]
##     df = floatDf(tn) # NA to NaN
##     dats = datsAsFloats(tn)
##     df[:Idx] = dats
##     nObs = size(tn, 1)
##     Gadfly.plot(df,
##                 Gadfly.layer(x = "Idx", y=nams[1], color=1*ones(nObs), Gadfly.Geom.line),
##                 Gadfly.layer(x = "Idx", y=nams[2], color=2*ones(nObs), Gadfly.Geom.line),
##                 Gadfly.layer(x = "Idx", y=nams[3], color=3*ones(nObs), Gadfly.Geom.line),
##                 Gadfly.layer(x = "Idx", y=nams[4], color=4*ones(nObs), Gadfly.Geom.line),
##                 Gadfly.layer(x = "Idx", y=nams[5], color=5*ones(nObs), Gadfly.Geom.line),
##                 Gadfly.layer(x = "Idx", y=nams[6], color=6*ones(nObs), Gadfly.Geom.line),
##                 Gadfly.layer(x = "Idx", y=nams[7], color=7*ones(nObs), Gadfly.Geom.line),
##                 Gadfly.layer(x = "Idx", y=nams[8], color=8*ones(nObs), Gadfly.Geom.line),
##                 Gadfly.Scale.discrete_color()
##                 )
## end

## Or if your data is in a DataFrame:
## plot(my_data, layer(x="some_column1", y="some_column2", Geom.point),
              ## layer(x="some_column3", y="some_column4", Geom.line))

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
