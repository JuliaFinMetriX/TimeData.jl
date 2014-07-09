module TestOperators

using Base.Test
using DataArrays
using DataFrames
using Datetime
using TimeData

println("\n Running operator tests\n")

## init test values
vals = rand(30, 4)
dats = Date{ISOCalendar}[date(2013, 7, ii) for ii=1:30]
nams = [:A, :B, :C, :D]
valsDf = composeDataFrame(vals, nams)

###############
## operators ##
###############

tm = TimeData.Timematr(vals, nams, dats)

## mathematical operators
-tm
+tm
tm .+ 2
tm/3
5*tm

## mathematical functions
sign(tm)
sign(-tm)
abs(tm)
exp(tm)
log(tm)

## comparison operators
tm .> 0.5
tm .== 0.3
tm .!= 0.3

kk = (tm .> 0.5) | (tm .> 0.7)
kk2 = tm .> 0.5
@test isequal(kk, kk2)

tm1 = exp(tm)
tm2 = log(tm1)
@test_approx_eq(TimeData.core(tm[4, 3]), TimeData.core(tm2[4, 3]))
@test_approx_eq(TimeData.core(tm[1, 2]), TimeData.core(tm2[1, 2]))

## rounding functions
round(tm)
round(tm, 2)
ceil(tm)
ceil(tm, 2)
floor(tm)
trunc(tm)

## arithmetics with scalar values
@test (tm .+ 1 == 1 .+ tm)

## careful: -0.0 != 0.0
@test ((-(tm .- 1.5)) == (1.5 .- tm))

@test (tm * 3 == 3 * tm)

end
