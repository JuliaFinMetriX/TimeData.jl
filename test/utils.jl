module TestUtilFuncs

using Base.Test
using TimeData
using Dates

println("Running utility function tests")

#############
## narowrm ##
#############

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
actOut = TimeData.narowrm(tn)
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
actOut = TimeData.narowrm(inputTn)
@test isequal(actOut, expOut)

## get input
tn = TimeData.testcase(TimeData.Timenum, 1)

## get expected outcome
expOut = TimeData.testcase(TimeData.Timenum, 1)

## test actual outcome
actOut = TimeData.narowrm(tn)
@test isequal(actOut, expOut)

#############
## anyToDa ##
#############

## findstub_vector
##----------------

@test TimeData.findstub_vector(Any[NA, NA, 3.4, 2]) == 3.4
@test TimeData.findstub_vector(Any[3.4, NA, 2]) == 3.4

## anyToDa
##--------

xx = Any[3, 4.2, NA]
@test isequal(@data([3, 4.2, NA]), TimeData.anyToDa(xx))

xx = Any[3, "hello", NA]
@test isequal(@data([3, "hello", NA]), TimeData.anyToDa(xx))

## anyToDf
##--------

xx = Any[3 4; NA 2.4]
expOut = DataFrame(a = @data([3, NA]), b = [4, 2.4])
@test isequal(expOut, TimeData.anyToDf(xx, [:a, :b]))

## wrong number of column names
@test_throws Exception TimeData.anyToDf(xx, [:a, :b, :c])

end
