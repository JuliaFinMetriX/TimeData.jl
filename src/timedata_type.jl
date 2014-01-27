type Timedata <: AbstractTimedata
    vals::DataFrame
    dates::DataArray

    function Timedata(vals::DataFrame, dates::DataArray)
        if(size(vals, 1) != length(dates))
            if (length(dates) == 0) | (size(vals, 1) == 0)
                return new(DataFrame([]), DataArray([]))
            end
            error("number of dates must equal number of columns of data")
        end
        return new(vals, dates)
    end
end

#################
## Conversions ##
#################

## conversion downwards: fails for non-numeric values
function convert(Timenum, td::Timedata)
    Timenum(td.vals, td.dates)
end

## conversion downwards: fails for NAs
function convert(Timematr, td::Timedata)
    Timematr(td.vals, td.dates)
end

#######################
## find boolean true ##
#######################

import Base.find
function find(td::Timedata)
    return find(array(td.vals))
end
