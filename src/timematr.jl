type Timematr <: AbstractTimenum
    vals::DataFrame
    dates::DataArray

    function Timematr(vals::DataFrame, dates::DataArray)
        chkDates(dates)
        chkNum(vals)
        if(size(vals, 1) != length(dates))
            if (length(dates) == 0) | (size(vals, 1) == 0)
                return new(DataFrame([]), DataArray([]))
            end
            error(length(dates), " dates, but ", size(vals, 1), " rows of data")
        end
        return new(vals, dates)
    end
end

#################
## Conversions ##
#################

## conversion upwards: always works
function convert(Timedata, tm::Timematr)
    Timedata(tm.vals, tm.dates)
end

## conversion upwards: always works
function convert(Timenum, tm::Timematr)
    Timenum(tm.vals, tm.dates)
end

#############################
## get numeric values only ##
#############################

## possible without NAs
function core(tm::Timematr)
    return matrix(tm.vals)
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
    means = DataFrame(meanVals, colnames(tm))
end

function rowmeans(tm::Timematr)
    ## output: Timematr
    meanVals = mean(core(tm), 2)
    means = Timematr(meanVals, dates(tm))
end

#########################
## Timematr covariance ##
#########################

import Base.cov
function cov(tm::Timematr)
    ## output: DataFrame
    covDf = DataFrame(cov(core(tm)), colnames(tm.vals))
    return covDf
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
    return DataFrame(minimum(core(tm), 1), colnames(tm))
end

############
## cumsum ##
############

import Base.cumsum
function cumsum(tm::Timematr)
    cumulated = cumsum(core(tm))
    return Timematr(DataFrame(cumulated, colnames(tm)), dates(tm))
end

function getVars(tm::Timematr, mapF::Function, crit::Function)
    ## get variables that fulfill some condition, and show values 
    ncol = size(tm, 2)
    nrow = size(tm, 1)
    vals = TimeData.core(tm)

    values = ones(ncol)
    for ii=1:ncol
        values[ii] = mapF(vals[:, ii])
    end

    logics = crit(values)

    df = DataFrame(names=colnames(tm)[logics], values=values[logics], )
    ## colnames!(df, colnames(tm)[logics])
    return df
end


##################################
## plotting numeric time series ##
##################################

import Winston.plot
function plot(tm::Timematr)
    plot(core(tm))
end

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
    dats = dates(tm)[startInd:finInd]

    movAvgTm = Timematr(scaledVals, colnames(tm), dats)
    return movAvgTm
end
