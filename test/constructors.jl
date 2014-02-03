module TestConstructors

using Base.Test
using DataArrays
using DataFrames
using Datetime
using TimeData

println("\n Running constructor tests\n")

## init test values
vals = rand(30, 4)
dats = [date(2013, 7, ii) for ii=1:30]
tims = DateTime{ISOCalendar,UTC}[datetime(2010,02,ii,00,00,00)
                                 for ii=1:30]
idxs = [1:30]
nams = ["A", "B", "C", "D"]
valsDf = DataFrame(vals, nams)
## datsDa = DataArray(dats)

allTypes = (:Timedata, :Timenum, :Timematr, :Timecop)
allTypes = (:Timematr, :Timematr)

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
    end)
end

######################################
## throwing errors for wrong inputs ##
######################################

## idx initialized with wrong type
vals = DataFrame([2, 3, 4])
invalidIdx = DataArray([1, 2, 3])
for t in allTypes
    eval(quote
        @test_throws $(t)(vals, idx)        
    end)
end

## idx and vals sizes not matching
idx = [date(2013, 7, ii) for ii=1:30]
valsArr = rand(20, 4)
for t in allTypes
    eval(quote
        @test_throws $(t)(valsArr, idx)
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
