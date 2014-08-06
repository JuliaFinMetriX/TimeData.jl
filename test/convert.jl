module TestConversions

using Base.Test
using DataArrays
using DataFrames
using Dates
using TimeData
## using TimeData

println("\n Running conversion tests\n")

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
