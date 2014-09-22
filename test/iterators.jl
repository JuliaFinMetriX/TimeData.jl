module TestIterators

using Base.Test
using DataArrays
using DataFrames

using TimeData
## using TimeData

println("Running iterator tests")

df = DataFrame()
df[:a] = @data([4, 5])
df[:b] = @data([3, 8])
dats = [Date(2014,1,1):Date(2014,1,2)]

tn = TimeData.Timenum(df, dats)
tm = TimeData.Timematr(df, dats)
td = TimeData.Timedata(df, dats)

## horizontal concatenation of column iterator
@test isequal(hcat([col for col in eachcol(tn)]...), tn)
@test isequal(hcat([col for col in eachcol(td)]...), td)
@test isequal(hcat([col for col in eachcol(tm)]...), tm)

## vertical concatenation of row iterator
@test isequal([[row for row in eachrow(tn)]...], tn)
@test isequal([[row for row in eachrow(tm)]...], tm)
@test isequal([[row for row in eachrow(td)]...], td)


@test typeof(eachcol(tn)[1]) == typeof(tn)
@test typeof(eachrow(td)[1]) == typeof(td)
@test typeof(eachrow(tm)[1]) == typeof(tm)

## testing map
df2 = DataFrame()
df2[:a] = @data([8, 10])
df2[:b] = @data([6, 16])
dats = [Date(2014,1,1):Date(2014,1,2)]

tn2 = TimeData.Timenum(df2, dats)
tm2 = TimeData.Timematr(df2, dats)
td2 = TimeData.Timedata(df2, dats)

@test map(x -> x.*2, eachcol(tn)) == tn2
@test map(x -> x.*2, eachcol(tm)) == tm2
@test map(x -> x.*2, eachcol(td)) == td2

end

