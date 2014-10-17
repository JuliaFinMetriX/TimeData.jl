#######################
## Timematr get mean ##
#######################

import Base.mean
function mean(tm::AbstractTimematr, dim::Int)
    ## output: DataFrame, since date dimension is lost
    if dim == 2
        error("For rowwise mean use rowmeans function")
    end
    meanVals = DataFrame()
    for (nam, col) in eachcol(tm.vals)
        meanVals[nam] = mean(col)
    end
    return meanVals
end

function mean(tn::AbstractTimenum, dim::Int)
    ## output: DataFrame, since date dimension is lost
    ## NAs are ignored!
    if dim == 2
        error("For rowwise mean use rowmeans function")
    end
    nObs, nAss = size(tn)
    meanVals = DataFrame()
    nVals = zeros(Int, nObs)
    for (nam, col) in eachcol(tn.vals)
        if isa(col, DataArray)
            meanVals[nam] = mean(col[!col.na])
        else
            meanVals[nam] = mean(col)
        end
    end
    return meanVals
end


## rowmeans
##---------

function rowmeans(tm::AbstractTimematr)
    ## output: Timematr
    nObs, nAss = size(tm)
    meanVals = zeros(Float64, nObs)
    for (nam, col) in eachcol(tm.vals)
        meanVals += col
    end
    return Timematr(DataFrame(mean_values = meanVals./nAss),
                    idx(tm))
end

function rowmeans(tn::Timenum)
    ## output: Timematr, NAs are ignored
    nObs, nAss = size(tn)
    meanVals = DataArray(zeros(Float64, nObs))
    nVals = zeros(Int, nObs)
    for (nam, col) in eachcol(tn.vals)
        if isa(col, DataArray)
            nVals[!col.na] += 1
            meanVals[!col.na] += col.data[!col.na]
        else
            nVals += 1
            meanVals += col
        end
    end
    return Timematr(DataFrame(mean_values = meanVals./nVals),
                    idx(tn))
end


#######################
## Timematr get prod ##
#######################

import Base.prod
function prod(tm::AbstractTimematr, dim::Int = 1)
    ## output: DataFrame, since date dimension is lost
    if dim == 2
        error("For rowwise prod use rowprods function")
    end
    prodVals = DataFrame()
    for (nam, col) in eachcol(tm.vals)
        prodVals[nam] = prod(col)
    end
    return prodVals
end

function rowprods(tm::AbstractTimematr)
    ## output: Timematr
    prodVals = prod(core(tm), 2)
    prods = Timematr(prodVals, idx(tm))
end
## function rowprods2(tm::AbstractTimematr)
##     ## output: Timematr
##     nObs, nAss = size(tm)
##     prodVals = ones(Float64, nObs)
##     for (nam, col) in eachcol(tm.vals)
##         prodVals = prodVals .* col
##     end
##     return Timematr(composeDataFrame(prodVals, [:prod_values]),
##                     idx(tm))
## end

######################################
## Timematr get row and column sums ##
######################################

import Base.sum
function sum(tm::AbstractTimematr, dim::Int = 1)
    ## output: DataFrame, since date dimension is lost
    if dim == 2
        error("For rowwise sum use rowsums function")
    end
    sumVals = sum(core(tm), dim)
    sums = composeDataFrame(sumVals, names(tm))
end

function rowsums(tm::AbstractTimematr)
    ## output: Timematr
    sumVals = sum(core(tm), 2)
    sums = Timematr(sumVals, idx(tm))
end


#########################
## Timematr covariance ##
#########################

import Base.cov
function cov(tm::AbstractTimematr)
    ## output: DataFrame
    covDf = composeDataFrame(cov(core(tm)), names(tm.vals))
    return covDf
end

##########################
## Timematr correlation ##
##########################

import Base.cor
function cor(tm::AbstractTimematr)
    ## output: DataFrame
    corDf = composeDataFrame(cor(core(tm)), names(tm.vals))
    return corDf
end

##########################
## Timematr std ##
##########################

import Base.std
function std(tm::AbstractTimematr)
    ## output: DataFrame
    stdDf = composeDataFrame(std(core(tm), 1), names(tm.vals))
    return stdDf
end

function std(tm::AbstractTimematr, dim::Integer)
    ## output: DataFrame
    if dim == 2
        error("For rowwise standard deviations use rowstds")
    end
    stdDf = composeDataFrame(std(core(tm), 1), names(tm.vals))
    return stdDf
end

function rowstds(tm::AbstractTimematr)
    rowStd = Timematr(std(core(tm), 2), idx(tm))
    return rowStd
end
   
#########################
## minimum and maximum ##
#########################

import Base.minimum
function minimum(tm::AbstractTimematr)
    return minimum(core(tm))
end
function minimum(tm::AbstractTimematr, dim::Integer)
    if dim == 2
        error("For rowwise minimum use rowmin function")
    end
    return composeDataFrame(minimum(core(tm), 1), names(tm))
end

############
## cumsum ##
############

import Base.cumsum
function cumsum(tm::AbstractTimematr, dim::Integer)
    cumulated = cumsum(core(tm), dim)
    return Timematr(composeDataFrame(cumulated, names(tm)), idx(tm))
end

import Base.cumprod
function cumprod(tm::AbstractTimematr, dim::Integer)
    cumulated = cumprod(core(tm), dim)
    return Timematr(composeDataFrame(cumulated, names(tm)), idx(tm))
end



####################
## geometric mean ##
####################

function geomMean(x::AbstractTimematr; percent = true)
    nObs = size(x, 1)
    if percent
        vals = (prod(1 + core(x)./100, 1).^(1/nObs) - 1)*100
    else
        vals = prod(1 + core(x), 1).^(1/nObs) - 1
    end
    return composeDataFrame(vals, names(x))
end

function geomMean(x; percent = true)
    nObs = size(x, 1)
    if percent
        vals = (prod(1 + x./100, 1).^(1/nObs) - 1)*100
    else
        vals = prod(1 + x./100, 1).^(1/nObs) - 1
    end
    return vals
end

#####################
## moving averages ##
#####################

function movAvg(tm::AbstractTimematr, nPeriods::Integer)
    (nObs, nAss) = size(tm)
    nMAs = nObs - nPeriods + 1
    vals = core(tm)
        
    ## get start and ending indices
    startInd = ceil(nPeriods/2)
    finInd = startInd + nMAs - 1
    
    ## preallocation
    movAvgs = ones(nMAs, nAss)

    movAvgs[1, :] = sum(vals[1:nPeriods, :], 1)

    for ii=2:nMAs
        movAvgs[ii, :] = movAvgs[ii-1, :] - vals[(ii-1), :] +
        vals[(ii-1)+nPeriods, :]
    end

    ## divide
    scaledVals = movAvgs / nPeriods
    dats = idx(tm)[startInd:finInd]

    movAvgTm = Timematr(scaledVals, names(tm), dats)
    return movAvgTm
end

