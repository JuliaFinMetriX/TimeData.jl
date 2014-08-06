module TestIoFuncs

using Base.Test
using DataArrays
using DataFrames
using Datetime
using TimeData

println("\n Running IO function tests\n")

dirPath = Pkg.dir("TimeData")
filePath = joinpath(dirPath, "data", "logRet.csv")
td = readTimedata(filePath)

end
