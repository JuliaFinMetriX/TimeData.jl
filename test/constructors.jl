module TestConstructors

using Base.Test
using DataArrays
using DataFrames
using Datetime
## using TimeData

## define macro for expressions that return nothing 
macro returnsNothing(ex)
    :(isa($ex, Nothing))
end

###########################
## shortcuts without NAs ##
###########################

## from numerical matrix only
vals = rand(30, 4)
td = TimeData.Timedata(vals)
td = TimeData.Timenum(vals)
td = TimeData.Timematr(vals)

## from arrays without names
dats = [date(2013, 7, ii) for ii=1:30]
td = TimeData.Timedata(vals, dats)
td = TimeData.Timenum(vals, dats)
td = TimeData.Timematr(vals, dats)

## from arrays without dates
nams = ["A", "B", "C", "D"]
td = TimeData.Timedata(vals, nams)
td = TimeData.Timenum(vals, nams)
td = TimeData.Timematr(vals, nams)

## from arrays with names
td = TimeData.Timedata(vals, nams, dats)
td = TimeData.Timenum(vals, nams, dats)
td = TimeData.Timematr(vals, nams, dats)

###################
## NAs in values ##
###################

## from DataFrame without names
valsDf = DataFrame(vals, nams)
td = TimeData.Timedata(valsDf)
td = TimeData.Timenum(valsDf)
td = TimeData.Timematr(valsDf)

##################
## NAs in dates ##
##################

## from DataArray dates without names
datsDa = DataArray(dats)
td = TimeData.Timedata(vals, datsDa)
td = TimeData.Timenum(vals, datsDa)
td = TimeData.Timematr(vals, datsDa)

end
