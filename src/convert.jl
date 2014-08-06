#############
## Timenum ##
#############

import Base.convert
## to Timedata: conversion upwards - always works
function convert(::Type{Timedata}, tn::Timenum)
    return Timedata(tn.vals, tn.idx)
end

## to Timematr: conversion downwards - fails for NAs
function convert(::Type{Timematr}, tn::Timenum, rmNA = false)
    if rmNA
        tm = narm(tn)
        tm = Timematr(tm.vals, tm.idx)
    else
        tm = Timematr(tn.vals, tn.idx)
    end
    return tm
end

##############
## Timematr ##
##############

## to Timedata: conversion upwards - always works
function convert(::Type{Timedata}, tm::Timematr)
    Timedata(tm.vals, tm.idx)
end

## to Timenum: conversion upwards - always works
function convert(::Type{Timenum}, tm::Timematr)
    Timenum(tm.vals, tm.idx)
end


##############
## Timedata ##
##############

## to Timenum: conversion downwards - fails for non-numeric values
function convert(::Type{Timenum}, td::Timedata)
    Timenum(td.vals, td.idx)
end

## to Timematr: conversion downwards - fails for NAs
function convert(::Type{Timematr}, td::Timedata)
    Timematr(td.vals, td.idx)
end

################
## DataFrames ##
################

## convert DataFrame with dates column (as String) to TimeData object 

function convert(::Type{AbstractTimedata}, df::DataFrame)
    ## test if some column already is of type Date
    if any(eltypes(df) .== Date)
        ## take first occuring column
        dateCol = find(eltypes(df) .== Date)[1]
        idx = array(df[dateCol])
        delete!(df, [dateCol])
        
    else ## find column that contain dates as String
        
        # find columns that have been parsed as Strings by readtable
        col_to_test = Array(Symbol, 0)
        
        nCols = size(df, 2)
        for ii=1:nCols
            isa(df[1, ii], String)?
            push!(col_to_test, names(df)[ii]):
            nothing
        end
        
        # test each column's data to see if Datetime will parse it
        col_that_pass = Array(Symbol, 0)
        
        for colname in col_to_test
            d = match(r"[-|\s|\/|.]", df[1, colname])
            d !== nothing? (bar = split(df[1, colname], d.match)): (bar = [])
            if length(bar) == 3
                push!(col_that_pass, colname)
            end
        end
        
        # parse first column that passes the Datetime regex test
        idx = Date[Date(d) for d in df[col_that_pass[1]]] # without
        # Date it would fail chkIdx
        # in constructor
        
        delete!(df, [col_that_pass[1]])
    end
    
    ## try whether DataFrame fits subtypes
    try
        td = Timematr(df, idx)
        return td        
    catch
        try
            td = Timenum(df, idx)
            return td
        catch
            td = Timedata(df, idx)
            return td
        end
    end
    
    return td
end


################
## TimeArrays ##
################

function convert(::Type{AbstractTimedata}, ta::TimeArray)

    namesAsSymbols = [DataFrames.identifier(nam) for nam in ta.colnames]
    
    df = composeDataFrame(ta.values, namesAsSymbols)
    idx = ta.timestamp

    try
        td = Timematr(df, idx)
        return td        
    catch
        try
            td = Timenum(df, idx)
            return td
        catch
            td = Timedata(df, idx)
            return td
        end
    end
    td
end
