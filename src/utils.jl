########################
## plotting utilities ##
########################

## process dates to strings
##-------------------------

function datesAsStrings(dats::Array{Date, 1})
    nObs = size(dats, 1)
    datsAsStr = Array(ASCIIString, nObs)
    for ii=1:nObs
        datsAsStr[ii] = string(dats[ii])
    end
    return datsAsStr
end

function datesAsStrings(dats::Array{DateTime, 1})
    nObs = size(dats, 1)
    datsAsStr = Array(ASCIIString, nObs)
    for ii=1:nObs
        datsAsStr[ii] = string(dats[ii])
    end
    return datsAsStr
end

function datesAsStrings(dats::Array{Integer, 1})
    nObs = size(dats, 1)
    datsAsStr = Array(ASCIIString, nObs)
    for ii=1:nObs
        datsAsStr[ii] = string(dats[ii])
    end
    return datsAsStr
end

function datesAsStrings(dats::Array{Float64, 1})
    nObs = size(dats, 1)
    datsAsStr = Array(ASCIIString, nObs)
    for ii=1:nObs
        datsAsStr[ii] = string(dats[ii])
    end
    return datsAsStr
end

function datesAsStrings(tm::AbstractTimedata)
    return datesAsStrings(idx(tm))
end

## process dates to floating point numbers
##----------------------------------------

function datesAsNumbers(dats::Array{Date, 1})
    nObs = size(dats, 1)
    datsAsFloat = Array(Float64, nObs)
    for ii=1:nObs
        datsAsFloat[ii] = Dates.dayofyear(dats[ii])./366 .+ Dates.year(dats[ii])
    end
    return datsAsFloat
end

function datesAsNumbers(dats::Array{DateTime, 1})
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

function datesAsNumbers(dats::Array{Float64, 1})
    return dats
end

function datesAsNumbers(dats::Array{Integer, 1})
    return dats
end

function datesAsNumbers(tm::AbstractTimedata)
    return datesAsNumbers(idx(tm))
end

## remove rows with NAs only
##--------------------------

function rmDatesOnlyNAs(tm::Timematr)
    return tm # nothing to do
end

function rmDatesOnlyNAs(tn::AbstractTimedata)
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
