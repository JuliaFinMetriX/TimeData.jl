module TestConstraints

using Base.Test
using DataArrays
using DataFrames
## using TimeData

## define macro for expressions that return nothing 
macro returnsNothing(ex)
    :(isa($ex, Nothing))
end

validDates = DataArray(today())
## @test isa(chkDates(validDates), Nothing)
@test @returnsNothing chkDates(validDates)

invalidDates = [1 2 3]
@test_throws chkDates(invalidDates)

## dates must be array!
invalidDates = today()
@test_throws chkDates(invalidDates)

validDf = DataFrame(quote
    a = [1, 2, 3]
    b = [4, 5, 6]
    end)
## @test isa(chkNumDf(validDf), Nothing)
@test @returnsNothing chkNumDf(validDf)

invalidDf = DataFrame(quote
    a = [1, 2, 3]
    b = ["hello", "world", "hello"]
    end)
@test_throws chkNumDf(invalidDates)

end
