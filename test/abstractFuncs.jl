module TestAbstractFuncs

using Base.Test
using DataArrays
using DataFrames
using Datetime
using TimeData

println("\n Running abstract function tests\n")

## create instance
vals = rand(30, 4)
dats = Date{ISOCalendar}[date(2013, 7, ii) for ii=1:30]
nams = ["A", "B", "C", "D"]

allTypes = (:Timedata, :Timenum, :Timematr, :Timecop)

## test information retrieval functions
for t in allTypes
    eval(quote
        td = $(t)(vals, nams, dats)
        @test isequal(names(td), nams)
        @test isequal(TimeData.idx(td), DataArray(dats))
    end)
end


end
