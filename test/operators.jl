module TestOperators

using Base.Test
using DataArrays
using DataFrames
using Datetime
using TimeData

println("\n Running operator tests\n")

## init test values
vals = rand(30, 4)
dats = [date(2013, 7, ii) for ii=1:30]
nams = ["A", "B", "C", "D"]
valsDf = DataFrame(vals, nams)
datsDa = DataArray(dats)

###############
## operators ##
###############

function setupTestInstance()
    df = DataFrame(reshape([1.:20], (5, 4)))
    df[1, 1] = NA
    df[2, 2] = NA
    df[3, 4] = NA
    df[4, 4] = NA
    idx = [date(2013, 7, 1),
             date(2013, 7, 2),
             date(2013, 7, 3),
             date(2013, 7, 4),
             date(2013, 7, 5)]
    tn = TimeData.Timenum(df, DataArray(idx))
    return tn
end    

## operations on Timenum only
tn = setupTestInstance()
-tn
+tn
## !tn
TimeData.abs(tn)
sign(tn)
sign(-tn)

tn1 = exp(tn)
tn2 = log(tn1)
@test isequal(tn, tn2)

round(tn)
round(tn, 2)
ceil(tn)
ceil(tn, 2)
floor(tn)
trunc(tn)

tn5 = tn2 .> tn
tn .> 2

## arithmetics with scalar values
@test (tn + 1 == 1 + tn)

## careful: -0.0 != 0.0
@test ((-(tn - 1.5)) == (1.5 - tn))

@test (tn * 3 == 3 * tn)

tn / 2
1 / tn



## create Timenum test instance

tn2 = tn + 3
tn3 = tn

tn2 .> tn
tn2 .>= tn
tn2 .<= tn
tn2 .== tn
tn2 .!= tn
tn2 != tn
## @test_throws tn3 != tn
tn3 == tn

tn4 = tn2 .* tn
tn5 = tn4 ./ tn
tn5 .== tn2

tn2  = setupTestInstance()

tn2 = tn2+tn
end
