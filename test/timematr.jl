## using Base.Test

#######################################
## reconstruction from core elements ##
#######################################

## reconstructing Timematr instance from core elements
tm = TimeData.Timematr(vals, nams, dats)
vals2 = TimeData.core(tm)
nams2 = TimeData.colnames(tm)
dats2 = TimeData.dates(tm)
tm2 = TimeData.Timenum(vals2, nams2, dats2)
@test TimeData.isequal(tm, tm2)

