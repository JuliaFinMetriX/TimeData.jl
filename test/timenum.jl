#####################
## TESTING TIMENUM ##
#####################

## using Base.Test

############################################
## test exception throwing in constructor ##
############################################


#############################
## test outer constructors ##
#############################

## general idea:
## - major order: values, names, dates
## - comprehensive constructor built on arrays

## inner constructor: with true field types
vals = DataFrame([2., 3, 4])
dates = [date(2013, 7, 1),
         date(2013, 7, 2),
         date(2013, 7, 3)]
dates = DataArray(dates)         
tn = TimeData.TimeNum(vals, dates)

## from core elements
vals = TimeData.core(tn)
names = TimeData.colnames(tn)
dates = TimeData.dates(tn)
tn2 = TimeData.TimeNum(vals, names, dates)
@test isequal(tn, tn2)

## with numeric data only
vals = rand(4, 3)
TimeData.TimeNum(vals)

## values and dates
vals = [2., 3, 4]
dates = [date(2013, 7, 1),
         date(2013, 7, 2),
         date(2013, 7, 3)]
TimeData.TimeNum(vals, dates)

## values and names
vals = rand(4, 3)
nams = ["X", "Y", "Z"]
TimeData.TimeNum(vals, nams)

## clean dates, sloppy values without names
dates = [date(2013, 7, 1),
         date(2013, 7, 2),
         date(2013, 7, 3)]
dates = DataArray(dates)
vals = rand(3, 4)
TimeData.TimeNum(vals, dates)

## single variable -> expressed as array
dates = [date(2013, 7, 1),
         date(2013, 7, 2),
         date(2013, 7, 3)]
tmp = TimeData.TimeNum([1.0, 4, 3], ["Z4"], dates)

## single date -> expressed as array
dates = date(2013, 7, 1)
tmp = TimeData.TimeNum([1.0 4 3], ["Z1", "Z2", "W3"], [dates])


#####################
## other functions ##
#####################

## test str
TimeData.str(tmp)

tmp = setupTestInstance()
df = tmp.vals
for ii=1:size(df, 2)
    da = df[ii]
    da[isna(da)] = 0
    df[ii] = da
end
tmp = TimeData.TimeNum(df, TimeData.dates(tmp))

## test mean
TimeData.mean(tmp)
TimeData.mean(tmp, 1)

@test_throws TimeData.mean(tmp, 2)

TimeData.rowmeans(tmp)

vals = TimeData.core(tmp)
nams = TimeData.vars(tmp)
dats = TimeData.dates(tmp)
tmp2 = TimeData.TimeNum(vals, nams, dats)
@test_throws TimeData.TimeNum(vals, dats, nams)
@test isequal(tmp, tmp2)

##################
## test isequal ##
##################

dates = [date(2013, 7, 1),
         date(2013, 7, 2),
         date(2013, 7, 3)]
valsArr = repmat([1. 2 3], 3, 1)

tmp = TimeData.TimeNum(valsArr, dates)
tmp2 = TimeData.TimeNum(valsArr, dates)

@test TimeData.isequal(tmp, tmp2)

##################################
## getindex DataFrame behaviour ##
##################################

## test for changes in DataFrame behaviour
df = DataFrame(rand(8, 4))
@test isa(df[1:2], DataFrame)
@test isa(df[1:2, 3:4], DataFrame)
@test isa(df[1, 3:4], DataFrame)
@test isa(df[1], DataArray{Float64,1})        
@test isa(df[2:4, 1], DataArray{Float64,1})   
@test isa(df[2, 2], Float64)                  

## create TimeNum test instance 
df = DataFrame(reshape([1:20], (5, 4)))
df[1, 1] = NA
df[2, 2] = NA
df[3, 4] = NA
df[4, 4] = NA

dates = [date(2013, 7, ii) for ii=1:5]
         
tn = TimeData.TimeNum(df, DataArray(dates))

## multiple columns
tn[1:2]
tn[[4, 1]]

## multiple rows, multiple columns
tn[1:3, 2:4]

## single row, multiple columns
tn[3, 3:4]

## single column
tn[1]
tn[:x4]
tn["x4"]

## multiple rows, single column
tn[2:4, 4]
tn[2:4, :x4]
tn[2:4, "x4"]

## single row and single column index
tn[1, 3]
tn[1, 1]

######################
## logical indexing ##
######################

## create TimeNum test instance 
tn = setupTestInstance()

@test isequal(TimeData.ndims(tn), 2)
@test isequal(TimeData.size(tn), (5, 4))
@test isequal(TimeData.size(tn, 1), 5)
@test isequal(TimeData.size(tn, 2), 4)

## create bolean vector
bol = tn.vals[1] .> 3
tn[bol, :]
tn[bol, 1:2]
tn[:, [true, true, false, false]]
tn[1:2, [true, true, false, false]]
tn[bol, [true, true, false, false]]

#################
## expressions ##
#################

## create TimeNum test instance 
tn = setupTestInstance()

ex = :(x1 .> 2)
tn[ex, 1]
tn[ex, :]
tn[ex, [2, 3]]


###############
## operators ##
###############

function setupTestInstance()
    df = DataFrame(reshape([1.:20], (5, 4)))
    df[1, 1] = NA
    df[2, 2] = NA
    df[3, 4] = NA
    df[4, 4] = NA
    dates = [date(2013, 7, 1),
             date(2013, 7, 2),
             date(2013, 7, 3),
             date(2013, 7, 4),
             date(2013, 7, 5)]
    tn = TimeData.TimeNum(df, DataArray(dates))
    return tn
end    

## operations on TimeNum only
tn = setupTestInstance()
-tn
+tn
## !tn
TimeData.abs(tn)
sign(tn)
sign(-tn)

tn1 = exp(tn)
tn2 = log(tn1)
@test isequal(tn, tn2)

round(tn)
round(tn, 2)
ceil(tn)
ceil(tn, 2)
floor(tn)
trunc(tn)

tn5 = tn2 .> tn
tn .> 2

## arithmetics with scalar values
@test (tn + 1 == 1 + tn)

## careful: -0.0 != 0.0
@test ((-(tn - 1.5)) == (1.5 - tn))

@test (tn * 3 == 3 * tn)

tn / 2
1 / tn



## create TimeNum test instance

tn2 = tn + 3
tn3 = tn

tn2 .> tn
tn2 .>= tn
tn2 .<= tn
tn2 .== tn
tn2 .!= tn
tn2 != tn
## @test_throws tn3 != tn
tn3 == tn

tn4 = tn2 .* tn
tn5 = tn4 ./ tn
tn5 .== tn2

tn2  = setupTestInstance()

tn2 = tn2+tn
