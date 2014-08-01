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

###########################
## names, idx, get, core ##
###########################


## test information retrieval functions
for t in allTypes
    eval(quote
        td = $(t)(vals, nams, dats)
        @test isequal(names(td), nams)
        @test isequal(TimeData.idx(td), DataArray(dats))
        @test get(td, 3, 4) == 0.5
        @test get(td)[3, 4] == 0.5
        @test core(td)[3, 4] == 0.5
        @test size(td) == (30, 4)
        @test ndims(td) == 2
        @test td[:, 1:2] == hcat(td[1], td[2])
#        @test td == hcat(td[1], td[2], td[3], td[4])
    end)
end

##########
## isna ##
##########

## set up Timenum with NAs
df = DataFrame()
df[:a] = @data([4, 5, 6, NA, 8])
df[:b] = @data([3, 8, NA, NA, 2])
dats = [date(2014,1,1):date(2014,1,5)]
tn = Timenum(df, dats)

## test outcome
naVals = [false false; false false; false true; true true; false false]
isNaTd = Timedata(naVals, names(tn), idx(tn))
@test isna(tn) == isNaTd

############
## setNA! ##
############

setNA!(tn, 1, 2)
get(tn, 1, 2) == NA

tm = Timematr(rand(2, 2))
@test_throws ErrorException setNA!(tm, 1, 2)

################
## hcat tests ##
################

tm = Timematr(rand(2, 3))
hcat(tm[:, 1], tm[:, 2], tm[:, 3])

td = Timedata(rand(2, 3))
hcat(td[:, 1], td[:, 2])
hcat(td[:, 1], td[:, 2], td[:, 1])
hcat(tm[:, 1], tm[:, 2], tm[:, 1])
@test_throws ErrorException hcat(tm[:, 1], td[:, 2])
@test_throws ErrorException hcat(tm[:, 1], tm[:, 2], td[:, 2])


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
