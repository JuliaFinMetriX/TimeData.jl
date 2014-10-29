module TestConstructors

using Base.Test
using DataArrays
using DataFrames
using Dates

using TimeData

println("Running constructor tests")

## init test values
vals = rand(30, 4)
dats = Date[Date(2013, 7, ii) for ii=1:30]
tims = DateTime[DateTime(2010,01,ii,00,00,00)
                                 for ii=1:30]
idxs = [1:30]
## nams = ["A", "B", "C", "D"]
nams = [:A, :B, :C, :D]
valsDf = convert(DataFrame, vals)
rename!(valsDf, names(valsDf), nams)

allTypes = (:Timedata, :Timenum, :Timematr)

########################
## inner constructors ##
########################

for t in allTypes
    eval(quote
        td = $t(valsDf, dats)
        td = $t(valsDf, tims)
        td = $t(valsDf, idxs)
    end)
end

#######################################
## shortcuts from arrays without NAs ##
#######################################


for t in allTypes
    eval(quote
        ## from numeric array only
        td = $(t)(vals)

        ## from arrays without names
        td = $(t)(vals, dats)
        td = $(t)(vals, tims)
        td = $(t)(vals, idxs)

        ## from arrays without idx
        td = $(t)(vals, nams)

        ## from three arrays with names and idx
        td = $(t)(vals, nams, dats)
        td = $(t)(vals, nams, tims)
        td = $(t)(vals, nams, idxs)
    end)
end

###################
## NAs in values ##
###################

for t in allTypes
    eval(quote
        ## from DataFrame without idx
        td = $(t)(valsDf)

        ## from DataFrame with idx as array
        td = $(t)(valsDf, dats)
        td = $(t)(valsDf, tims)
        td = $(t)(valsDf, idxs)

        ## testing index values as DataArray
        td = $(t)(valsDf, convert(DataArray, idxs))
    end)
end

######################################
## throwing errors for wrong inputs ##
######################################

## idx initialized with wrong type
vals = DataFrame(a = [2, 3, 4])
invalidIdx = @data([1., NA, 3])
for t in allTypes
    eval(quote
        @test_throws Exception $(t)(vals, invalidIdx)
    end)
end

## idx and vals sizes not matching
idxVals = [Date(2013, 7, ii) for ii=1:30]
valsArr = rand(20, 4)
for t in allTypes
    eval(quote
        @test_throws Exception $(t)(valsArr, idxVals)
    end)
end

######################################
## check single column constructors ##
######################################

for t in allTypes
    eval(quote
        td = $t(rand(4))
    end)
end

end
