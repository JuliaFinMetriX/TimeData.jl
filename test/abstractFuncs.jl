module TestAbstractFuncs

using Base.Test
using DataArrays
using DataFrames
using Datetime
using TimeData

println("\n Running abstract function tests\n")

## create instance
vals = rand(30, 4)
vals[3, 4] = 0.5
dats = Date{ISOCalendar}[date(2013, 7, ii) for ii=1:30]
nams = [:A, :B, :C, :D]

allTypes = (:Timedata, :Timenum, :Timematr, :Timecop)

## test information retrieval functions
for t in allTypes
    eval(quote
        td = $(t)(vals, nams, dats)
        @test isequal(names(td), nams)
        @test isequal(TimeData.idx(td), DataArray(dats))
        @test get(td, 3, 4) == 0.5
        @test get(td)[3, 4] == 0.5
    end)
end

################
## vcat tests ##
################

tm = Timedata(rand(10,2))
tm2 = Timedata(rand(10,2), [:a, :b])
@test_throws ErrorException vcat(tm, tm2)

tm = Timedata(rand(10,2), [:a, :b])
tm2 = Timedata(rand(10,2), [:a, :b], [date(2010,1,1):date(2010,1,10)])
@test_throws ErrorException vcat(tm, tm2)

tm = Timedata(rand(10, 2))
tm2 = Timedata(rand(10, 2))
vcat(tm, tm2)

tm = Timecop(rand(10,2))
tm2 = Timecop(rand(10,2), [:a, :b])
@test_throws ErrorException vcat(tm, tm2)

tm = Timecop(rand(10,2), [:a, :b])
tm2 = Timecop(rand(10,2), [:a, :b], [date(2010,1,1):date(2010,1,10)])
@test_throws ErrorException vcat(tm, tm2)

tm = Timecop(rand(10, 2))
tm2 = Timecop(rand(10, 2))
vcat(tm, tm2)

end
