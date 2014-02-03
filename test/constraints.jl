module TestConstraints

using Base.Test
using DataArrays
using DataFrames
using Datetime
using TimeData
## using TimeData

############
## chkIdx ##
############

## test dates
validIdx = [date(2010,02,ii) for ii=1:10]
TimeData.chkIdx(validIdx)

## test times
validIdx = DateTime{ISOCalendar,UTC}[datetime(2010,02,ii,00,00,00)
                                 for ii=1:10]
TimeData.chkIdx(validIdx)

## test integers
validIdx = [1:10]                                 
TimeData.chkIdx(validIdx)

## test invalid idx
invalidIdx = [1. 2 3]
@test_throws TimeData.chkIdx(invalidIdx)

## array of element type Any
invalidIdx = [datetime(2010,02,ii,00,00,00) for ii=1:10]
@test_throws TimeData.chkIdx(invalidIdx)

## idx must be array!
invalidIdx = today()
@test_throws TimeData.chkIdx(invalidIdx)

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

invalidDf = DataFrame(quote
    a = [true, false, true]
    end)
@test_throws TimeData.chkNumDf(invalidDf)    

#############
## chkUnit ##
#############

validDf = DataFrame(rand(8, 3))
TimeData.chkUnit(validDf)

invalidDf = DataFrame(rand(8, 3))
invalidDf[2, 2] = -0.2
@test_throws TimeData.chkUnit(invalidDf)
end
