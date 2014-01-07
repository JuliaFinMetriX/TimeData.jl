## using DataFrames
## using Datetime

module TimeData

using DataFrames
using DataArrays
using Datetime

export #
str,
TimeNum

include("constraints.jl")
include("timenum.jl")

end
