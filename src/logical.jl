## istrue
##-------

function istrue(x::Bool)
    return x
end

function istrue(x::NAtype)
    return false
end

function istrue(da::DataArray{Bool, 1})
    return da.data & !da.na # may not be NA
end

function istrue(df::DataFrame)
    boolDf = DataFrame()
    for (nam, col) in eachcol(df)
        boolDf[nam] = istrue(col)
    end
    return boolDf
end

function istrue(td::TimeData.Timedata)
    return TimeData.Timedata(istrue(td.vals), idx(td)) 
end

## isfalse
##--------

function isfalse(x::Bool)
    return !x
end

function isfalse(x::NAtype)
    return false
end

function isfalse(da::DataArray{Bool, 1})
    return !da.data & !da.na # may not be NA
end

function isfalse(df::DataFrame)
    boolDf = DataFrame()
    for (nam, col) in eachcol(df)
        boolDf[nam] = isfalse(col)
    end
    return boolDf
end

function isfalse(td::TimeData.Timedata)
    return TimeData.Timedata(isfalse(td.vals), idx(td)) 
end

## isunknown
##----------

function isunknown(x::Bool)
    return false
end

function isunknown(da::DataArray{Bool, 1})
    return isna(da)
end

function isunknown(df::DataFrame)
    boolDf = DataFrame()
    for (nam, col) in eachcol(df)
        boolDf[nam] = isna(col)
    end
    return boolDf
end

function isunknown(td::TimeData.Timedata)
    return TimeData.Timedata(isunknown(td.vals), idx(td)) 
end
