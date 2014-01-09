type TimeDf <: AbstractTimeData
    vals::DataFrame
    dates::DataArray
    
    function TimeDf(vals::DataFrame, dates::DataArray)
        chkDates(dates)
        if(size(vals, 1) != length(dates))
            error("number of dates must equal number of columns of data")
        end
        return new(vals, dates)
    end
end
