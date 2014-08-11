module TestSetindex

using Base.Test
using DataArrays
using DataFrames
using Dates
using TimeData

println("\n Running setindex function tests\n")



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


end
