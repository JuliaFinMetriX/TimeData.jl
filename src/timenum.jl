#################################
## definition of TimeData type ##
#################################

## constraints:
## - DataArray, where individual entries are subtype of Date
## - dates and vals must have same number of observations
## - values must be numeric

type TimeNum
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

function TimeNum(vals::Array{Float64, 2},
                 names::Array{Union(UTF8String,ASCIIString),1},
                 dates::DataArray{Date{ISOCalendar},1})
    TimeNum(DataFrame(vals, names), dates)
end

function TimeNum(vals::Array{Float64, 2},
                 names::Union(UTF8String,ASCIIString),
                 dates::DataArray{Date{ISOCalendar},1})
    df = DataFrame(vals)
    colnames!(df, [names])
    TimeNum(df, dates)
end

function TimeNum(vals::Array{Float64, 1},
                 names::Union(UTF8String,ASCIIString),
                 dates::DataArray{Date{ISOCalendar},1})
    df = DataFrame(vals)
    colnames!(df, [names])
    TimeNum(df, dates)
end

function TimeNum(vals::Array{Float64, 2},
                 names::Array{Union(UTF8String,ASCIIString),1},
                 dates::Date{ISOCalendar})
    ## only valid if vals are row vector
    if size(vals, 1) > 1
        error("Only one date given, but called with multiple
                 observations")
    end
    df = DataFrame(vals, names)
    TimeNum(df, DataArray(dates))
end

function TimeNum(vals::Array{Float64, 2},
                 names::Array{ASCIIString,1},
                 dates::Date{ISOCalendar})
    ## only valid if vals are row vector
    if size(vals, 1) > 1
        error("Only one date given, but called with multiple
                 observations")
    end
    df = DataFrame(vals, names)
    TimeNum(df, DataArray(dates))
end

function TimeNum(vals::Float64,
                 names::Union(UTF8String,ASCIIString),
                 dates::Date{ISOCalendar})
    df = DataFrame(vals)
    colnames!(df, [names])
    TimeNum(df, DataArray(dates))
end

function TimeNum(vals::Array{Float64, 2},
                 dates::DataArray{Date{ISOCalendar},1},
                 names::Array{Union(UTF8String,ASCIIString),1})
    TimeNum(DataFrame(vals, names), dates)
end

## no dates
function TimeNum(vals::DataFrame)
    dates = DataArray(Date, size(vals, 1))
    tn = TimeNum(vals, dates)
end

## no dates
function TimeNum(vals::Array{Float64, 2},
                 names::Array{Union(UTF8String,ASCIIString),1})
    TimeNum(DataFrame(vals, names))
end

## no names
function TimeNum(vals::Array{Float64, 2}, dates::DataArray)
    TimeNum(DataFrame(vals), dates)
end

## no names
function TimeNum(vals::Array{Float64, 2},
                 dates::Array{Date{ISOCalendar},1})
    TimeNum(DataFrame(vals), DataArray(dates))
end

## no names or dates
function TimeNum(vals::Array{Float64, 2})
    dates = DataArray(Date, size(vals, 1))
    TimeNum(DataFrame(vals))
end

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
    return size(core(tn))
end

#######################
## TimeNum getindex ##
#######################

typealias ColumnIndex Union(Real, String, Symbol)

import Base.getindex
function getindex(tn::TimeNum, col_ind::ColumnIndex)
    ## select single column
    selected_column = tn.vals.colindex[col_ind]

    vals = tn.vals.columns[selected_column]
    valsDf = DataFrame(vals)
    name = colnames(tn)[selected_column]
    colnames!(valsDf, [name])

    tnSelection = TimeNum(valsDf, dates(tn))
    ## vals = DataFrame(getindex(tn.vals, col_ind))
    ## tnSelection = TimeNum(vals, dates(tn))
    return tnSelection
end

function getindex{T <: ColumnIndex}(tn::TimeNum, col_inds::AbstractVector{T})
    ## select multiple columns
    valsDf = getindex(tn.vals, col_inds)
    return TimeNum(valsDf, dates(tn))
end

function getindex(tn::TimeNum, row_ind::Real, col_ind::ColumnIndex)
    ## select single row and column index
    selected_column = tn.vals.colindex[col_ind]

    ## extract individual components
    val = getindex(tn.vals, row_ind, col_ind)
    name = colnames(tn)[selected_column]
    dat = dates(tn)[row_ind]

    ## manually attach colname and date again
    return TimeNum(val, name, dat)
end

function getindex{T <: ColumnIndex}(tn::TimeNum, row_ind::Real,
                                         col_inds::AbstractVector{T})
    ## single row, multiple columns
    df = getindex(tn.vals, row_ind, col_inds)
    date = DataArray([dates(tn)[row_ind]])
    return TimeNum(df, date)
end

function getindex{T <: Real}(tn::TimeNum, row_inds::AbstractVector{T},
                             col_ind::ColumnIndex)
    ## multiple rows, single column

    ## get single column
    tnCol = tn[col_ind]

    ## get rows
    vals = core(tnCol)[row_inds, 1]
    dats = dates(tnCol)[row_inds]

    return TimeNum(vals, colnames(tnCol)[1], dats)
end

# df[MultiRowIndex, MultiColumnIndex] => (Sub)?DataFrame
function getindex{R <: Real, T <: ColumnIndex}(tn::TimeNum,
                                               row_inds::AbstractVector{R},
                                               col_inds::AbstractVector{T})
    ## multiple rows, multiple columns
    dats = dates(tn)[row_inds]

    df = getindex(tn.vals, row_inds, col_inds)
    return TimeNum(df, dats)
end

##########
## TODO ##
##########

## function readTimeNum
## end

## function fromToWithDates
## end
