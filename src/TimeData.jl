## list packages that shall be automatically loaded
using DataFrames
## using Datetime

module TimeData

## list packages whos namespace is used
using DataFrames
using DataArrays
using Datetime

importall Base
importall Stats

export #
str,
TimeNum

include("constraints.jl")
include("timenum.jl")
include("operators.jl")

end
