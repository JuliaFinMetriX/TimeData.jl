module TestJoin

using Base.Test
using TimeData
using DataArrays
using Datetime
using DataFrames

println("\n Running join tests\n")

##########################
## find dates functions ##
##########################


idx1 = [5, 6, 8, 9, 10]
idx2 = [2, 3, 4, 5, 6, 7, 9]

## with numeric indices
equalIds = TimeData.findAllOccurringDates(idx1, idx2)
ids = TimeData.getIndices(equalIds, idx1, idx2)
@test ids == sort(unique([idx1, idx2]))

## with date indices
dats1 = [date(2000,1, ii) for ii=idx1]
dats2 = [date(2000,1, ii) for ii=idx2]
equalIds = TimeData.findAllOccurringDates(idx1, idx2)
ids = TimeData.getIndices(equalIds, dats1, dats2)
@test ids == sort(unique([dats1, dats2]))

## left join with numeric indices
equalIds = TimeData.findDatesOfLeftInRight(idx1, idx2)

vals = TimeData.getIndices(equalIds, idx2) |>
ids -> DataFrame(x = ids) |>
complete_cases! |>
array 
@test vals[:] == sort(unique(intersect(idx1, idx2)))

## left join with dates
equalIds = TimeData.findDatesOfLeftInRight(dats1, dats2)

vals = TimeData.getIndices(equalIds, dats2) |>
inds -> DataFrame(x = inds) |>
complete_cases! |>
array
@test vals[:] == sort(unique(intersect(dats1, dats2)))

## inner join with numeric indices
equalIds = TimeData.findCommonDates(idx1, idx2)
vals = TimeData.getIndices(equalIds, idx1, idx2) 
@test vals == sort(unique(intersect(idx1, idx2)))

## join for numeric index
tm1 = Timematr(rand(length(idx1), 2), idx1)
tm2 = Timematr(rand(length(idx2), 3), idx2)

joinSortedIdx_left(tm1, tm2)
joinSortedIdx_right(tm1, tm2)
joinSortedIdx_inner(tm1, tm2)
joinSortedIdx_outer(tm1, tm2)

## join for date index
tm1 = Timematr(rand(length(idx1), 2), dats1)
tm2 = Timematr(rand(length(idx2), 3), dats2)

joinSortedIdx_left(tm1, tm2)
joinSortedIdx_right(tm1, tm2)
joinSortedIdx_inner(tm1, tm2)
joinSortedIdx_outer(tm1, tm2)

end

