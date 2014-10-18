########################
## plotting utilities ##
########################

## process dates to strings
##-------------------------

function dat2str(dats::Array{Date, 1})
    nObs = size(dats, 1)
    datsAsStr = Array(ASCIIString, nObs)
    for ii=1:nObs
        datsAsStr[ii] = string(dats[ii])
    end
    return datsAsStr
end

function dat2str(dats::Array{DateTime, 1})
    nObs = size(dats, 1)
    datsAsStr = Array(ASCIIString, nObs)
    for ii=1:nObs
        datsAsStr[ii] = string(dats[ii])
    end
    return datsAsStr
end

function dat2str(dats::Array{Integer, 1})
    nObs = size(dats, 1)
    datsAsStr = Array(ASCIIString, nObs)
    for ii=1:nObs
        datsAsStr[ii] = string(dats[ii])
    end
    return datsAsStr
end

function dat2str(dats::Array{Float64, 1})
    nObs = size(dats, 1)
    datsAsStr = Array(ASCIIString, nObs)
    for ii=1:nObs
        datsAsStr[ii] = string(dats[ii])
    end
    return datsAsStr
end

function dat2str(tm::AbstractTimedata)
    return dat2str(idx(tm))
end

## process dates to floating point numbers
##----------------------------------------

function dat2num(dats::Array{Date, 1})
    nObs = size(dats, 1)
    datsAsFloat = Array(Float64, nObs)
    for ii=1:nObs
        datsAsFloat[ii] = Dates.dayofyear(dats[ii])./366 .+ Dates.year(dats[ii])
    end
    return datsAsFloat
end

function dat2num(dats::Array{DateTime, 1})
    nObs = size(dats, 1)
    datsAsFloat = Array(Float64, nObs)
    for ii=1:nObs
        datsAsFloat[ii] = Dates.year(dats[ii]) .+
        Dates.dayofyear(dats[ii])./366 .+
        Dates.hour(dats[ii])./(366*24) .+
        Dates.minute(dats[ii])./(366*24*60) .+
        Dates.second(dats[ii])./(366*24*60*60)
    end
    return datsAsFloat
end

function dat2num(dats::Array{Float64, 1})
    return dats
end

function dat2num(dats::Array{Integer, 1})
    return dats
end

function dat2num(tm::AbstractTimedata)
    return dat2num(idx(tm))
end

## remove rows with NAs only
##--------------------------

function narowrm(tm::Timematr)
    return tm # nothing to do
end

function narowrm(tn::AbstractTimedata)
    nObs, nVars = size(tn)
    onlyNAs = trues(nObs)
    for ii=1:nVars
        if isa(tn.vals.columns[ii], DataArray)
            onlyNAs = onlyNAs & tn.vals.columns[ii].na
        else
            onlyNAs = falses(nObs)
            break
        end
    end
    return tn[!onlyNAs, :]
end


#########################
## unit test utilities ##
#########################

function testcase(timedataType, number::Int)
    ## easily create TimeData objects for testing

    if number == 1
        dats = [Date(2010, 1, 1):Date(2010, 1, 4)]
        df = DataFrame()
        df[:prices1] = @data([100, 120, 110, 170])
        df[:prices2] = @data([110, 120, 100, 130])
        testInst = timedataType(df, dats)

    elseif number == 2
        dats = [Date(2010, 1, 1):Date(2010, 1, 5)]
        df = DataFrame()
        df[:prices1] = @data([NA, 120, 140, 170, 200])
        df[:prices2] = @data([110, 120, NA, 130, NA])
        testInst = timedataType(df, dats)

    elseif number == 3
        dats = [Date(2010, 1, 1):Date(2010, 1, 3)]
        df = DataFrame()
        df[:color] = @data([NA, "green", "red"])
        df[:value] = @data([110, 120, NA])
        testInst = timedataType(df, dats)
    elseif number == 4
        dats = [Date(2010, 1, 1):Date(2010, 1, 5)]
        df = DataFrame()
        df[:prices1] = @data([100, 120, 140, 170, 200])
        df[:prices2] = @data([110, 120, NA, 130, 150])
        testInst = timedataType(df, dats)
    elseif number == 5
        dats = [Date(2010, 1, 1):Date(2010, 1, 5)]
        df = DataFrame()
        df[:prices1] = @data([100, 120, NA, 170, 200])
        df[:prices2] = @data([110, 120, NA, 130, 150])
        testInst = timedataType(df, dats)
    else
        error("testInst number not implemented yet")
    end
    return deepcopy(testInst)
end

#########################
## DataArray utilities ##
#########################

function findstub_vector(x::Vector)
    ## return first value that is not NA
    if !isna(x[1])
        return x[1]
    else
        for ii=2:length(x)
            if !isna(x[ii])
                return x[ii]
            end
        end
    end
    return NA
end

function anyToDa(x::Vector)
    nObs = size(x, 1)
    stubVal = findstub_vector(x)
    if isna(stubVal) # only NAs
        return DataArray(NAtype, nObs)
    else
        # split up in values and NAs
        naIndicator = falses(nObs)
        data = Array(Any, nObs)
        for ii=1:nObs
            if isna(x[ii])
                naIndicator[ii] = true
                data[ii] = stubVal
            else
                data[ii] = x[ii]
            end
        end
    end
    return DataArray([data...], naIndicator)
end

function anyToDf(x::Matrix, nams::Array{Symbol, 1})
    nObs, nCols = size(x)
    if length(nams) != nCols
        error("number of names and columns must match")
    end
    df = DataFrame()
    for ii=1:nCols
        df[nams[ii]] = anyToDa(x[:, ii])
    end
    return df
end

