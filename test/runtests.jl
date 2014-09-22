module runtests


using DataFrames
using DataArrays

tests = ["abstractFuncs.jl",
         "preservingFuncs.jl",
         "constraints.jl",
         "constructors.jl",
         "convert.jl",
         "dataframe_extensions.jl",
         "doctests.jl",
         "getindex.jl",
         "setindex.jl",
         "showEntries.jl",
         "iterators.jl",
         "io.jl",
         "timematr.jl",
         "timenum.jl",
         "timedata.jl",
         "operators.jl"]


for t in tests
    include(string(Pkg.dir("TimeData"), "/test/", t))
end

end
