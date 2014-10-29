module TestGetIndex

using Base.Test
using DataArrays
using DataFrames
using Dates

using TimeData

println("Running getindex tests:")

## test for changes in DataFrame behaviour
df = convert(DataFrame, rand(8, 4))
df2 = DataFrame(a = rand(8), b = rand(8))
@test isa(df[1:2], DataFrame)
@test isa(df[1:2, 3:4], DataFrame)
@test isa(df[1, 3:4], DataFrame)
@test isa(df[1], Array{Float64,1})
@test isa(df[2:4, 1], Array{Float64,1})   
@test isa(df2[1], DataArray{Float64,1})        
@test isa(df2[2:4, 1], DataArray{Float64,1})   
@test isa(df[2, 2], Float64)                  

## init test values
vals = rand(30, 4)
dats = Date[Date(2013, 7, ii) for ii=1:30]
nams = [:A, :B, :C, :D]

for t = (:Timedata, :Timenum, :Timematr)
    eval(quote

        println("   Running getindex for ", $t)        
        
        tn = $(t)(vals, nams, dats)
        
        ## multiple columns
        tmp = tn[2:4]
        @test isa(tmp, $(t))
        
        ## multiple rows, multiple columns
        tmp = tn[3:5, 1:2]
        @test isa(tmp, $(t))
        
        ## single row, multiple columns
        tmp = tn[5, :]
        @test isa(tmp, $(t))
        
        ## single column
        tmp = tn[2]
        @test isa(tmp, $(t))
        
        ## multiple rows, single column
        tmp = tn[5:8, 2]
        @test isa(tmp, $(t))
        
        ## single row, single column
        tmp = tn[5, 3]
        @test isa(tmp, $(t))
        
        ## multiple rows, single column
        tmp = tn[4:10, :A]
        @test isa(tmp, $(t))
        
        ## logical indexing
        logicCol = [true, false, true, false]
        tmp = tn[logicCol]
        @test isa(tmp, $(t))
        
        ## logical indexing
        logicRow = repmat([true, false, true], 10, 1)[:]
        tmp = tn[logicRow, logicCol]
        @test isa(tmp, $(t))
        
        ## logical indexing rows
        tmp = tn[logicRow, :]
        @test isa(tmp, $(t))

        ## logical indexing from expression
        ## ex = :(A .> 0.5)
        ## tmp = tn[ex, :]
        ## @test isa(tmp, $(t))
        
        ## indexing single row by Date
        tmp = tn[Date(2013, 07, 04)]
        @test isa(tmp, $(t))
        
        ## indexing rows by idx
        idxToFind = Date[Date(2013, 07, ii) for ii=12:18]
        tmp = tn[idxToFind]
        @test isa(tmp, $(t))
        
        ## indexing rows by idx, columns
        @test isa(tn[idxToFind, 2:3], $(t))
        @test isa(tn[idxToFind, :A], $(t))
        @test isa(tn[Date(2013,01,03):Date(2013,07,12)], $(t))
        @test isa(tn[Date(2013,01,03):Date(2013,07,12), :D], $(t))
        @test isa(tn[Date(2013,01,03):Date(2013,07,12), 2:3], $(t))
        @test isa(tn[Date(2013,01,03):Date(2013,07,12),
                     [true, false, false, true]], $(t))
        
        ## test empty instance
        @test isa(tn[Date(2013,01,03):Date(2013,07,12),
                     [false, false, false, false]], $(t))
    end)
end

end
