########################
## plotting utilities ##
########################

## process dates
##--------------

function datsAsStrings(dats::Array{Date, 1})
    nObs = size(dats, 1)
    datsAsStr = Array(ASCIIString, nObs)
    for ii=1:nObs
        datsAsStr[ii] = string(dats[ii])
    end
    return datsAsStr
end

function datsAsStrings(tm::AbstractTimedata)
    return datsAsStrings(idx(tm))
end

function datsAsFloats(dats::Array{Date, 1})
    nObs = size(dats, 1)
    datsAsFloat = Array(Float64, nObs)
    for ii=1:nObs
        datsAsFloat[ii] = Dates.dayofyear(dats[ii])./366 .+ Dates.year(dats[ii])
    end
    return datsAsFloat
end

function datsAsFloats(tm::AbstractTimedata)
    return datsAsFloats(idx(tm))
end

## remove rows with NAs only
##--------------------------

function rmDatesOnlyNAs(tn::Timenum)
    nObs, nVars = size(tn)
    onlyNAs = [true for ii=1:nObs]
    for ii=1:nObs
        onlyNAsInRow = true
        for jj=1:nVars
            if !isna(get(tn, ii, jj))
                onlyNAs[ii] = false
                break
            end
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

    else
        error("testInst number not implemented yet")
    end
    return deepcopy(testInst)
end
