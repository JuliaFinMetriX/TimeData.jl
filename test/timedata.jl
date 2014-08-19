module TestTimedata

using Base.Test
using DataArrays
using DataFrames
using Dates
using TimeData

println("Running Timedata tests")


##########
## find ##
##########

## with NAs present
##-----------------
td = TimeData.testcase(TimeData.Timenum, 2)
boolTd = td .> 130

## from boolean Timedata
@test isequal(find(boolTd), [3, 4, 5])
@test isequal(TimeData.find2sub(boolTd), ([3, 4, 5], [1, 1, 1]))

## using function
@test isequal(find(x -> x .> 130, td), [3, 4, 5])
@test isequal(TimeData.find2sub(x -> x .> 130, td), ([3, 4, 5], [1, 1, 1]))


## no true value
##--------------

td = TimeData.testcase(TimeData.Timenum, 2)
boolTd = td .> 230

## from boolean Timedata
@test isequal(find(boolTd), [])
@test isequal(TimeData.find2sub(boolTd), ([], []))

## using function
@test isequal(find(x -> x .> 230, td), [])
@test isequal(TimeData.find2sub(x -> x .> 230, td), ([], []))


## applied to non-boolean function
##--------------------------------

td = TimeData.testcase(TimeData.Timenum, 2)
@test_throws ErrorException find(x -> x .* 2, td)
@test_throws ErrorException TimeData.find2sub(x -> x .* 2, td)

## applied to numeric Timedata
td = TimeData.testcase(TimeData.Timedata, 2)
@test_throws MethodError find(td)

end
