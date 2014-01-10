################################
## definition of Timenum type ##
################################

## constraints:
## - DataArray, where individual entries are subtype of Date
## - dates and vals must have same number of observations
## - values must be numeric

type Timenum <: AbstractTimenum
    vals::DataFrame
    dates::DataArray

    function Timenum(vals::DataFrame, dates::DataArray)
        chkDates(dates)
        chkNumDf(vals)
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
function convert(Timedata, tn::Timenum)
    Timedata(tn.vals, tn.dates)
end

## conversion downwards: fails for NAs
function convert(Timematr, tn::Timenum)
    Timematr(tn.vals, tn.dates)
end

