abstract AbstractTimeData

type Timedata <: AbstractTimeData
    vals::DataFrame
    dates::DataArray

    function Timedata(vals::DataFrame, dates::DataArray)
        if(size(vals, 1) != length(dates))
            error("number of dates must equal number of columns of data")
        end
        return new(vals, dates)
    end
end
