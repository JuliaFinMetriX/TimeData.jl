#################################
## definition of TimeData type ##
#################################

## constraints:
## - DataArray, where individual entries are subtype of Date
## - dates and vals must have same number of observations
## - values must be numeric

type TimeNum <: AbstractTimeData
    vals::DataFrame
    dates::DataArray

    function TimeNum(vals::DataFrame, dates::DataArray)
        chkDates(dates)
        chkNumDf(vals)
        if(size(vals, 1) != length(dates))
            error("number of dates must equal number of columns of data")
        end
        return new(vals, dates)
    end
end

################################
## TimeNum outer contructors ##
################################

## no names or dates (just simulated values)
function TimeNum(vals::Array{Float64, 2})
    dates = DataArray(Date, size(vals, 1))
    TimeNum(DataFrame(vals), dates)
end

## from core elements
function TimeNum(vals::Array{Float64, 2},
                 names::Array{Union(UTF8String,ASCIIString),1},
                 dates::DataArray{Date{ISOCalendar}, 1})
    df = DataFrame(vals, names)
    return TimeNum(df, dates)
end

## comprehensive constructor: very general, all elements
function TimeNum{T<:Array, K<:Array, S<:Array}(vals::T, names::K, dates::S) 
    df = DataFrame(vals)
    colnames!(df, names)
    return TimeNum(df, DataArray(dates))
end
    
## two inputs only, general form
function TimeNum{T<:Array, S<:Array}(vals::T, names::S)
    if isa(names[1], Date)
        TimeNum(DataFrame(vals), DataArray(names))
    else
        TimeNum(DataFrame(vals, names))
    end
end

## no dates
function TimeNum(vals::DataFrame)
    dates = DataArray(Date, size(vals, 1))
    tn = TimeNum(vals, dates)
end

## no names
function TimeNum(vals::Array{Float64, 2}, dates::DataArray)
    TimeNum(DataFrame(vals), dates)
end


## ## no dates
## function TimeNum(vals::Array{Float64, 2},
##                  names::Array{Union(UTF8String,ASCIIString),1})
##     TimeNum(DataFrame(vals, names))
## end

## ## no names
## function TimeNum(vals::Array{Float64, 2},
##                  dates::Array{Date{ISOCalendar},1})
##     TimeNum(DataFrame(vals), DataArray(dates))
## end

####################################


## ## multiple dates, multiple columns, core elements
## function TimeNum(vals::Array{Float64, 2},
##                  names::Array{Union(UTF8String,ASCIIString),1},
##                  dates::DataArray{Date{ISOCalendar},1})
##     TimeNum(DataFrame(vals, names), dates)
## end

## ## multiple dates, single column, core elements
## function TimeNum(vals::Array{Float64, 2},
##                  names::Union(UTF8String,ASCIIString),
##                  dates::DataArray{Date{ISOCalendar},1})
##     df = DataFrame(vals)
##     colnames!(df, [names])
##     TimeNum(df, dates)
## end

## ## multiple dates, single column, core elements
## function TimeNum(vals::Array{Float64, 1},
##                  names::Union(UTF8String,ASCIIString),
##                  dates::DataArray{Date{ISOCalendar},1})
##     df = DataFrame(vals)
##     colnames!(df, [names])
##     TimeNum(df, dates)
## end

## ## single date, multiple columns, core elements
## function TimeNum(vals::Array{Float64, 2},
##                  names::Array{Union(UTF8String,ASCIIString),1},
##                  dates::Date{ISOCalendar})
##     ## only valid if vals are row vector
##     if size(vals, 1) > 1
##         error("Only one date given, but called with multiple
##                  observations")
##     end
##     df = DataFrame(vals, names)
##     TimeNum(df, DataArray(dates))
## end

## ## single date, multiple columns, core elements: manual names
## function TimeNum(vals::Array{Float64, 2},
##                  names::Array{ASCIIString,1},
##                  dates::Date{ISOCalendar})
##     ## only valid if vals are row vector
##     if size(vals, 1) > 1
##         error("Only one date given, but called with multiple
##                  observations")
##     end
##     df = DataFrame(vals, names)
##     TimeNum(df, DataArray(dates))
## end

## ## single date, single column, core elements
## function TimeNum(vals::Float64,
##                  names::Union(UTF8String,ASCIIString),
##                  dates::Date{ISOCalendar})
##     df = DataFrame(vals)
##     colnames!(df, [names])
##     TimeNum(df, DataArray(dates))
## end

## ## multiple dates, multiple columns, core elements
## function TimeNum(vals::Array{Float64, 2},
##                  dates::DataArray{Date{ISOCalendar},1},
##                  names::Array{Union(UTF8String,ASCIIString),1})
##     TimeNum(DataFrame(vals, names), dates)
## end



## getindex never breaks parts deeper than dataframe in order to cope
## with NAs -> only uses TimeNum(df::DataFrame, da::DataArray)

## sometimes instances will represent simulated data, and hence could
## be built from Arrays directly, missing dates or names ->
## constructor for elementary parts, with some parts missing

## if I manually construct an instance, I will use:
## - Array{Float64, 2} or Array{Float64, 1}
## - Array{ASCIIString, 1}
## - Date{ISOCalendar}, Array{Date{ISOCalendar}, 1} or DataArray{Date{ISOCalendar},1}

#############################
## TimeNum dislay methods ##
#############################

function str(tn::TimeNum)
    ## display information about an array
    
    ## set display parameters
    maxDispRows = 5;
    maxDispCols = 5;
    
    ## get type and field information
    println("\ntype: TimeNum")    
    nms = names(tn)
    ## types = DataType[]
    for fieldname in nms
        tp = fieldtype(tn, fieldname)
        ## push!(types, fieldtype(tn, fieldname))
        println(":$fieldname  \t\t  $tp")
    end

    print("\ndimensions: ")
    print(size(tn.vals))

    
    ## get min and max
    ## minVal = minimum(tn.vals);
    ## maxVal = maximum(tn.vals);

    fromDate = tn.dates[1];
    toDate = tn.dates[end];
    
    println("\n\n-------------------------------------------")
    println("From: $fromDate, To: $toDate")
    println("-------------------------------------------\n")
    
    ## get first entries
    nrow = length(tn.vals[:, 1]);
    ncol = length(tn.vals[1, :]);

    showRows = minimum([maxDispRows nrow]);
    showCols = minimum([maxDispCols ncol]);

    Peekdates = DataFrame(dates = tn.dates[1:showRows]);
    Peek = [Peekdates tn.vals[1:showRows, 1:showCols]];
    display(Peek)
end

import Base.Multimedia.display
function display(tn::TimeNum)
    ## display information about an array
    
    ## set display parameters
    maxDispRows = 5;
    maxDispCols = 5;
    
    ## get type and field information
    println("\ntype: TimeNum")
    print("dimensions: ")
    print(size(tn.vals))
    print("\n")
    
    ## get first entries
    nrow = length(tn.vals[:, 1]);
    ncol = length(tn.vals[1, :]);

    showRows = minimum([maxDispRows nrow]);
    showCols = minimum([maxDispCols ncol]);

    Peekdates = DataFrame(dates = tn.dates[1:showRows]);
    Peek = [Peekdates tn.vals[1:showRows, 1:showCols]];
    display(Peek)
end

###################################
## TimeNum information retrieval ##
###################################

function core(tn::TimeNum)
    return matrix(tn.vals)
end

function dates(tn::TimeNum)
    return tn.dates
end

function vars(tn::TimeNum)
    return colnames(tn.vals)
end

import DataFrames.colnames
function colnames(tn::TimeNum)
    return colnames(tn.vals)
end

#######################
## TimeNum get mean ##
#######################

import Base.mean
function mean(tn::TimeNum, dim::Int = 1)
    ## output: DataFrame
    if dim == 2
        error("For rowwise mean use rowmeans function")
    end
    meanVals = mean(core(tn), dim)
    means = DataFrame(meanVals, vars(tn))
end

function rowmeans(tn::TimeNum)
    ## output: TimeNum
    meanVals = mean(core(tn), 2)
    means = TimeNum(meanVals, dates(tn))
end

#########################
## TimeNum covariance ##
#########################

import Base.cov
function cov(tn::TimeNum)
    ## output: DataFrame
    covDf = DataFrame(cov(core(vals)), vars(tn.vals))
    return covDf
end

###################
## TimeNum size ##
###################

import Base.size
function size(tn::TimeNum)
    return size(tn.vals)
end
function size(tn::TimeNum, ind::Int)
    return size(tn.vals, ind)
end

#######################
## TimeNum getindex ##
#######################

typealias ColumnIndex Union(Real, String, Symbol)

import Base.getindex

## Based on following DataFrame getindex behaviour:
## isa(df[1:2], DataFrame)
## isa(df[1:2, 3:4], DataFrame)
## isa(df[1, 3:4], DataFrame)
## isa(df[1], DataArray{Float64,1})        # loses column name
## isa(df[2:4, 1], DataArray{Float64,1})   # loses column name
## isa(df[2, 2], Float64)                  # loses column name

## select multiple columns
function getindex{T <: ColumnIndex}(tn::TimeNum, col_inds::AbstractVector{T})
    valsDf = getindex(tn.vals, col_inds) # dataframe
    return TimeNum(valsDf, dates(tn))
end

## multiple rows, multiple columns
function getindex{R <: Real, T <: ColumnIndex}(tn::TimeNum,
                                               row_inds::AbstractVector{R},
                                               col_inds::AbstractVector{T})
    valsDf = getindex(tn.vals, row_inds, col_inds) # dataframe
    dats = dates(tn)[row_inds]
    return TimeNum(valsDf, dats)
end

## single row, multiple columns
function getindex{T <: ColumnIndex}(tn::TimeNum, row_ind::Real,
                                         col_inds::AbstractVector{T})
    valsDf = getindex(tn.vals, row_ind, col_inds) # dataframe

    dat = DataArray(dates(tn)[row_ind])
    return TimeNum(valsDf, dat)
end

## select single column
function getindex(tn::TimeNum, col_ind::ColumnIndex)
    valsDa = getindex(tn.vals, col_ind) # dataarray

    ## manually get column name
    selected_column = tn.vals.colindex[col_ind]
    name = colnames(tn)[selected_column] # ASCIIString

    ## create respective dataframe
    valsDf = DataFrame(valsDa)
    colnames!(valsDf, [name])           # colnames must be given as
                                        # array 

    return TimeNum(valsDf, dates(tn))
end

## multiple rows, single column
function getindex{T <: Real}(tn::TimeNum, row_inds::AbstractVector{T},
                             col_ind::ColumnIndex)
    valsDa = getindex(tn.vals, row_inds, col_ind) # dataarray

    ## manually get column name
    selected_column = tn.vals.colindex[col_ind]
    name = colnames(tn)[selected_column] # ASCIIString

    ## create respective dataframe
    valsDf = DataFrame(valsDa)
    colnames!(valsDf, [name])           # colnames must be given as
                                        # array 

    ## get dates
    dats = dates(tn)[row_inds]

    return TimeNum(valsDf, dats)
end

## select single row and single column index
function getindex(tn::TimeNum, row_ind::Real, col_ind::ColumnIndex)
    val = getindex(tn.vals, row_ind, col_ind) # single value / NA

    ## manually get column name
    selected_column = tn.vals.colindex[col_ind]
    name = colnames(tn)[selected_column] # ASCIIString

    ## create respective dataframe
    valDf = DataFrame(val)
    colnames!(valDf, [name])           # colnames must be given as
                                       # array 

    ## single date needs to be transformed to DataArray
    dat = DataArray(dates(tn)[row_ind])

    return TimeNum(valDf, dat)
end

getindex(tn::TimeNum, ex::Expr) = getindex(tn, with(tn.vals, ex))
getindex(tn::TimeNum, ex::Expr, c::ColumnIndex) =
    getindex(tn, with(tn.vals, ex), c)

## typealias ColumnIndex Union(Real, String, Symbol)
getindex{T <: ColumnIndex}(tn::TimeNum, ex::Expr, c::AbstractVector{T}) =
                               getindex(tn, with(tn.vals, ex), c)

getindex(tn::TimeNum, c::Real, ex::Expr) =
    getindex(tn, c, with(tn.vals, ex))
getindex{T <: Real}(tn::TimeNum, c::AbstractVector{T}, ex::Expr) =
    getindex(tn, c, with(tn.vals, ex))
getindex(tn::TimeNum, ex1::Expr, ex2::Expr) =
    getindex(tn, with(tn.vals, ex1), with(tn.vals, ex2))



##############################
## TimeNum logical indexing ##
##############################

import Base.ndims
function ndims(tn::TimeNum)
    return ndims(tn.vals)
end

## function getindex(tn::TimeNum, )


#####################
## TimeNum isequal ##
#####################

import Base.isequal
function isequal(tn::TimeNum, tn2::TimeNum)
    valsEqu = isequal(tn.vals, tn2.vals)
    datesEqu = isequal(tn.dates, tn2.dates)
    equ = (valsEqu & datesEqu)
    return equ
end

import DataFrames.isna
function isna(tn::TimeNum)
    return isna(tn.vals)
end


############################
## read and write to disk ##
############################

function readTimeNum(filename::String)

    df = readtable(filename, nastrings=[".", "", "NA"])
    
    # find columns that have been parsed as Strings by readtable
    col_to_test = String[]

    for col_data in df[1,:]
        typeof(df[1,col_data[1]]) == UTF8String?
        push!(col_to_test, col_data[1]):
        nothing
    end

    # test each column's data to see if Datetime will parse it
    col_that_pass = String[]

    for colname in col_to_test
        d = match(r"[-|\s|\/|.]", df[1,colname])
        d !== nothing? (bar = split(df[1, colname], d.match)): (bar = [])
        if length(bar) == 3
            push!(col_that_pass, colname)
        end
    end

    # parse first column that passes the Datetime regex test
    datesArr = Date[date(d) for d in df[col_that_pass[1]]] # without
                                        # Date it would fail chkDates
                                        # in constructor
    dates = DataArray(datesArr)
    
    delete!(df, [col_that_pass[1]])
    return TimeNum(df, dates)
end

function writeTimeNum(filename::String, tn::TimeNum)
    ## create large dataframe
    datesDf = DataFrame(dates = dates(tn));
    df = [datesDf tn.vals];
    writetable(filename, df)
end

##########
## TODO ##
##########

## function readTimeNum
## end

## function fromToWithDates
## end
