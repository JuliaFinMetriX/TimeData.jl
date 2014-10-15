module TestUtilFuncs

using Base.Test
using TimeData

println("Running utility function tests")

####################
## rmDatesOnlyNAs ##
####################

## get input
tn = TimeData.testcase(TimeData.Timenum, 5)

## get expected outcome
dats = [Date(2010, 1, 1),
        Date(2010, 1, 2),
        Date(2010, 1, 4),
        Date(2010, 1, 5)]
df = DataFrame()
df[:prices1] = @data([100, 120, 170, 200])
df[:prices2] = @data([110, 120, 130, 150])
expOut = TimeData.Timenum(df, dats)

## test actual outcome
actOut = TimeData.rmDatesOnlyNAs(tn)
@test isequal(actOut, expOut)

## get input
dats = [Date(2010, 1, 1),
        Date(2010, 1, 2)]
df = DataFrame()
df[:prices1] = @data([100, NA])
df[:prices2] = @data([110, NA])
inputTn = TimeData.Timenum(df, dats)

## get expected outcome
dats = [Date(2010, 1, 1)]
df = DataFrame()
df[:prices1] = @data([100])
df[:prices2] = @data([110])
expOut = TimeData.Timenum(df, dats)

## test actual outcome
actOut = TimeData.rmDatesOnlyNAs(inputTn)
@test isequal(actOut, expOut)

## get input
tn = TimeData.testcase(TimeData.Timenum, 1)

## get expected outcome
expOut = TimeData.testcase(TimeData.Timenum, 1)

## test actual outcome
actOut = TimeData.rmDatesOnlyNAs(tn)
@test isequal(actOut, expOut)


end
