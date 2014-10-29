module TestTimematr

using Base.Test
using DataArrays
using DataFrames
using Dates

using TimeData

println("Running timematr tests")

#######################################
## reconstruction from core elements ##
#######################################

## create instance
vals = rand(30, 4)
dats = Date[Date(2013, 7, ii) for ii=1:30]
nams = [:A, :B, :C, :D]
df = composeDataFrame(vals, nams)

tm = TimeData.Timematr(df, dats)
tm = TimeData.Timematr(vals, nams, [31:60])
tm = TimeData.Timematr(vals, nams, dats)



## reconstructing Timematr instance from core elements
tm = TimeData.Timematr(vals, nams, dats)
vals2 = TimeData.core(tm)
nams2 = TimeData.names(tm)
dats2 = TimeData.idx(tm)
tm2 = TimeData.Timematr(vals2, nams2, dats2)
@test TimeData.isequal(tm, tm2)

## core function should not return Array{Real, 2}
vals1 = [4000, 4001, 4002]
vals2 = [1., 2., 3.]
df = DataFrame(a = vals1, b = vals2)
tm = TimeData.Timematr(df)
@test isa(TimeData.core(tm), Array{Float64})

end
