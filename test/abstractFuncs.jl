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

## test information retrieval functions
for t in allTypes
    eval(quote
        ## unequal column names
        td = $(t)(rand(10, 2))
        td2 = $(t)(rand(10,2), [:a, :b])
        @test_throws ErrorException vcat(td, td2)
        
        ## unequal indices
        td = $(t)(rand(10,2), [:a, :b])
        td2 = $(t)(rand(10,2), [:a, :b],
                   [date(2010,1,1):date(2010,1,10)]) 
        @test_throws ErrorException vcat(td, td2)
        
        ## vcat
        df = DataFrame()
        df[:a] = @data([0.4, 0.3])
        df[:b] = @data([0.3, 0.8])
        
        dats1 = [date(2014,1,1):date(2014,1,2)]
        dats2 = [date(2014,1,3):date(2014,1,4)]
        td = $(t)(df, dats1)
        td2 = $(t)(df, dats2)
        td3 = $(t)(vcat(df, df), [dats1, dats2])
        td4 = $(t)(vcat(df, df, df), [dats1, dats2, dats1])
        
        ## multiple arguments
        @test isequal(vcat(td, td2), td3)
        @test isequal(vcat(td, td2, td), td4)
        
        ## throw error for unequal types
        td = Timedata(rand(4, 3))
        tm = Timematr(rand(4, 3))
        @test_throws ErrorException vcat(tm, td)
        @test_throws ErrorException vcat(tm, td, td)
        
    end)
end

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
tn4 = Timenum(df, [date(2010, 1, 1):date(2010, 1, 2)])

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

##################
## flipud tests ##
##################

for t in allTypes
    eval(quote
        
        nams = [:a, :b]
        vals = [0.2 0.4; 0.6 0.8]
        df = composeDataFrame(vals, nams)
        df2 = composeDataFrame(flipud(vals), nams)
        td = $(t)(df)
        expFlipped = $(t)(df2, flipud(idx(td)))
        
        @test flipud(td) == expFlipped
        @test isequal(expFlipped, flipud(td))
        
        @test flipud(flipud(td)) == td
        @test isequal(flipud(flipud(td)), td)
        
    end)
end

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

##########
## narm ##
##########

dfShort = DataFrame()
dfShort[:a] = @data([3])
dfShort[:b] = @data([4])
tdShort = Timedata(dfShort)
tnShort = Timenum(dfShort)
tm = Timematr(rand(2, 3))

@test narm(td) == tdShort
@test narm(tn) == tnShort
@test narm(tm) == tm

########################
## asTd / asTm / asTn ##
########################

## test isaRowVector
@test isaRowVector([1 2 3])
@test !isaRowVector([1, 2, 3])

kk = Array(Float64, 1, 1)
@test isaRowVector(kk)

@test !isaRowVector([1])
@test_throws ErrorException isaRowVector(1)

## test asArrayOfEqualDimensions
td = Timedata(rand(2, 2))
@test asArrayOfEqualDimensions([1 2], td) == [1 2; 1 2]
@test asArrayOfEqualDimensions([1, 2], td) == [1 1; 2 2]

kk = Array(Int, 1, 1)
kk[1] = 1
@test asArrayOfEqualDimensions([1], td[1, 1]) == kk
@test asArrayOfEqualDimensions(1, td[1, 1]) == kk
@test asArrayOfEqualDimensions(1, td) == [1 1; 1 1]
@test_throws ErrorException asArrayOfEqualDimensions([3 4; 5 6], td[1, 1])

df = DataFrame(x1 = [1, 2], x2 = [1, 2])
@test TimeData.asTd([1, 2], td) == TimeData.Timedata(df)

df = DataFrame(x1 = [1, 1], x2 = [2, 2])
@test TimeData.asTd([1 2], td) == TimeData.Timedata(df)

###############
## issimilar ##
###############

df = DataFrame()
df[:a] = @data([4, 5, 6, NA, 8])
df[:b] = @data([3, 8, NA, NA, 2])
dats = [date(2014,1,1):date(2014,1,5)]
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
dats = [date(2014,1,1):date(2014,1,5)]
tn2 = TimeData.Timenum(df, dats)
names!(tn2.vals, [:c, :d])
@test !TimeData.issimilar(tn, tn2)

## different types
tm = TimeData.Timedata(df, dats)
@test !TimeData.issimilar(tn, tm)

end
