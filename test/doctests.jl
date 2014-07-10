
module TestDocumentation

using Base.Test
using DataArrays
using DataFrames

println("\n Running documentation tests\n")

using TimeData
using Datetime

vals = rand(4, 3);
dats = Date{ISOCalendar}[date(2013, 7, ii) for ii=1:4];
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

## indexing with dates
datesToFind = Date{ISOCalendar}[date(2013, 7, ii) for ii=2:3]
tmp = tm[datesToFind]
tm[date(2013,7,1):date(2013,7,3)]
tm[date(2013,7,2):date(2013,7,3), :B]
tm[date(2013,7,3):date(2013,7,12), [true, false, false]]

filePath = joinpath(Pkg.dir("TimeData"), "data", "logRet.csv");
tm = readTimedata(filePath)

#   str(tm) # uncomment for execution

#   writeTimedata("data/logRet2.csv", tm) # uncomment for execution

typeof(tm .+ tm)
typeof(tm .> 0.5)

tm[1:3, 1:3] .> 0.5
exp(tm[1:3, 1:3])
round(tm[1:3, 1:3], 2)

end
