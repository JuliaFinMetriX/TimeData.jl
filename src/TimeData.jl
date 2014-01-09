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
str,
TimeDf,
TimeNum

abstract AbstractTimeData

include("constraints.jl")
include("timenum.jl")
include("timedf.jl")
include("operators.jl")

end
