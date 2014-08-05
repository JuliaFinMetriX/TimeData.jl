module runtests

using Datetime
using DataFrames
using DataArrays

tests = ["abstractFuncs.jl",
         "constraints.jl",
         "constructors.jl",
         "convert.jl",
         "doctests.jl",
         "getindex.jl",
         "timematr.jl",
         "timenum.jl",
         "operators.jl"]


for t in tests
    include(string(Pkg.dir("TimeData"), "/test/", t))
end

end
