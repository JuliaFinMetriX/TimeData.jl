module TestMapFunctions

using Base.Test
using DataArrays
using DataFrames

using TimeData

println("Running map function tests")

##################################
## map for columnwise iterators ##
##################################

tm = TimeData.testcase(TimeData.Timematr, 1)

## eachcol
##--------

## multiplication 
td3 = map(x -> x.*3.0, eachcol(tm)) # function acts on DataArray
tm3 = TimeData.Timematr(td3.vals, td3.idx)
expOut = tm.*3
@test TimeData.isequal(tm3, expOut)

## isna for each column
tdisna = map(x -> isna(x), eachcol(tm)) # function acts on DataArray
@test tdisna.vals[:, 1] == convert(DataArray, falses(4))

## cumulated sum for each column
tdaggr = map(x -> cumsum(x), eachcol(tm))
@test tdaggr.vals[:, 1] == @data([100, 220, 330, 500])

## eachvar
##--------

## multiplication
td3 = map(x -> x.*3.0, TimeData.eachvar(tm))
tm3 = TimeData.Timematr(td3.vals, td3.idx)
expOut = tm.*3
@test TimeData.isequal(tm3, expOut)

## isna for each column
tdisna = map(x -> TimeData.isnaElw(x), TimeData.eachvar(tm))
@test tdisna.vals[:, 1] == convert(DataArray, falses(4))

## cumulated sum for each column
tdaggr = map(x -> cumsum(x, 1), TimeData.eachvar(tm))
@test tdaggr.vals[:, 1] == @data([100, 220, 330, 500])

###############################
## map for rowwise iterators ##
###############################

tm = TimeData.testcase(TimeData.Timematr, 1)

## eachrow
##--------

## identity function
tdIden = map(x -> x, TimeData.eachrow(tm))
tmIden = TimeData.Timematr(tdIden.vals, tdIden.idx)
@test TimeData.isequal(tm, tmIden)

## value of second column everywhere
tdDup = map(x -> [x[1, 2], x[1, 2]], TimeData.eachrow(tm))
tmDup = TimeData.Timematr(tdDup.vals, tdDup.idx)
expOut = TimeData.Timematr(DataFrame(prices1 = tm.vals[:, 2],
                                     prices2 = tm.vals[:, 2]),
                           TimeData.idx(tm))
@test TimeData.isequal(tmDup, expOut)

## eachdate
##---------

## multiplication
td3 = map(x -> (x.*3.5).vals, TimeData.eachdate(tm))
tm3 = TimeData.Timematr(td3.vals, td3.idx)
expOut = tm.*3.5
@test TimeData.isequal(tm3, expOut)

td3 = map(x -> x.*3.5, TimeData.eachdate(tm))
tm3 = TimeData.Timematr(td3.vals, td3.idx)
@test TimeData.isequal(tm3, expOut)

## cumulated sum for each column
tdaggr = map(x -> cumsum(x, 2), TimeData.eachdate(tm))
@test tdaggr.vals[:, 1] == tm.vals[:, 1]
@test tdaggr.vals[:, 2] == @data([210, 240, 210, 300])

tdaggr = map(x -> cumsum(x, 2).vals, TimeData.eachdate(tm))
@test tdaggr.vals[:, 1] == tm.vals[:, 1]
@test tdaggr.vals[:, 2] == @data([210, 240, 210, 300])


###################################
## map for elementwise iterators ##
###################################

## multiplication
tn = TimeData.testcase(TimeData.Timenum, 2)
td2 = map(x -> 2*x, TimeData.eachentry(tn))
tn2 = convert(TimeData.Timenum, td2)
expOut = tn.*2
@test isequal(tn2, expOut)

tn = TimeData.testcase(TimeData.Timenum, 2)
td2 = map(x -> 2.*get(x, 1, 1), TimeData.eachobs(tn))
## mathematical operations on DataArray{NAtype, 1} with single row are
## currently not working

tn2 = convert(TimeData.Timenum, td2)
expOut = tn.*2
@test isequal(tn2, expOut)


##################
## test chkVars ##
##################

## column sum greater 490
td = TimeData.testcase(TimeData.Timedata, 1)
actOut = TimeData.chkVars(x -> sum(x) > 490, eachcol(td))
expOut = DataFrame(prices1 = true, prices2 = false)
@test isequal(expOut, actOut)

## NA in column
td = TimeData.testcase(TimeData.Timedata, 3)
actOut = TimeData.chkVars(x -> any(isna(x)), eachcol(td))
expOut = DataFrame(color = true, value = true)
@test isequal(expOut, actOut)

## column mean greater than 120 using eachvar
tm = TimeData.testcase(TimeData.Timematr, 1)
actOut = TimeData.chkVars(x -> mean(x, 1)[1, 1] .> 120,
                          TimeData.eachvar(tm))
expOut = DataFrame(prices1 = true, prices2 = false)
@test isequal(expOut, actOut)

## NA at day 2010-01-01
td = TimeData.testcase(TimeData.Timedata, 3)
actOut = TimeData.chkVars(x -> TimeData.isnaElw(x[Date(2010,1,1)]),
                          TimeData.eachvar(td))
expOut = DataFrame(color = true, value = false)
@test isequal(expOut, actOut)


###################
## test chkDates ##
###################

## is NA in row?
td = TimeData.testcase(TimeData.Timedata, 3)
function anyNA(dfr::DataFrame)
    containsNA = false
    for ii=1:size(dfr, 2)
        if isna(dfr[1, ii])
            containsNA = true
            break
        end
    end
    return containsNA
end

tdHolds = TimeData.chkDates(x -> anyNA(x), TimeData.eachrow(td))
@test isequal(tdHolds.vals[:, 1], @data([true, false, true]))

## is row equal to given date
tdHolds = TimeData.chkDates(x -> TimeData.idx(x) == [Date(2010,1,1)],
                            TimeData.eachdate(td))

@test isequal(tdHolds.vals[:, 1], @data([true, false, false]))

#################
## test chkElw ##
#################

tn = TimeData.testcase(TimeData.Timenum, 2)
tnHolds = TimeData.chkElw(x -> x.>120, TimeData.eachentry(tn))
expOut = tn .> 120
@test isequal(tnHolds, expOut)


########################
## test collapseDates ##
########################

## eachcol
##--------

## column sum with NAs
tn = TimeData.testcase(TimeData.Timenum, 2)
df = TimeData.collapseDates(x -> sum(x), eachcol(tn))
expOut = DataFrame(prices1 = [NA], prices2 = [NA])
@test isequal(df, expOut)

## column sum skipping NAs
function sumSkipNA(da::DataArray)
    sumVal = 0
    for ii=1:length(da)
        if !isna(da[ii])
            sumVal += da[ii]
        end
    end 
    return sumVal
end

tn = TimeData.testcase(TimeData.Timenum, 2)
df = TimeData.collapseDates(x -> sumSkipNA(x), eachcol(tn))
expOut = DataFrame(prices1 = 630, prices2 = 360)
@test isequal(df, expOut)

## eachvar
##--------

## column sum
tm = TimeData.testcase(TimeData.Timematr, 1)
df = TimeData.collapseDates(x -> sum(x, 1), TimeData.eachvar(tm))
expOut = DataFrame(prices1 = 500, prices2 = 460)
@test isequal(df, expOut)

## count NAs
function countNAs(td::TimeData.AbstractTimedata)
    return sum(TimeData.asArr(TimeData.isnaElw(td), Bool, false))
end

tn = TimeData.testcase(TimeData.Timenum, 2)
df = TimeData.collapseDates(x -> countNAs(x),
                            TimeData.eachvar(tn))
expOut = DataFrame(prices1 = 1, prices2 = 2)
@test isequal(df, expOut)


#######################
## test collapseVars ##
#######################

## eachrow
##--------

## count NAs
function countNAs(df::DataFrame)
    sumNAs = 0
    for ii=1:size(df, 2)
        if isna(df[1, ii])
            sumNAs += 1
        end
    end
    return sumNAs
end

tn = TimeData.testcase(TimeData.Timenum, 2)
td = TimeData.collapseVars(x -> countNAs(x),
                           eachrow(tn))

expOut = TimeData.Timedata(DataFrame(funcVal = [1, 0, 1, 0, 1]),
                           TimeData.idx(tn))

@test isequal(expOut, td)

## eachdate
##---------

## calculate mean
function meanDfRow(df::DataFrame)
    sumVal = 0
    sumNAs = 0
    for ii=1:size(df, 2)
        if !isna(df[1, ii])
            sumVal += df[1, ii]
        else
            sumNAs += 1
        end
    end
    return sumVal ./ (size(df, 2) - sumNAs)
end

tn = TimeData.testcase(TimeData.Timenum, 2)
td = TimeData.collapseVars(x -> meanDfRow(x.vals),
                           TimeData.eachdate(tn))

mVals = [110, 120, 140, 150, 200]
expOut = TimeData.Timedata(DataFrame(funcVal = mVals),
                           TimeData.idx(tn))

@test isequal(expOut, td)

## using already existing rowmeans function for Timenum
td = TimeData.collapseVars(x -> TimeData.rowmeans(x),
                           TimeData.eachdate(tn))
@test isequal(expOut, td)
end
