module TestAbstractFuncs

using Base.Test
using DataArrays
using DataFrames
using Datetime
## using TimeData

## define macro for expressions that return nothing 
macro returnsNothing(ex)
    :(isa($ex, Nothing))
end

## create instance
dats = [date(2013, 7, ii) for ii=1:30]
vals = rand(30, 4)
tn = TimeData.Timematr(vals, dats)

## test dates
@test isequal(TimeData.dates(tn), DataArray(dats))
TimeData.colnames(tn)


end
