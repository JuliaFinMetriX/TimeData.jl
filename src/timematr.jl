type Timematr <: AbstractTimenum
    vals::DataFrame
    dates::DataArray

    function Timematr(vals::DataFrame, dates::DataArray)
        chkDates(dates)
        chkNum(vals)
        if(size(vals, 1) != length(dates))
            error("number of dates must equal number of columns of data")
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
    means = DataFrame(meanVals, vars(tm))
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
    covDf = DataFrame(cov(core(vals)), vars(tm.vals))
    return covDf
end

