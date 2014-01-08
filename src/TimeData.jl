## using DataFrames
## using Datetime

module TimeData

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
