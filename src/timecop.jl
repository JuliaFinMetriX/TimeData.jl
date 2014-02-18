type Timecop{T} <: AbstractTimematr
    vals::DataFrame
    idx::Array{T, 1}

    function Timecop(vals::DataFrame, idx::Array{T, 1})
        chkIdx(idx)
        chkNum(vals)
        chkUnit(vals)
        if(size(vals, 1) != length(idx))
            if (length(idx) == 0) | (size(vals, 1) == 0)
                df = convert(DataFrame, rand(2, 2))
                return new(df[1:2, []], Array{T, 1}[])
            end
            error(length(idx), " idx, but ", size(vals, 1), " rows of data")
        end
        return new(vals, idx)
    end
end

function Timecop{T}(vals::DataFrame, idx::Array{T, 1})
    return Timecop{T}(vals, idx)
end
