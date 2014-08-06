module TestAbstractFuncs

using Base.Test
using DataArrays
using DataFrames
using Dates
using TimeData

println("\n Running abstract function tests\n")

## create instance
vals = rand(30, 4)
vals[3, 4] = 0.5
dats = Date[Date(2013, 7, ii) for ii=1:30]
nams = [:A, :B, :C, :D]

allTypes = (:Timedata, :Timenum, :Timematr)

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
dats = [Date(2014,1,1):Date(2014,1,5)]
tn = Timenum(df, dats)

## test outcome
naVals = [false false; false false; false true; true true; false false]
isNaTd = Timedata(naVals, names(tn), idx(tn))
@test isna(tn) == isNaTd



###################
## isequal tests ##
###################

df = DataFrame()
df[:a] = @data([3, NA])
df[:b] = @data([4, NA])

df2 = DataFrame()
df2[:a] = @data([3, 4])
df2[:b] = @data([4, NA])

df3 = DataFrame()
df3[:a] = @data([10, 4])
df3[:b] = @data([4, NA])

tn = Timenum(df)
tn2 = Timenum(df2)
tn3 = Timenum(df3)
td = Timedata(df)
tn4 = Timenum(df, [Date(2010, 1, 1):Date(2010, 1, 2)])

## testing isequal
@test isequal(tn, tn)
@test !isequal(tn, tn2)
@test !isequal(tn, tn3)

## testing == 
@test isna(tn == tn)
@test isna(tn == tn2)
@test !(tn == tn3)

## differences in names, indices or types
@test !isequal(tn, td)
@test !(tn == td)
@test !isequal(tn, tn4)
@test !(tn == tn4)

## elementwise equal objects
@test isequalElemwise(tn, tn) == Timedata([true true; true true],
                                          names(td), idx(td))

## elementwise with unequal entries

## differences in names, indices or types throw errors
@test_throws ErrorException !isequalElemwise(tn, td)
@test_throws ErrorException !isequalElemwise(tn, tn4)

@test isequalElemwise(tn, tn2) == Timedata([true true; false true],
                                           names(td), idx(td))


####################
## complete_cases ##
####################

df = DataFrame()
df[:a] = @data([3, NA])
df[:b] = @data([4, NA])
td = Timedata(df)
tn = Timenum(df)
tm = Timematr(rand(2, 3))

@test complete_cases(td) == [true, false]
@test complete_cases(tn) == [true, false]
@test complete_cases(tm) == [true, true]


###############
## issimilar ##
###############

df = DataFrame()
df[:a] = @data([4, 5, 6, NA, 8])
df[:b] = @data([3, 8, NA, NA, 2])
dats = [Date(2014,1,1):Date(2014,1,5)]
tn = TimeData.Timenum(df, dats)

## similar
@test TimeData.issimilar(tn, tn)

## different indices
tn2 = TimeData.Timenum(df)
@test !TimeData.issimilar(tn, tn2)

## different names
df = DataFrame()
df[:a] = @data([4, 5, 6, NA, 8])
df[:b] = @data([3, 8, NA, NA, 2])
dats = [Date(2014,1,1):Date(2014,1,5)]
tn2 = TimeData.Timenum(df, dats)
names!(tn2.vals, [:c, :d])
@test !TimeData.issimilar(tn, tn2)

## different types
tm = TimeData.Timedata(df, dats)
@test !TimeData.issimilar(tn, tm)

end
