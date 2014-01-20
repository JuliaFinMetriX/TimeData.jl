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

movAvgs = TimeData.movAvg(tm, 150)
TimeData.plot(movAvgs)

marketMeans = TimeData.rowmeans(tm)
TimeData.plot(marketMeans)
var(TimeData.core(marketMeans))

marketMovAvg = TimeData.movAvg(marketMeans, 400)
TimeData.plot(marketMovAvg)
Winston.ylim(-0.6, 0.6)

######################################
## mean-shifting induced dependency ##
######################################

marketMovAvg = TimeData.movAvg(marketMeans, 20)
TimeData.plot(marketMovAvg)
Winston.ylim(-0.6, 0.6)

## for each day, simulate independent normally distributed values
nDays = size(marketMovAvg, 1)

using Distributions
d = Normal(0, 1.6)
simInnov = rand(d, nDays, 2)
simVals = simInnov + repmat(TimeData.core(marketMovAvg), 1, 2)
cor(simVals[:, 1], simVals[:,2])

## plot autocor
function autocorr(x::Vector, lag::Integer = 30)
    acVals = ones(lag)
    for ii=1:lag
        acVals[ii] = cor(x[1:(end-ii)], x[(1+ii):end])
    end
    Winston.plot(acVals, "-b")
    Winston.oplot(acVals, ".b")    
    Winston.ylim(-0.1, 1)
    ## return acVals
end

function autocorr!(x::Vector, lag::Integer = 30)
    acVals = ones(lag)
    for ii=1:lag
        acVals[ii] = cor(x[1:(end-ii)], x[(1+ii):end])
    end
    Winston.oplot(acVals, "-b")
    Winston.oplot(acVals, ".b")    
end

function autocorr_red!(x::Vector, lag::Integer = 30)
    acVals = ones(lag)
    for ii=1:lag
        acVals[ii] = cor(x[1:(end-ii)], x[(1+ii):end])
    end
    Winston.oplot(acVals, "-r")
    Winston.oplot(acVals, ".r")    
end



p = []
for ii=1:20
    if(ii==1)
        p = autocorr(TimeData.core(tm[1])[:])
    else
        p = autocorr!(TimeData.core(tm[ii])[:])
    end
end
p
autocorr_red!(simVals[:, 1])

## look at ranks!!

######################################
## correlations for all frequencies ##
######################################

maxAggregation = 100

include("/home/chris/research/julia/TimeData/src/TimeData.jl")
tm = TimeData.readTimedata("/home/chris/research/asset_mgmt/data/datesLogRet.csv")
nObs = size(tm, 2)

frequ = 50
for ii=1:20
    eqVal = true
    x = 0
    y = 0
    while(eqVal)
        (x, y) = [rand(1:nObs) rand(1:nObs)]
        if x !== y
            eqVal = false
        end
    end
    println("first: ", x, " , second: ", y)
    a = TimeData.frequCorrPlot(tm, x, y, frequ)
    plot(a[:, 1], a[:, 2], "+b")
    ylim(-0.2, 1)
    ## p = FramedPlot(
    ##                xrange=(0,frequ),
    ##                yrange=(-0.3,1))
    ## ## pts = Points(a[:, 1], a[:, 2], kind="filled circle")
    ## pts = Points(a[:, 1], a[:, 2], kind="plus")
    ## add(p, pts)
    fname = string("./pics/corrFrequ", ii, ".png")
    file(fname)
end
    
    
    ## create simulated data with no autocorrelation

nSim = 15000
using Distributions
## create two-dimensional normal distribution
rho = 0.5
sigma1 = 1.4
sigma2 = 1.4
covMatr = [sigma1^2 sigma1*sigma2*rho; sigma1*sigma2*rho sigma2^2]
d = MvNormal(covMatr)

simInnov = rand(d, nSim)
tmSim = TimeData.Timematr(simInnov')
a = TimeData.frequCorrPlot(tmSim, 1, 2, frequ)
plot(a[:, 1], a[:, 2], "+b")
ylim(-0.2, 1)

