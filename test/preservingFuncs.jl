module TestPreservingFuncs

using Base.Test
using DataArrays
using DataFrames
using Dates
using TimeData

println("\n Running type preserving function tests\n")

allTypes = (:Timedata, :Timenum, :Timematr)

############
## setNA! ##
############

## set up Timenum with NAs
df = DataFrame()
df[:a] = @data([4, 5, 6, NA, 8])
df[:b] = @data([3, 8, NA, NA, 2])
dats = [Date(2014,1,1):Date(2014,1,5)]
tn = Timenum(df, dats)

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
                   [Date(2010,1,1):Date(2010,1,10)]) 
        @test_throws ErrorException vcat(td, td2)
        
        ## vcat
        df = DataFrame()
        df[:a] = @data([0.4, 0.3])
        df[:b] = @data([0.3, 0.8])
        
        dats1 = [Date(2014,1,1):Date(2014,1,2)]
        dats2 = [Date(2014,1,3):Date(2014,1,4)]
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

##########
## narm ##
##########

df = DataFrame()
df[:a] = @data([3, NA])
df[:b] = @data([4, NA])
td = Timedata(df)
tn = Timenum(df)
tm = Timematr(rand(2, 3))

td = Timedata(df)
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


end
