module TestShowEntries

using Base.Test
using DataArrays
using DataFrames
using Dates

using TimeData

println("Running getEntries function tests")


######################
## test getEntries ##
######################

## create test case
df1 = DataFrame()
df2 = DataFrame()
df1[:prices1] = @data([100, 120, 140, 170, 200])
df1[:prices2] = @data([110, 120, NA, 130, 150])
df2[:prices1] = @data([110, 120, NA, 130, 150])
df2[:prices2] = @data([100, 120, 140, 170, 200])
dats = [Date(2010, 1, 1):Date(2010, 1, 5)]
testcase1 = TimeData.Timenum(df1, dats)
testcase2 = TimeData.Timenum(df2, dats)

## expected results for dates ordering
idxVals = Date[Date("2010-01-03"),
               Date("2010-01-04"),
               Date("2010-01-05"),
               Date("2010-01-05")]
variables = [:prices1, :prices1, :prices1, :prices2]
values = Any[140, 170, 200, 150]

df = DataFrame(variable = variables, value = values)
expTd = TimeData.Timedata(df, idxVals)

## entries large than 130
actOut = TimeData.chkElw(x -> x.>130,
                     TimeData.eachentry(testcase1)) |>
     x -> TimeData.asArr(x, Bool, false) |>
     x -> TimeData.getEntries(testcase1, x)

@test isequal(expTd, actOut)

## expected results for second test case with variable ordering 
idxVals = Date[Date("2010-01-05"),
               Date("2010-01-03"),
               Date("2010-01-04"),
               Date("2010-01-05")]
variables = [:prices1, :prices2, :prices2, :prices2]
values = Any[150, 140, 170, 200]

df = DataFrame(variable = variables, value = values)
expTd2 = TimeData.Timedata(df, idxVals)

actOut = TimeData.chkElw(x -> x.>130,
                         TimeData.eachentry(testcase2)) |>
         x -> TimeData.asArr(x, Bool, false) |>
         x -> TimeData.getEntries(testcase2, x, false)

@test isequal(expTd2, actOut)

####################################
## test getEntries with indexing ##
####################################

idxVals = Date[Date("2010-01-01"),
               Date("2010-01-05"),
               Date("2010-01-01"),
               Date("2010-01-03")]
variables = [:prices1, :prices1, :prices2, :prices2]
values = Any[100, 200, 110, NA]

df = DataFrame(variable = variables, value = values)
expTd = TimeData.Timedata(df, idxVals)

singleInd = [1, 5, 6, 8]
@test isequal(expTd, TimeData.getEntries(testcase1, singleInd))

@test isequal(expTd,
              TimeData.getEntries(testcase1,
                          ind2sub(size(testcase1),
                                  singleInd)...))

end
