
module TestDocumentation

using Base.Test
using DataArrays
using DataFrames
using Dates

println("\n Running documentation tests\n")

using TimeData
using Dates

fileName = joinpath(Pkg.dir("TimeData"), "data/logRet.csv")
tm = TimeData.readTimedata(fileName)[1:10, 1:4]

tm[Date(2012, 1, 4):Date(2012, 1, 10), 1:2]

tm[3:8, 2:3]

tm[3:8, [:ABT, :MMM]]

newTm = 2.*tm

mean(tm, 1)

rowmeans(tm)

vals = rand(4, 3);
dats = [Date(2013, 7, ii) for ii=1:4];
nams = [:A, :B, :C];
valsDf = composeDataFrame(vals, nams);

tm = Timematr(valsDf, dats)

td = Timedata(vals, nams, dats)
td = Timedata(vals, nams)
td = Timedata(vals, dats)
td = Timedata(vals)

typeof(valsDf[:, 1])
typeof(td[:, 1])

typeof(valsDf[1, 1])
typeof(td[1, 1])

## empty instance
typeof(td[4:3, 5:4])

## indexing by numeric indices
tmp = tm[2:3]
tmp = tm[1:3, 1:2]
tmp = tm[2, :]
tmp = tm[2]
tmp = tm[1:2, 2]
tmp = tm[3, 3]

## indexing with column names as symbols
tmp = tm[:A]
tmp = tm[2, [:A, :B]]

## logical indexing
logicCol = [true, false, true]
logicRow = repmat([true, false], 2, 1)[:]
tmp = tm[logicCol]
tmp = tm[logicRow, logicCol]
tmp = tm[logicRow, :]

## indexing with Dates
DatesToFind = [Date(2013, 7, ii) for ii=2:3]
tmp = tm[DatesToFind]
tm[Date(2013,7,1):Date(2013,7,3)]
tm[Date(2013,7,2):Date(2013,7,3), :B]
tm[Date(2013,7,3):Date(2013,7,12), [true, false, false]]

## returning the first value only
get(tm, 1, 1)

## returning all values as Array{Any,2}
kk = get(tm)
isa(kk, Array{Any})

filePath = joinpath(Pkg.dir("TimeData"), "data", "logRet.csv");
tm = readTimedata(filePath)
tm[1:5, 1:4]

tm

## str(tm) # uncomment for execution

#   writeTimedata("data/logRet2.csv", tm) # uncomment for execution

typeof(tm .+ tm)
typeof(tm .> 0.5)

tm[1:3, 1:3] .> 0.5
exp(tm[1:3, 1:3])
round(tm[1:3, 1:3], 2)

end
