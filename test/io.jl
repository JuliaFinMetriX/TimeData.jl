module TestIoFuncs

using Base.Test
using DataArrays
using DataFrames
using Dates

using TimeData

println("Running IO function tests")

dirPath = Pkg.dir("TimeData")
filePath = joinpath(dirPath, "data", "logRet.csv")
td = readTimedata(filePath)

end
