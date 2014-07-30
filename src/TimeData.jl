## list packages that shall be automatically loaded
using DataFrames
using Datetime

module TimeData

## list packages whos namespace is used
using DataArrays
using DataFrames
using Datetime
## using Winston
## using Gadfly

importall Base
## importall Stats

export #
@roundDf,
@table,
AbstractTimedata,
AbstractTimenum,
AbstractTimematr,
aggrRets,
complete_cases,
composeDataFrame,
cor,
core,
cov,
cumprod,
cumsum,
eachcol,
eachrow,
geomMean,
get,
hcat,
HTML,
idx,
joinSortedIdx_inner,
joinSortedIdx_left,
joinSortedIdx_outer,
joinSortedIdx_right,
mean,
minimum,
movAvg,
narm,
plot,
prod,
readTimedata,
resample,
round,
rowmeans,
rowprods,
rowstds,
rowsums,
setDfRow!,
setNA!,
std,
str,
sum,
Timecop,
Timedata,
Timematr,
Timenum,
vcat,
writedlm,
writeTimedata

include("constraints.jl")
include("abstractTypes.jl")
include("timecop.jl")
include("timedata_type.jl")
include("timenum.jl")
include("timematr.jl")
include("constructors.jl")
include("getindex.jl")
include("display.jl")
include("abstractFuncs.jl")
include("operators.jl")
include("stats_AbstractTimematr.jl")
include("io.jl")
include("join.jl")
## include("plotting.jl")
include("dataframe_extensions.jl")
include("iterators.jl")
include("convert.jl")

end
