type Timematr{T} <: AbstractTimematr
    vals::DataFrame
    idx::Array{T, 1}

    function Timematr(vals::DataFrame, idx::Array{T, 1})
        chkIdx(idx)
        chkNum(vals)
        if(size(vals, 1) != length(idx))
            if (length(idx) == 0) | (size(vals, 1) == 0)
                return new(DataFrame([]), Array{T, 1}[])
            end
            error(length(idx), " idx entries, but ", size(vals, 1), " rows of data")
        end
        return new(vals, idx)
    end
end

function Timematr{T}(vals::DataFrame, idx::Array{T, 1})
    return Timematr{T}(vals, idx)
end

    
#################
## Conversions ##
#################

## conversion upwards: always works
function convert(Timedata, tm::Timematr)
    Timedata(tm.vals, tm.idx)
end

## conversion upwards: always works
function convert(Timenum, tm::Timematr)
    Timenum(tm.vals, tm.idx)
end

#############################
## get numeric values only ##
#############################

## possible without NAs: extract values as Float64
function core(tm::AbstractTimematr)
    return convert(Array{Float64}, array(tm.vals))
end

#######################
## Timematr get mean ##
#######################

import Base.mean
function mean(tm::Timematr, dim::Int = 1)
    ## output: DataFrame, since date dimension is lost
    if dim == 2
        error("For rowwise mean use rowmeans function")
    end
    meanVals = mean(core(tm), dim)
    means = DataFrame(meanVals, names(tm))
end

function rowmeans(tm::Timematr)
    ## output: Timematr
    meanVals = mean(core(tm), 2)
    means = Timematr(meanVals, idx(tm))
end

######################################
## Timematr get row and column sums ##
######################################

import Base.sum
function sum(tm::Timematr, dim::Int = 1)
    ## output: DataFrame, since date dimension is lost
    if dim == 2
        error("For rowwise sum use rowsums function")
    end
    sumVals = sum(core(tm), dim)
    sums = DataFrame(sumVals, names(tm))
end

function rowsums(tm::Timematr)
    ## output: Timematr
    sumVals = sum(core(tm), 2)
    sums = Timematr(sumVals, idx(tm))
end


#########################
## Timematr covariance ##
#########################

import Base.cov
function cov(tm::Timematr)
    ## output: DataFrame
    covDf = DataFrame(cov(core(tm)), names(tm.vals))
    return covDf
end

##########################
## Timematr correlation ##
##########################

import Base.cor
function cor(tm::Timematr)
    ## output: DataFrame
    corDf = DataFrame(cor(core(tm)), names(tm.vals))
    return corDf
end

#########################
## minimum and maximum ##
#########################

import Base.minimum
function minimum(tm::Timematr)
    return minimum(core(tm))
end
function minimum(tm::Timematr, dim::Integer)
    if dim == 2
        error("For rowwise minimum use rowmin function")
    end
    return DataFrame(minimum(core(tm), 1), names(tm))
end

############
## cumsum ##
############

import Base.cumsum
function cumsum(tm::Timematr, dim::Integer)
    cumulated = cumsum(core(tm), dim)
    return Timematr(DataFrame(cumulated, names(tm)), idx(tm))
end


function getVars(tm::Timematr, mapF::Function, crit::Function)
    ## map each column to a value, and apply some condition on value
    ## e.g.: find variables with minimum return less than -30
    ncol = size(tm, 2)
    nrow = size(tm, 1)
    vals = TimeData.core(tm)

    values = ones(ncol)
    for ii=1:ncol
        values[ii] = mapF(vals[:, ii])
    end

    logics = crit(values)

    df = DataFrame(names=names(tm)[logics], values=values[logics], )
    ## names!(df, names(tm)[logics])
    return df
end


##################################
## plotting numeric time series ##
##################################

## import Winston.plot
## function plot(tm::Timematr)
##     plot(core(tm))
## end

#####################
## moving averages ##
#####################

function movAvg(tm::Timematr, nPeriods::Integer)
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
