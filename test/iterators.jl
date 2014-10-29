module TestIterators

using Base.Test
using DataArrays
using DataFrames
using Dates

using TimeData
## using TimeData

println("Running iterator tests")

##########################
## iteration by columns ##
##########################

tm = TimeData.testcase(TimeData.Timematr, 1)

## TdColumnIterator
##-----------------

tdci = eachcol(tm)
dfci = eachcol(tm.vals)
@test next(tdci, 1) == next(dfci, 1)
nam, da = next(tdci, 1)[1]
@test isa(nam, Symbol)
@test isa(da, DataArray)
@test nam == :prices1
@test da == tm.vals[:, 1]

## TdVariableIterator
##-------------------

tdvi = TimeData.eachvar(tm)
tmCol = next(tdvi, 1)[1]
@test isa(tmCol, TimeData.AbstractTimedata)
@test names(tmCol)[1] == :prices1
@test tmCol.vals[:, 1] == tm.vals[:, 1]
@test TimeData.idx(tmCol) == TimeData.idx(tm)

## horizontal concatenation should return original object
@test tm == hcat([col for col in TimeData.eachvar(tm)]...)


#######################
## iteration by rows ##
#######################

tm = TimeData.testcase(TimeData.Timematr, 1)

## eachrow
##--------

tdri = eachrow(tm)
df = next(tdri, 3)[1]
@test isa(df, DataFrame)
@test names(df) == names(tm)
@test df[1, 1] == get(tm, 3, 1)

## eachdate
##---------

tddi = TimeData.eachdate(tm)
tmRow = next(tddi, 3)[1]
@test isa(tmRow, TimeData.AbstractTimedata)
@test names(tmRow) == names(tm)
@test TimeData.idx(tmRow)[1] == TimeData.idx(tm)[3]
@test get(tmRow, 1, 1) == get(tm, 3, 1)

## vertical concatenation should return original object
@test isequal([[row for row in TimeData.eachdate(tm)]...], tm)

###########################
## elementwise iterators ##
###########################

## eachentry
##----------

tm = TimeData.testcase(TimeData.Timematr, 1)

allEntries = Float64[]
for entry in TimeData.eachentry(tm)
    push!(allEntries, entry)
end
expOut = [100, 120, 110, 170, 110, 120, 100, 130.]
@test isequal(allEntries, expOut)

## eachobs
##--------

@test isequal(tm[1, 1], next(TimeData.eachobs(tm), 1)[1])
@test isa(next(TimeData.eachobs(tm), 5)[1], TimeData.Timematr)

td = TimeData.testcase(TimeData.Timedata, 3)
@test isa(next(TimeData.eachobs(td), 5)[1], TimeData.Timedata)


end

