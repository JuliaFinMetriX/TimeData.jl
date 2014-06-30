## list packages that shall be automatically loaded
using DataFrames
using Datetime

module TimeData

## list packages whos namespace is used
using DataArrays
using DataFrames
using Datetime
using Winston
using Gadfly

importall Base
## importall Stats

export #
@bootstrap,
@roundDf,
@table,
AbstractTimedata,
AbstractTimenum,
AbstractTimematr,
aggrRets,
composeDataFrame,
cor,
core,
cov,
cumprod,
cumsum,
geomMean,
HTML,
idx,
mean,
minimum,
movAvg,
plot,
prod,
readTimedata,
resample,
round,
rowmeans,
rowprods,
rowstds,
rowsums,
std,
str,
sum,
Timecop,
Timedata,
Timematr,
Timenum,
writeTimedata

include("constraints.jl")
include("abstractTypes.jl")
include("timecop.jl")
include("timedata_type.jl")
include("timenum.jl")
include("timematr.jl")
include("timematr_operators.jl")
include("constructors.jl")
include("getindex.jl")
## include("operators.jl")
include("abstractFuncs.jl")
include("io.jl")
include("plotting.jl")
include("econometrics.jl")
include("dataframe_extensions.jl")
include("ijulia_utilities.jl")

end
