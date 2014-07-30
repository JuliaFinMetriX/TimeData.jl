################################
## definition of Timenum type ##
################################

## constraints:
## - DataArray, where individual entries are subtype of Date
## - idx and vals must have same number of observations
## - values must be numeric

type Timenum{T} <: AbstractTimenum
    vals::DataFrame
    idx::Array{T, 1}

    function Timenum(vals::DataFrame, idx::Array{T, 1})
        chkIdx(idx)
        chkNumDf(vals)
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

function Timenum{T}(vals::DataFrame, idx::Array{T, 1})
    return Timenum{T}(vals, idx)
end

