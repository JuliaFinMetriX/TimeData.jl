type Timedata{T} <: AbstractTimedata
    vals::DataFrame
    idx::Array{T, 1}

    function Timedata(vals::DataFrame, idx::Array{T, 1})
        chkIdx(idx)
        if(size(vals, 1) != length(idx))
            if (length(idx) == 0) | (size(vals, 1) == 0)
                df = convert(DataFrame, rand(2, 2))
                return new(df[1:2, []], Array{T, 1}[])
            end
            error(length(idx), " idx entries, but ", size(vals, 1), " rows of data")
        end
        return new(vals, idx)
    end
end

function Timedata{T}(vals::DataFrame, idx::Array{T, 1})
    return Timedata{T}(vals, idx)
end

#######################
## find boolean true ##
#######################

import Base.find
function find(td::Timedata)
    return find(array(td.vals))
end
