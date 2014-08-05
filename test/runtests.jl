module runtests

using Datetime
using DataFrames
using DataArrays

tests = ["abstractFuncs.jl",
         "constraints.jl",
         "constructors.jl",
         "convert.jl",
         "dataframe_extensions.jl",
         "doctests.jl",
         "getindex.jl",
         "iterators.jl",
         "timematr.jl",
         "timenum.jl",
         "operators.jl"]


for t in tests
    include(string(Pkg.dir("TimeData"), "/test/", t))
end

end
