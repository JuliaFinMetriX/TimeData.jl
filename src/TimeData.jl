## list packages that shall be automatically loaded
using DataFrames
## using Datetime

module TimeData

## list packages whos namespace is used
using DataFrames
using DataArrays
using Datetime
## using TimeSeries

importall Base
## importall Stats

export #
AbstractTimedata,
AbstractTimenum,
str,
Timedata,
Timematr,
Timenum

include("constraints.jl")
include("timedata.jl")
include("timenum.jl")
include("timematr.jl")
include("constructors.jl")
include("getindex.jl")
include("operators.jl")
include("abstractFuncs.jl")
include("io.jl")
include("financial.jl")

end
