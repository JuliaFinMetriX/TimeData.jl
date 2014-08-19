module TestDfExtensions

using Base.Test
using DataArrays
using DataFrames
using Dates
using TimeData
## using TimeData

println("Running DataFrame extension tests")

######################
## composeDataFrame ##
######################

df = DataFrame()
df[:a] = @data([4, 5])
df[:b] = @data([3, 8])

vals = [4 3; 5 8]
df2 = TimeData.composeDataFrame(vals, [:a, :b])
@test isequal(df, df2)

#############################
## conversion to DataFrame ##
#############################

df = DataFrame()
df[:a] = @data([4, 5])
df[:b] = @data([3, 8])
dats = [Date(2014,1,1):Date(2014,1,2)]
tn = TimeData.Timenum(df, dats)

df2 = DataFrame()
df2[:idx] = dats
df2[:a] = @data([4, 5])
df2[:b] = @data([3, 8])

@test isequal(df2, TimeData.convert(DataFrame, tn))

###########
## round ##
###########

df = DataFrame()
df[:a] = @data([3.44444, 5., 2.88888, NA])
df[:b] = @data(["he", "ll", NA, "o"])

@test isequal(round(df), round(df, 2))

df2 = DataFrame()
df2[:a] = @data([3.44, 5., 2.89, NA])
df2[:b] = @data(["he", "ll", NA, "o"])

@test isequal(round(df, 2), df2)

###############
## setDfRow! ##
###############

df = DataFrame()
df[:a] = @data([4, 5])
df[:b] = @data([3, 8])

df2 = DataFrame()
df2[:a] = @data([4, 10])
df2[:b] = @data([3, 10])

@test isequal(TimeData.setDfRow!(df, Any[10 10], 2), df2)

df2 = DataFrame()
df2[:a] = @data([4, NA])
df2[:b] = @data([3, 10])

@test isequal(TimeData.setDfRow!(df, Any[NA 10], 2), df2)

@test_throws ErrorException TimeData.setDfRow!(df, [1 2 3], 2)

end
