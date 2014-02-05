## list packages that shall be automatically loaded
using DataFrames
## using Datetime

module TimeData

## list packages whos namespace is used
using DataArrays
using DataFrames
using Datetime
## using Winston

importall Base
## importall Stats

export #
AbstractTimedata,
AbstractTimenum,
AbstractTimematr,
core,
idx,
movAvg,
readTimedata,
rowmeans,
rowsums,
str,
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

end
