## testing timenum
## using Base.Test

############################################
## test exception throwing in constructor ##
############################################

## no dates
vals = DataFrame([2, 3, 4])
dates = DataArray([1, 2, 3])
@test_throws TimeData.TimeNum(vals, dates)

## no matching sizes
dates = [date(2013, 7, 1),
         date(2013, 7, 2),
         date(2013, 7, 3)]
dates = DataArray(dates)
valsArr = ones(8, 4)
@test_throws TimeData.TimeNum(valsArr, dates)

#############################
## test outer constructors ##
#############################

dates = [date(2013, 7, 1),
         date(2013, 7, 2),
         date(2013, 7, 3)]
dates = DataArray(dates)         
TimeData.TimeNum(vals, dates)

TimeData.TimeNum(vals)

valsArr = ones(8, 4)
TimeData.TimeNum(valsArr)

dates = [date(2013, 7, 1),
         date(2013, 7, 2),
         date(2013, 7, 3)]
dates = DataArray(dates)
valsArr = ones(3, 4)
TimeData.TimeNum(valsArr, dates)

tmp = TimeData.TimeNum(3.0, "Z4", date(2013, 7, 1))

tmp = TimeData.TimeNum([1.0, 4, 3], "Z4", dates)
tmp = TimeData.TimeNum([1.0 4 3], ["Z1", "Z2", "W3"], dates[1])

dates = [date(2013, 7, 1),
         date(2013, 7, 2),
         date(2013, 7, 3)]
valsArr = ones(3, 4)
tmp = TimeData.TimeNum(valsArr, dates)

## test str
TimeData.str(tmp)

## test mean
TimeData.mean(tmp)
TimeData.mean(tmp, 1)

@test_throws TimeData.mean(tmp, 2)

TimeData.rowmeans(tmp)

vals = TimeData.core(tmp)
nams = TimeData.vars(tmp)
dats = TimeData.dates(tmp)
tmp2 = TimeData.TimeNum(vals, nams, dats)
tmp3 = TimeData.TimeNum(vals, dats, nams)

## test getindex methods
dates = [date(2013, 7, 1),
         date(2013, 7, 2),
         date(2013, 7, 3)]
valsArr = repmat([1. 2 3], 3, 1)
tmp = TimeData.TimeNum(valsArr, dates)

## multiple rows, multiple columns
tmp[2:3, 2:3]
tmp[1:2, ["x2", "x1"]]
tmp[1:2, 2:3]

## multiple rows, single columns
tmp[1:2, "x2"]

## single row, multiple columns
tmp[1, 2:3]
tmp[3, ["x2", "x1"]]

## single column, single row
tmp[3, 3]
tmp[2, :x2]
tmp[2, "x3"]

## single column
tmp["x2"]
tmp[2]
tmp[:x2]
tmp["x3"]
tmp[3]
tmp[:x3]

## multiple columns
tmp[1:3]
tmp[2:3]
tmp[["x2", "x1"]]



df = DataFrame(rand(10, 6))
df[["x2", "x1"]]
