type Timematr <: AbstractTimeData
    vals::DataFrame
    dates::DataArray

    function Timematr(vals::DataFrame, dates::DataArray)
        chkDates(dates)
        chkNum(vals)
        if(size(vals, 1) != length(dates))
            error("number of dates must equal number of columns of data")
        end
        return new(vals, dates)
    end
end
