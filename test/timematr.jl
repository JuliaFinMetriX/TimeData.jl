## using Base.Test

#######################################
## reconstruction from core elements ##
#######################################

## reconstructing Timematr instance from core elements
tm = TimeData.Timematr(vals, nams, dats)
vals2 = TimeData.core(tm)
nams2 = TimeData.names(tm)
dats2 = TimeData.dates(tm)
tm2 = TimeData.Timenum(vals2, nams2, dats2)
@test TimeData.isequal(tm, tm2)


## core function should not return Array{Real, 2}
vals1 = [4000, 4001, 4002]
vals2 = [1., 2., 3.]
df = DataFrame(a = vals1, b = vals2)
tm = TimeData.Timematr(df)
@test isa(TimeData.core(tm), Array{Float64})
