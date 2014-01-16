module TestConstructors

using Base.Test
using DataArrays
using DataFrames
using Datetime
using TimeData

## init test values
vals = rand(30, 4)
dats = [date(2013, 7, ii) for ii=1:30]
nams = ["A", "B", "C", "D"]
valsDf = DataFrame(vals, nams)
datsDa = DataArray(dats)

#######################################
## shortcuts from arrays without NAs ##
#######################################

## from numeric array only
td = TimeData.Timedata(vals)
td = TimeData.Timenum(vals)
td = TimeData.Timematr(vals)

## from arrays without names
td = TimeData.Timedata(vals, dats)
td = TimeData.Timenum(vals, dats)
td = TimeData.Timematr(vals, dats)

## from arrays without dates
td = TimeData.Timedata(vals, nams)
td = TimeData.Timenum(vals, nams)
td = TimeData.Timematr(vals, nams)

## from three arrays with names and dates
td = TimeData.Timedata(vals, nams, dats)
td = TimeData.Timenum(vals, nams, dats)
td = TimeData.Timematr(vals, nams, dats)

###################
## NAs in values ##
###################

## from DataFrame without dates
td = TimeData.Timedata(valsDf)
td = TimeData.Timenum(valsDf)
td = TimeData.Timematr(valsDf)

## from DataFrame with dates as array
td = TimeData.Timedata(valsDf, dats)
td = TimeData.Timenum(valsDf, dats)
td = TimeData.Timematr(valsDf, dats)


##################
## NAs in dates ##
##################

## from DataArray dates without names
td = TimeData.Timedata(vals, datsDa)
td = TimeData.Timenum(vals, datsDa)
td = TimeData.Timematr(vals, datsDa)

######################################
## throwing errors for wrong inputs ##
######################################

## dates initialized with wrong type
vals = DataFrame([2, 3, 4])
invalidDates = DataArray([1, 2, 3])
@test_throws TimeData.Timedata(vals, dates)
@test_throws TimeData.Timenum(vals, dates)
@test_throws TimeData.Timematr(vals, dates)

## dates and vals sizes not matching
dates = [date(2013, 7, ii) for ii=1:30]
dates = DataArray(dates)
valsArr = rand(20, 4)
@test_throws TimeData.Timedata(valsArr, dates)
@test_throws TimeData.Timenum(valsArr, dates)
@test_throws TimeData.Timematr(valsArr, dates)

end
