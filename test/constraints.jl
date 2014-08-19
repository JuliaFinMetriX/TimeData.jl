module TestConstraints

using Base.Test
using DataArrays
using DataFrames
using Dates
using TimeData
## using TimeData

println("Running constraints tests")

############
## chkIdx ##
############

## test Dates
validIdx = Date[Date(2010,02,ii) for ii=1:10]
TimeData.chkIdx(validIdx)

## test times
validIdx = DateTime[DateTime(2010,02,ii,00,00,00)
                                 for ii=1:10]
TimeData.chkIdx(validIdx)

## test integers
validIdx = [1:10]                                 
TimeData.chkIdx(validIdx)

## test invalid idx
invalidIdx = [1. 2 3]
@test_throws TypeError TimeData.chkIdx(invalidIdx)


## idx must be array!
invalidIdx = today()
@test_throws TypeError TimeData.chkIdx(invalidIdx)

#########################
## chkNum and chkNumDf ##
#########################

## numeric DataFrame with NAs
naDf = DataFrame(a = [1, 2, 3], b = [4, 5, 6])
naDf[1, 2] = NA
naDf[3, 1] = NA
TimeData.chkNumDf(naDf)
@test_throws ArgumentError TimeData.chkNum(naDf)

numDf = DataFrame(a = [1, 2, 3], b = [4, 5, 6])
TimeData.chkNumDf(numDf)
TimeData.chkNum(numDf)

## invalid DataFrame with strings


invalidDf = DataFrame(a = [1, 2, 3], b = ["hello", "world", "hello"]) 
@test_throws ArgumentError TimeData.chkNumDf(invalidDf)
@test_throws ArgumentError TimeData.chkNum(invalidDf)

invalidDf = DataFrame(a = [true, false, true])
@test_throws ArgumentError TimeData.chkNumDf(invalidDf)

#############
## chkUnit ##
#############

validDf = convert(DataFrame, rand(8, 3))
TimeData.chkUnit(validDf)

invalidDf = convert(DataFrame, rand(8, 3))
invalidDf[2, 2] = -0.2
@test_throws ArgumentError TimeData.chkUnit(invalidDf)
end
