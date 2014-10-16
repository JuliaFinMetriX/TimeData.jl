module TestConversions

using Base.Test
using DataArrays
using DataFrames

using TimeData
## using TimeData

println("Running conversion tests")

###########
## asArr ##
###########

## DataArray
##----------

da = @data([NA, 3, 4, NA])
expOut = Float64[NaN, 3.0, 4.0, NaN]
@test isequal(expOut, TimeData.asArr(da, Float64, NaN))

da = @data([NA, true, true, false])
expOut = Bool[true, true, true, false]
@test isequal(expOut, TimeData.asArr(da, Bool, true))

da = @data([true, true, "hello", NA])
expOut = Any[true, true, "hello", NaN]
@test isequal(expOut, TimeData.asArr(da, Any, NaN))

da = @data(["dog", "house", "hello", NA])
expOut = UTF8String["dog", "house", "hello", ""]
@test isequal(expOut, TimeData.asArr(da, UTF8String, ""))

## should throw error

da = @data([true, true, "hello", NA])
@test_throws Exception TimeData.asArr(da, Float64, true)

da = @data(["dog", "house", "hello", NA])
@test_throws Exception TimeData.asArr(da, UTF8String, 4.3)


## DataFrames
##-----------

df = DataFrame(a = @data([3.4, NA]),
               b = @data([3.4, NA]))
               
expOut = [3.4 3.4; NaN NaN]
@test isequal(expOut, TimeData.asArr(df, Float64, NaN))
@test_throws Exception TimeData.asArr(df, Float64)

df = DataFrame(a = ["hello", "world"],
               b = @data(["what", NA]))

expOut = ["hello" "what"; "world" "is"]
@test isequal(expOut, TimeData.asArr(df, String, "is"))

df = DataFrame(a = true, b = false, c = NA)
@test isequal([true false true], TimeData.asArr(df, Bool, true))


## TimeData
##---------

tn = TimeData.testcase(TimeData.Timenum, 2)[1:2,:]
expOut = [NaN 110; 120 120.0]
@test isequal(expOut, TimeData.asArr(tn, Float64, NaN))

expOut = [0 110; 120 120]
@test isequal(expOut, TimeData.asArr(tn, Float64, 0))

## NaN not allowed in Int
@test_throws InexactError TimeData.asArr(tn, Int, NaN)

expOut = Any[NA 110; 120 120]
@test isequal(expOut, TimeData.asArr(tn))

## DataFrameRow
##-------------

df = DataFrame(a = @data([3, NA]),
               b = @data([3, NA]))

rowIter = eachrow(df)
expOut = Float64[3.0 3.0]
@test isequal(expOut, TimeData.asArr(next(rowIter, 1)[1], Float64))

expOut = Float64[NaN NaN]
@test isequal(expOut, TimeData.asArr(next(rowIter, 2)[1], Float64, NaN))


##############
## TimeData ##
##############

df = DataFrame()
df[:a] = @data([4, NA])
df[:b] = @data([3, 8])
dats1 = [Date(2014,1,1):Date(2014,1,2)]
tn = TimeData.Timenum(df, dats1)

## convert Timenum
@test isequal(TimeData.convert(TimeData.Timedata, tn), TimeData.Timedata(df, dats1))
@test_throws ArgumentError TimeData.convert(TimeData.Timematr, tn)
@test TimeData.convert(TimeData.Timematr, tn, true) == TimeData.Timematr(df[1, :], [dats1[1]])

## convert Timematr
vals = rand(2, 4)
tm = TimeData.Timematr(vals, dats1)
@test TimeData.convert(TimeData.Timedata, tm) == TimeData.Timedata(vals, dats1)
@test TimeData.convert(TimeData.Timenum, tm) == TimeData.Timenum(vals, dats1)


## convert Timedata
vals = rand(2, 4)
tm = TimeData.Timedata(vals, dats1)
@test TimeData.convert(TimeData.Timematr, tm) == TimeData.Timematr(vals, dats1)
@test TimeData.convert(TimeData.Timenum, tm) == TimeData.Timenum(vals, dats1)

## non-convertible objects: NAs included
df = DataFrame()
df[:a] = @data([4, NA])
df[:b] = @data([3, 8])
dats1 = [Date(2014,1,1):Date(2014,1,2)]
tn = TimeData.Timedata(df, dats1)

TimeData.convert(TimeData.Timenum, tn)
@test_throws ArgumentError TimeData.convert(TimeData.Timematr, tn)

## non-convertible objects: strings included
df = DataFrame()
df[:a] = @data(["hello", NA])
df[:b] = @data([3, 8])
dats1 = [Date(2014,1,1):Date(2014,1,2)]
tn = TimeData.Timedata(df, dats1)

@test_throws ArgumentError TimeData.convert(TimeData.Timenum, tn)
@test_throws ArgumentError TimeData.convert(TimeData.Timematr, tn)

end
