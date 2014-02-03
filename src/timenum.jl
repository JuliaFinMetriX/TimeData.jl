################################
## definition of Timenum type ##
################################

## constraints:
## - DataArray, where individual entries are subtype of Date
## - idx and vals must have same number of observations
## - values must be numeric

type Timenum <: AbstractTimenum
    vals::DataFrame
    idx::DataArray

    function Timenum(vals::DataFrame, idx::DataArray)
        chkIdx(idx)
        chkNumDf(vals)
        if(size(vals, 1) != length(idx))
            if (length(idx) == 0) | (size(vals, 1) == 0)
                return new(DataFrame([]), DataArray([]))
            end
            error("number of idx must equal number of columns of data")
        end
        return new(vals, idx)
    end
end


#################
## Conversions ##
#################

## conversion upwards: always works
function convert(Timedata, tn::Timenum)
    Timedata(tn.vals, tn.idx)
end

## conversion downwards: fails for NAs
function convert(Timematr, tn::Timenum)
    Timematr(tn.vals, tn.idx)
end
