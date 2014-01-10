module TestConstraints

using Base.Test
using DataArrays
using DataFrames
using Datetime
## using TimeData

## define macro for expressions that return nothing 
macro returnsNothing(ex)
    :(isa($ex, Nothing))
end

##############
## chkDates ##
##############

## test valid dates
validDates = DataArray(today())
@test @returnsNothing TimeData.chkDates(validDates)

## test invalid dates
invalidDates = [1 2 3]
@test_throws TimeData.chkDates(invalidDates)

## dates must be array!
invalidDates = today()
@test_throws TimeData.chkDates(invalidDates)

#########################
## chkNum and chkNumDf ##
#########################

## numeric DataFrame with NAs
naDf = DataFrame(quote
    a = [1, 2, 3]
    b = [4, 5, 6]
    end)
naDf[1, 2] = NA
naDf[3, 1] = NA
@test @returnsNothing TimeData.chkNumDf(naDf)
@test_throws TimeData.chkNum(naDf)

numDf = DataFrame(quote
    a = [1, 2, 3]
    b = [4, 5, 6]
    end)
@test @returnsNothing TimeData.chkNumDf(numDf)
@test @returnsNothing TimeData.chkNum(numDf)

## invalid DataFrame with strings
invalidDf = DataFrame(quote
    a = [1, 2, 3]
    b = ["hello", "world", "hello"]
    end)
@test_throws TimeData.chkNumDf(invalidDf)
@test_throws TimeData.chkNum(invalidDf)

end
