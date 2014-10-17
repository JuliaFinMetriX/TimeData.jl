##################################
## map for columnwise iterators ##
##################################

import Base.map
function map(f::Function, tdci::TdColumnIterator)
    ## function works on da values only (second part of tuple)!!
    ## function returns array or da
    df = DataFrame()
    for (nam, col) in tdci
        df[nam] = f(col)
    end
    td = Timedata(df, idx(tdci.td))
    return td
end

## getColData
##-----------

## transform output data into a format that can be assigned to
## DataFrame column
function getColData(x::Vector)
    return x
end
function getColData(x::DataArray)
    return x
end
function getColData(x::DataFrame)
    return x[:, 1]
end
function getColData(x::AbstractTimedata)
    return x.vals[:, 1]
end
    
function map(f::Function, tdvi::TdVariableIterator)
    ## function must not work on DataArray, but on TimeData
    ## function returns array, da or TimeData
    df = DataFrame()
    for tdCol in tdvi
        tdRes = f(tdCol)
        df[names(tdCol)[1]] = getColData(tdRes)
    end
    td = Timedata(df, idx(tdvi.td))
    return td
end

###############################
## map for rowwise iterators ##
###############################

## nthRowElem
##-----------

## extract nth value from given output and transform it into a format
## that does not contain metadata anymore

## the following output formats are allowed for f:
function nthRowElem(x::Vector, n::Int)
    return x[n]
end
function nthRowElem(x::Matrix, n::Int)
    return x[1, n]
end
function nthRowElem(x::DataFrame, n::Int)
    return x[1, n]
end
function nthRowElem(x::AbstractTimedata, n::Int)
    return get(x, 1, n)
end

function map(f::Function, tdri::TdRowIterator)
    nObs, nVars = size(tdri.td)
    vals = Array(Any, nObs, nVars)
    rowCounter = 1;
    for row in tdri # DataFrame
        rowRes = f(row)
        for jj=1:nVars
            vals[rowCounter, jj] = nthRowElem(rowRes, jj)
        end
        rowCounter += 1
    end
    df = anyToDf(vals, names(tdri.td))
    td = Timedata(df, idx(tdri.td))
    return td
end

function map(f::Function, tddi::TdDateIterator)
    nObs, nVars = size(tddi.td)
    vals = Array(Any, nObs, nVars)
    rowCounter = 1;
    for tmRow in tddi # TimeData object
        rowRes = f(tmRow)
        for jj=1:nVars
            vals[rowCounter, jj] = nthRowElem(rowRes, jj)
        end
        rowCounter += 1
    end
    df = anyToDf(vals, names(tddi.td))
    td = Timedata(df, idx(tddi.td))
    return td
end

###################################
## map for elementwise iterators ##
###################################

function map(f::Function, tdei::TdEntryIterator)
    nObs, nVars = size(tdei.td)
    vals = Array(Any, nObs, nVars)
    indRow = 1
    indCol = 1
    for entry in tdei
        vals[indRow, indCol] = f(entry)
        if indRow == nObs # move to next column
            indRow = 1
            indCol += 1
        else
            indRow += 1
        end
    end
    df = anyToDf(vals, names(tdei.td))
    td = Timedata(df, idx(tdei.td))
end

function map(f::Function, tdoi::TdObsIterator)
    nObs, nVars = size(tdoi.td)
    vals = Array(Any, nObs, nVars)
    indRow = 1
    indCol = 1
    for obs in tdoi
        vals[indRow, indCol] = get(f(obs), :)
        if indRow == nObs # move to next column
            indRow = 1
            indCol += 1
        else
            indRow += 1
        end
    end
    df = anyToDf(vals, names(tdoi.td))
    td = Timedata(df, idx(tdoi.td))
end

## ####################################
## ## map with two collections - old ##
## ####################################

## ## map function for column iterator always returns Timedata object of
## ## same size! Indices remain unchanged!

## ## map for two collections:
## function map(f::Function, tdci::TdColumnIterator, x)
##     # note: `f` must return a consistent length
##     nIter1 = length(tdci)
##     nIter2 = length(x)
##     if nIter1 != nIter2
##         error("length of iterators must be identical")
##     end

##     res = DataFrame()
##     nams = names(tdci.td)
##     state = start(x)
##     for ii=1:nIter1
##         val, state = next(x, state)
##         res[nams[ii]] = f(tdci.td.vals[:, ii], val)
##     end

##     display(res)
##     td = Timedata(res, idx(tdci.td))
##     if isa(tdci.td, AbstractTimenum)
##         try
##             td = convert(Timenum, td)
##         catch
##         end
##     elseif isa(tdci.td, AbstractTimenum)
##         try
##             td = convert(Timematr, td)
##         catch
##         end
##     end
##     return td
## end



############
## chkElw ##
############

function chkElw(f::Function, tdei::TdEntryIterator)
    nObs, nVars = size(tdei.td)
    res = preallocateBoolDf(names(tdei.td), nObs)
    indRow = 1
    indCol = 1
    for entry in tdei
        res[indRow, indCol] = get(f(entry), :)
        if indRow == nObs
            indRow = 1
            indCol += 1
        else
            indRow += 1
        end
    end
    return Timedata(res, idx(tdei.td))
end

function chkElw(f::Function, tdoi::TdEntryIterator)
    nObs, nVars = size(tdoi.td)
    res = preallocateBoolDf(names(tdoi.td), nObs)
    indRow = 1
    indCol = 1
    for obs in tdoi
        res[indRow, indCol] = get(f(obs), :)
        if indRow == nObs
            indRow = 1
            indCol += 1
        else
            indRow += 1
        end
    end
    return Timedata(res, idx(tdoi.td))
end

## chkVars
##--------

function chkVars(f::Function, tdci::TdColumnIterator)
    res = preallocateBoolDf(names(tdci.td), 1)
    for (nam, col) in tdci
        res[nam] = get(f(col), :)
    end
    return res
end

function chkVars(f::Function, tdvi::TdVariableIterator)
    res = preallocateBoolDf(names(tdvi.td), 1)
    for tdCol in tdvi
        res[names(tdCol)] = get(f(tdCol), :)
    end
    return res
end

## chkDates
##---------

function chkDates(f::Function, tdri::TdRowIterator)
    nObs = size(tdri.td, 1)
    res = DataArray(Bool, nObs)
    indCounter = 1
    for df in tdri
        res[indCounter] = get(f(df), :)
        indCounter += 1
    end
    return Timedata(DataFrame(test_is = res), idx(tdri.td))
end

function chkDates(f::Function, tddi::TdDateIterator)
    nObs = size(tddi.td, 1)
    res = DataArray(Bool, nObs)
    indCounter = 1
    for tdRow in tddi
        res[indCounter] = get(f(tdRow), :)
        indCounter += 1
    end
    return Timedata(DataFrame(test_is = res), idx(tddi.td))
end


###################
## collapseDates ##
###################

## reduces columns to single value
## output: DataFrame

function collapseDates(f::Function, tdci::TdColumnIterator)
    df = DataFrame()
    for (nam, col) in tdci
        df[nam] = f(col)
    end
    return df
end


function collapseDates(f::Function, tdvi::TdVariableIterator)
    df = DataFrame()
    for tdCol in tdvi
        tdRes = f(tdCol)
        df[names(tdCol)[1]] = get(tdRes, :) # get single value
    end
    return df
end

##################
## collapseVars ##
##################

## reduces row to single value
## output: TimeData object
function collapseVars(f::Function, tdri::TdRowIterator)
    nObs = size(tdri.td, 1)
    vals = Array(Any, nObs)
    rowCounter = 1
    for row in tdri # DataFrame
        rowRes = f(row)
        vals[rowCounter, 1] = get(rowRes, :) # get single value
        rowCounter += 1
    end
    df = DataFrame(funcVal = anyToDa(vals))
    return Timedata(df, idx(tdri.td))
end

function collapseVars(f::Function, tddi::TdDateIterator)
    nObs = size(tddi.td, 1)
    vals = Array(Any, nObs)
    rowCounter = 1
    for tmRow in tddi # TimeData object
        rowRes = f(tmRow)
        vals[rowCounter, 1] = get(rowRes, :) # get single value
        rowCounter += 1
    end
    df = DataFrame(funcVal = anyToDa(vals))
    return Timedata(df, idx(tddi.td))
end
