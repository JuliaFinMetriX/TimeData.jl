
using TimeData
using Datetime

vals = rand(30, 4)
dats = [date(2013, 7, ii) for ii=1:30]
nams = ["A", "B", "C", "D"]
valsDf = DataFrame(vals, nams)
datsDa = DataArray(dats)

tm = Timematr(valsDf, datsDa)

tm = Timematr(vals, nams, dats)
tm = Timematr(vals, nams)
tm = Timematr(vals, dats)
tm = Timematr(vals)

tm = Timematr(valsDf)
tm = Timematr(valsDf, dats)

tm = Timematr(vals, datsDa)
tm = Timematr(vals, nams, datsDa)

typeof(valsDf[:, 1])
typeof(tm[:, 1])

typeof(valsDf[1, 1])
typeof(tm[1, 1])

## empty instance
typeof(tm[4:3, 5:4])

## indexing by numeric indices
tmp = tm[2:4]
tmp = tm[3:5, 1:2]
tmp = tm[5, :]
tmp = tm[2]
tmp = tm[5:8, 2]
tmp = tm[5, 3]

## indexing with column names
tmp = tm["A"]
tmp = tm[5, ["A", "B"]]

## indexing with column names as symbols
tmp = tm[4:10, :A]

## logical indexing
logicCol = [true, false, true, false]
logicRow = repmat([true, false, true], 10, 1)[:]
tmp = tm[logicCol]
tmp = tm[logicRow, logicCol]
tmp = tm[logicRow, :]

## logically indexing rows directly from expression
ex = :(A .> 0.5)
tmp = tm[ex, :]

## indexing by date
tmp = tm[date(2013, 07, 04)]

datesToFind = [date(2013, 07, ii) for ii=12:18]
tmp = tm[datesToFind]
tm[date(2013,01,03):date(2013,07,12)]
tm[date(2013,01,03):date(2013,07,12), ["B", "C"]]
tm[date(2013,01,03):date(2013,07,12), :D]
tm[date(2013,01,03):date(2013,07,12),
             [true, false, false, true]]

tm = readTimedata("data/logRet.csv")

str(tm)

writeTimedata("data/logRet2.csv", tm)

typeof(tm + tm)
typeof(tm .> 0.5)

tm[1:3, 1:3] .> 0.5
exp(tm[1:3, 1:3])
round(tm[1:3, 1:3], 2)
