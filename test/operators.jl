module TestOperators

using Base.Test
using DataArrays
using DataFrames
using Datetime
using TimeData

println("\n Running operator tests\n")

## init test values
vals = rand(30, 4)
dats = Date{ISOCalendar}[date(2013, 7, ii) for ii=1:30]
nams = [:A, :B, :C, :D]
valsDf = composeDataFrame(vals, nams)

###############
## operators ##
###############

macro test_basic_operators(t)
    esc(quote
        
        td = $(t)(vals, nams, dats)
        
        ## mathematical operators
        -td
        +td
        @test (td .+ td) == (2.*td)
        @test td == 3.*(td./3)
        
        sign(td)
        sign(-td)
        abs(td)
        exp(td)
        log(td)
        
        td .> 0.5
        td .== 0.3
        td .!= 0.3
        
        kk = (td .> 0.5) | (td .> 0.7)
        kk2 = td .> 0.5
        @test isequal(kk, kk2)
        
        td1 = exp(td)
        td2 = log(td1)
        @test_approx_eq get(td) get(td2)
        
        ## rounding functions
        round(td)
        round(td, 2)
        ceil(td)
        ceil(td, 2)
        floor(td)
        trunc(td)
        
        ## arithmetics with scalar values
        @test (td .+ 1 == 1 .+ td)
        
        ## careful: -0.0 != 0.0
        @test ((-(td .- 1.5)) == (1.5 .- td))
        
        @test (td .* 3 == 3 .* td)
        
    end)
end

for t = (:Timenum, :Timematr)
    eval(macroexpand(:(@test_basic_operators($t))))        
end

end
