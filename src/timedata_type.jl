type Timedata{T} <: AbstractTimedata
    vals::DataFrame
    idx::Array{T, 1}

    function Timedata(vals::DataFrame, idx::Array{T, 1})
        chkIdx(idx)
        if(size(vals, 1) != length(idx))
            if (length(idx) == 0) | (size(vals, 1) == 0)
                return new(DataFrame([]), Array{T, 1}[])
            end
            error(length(idx), " idx entries, but ", size(vals, 1), " rows of data")
        end
        return new(vals, idx)
    end
end

function Timedata{T}(vals::DataFrame, idx::Array{T, 1})
    return Timedata{T}(vals, idx)
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
