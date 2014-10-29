module TestSetindex

using Base.Test
using DataArrays
using DataFrames
using Dates

using TimeData

println("Running setindex function tests")



############
## setNA! ##
############

## set up Timenum with NAs
df = DataFrame()
df[:a] = @data([4, 5, 6, NA, 8])
df[:b] = @data([3, 8, NA, NA, 2])
dats = [Date(2014,1,1):Date(2014,1,5)]
tn = Timenum(df, dats)

setNA!(tn, 1, 2)
get(tn, 1, 2) == NA

tm = Timematr(rand(2, 2))
@test_throws ErrorException setNA!(tm, 1, 2)

###############
## setindex! ##
###############

##############
## Timematr ##
##############

dats = [Date(2010, 1, 1):Date(2010, 1, 3)]
tm = TimeData.Timematr(rand(3, 4), dats)
setindex!(tm, 10, 1, 1)
tm[1, 2] = 20

## should fail
@test_throws ErrorException setindex!(tm, "hello", 1, 1)
@test_throws ErrorException setindex!(tm, NA, 1, 1)
@test_throws ErrorException tm[1, 1] = "hello"
@test_throws ErrorException tm[1, 1] = NA

#############
## Timenum ##
#############

dats = [Date(2010, 1, 1):Date(2010, 1, 3)]
tm = TimeData.Timenum(rand(3, 4), dats)
setindex!(tm, 10, 1, 1)
tm[1, 2] = 20
setindex!(tm, NA, 1, 3)

@test isequal(get(tm, 1, 1), 10)
@test isequal(get(tm, 1, 2), 20)
@test isequal(get(tm, 1, 3), NA)

## should fail
@test_throws ErrorException setindex!(tm, "hello", 1, 1)
@test_throws ErrorException tm[1, 1] = "hello"

##############
## Timedata ##
##############

da1 = @data([100, 120, NA])
da2 = @data(["blue", "green", "yellow"])
df = DataFrame()
df[:value] = da1
df[:color] = da2

td = TimeData.Timedata(df, dats)
td[1, 1] = 200
td[1, 2] = "red"
td[2, 1] = NA
td[2, 2] = NA
td[3, 1] = bool(1)

da1 = @data([200, NA, 1])
da2 = @data(["red", NA, "yellow"])
df = DataFrame()
df[:value] = da1
df[:color] = da2

expTd = TimeData.Timedata(df, dats)
@test isequal(expTd, td)
    
## should fail
@test_throws MethodError td[1, 1] = "hello"
@test_throws MethodError td[1, 2] = 120
@test_throws MethodError td[3, 2] = true


##################
## test impute! ##
##################

## imputing with zeros: 1.
##------------------------

td = TimeData.testcase(TimeData.Timenum, 2)
impute!(td, "zero")

## manually get expected value
dats = td.idx
df = DataFrame(prices1 = [0, 120, 140, 170, 200],
               prices2 = [110, 120, 0, 130, 0])
expTd = TimeData.Timenum(df, dats)

## test
@test isequal(expTd, td)

## imputing with zeros: 2.
##------------------------

## zero in string column
td = TimeData.testcase(TimeData.Timedata, 3)
@test_throws MethodError impute!(td, "zero")

## imputing last: 1.
##------------------

td = TimeData.testcase(TimeData.Timenum, 2)
impute!(td, "last")

## manually get expected value
dats = td.idx
df = DataFrame(prices1 = @data([NA, 120, 140, 170, 200]),
               prices2 = [110, 120, 120, 130, 130])
expTd = TimeData.Timenum(df, dats)

## test
@test isequal(expTd, td)


## imputing with next: 1.
##-----------------------

td = TimeData.testcase(TimeData.Timenum, 2)
impute!(td, "next")

## manually get expected value
dats = td.idx
df = DataFrame(prices1 = [120, 120, 140, 170, 200],
               prices2 = @data([110, 120, 130, 130, NA]))
expTd = TimeData.Timenum(df, dats)

## test
@test isequal(expTd, td)

## imputing with single last:
##---------------------------

da1 = @data([NA; 3; 4; NA; NA; 4; 5; NA])
da2 = @data([3; 4; NA; 8;  9;  5; NA; NA])
df = DataFrame(prices1 = da1, prices2 = da2)

dats = [Date(2010,1,1):Date(2010,1,8)]
td = Timedata(df, dats)

impute!(td, "single last")

## manually get expected value
dats = td.idx
df = DataFrame(prices1 = @data([NA, 3, 4, NA, NA, 4, 5, 5]),
               prices2 = @data([3, 4, 4, 8, 9, 5, NA, NA]))
expTd = TimeData.Timedata(df, dats)

## test
@test isequal(expTd, td)

end
