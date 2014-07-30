type Timematr{T} <: AbstractTimematr
    vals::DataFrame
    idx::Array{T, 1}

    function Timematr(vals::DataFrame, idx::Array{T, 1})
        chkIdx(idx)
        chkNum(vals)
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

function Timematr{T}(vals::DataFrame, idx::Array{T, 1})
    return Timematr{T}(vals, idx)
end

#############################
## get numeric values only ##
#############################

## possible without NAs: extract values as Float64
## Will always return Array{Float64, 2}, since it is based on
## DataFrames. array only returns Array{Float, 1} for DataArrays. 
function core(tm::AbstractTimematr)
    return convert(Array{Float64}, array(tm.vals))
end
## alternative implementation not determining Float64
## function core(tm::AbstractTimematr)
##     return reshape([promote(array(tm.vals)...)...], size(tm))
## end

#############
## getVars ##
#############

function getVars(tm::Timematr, mapF::Function, crit::Function)
    ## map each column to a value, and apply some condition on value
    ## e.g.: find variables with minimum value less than -30
    ncol = size(tm, 2)
    nrow = size(tm, 1)
    vals = TimeData.core(tm)

    values = ones(ncol)
    for ii=1:ncol
        values[ii] = mapF(vals[:, ii])
    end

    logics = crit(values)

    df = DataFrame(names=names(tm)[logics], values=values[logics])
    ## names!(df, names(tm)[logics])
    return df
end
