## using TimeData

include("/home/chris/research/julia/TimeData/src/TimeData.jl")

tm = TimeData.readTimedata("/home/chris/research/asset_mgmt/data/datesLogRet.csv")

## functions to indentify lowest and highest values by boolean
function islowest(x::Array{Float64, 1}, n::Integer = 1)
    nVals = length(x)
    inds = sortperm(x)
    logics = falses(nVals)
    logics[inds[1:n]] = true
    return logics
end

function ishighest(x::Array{Float64, 1}, n::Integer = 1)
    nVals = length(x)
    inds = sortperm(x, rev=true)
    logics = falses(nVals)
    logics[inds[1:n]] = true
    return logics
end

## get 5 lowest minima stocks
mapFunc(x) = minimum(x)
critFunc(x) = islowest(x, 5)
mostNegativeReturns = TimeData.getVars(tm, mapFunc, critFunc)

#########################################
## normalized 120 day price evolutions ##
#########################################

## plot 120 day normalized log-prices each 60 days
horizon = 120
steps = 60
nObs = size(tm, 1)

normPrices = cumsum(tm[1:120, :])
TimeData.plot(normPrices)
ylim(-200, 200)
title(TimeData.dates(tm)[1])
file("./pics/normPrices.png")

for ii=1:steps:(nObs-horizon)
    normPrices = cumsum(tm[ii:(ii+horizon), :])
    TimeData.plot(normPrices)
    ylim(-200, 200)
    periodBegin = string(TimeData.dates(tm)[ii])
    title(periodBegin)
    fname = string("./pics/normPrices", ii, ".png")
    file(fname)
end
    
#########################
## get moving averages ##
#########################

include("/home/chris/research/julia/TimeData/src/TimeData.jl")
tm = TimeData.readTimedata("/home/chris/research/asset_mgmt/data/datesLogRet.csv")

movAvgs = TimeData.movAvg(tm, 150)
TimeData.plot(movAvgs)

marketMeans = TimeData.rowmeans(tm)
TimeData.plot(marketMeans)

marketMovAvg = TimeData.movAvg(marketMeans, 150)
TimeData.plot(marketMovAvg)
Winston.ylim(-0.6, 0.6)
