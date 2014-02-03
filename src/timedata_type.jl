type Timedata <: AbstractTimedata
    vals::DataFrame
    idx::DataArray

    function Timedata(vals::DataFrame, idx::DataArray)
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

## conversion downwards: fails for non-numeric values
function convert(Timenum, td::Timedata)
    Timenum(td.vals, td.idx)
end

## conversion downwards: fails for NAs
function convert(Timematr, td::Timedata)
    Timematr(td.vals, td.idx)
end

#######################
## find boolean true ##
#######################

import Base.find
function find(td::Timedata)
    return find(array(td.vals))
end
