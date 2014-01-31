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
nams = ["A", "B", "C", "D"]
valsDf = DataFrame(vals, nams)
datsDa = DataArray(dats)

allTypes = (:Timedata, :Timenum, :Timematr, :Timecop)

########################
## inner constructors ##
########################

for t in allTypes
    eval(quote
        td = $t(valsDf, datsDa)
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

        ## from arrays without dates
        td = $(t)(vals, nams)

        ## from three arrays with names and dates
        td = $(t)(vals, nams, dats)
    end)
end

###################
## NAs in values ##
###################

for t in allTypes
    eval(quote
        ## from DataFrame without dates
        td = $(t)(valsDf)

        ## from DataFrame with dates as array
        td = $(t)(valsDf, dats)
    end)
end

##################
## NAs in dates ##
##################

for t in allTypes
    eval(quote
        ## from DataArray dates without names
        td = $(t)(vals, datsDa)

        ## from DataArray dates with names
        td = $(t)(vals, nams, datsDa)
    end)
end


######################################
## throwing errors for wrong inputs ##
######################################

## dates initialized with wrong type
vals = DataFrame([2, 3, 4])
invalidDates = DataArray([1, 2, 3])
for t in allTypes
    eval(quote
        @test_throws $(t)(vals, dates)        
    end)
end

## dates and vals sizes not matching
dates = [date(2013, 7, ii) for ii=1:30]
dates = DataArray(dates)
valsArr = rand(20, 4)
for t in allTypes
    eval(quote
        @test_throws $(t)(valsArr, dates)
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
