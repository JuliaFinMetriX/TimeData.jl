################################
## definition of Timenum type ##
################################

## constraints:
## - DataArray, where individual entries are subtype of Date
## - dates and vals must have same number of observations
## - values must be numeric

type Timenum <: AbstractTimeData
    vals::DataFrame
    dates::DataArray

    function Timenum(vals::DataFrame, dates::DataArray)
        chkDates(dates)
        chkNumDf(vals)
        if(size(vals, 1) != length(dates))
            error("number of dates must equal number of columns of data")
        end
        return new(vals, dates)
    end
end

################################
## Timenum outer contructors ##
################################

## no names or dates (just simulated values)
function Timenum(vals::Array{Float64, 2})
    dates = DataArray(Date, size(vals, 1))
    Timenum(DataFrame(vals), dates)
end

## from core elements
function Timenum(vals::Array{Float64, 2},
                 names::Array{Union(UTF8String,ASCIIString),1},
                 dates::DataArray{Date{ISOCalendar}, 1})
    df = DataFrame(vals, names)
    return Timenum(df, dates)
end

## comprehensive constructor: very general, all elements
function Timenum{T<:Array, K<:Array, S<:Array}(vals::T, names::K, dates::S) 
    df = DataFrame(vals)
    colnames!(df, names)
    return Timenum(df, DataArray(dates))
end
    
## two inputs only, general form
function Timenum{T<:Array, S<:Array}(vals::T, names::S)
    if isa(names[1], Date)
        Timenum(DataFrame(vals), DataArray(names))
    else
        Timenum(DataFrame(vals, names))
    end
end

## no dates
function Timenum(vals::DataFrame)
    dates = DataArray(Date, size(vals, 1))
    tn = Timenum(vals, dates)
end

## no names
function Timenum(vals::Array{Float64, 2}, dates::DataArray)
    Timenum(DataFrame(vals), dates)
end


## ## no dates
## function Timenum(vals::Array{Float64, 2},
##                  names::Array{Union(UTF8String,ASCIIString),1})
##     Timenum(DataFrame(vals, names))
## end

## ## no names
## function Timenum(vals::Array{Float64, 2},
##                  dates::Array{Date{ISOCalendar},1})
##     Timenum(DataFrame(vals), DataArray(dates))
## end

####################################


## ## multiple dates, multiple columns, core elements
## function Timenum(vals::Array{Float64, 2},
##                  names::Array{Union(UTF8String,ASCIIString),1},
##                  dates::DataArray{Date{ISOCalendar},1})
##     Timenum(DataFrame(vals, names), dates)
## end

## ## multiple dates, single column, core elements
## function Timenum(vals::Array{Float64, 2},
##                  names::Union(UTF8String,ASCIIString),
##                  dates::DataArray{Date{ISOCalendar},1})
##     df = DataFrame(vals)
##     colnames!(df, [names])
##     Timenum(df, dates)
## end

## ## multiple dates, single column, core elements
## function Timenum(vals::Array{Float64, 1},
##                  names::Union(UTF8String,ASCIIString),
##                  dates::DataArray{Date{ISOCalendar},1})
##     df = DataFrame(vals)
##     colnames!(df, [names])
##     Timenum(df, dates)
## end

## ## single date, multiple columns, core elements
## function Timenum(vals::Array{Float64, 2},
##                  names::Array{Union(UTF8String,ASCIIString),1},
##                  dates::Date{ISOCalendar})
##     ## only valid if vals are row vector
##     if size(vals, 1) > 1
##         error("Only one date given, but called with multiple
##                  observations")
##     end
##     df = DataFrame(vals, names)
##     Timenum(df, DataArray(dates))
## end

## ## single date, multiple columns, core elements: manual names
## function Timenum(vals::Array{Float64, 2},
##                  names::Array{ASCIIString,1},
##                  dates::Date{ISOCalendar})
##     ## only valid if vals are row vector
##     if size(vals, 1) > 1
##         error("Only one date given, but called with multiple
##                  observations")
##     end
##     df = DataFrame(vals, names)
##     Timenum(df, DataArray(dates))
## end

## ## single date, single column, core elements
## function Timenum(vals::Float64,
##                  names::Union(UTF8String,ASCIIString),
##                  dates::Date{ISOCalendar})
##     df = DataFrame(vals)
##     colnames!(df, [names])
##     Timenum(df, DataArray(dates))
## end

## ## multiple dates, multiple columns, core elements
## function Timenum(vals::Array{Float64, 2},
##                  dates::DataArray{Date{ISOCalendar},1},
##                  names::Array{Union(UTF8String,ASCIIString),1})
##     Timenum(DataFrame(vals, names), dates)
## end



## getindex never breaks parts deeper than dataframe in order to cope
## with NAs -> only uses Timenum(df::DataFrame, da::DataArray)

## sometimes instances will represent simulated data, and hence could
## be built from Arrays directly, missing dates or names ->
## constructor for elementary parts, with some parts missing

## if I manually construct an instance, I will use:
## - Array{Float64, 2} or Array{Float64, 1}
## - Array{ASCIIString, 1}
## - Date{ISOCalendar}, Array{Date{ISOCalendar}, 1} or DataArray{Date{ISOCalendar},1}
function core(tn::Timenum)
    return matrix(tn.vals)
end

#######################
## Timenum get mean ##
#######################

import Base.mean
function mean(tn::Timenum, dim::Int = 1)
    ## output: DataFrame
    if dim == 2
        error("For rowwise mean use rowmeans function")
    end
    meanVals = mean(core(tn), dim)
    means = DataFrame(meanVals, vars(tn))
end

function rowmeans(tn::Timenum)
    ## output: Timenum
    meanVals = mean(core(tn), 2)
    means = Timenum(meanVals, dates(tn))
end

#########################
## Timenum covariance ##
#########################

import Base.cov
function cov(tn::Timenum)
    ## output: DataFrame
    covDf = DataFrame(cov(core(vals)), vars(tn.vals))
    return covDf
end

#######################
## Timenum getindex ##
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
function getindex{T <: ColumnIndex}(tn::Timenum, col_inds::AbstractVector{T})
    valsDf = getindex(tn.vals, col_inds) # dataframe
    return Timenum(valsDf, dates(tn))
end

## multiple rows, multiple columns
function getindex{R <: Real, T <: ColumnIndex}(tn::Timenum,
                                               row_inds::AbstractVector{R},
                                               col_inds::AbstractVector{T})
    valsDf = getindex(tn.vals, row_inds, col_inds) # dataframe
    dats = dates(tn)[row_inds]
    return Timenum(valsDf, dats)
end

## single row, multiple columns
function getindex{T <: ColumnIndex}(tn::Timenum, row_ind::Real,
                                         col_inds::AbstractVector{T})
    valsDf = getindex(tn.vals, row_ind, col_inds) # dataframe

    dat = DataArray(dates(tn)[row_ind])
    return Timenum(valsDf, dat)
end

## select single column
function getindex(tn::Timenum, col_ind::ColumnIndex)
    valsDa = getindex(tn.vals, col_ind) # dataarray

    ## manually get column name
    selected_column = tn.vals.colindex[col_ind]
    name = colnames(tn)[selected_column] # ASCIIString

    ## create respective dataframe
    valsDf = DataFrame(valsDa)
    colnames!(valsDf, [name])           # colnames must be given as
                                        # array 

    return Timenum(valsDf, dates(tn))
end

## multiple rows, single column
function getindex{T <: Real}(tn::Timenum, row_inds::AbstractVector{T},
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

    return Timenum(valsDf, dats)
end

## select single row and single column index
function getindex(tn::Timenum, row_ind::Real, col_ind::ColumnIndex)
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

    return Timenum(valDf, dat)
end

getindex(tn::Timenum, ex::Expr) = getindex(tn, with(tn.vals, ex))
getindex(tn::Timenum, ex::Expr, c::ColumnIndex) =
    getindex(tn, with(tn.vals, ex), c)

## typealias ColumnIndex Union(Real, String, Symbol)
getindex{T <: ColumnIndex}(tn::Timenum, ex::Expr, c::AbstractVector{T}) =
                               getindex(tn, with(tn.vals, ex), c)

getindex(tn::Timenum, c::Real, ex::Expr) =
    getindex(tn, c, with(tn.vals, ex))
getindex{T <: Real}(tn::Timenum, c::AbstractVector{T}, ex::Expr) =
    getindex(tn, c, with(tn.vals, ex))
getindex(tn::Timenum, ex1::Expr, ex2::Expr) =
    getindex(tn, with(tn.vals, ex1), with(tn.vals, ex2))



##############################
## Timenum logical indexing ##
##############################

## function getindex(tn::Timenum, )

############################
## read and write to disk ##
############################

## function readTimenum(filename::String)

##     df = readtable(filename, nastrings=[".", "", "NA"])
    
##     # find columns that have been parsed as Strings by readtable
##     col_to_test = String[]

##     for col_data in df[1,:]
##         typeof(df[1,col_data[1]]) == UTF8String?
##         push!(col_to_test, col_data[1]):
##         nothing
##     end

##     # test each column's data to see if Datetime will parse it
##     col_that_pass = String[]

##     for colname in col_to_test
##         d = match(r"[-|\s|\/|.]", df[1,colname])
##         d !== nothing? (bar = split(df[1, colname], d.match)): (bar = [])
##         if length(bar) == 3
##             push!(col_that_pass, colname)
##         end
##     end

##     # parse first column that passes the Datetime regex test
##     datesArr = Date[date(d) for d in df[col_that_pass[1]]] # without
##                                         # Date it would fail chkDates
##                                         # in constructor
##     dates = DataArray(datesArr)
    
##     delete!(df, [col_that_pass[1]])
##     return Timenum(df, dates)
## end

## function writeTimenum(filename::String, tn::Timenum)
##     ## create large dataframe
##     datesDf = DataFrame(dates = dates(tn));
##     df = [datesDf tn.vals];
##     writetable(filename, df)
## end

##########
## TODO ##
##########

## function readTimenum
## end

## function fromToWithDates
## end
