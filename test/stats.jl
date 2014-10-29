module TestStats

using Base.Test
using DataArrays
using DataFrames
using Dates

using TimeData

println("Running statistical function tests")

a = rand(5, 5)
tm = TimeData.Timematr(a)
tn = TimeData.Timenum(a)

#####################
## columnwise mean ##
#####################

expMean = mean(a, 1)
arrMean1 = array(mean(tm, 1))
arrMean2 = array(mean(tn, 1))

@test_approx_eq(expMean, arrMean1)
@test_approx_eq(expMean, arrMean2)

##################
## rowwise mean ##
##################

include("/home/chris/.julia/v0.3/TimeData/src/TimeData.jl")
expMean = mean(a, 2)
arrMean1 = TimeData.core(TimeData.rowmeans(tm))
arrMean2 = TimeData.core(TimeData.rowmeans(tn))

@test_approx_eq(expMean, arrMean1)
@test_approx_eq(expMean, arrMean2)

@test names(TimeData.rowmeans(tm)) == [:mean_values]

expProd = prod()

end
