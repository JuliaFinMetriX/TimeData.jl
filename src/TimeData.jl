## list packages that shall be automatically loaded
using DataFrames
## using Datetime

module TimeData

## list packages whos namespace is used
using DataFrames
using DataArrays
using Datetime
using TimeSeries

importall Base
importall Stats

export #
AbstractTimeData,
str,
Timedata,
Timematr,
Timenum

include("constraints.jl")
include("timedata.jl")
include("timenum.jl")
include("timematr.jl")
## include("timedf.jl")
include("operators.jl")
include("abstractFuncs.jl")

end
