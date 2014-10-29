module TestOperators

using Base.Test
using DataArrays
using DataFrames
using Dates

using TimeData

println("Running operator tests")

## init test values
vals = [1 1 1 1;
        2 2 2 2;
        3 3 3 3;
        4 4 4 4]
dats = Date[Date(2013, 7, ii) for ii=1:4]
nams = [:A, :B, :C, :D]
valsDf = TimeData.composeDataFrame(vals, nams)

###############
## operators ##
###############

## almost all tests for Timematr should also work for Timenum without
## missing observations

## separate testing
## - matrix-mult
## - comparisons for Timedata objects
macro test_basic_operators(myType)
    esc(quote
        
        td = $(myType)(vals, nams, dats)
        
        ## mathematical operators
        td[2:end, :] .- td[1:(end-1), :]
        
        @test isequal(td .+ td, 2.*td)
        @test isequal(td, 3.*(td./3))
        @test isequal(get((3./td).*td, 1, 1), 3)

        ## arithmetics with scalar values
        @test isequal(td .+ 1,  1 .+ td)
        
        @test isequal((td .- 1.5).*(-1), 1.5 .- td)
        @test isequal(td .* 3, 3 .* td)

        ## unary operators / mathematical functions
        pres_msUnitary_functions = [:abs, :sign,
                                    :exp, :log, :sqrt, :gamma,
                                    :(+), :(-)
                                    ]
        for f in pres_msUnitary_functions
            eval(:($(f)(td)))
        end

        ## comparisons
        td .> td
        td .< td
        td .<= td
        td .>= td
        td .== td
        td .!= td

        td .< 0.5
        td .== 0.3
        td .!= 0.3
        
        kk = (td .> 0.5) | (td .> 0.7)
        kk2 = td .> 0.5
        @test isequal(kk, kk2)
        
        td1 = exp(td)
        td2 = log(td1)
        @test_approx_eq convert(Array{Float64, 1}, get(td)[:]) convert(Array{Float64, 1}, get(td2)[:])
        
        ## rounding functions
        roundFunc = [:round, :ceil, :floor, :trunc]
        for f in roundFunc
            eval(:($(f)(td)))
            eval(:($(f)(td, 2)))
        end
    end)
end

for t = (:Timenum, :Timematr)
    eval(macroexpand(:(@test_basic_operators($t))))        
end

############
## test ! ##
############

df = DataFrame(a = @data([NA, true, false]),
               b = @data([true, NA, false]))
dfNegated = DataFrame(a = @data([NA, false, true]),
               b = @data([false, NA, true]))

td = Timedata(df)
@test isequal(!td, Timedata(dfNegated))

end
