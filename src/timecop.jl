type Timecop <: AbstractTimematr
    vals::DataFrame
    idx::DataArray

    function Timecop(vals::DataFrame, idx::DataArray)
        chkIdx(idx)
        chkNum(vals)
        chkUnit(vals)
        if(size(vals, 1) != length(idx))
            if (length(idx) == 0) | (size(vals, 1) == 0)
                return new(DataFrame([]), DataArray([]))
            end
            error(length(idx), " idx, but ", size(vals, 1), " rows of data")
        end
        return new(vals, idx)
    end
end
