type Timecop <: AbstractTimematr
    vals::DataFrame
    dates::DataArray

    function Timecop(vals::DataFrame, dates::DataArray)
        chkDates(dates)
        chkNum(vals)
        chkUnit(vals)
        if(size(vals, 1) != length(dates))
            if (length(dates) == 0) | (size(vals, 1) == 0)
                return new(DataFrame([]), DataArray([]))
            end
            error(length(dates), " dates, but ", size(vals, 1), " rows of data")
        end
        return new(vals, dates)
    end
end
