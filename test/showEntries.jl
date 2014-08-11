module TestShowEntries

using Base.Test
using DataArrays
using DataFrames
using Dates
using TimeData

println("\n Running showEntries function tests\n")

######################
## test showEntries ##
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

@test isequal(expTd, showEntries(testcase1, x -> x.>130))
@test isequal(expTd, showEntries(testcase1, x -> x.>130;
                                 sort="dates")) 
@test_throws ErrorException showEntries(testcase1, x -> x.>130;
                                        sort="something") 

## expected results for second test case with variable ordering 
idxVals = Date[Date("2010-01-05"),
               Date("2010-01-03"),
               Date("2010-01-04"),
               Date("2010-01-05")]
variables = [:prices1, :prices2, :prices2, :prices2]
values = Any[150, 140, 170, 200]

df = DataFrame(variable = variables, value = values)
expTd2 = TimeData.Timedata(df, idxVals)
@test isequal(expTd2, showEntries(testcase2, x -> x.>130; sort="variables"))


####################################
## test showEntries with indexing ##
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
@test isequal(expTd, showEntries(testcase1, singleInd))

@test isequal(expTd,
              showEntries(testcase1,
                          ind2sub(size(testcase1),
                                  singleInd)...))

###########################
## test logical indexing ##
###########################

expTd = showEntries(testcase2, x -> x.> 130, sort="variables")
@test isequal(expTd, showEntries(testcase2, testcase2 .> 130)) 

expDf = DataFrame(variable = [:prices2], value = NA)
expTd = TimeData.Timedata(expDf, [Date(2010,1,3)])
@test TimeData.isequal(showEntries(testcase1, isna(testcase1)), expTd)


end
