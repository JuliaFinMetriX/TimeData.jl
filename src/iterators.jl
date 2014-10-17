##########################
## iteration by columns ##
##########################

## column iterator without dates
##------------------------------

## iterate over columns without dates equal to DataFrames:
## (nam, col)
immutable TdColumnIterator
    td::AbstractTimedata
end
import DataFrames.eachcol
eachcol(td::AbstractTimedata) = TdColumnIterator(td)

Base.start(itr::TdColumnIterator) = 1
Base.done(itr::TdColumnIterator, j::Int) = j > size(itr.td, 2)
function Base.next(itr::TdColumnIterator, j::Int)
    return ((names(itr.td)[j], itr.td.vals[j]), j + 1)
end
Base.size(itr::TdColumnIterator) = (size(itr.td, 2), )
Base.length(itr::TdColumnIterator) = size(itr.td, 2)
Base.getindex(itr::TdColumnIterator, j::Any) = itr.td.vals[j]

## column iterator with dates
##---------------------------

## iterate over variable as TimeData object
immutable TdVariableIterator
    td::AbstractTimedata
end
eachvar(td::AbstractTimedata) = TdVariableIterator(td)

Base.start(itr::TdVariableIterator) = 1
Base.done(itr::TdVariableIterator, j::Int) = j > size(itr.td, 2)
function Base.next(itr::TdVariableIterator, j::Int)
    return (itr.td[:, j], j + 1)
end
Base.size(itr::TdVariableIterator) = (size(itr.td, 2), )
Base.length(itr::TdVariableIterator) = size(itr.td, 2)
Base.getindex(itr::TdVariableIterator, j::Any) = itr.td[:, j]






#######################
## iteration by rows ##
#######################

## row without date information
##-----------------------------

## iterate over rows as DataFrames without date information:
immutable TdRowIterator
    td::AbstractTimedata
end
import DataFrames.eachrow
eachrow(td::AbstractTimedata) = TdRowIterator(td)

Base.start(itr::TdRowIterator) = 1
Base.done(itr::TdRowIterator, i::Int) = i > size(itr.td, 1)
function Base.next(itr::TdRowIterator, i::Int)
    return (itr.td.vals[i, :], i + 1)
end
Base.size(itr::TdRowIterator) = (size(itr.td, 1), )
Base.length(itr::TdRowIterator) = size(itr.td, 1)
Base.getindex(itr::TdRowIterator, i::Any) = itr.td.vals[i, :]

## row with date information
##--------------------------

## iterator over rows as TimeData object
immutable TdDateIterator
    td::AbstractTimedata
end
eachdate(td::AbstractTimedata) = TdDateIterator(td)

Base.start(itr::TdDateIterator) = 1
Base.done(itr::TdDateIterator, i::Int) = i > size(itr.td, 1)
function Base.next(itr::TdDateIterator, i::Int)
    return (itr.td[i, :], i + 1)
end
Base.size(itr::TdDateIterator) = (size(itr.td, 1), )
Base.length(itr::TdDateIterator) = size(itr.td, 1)
Base.getindex(itr::TdDateIterator, i::Any) = itr.td[i, :]





#################################
## iteration over each element ##
#################################

## to be implemented
## column-first iterator over individual entries without metadata 
immutable TdEntryIterator
    td::AbstractTimedata
end
eachentry(td::AbstractTimedata) = TdEntryIterator(td)

Base.start(itr::TdEntryIterator) = 1
function Base.done(itr::TdEntryIterator, i::Int)
    return i > size(itr.td, 1)*size(itr.td, 2)
end
function Base.next(itr::TdEntryIterator, i::Int)
    rowInd, colInd = ind2sub(size(itr.td), i)
    return (get(itr.td, rowInd, colInd), i + 1)
end
Base.size(itr::TdEntryIterator) = (size(itr.td, 1)*size(itr.td, 2), )
Base.length(itr::TdEntryIterator) = size(itr.td, 1)*size(itr.td, 2)
function Base.getindex(itr::TdEntryIterator, i::Any)
    rowInd, colInd = ind2sub(size(itr.td), i)
    return get(itr.td, rowInd, colInd)
end

## column-first iterator over individual entries with metadata
immutable TdObsIterator
    td::AbstractTimedata
end
eachobs(td::AbstractTimedata) = TdObsIterator(td)

Base.start(itr::TdObsIterator) = 1
function Base.done(itr::TdObsIterator, i::Int)
    return i > size(itr.td, 1)*size(itr.td, 2)
end
function Base.next(itr::TdObsIterator, i::Int)
    rowInd, colInd = ind2sub(size(itr.td), i)
    return (itr.td[rowInd, colInd], i + 1)
end
Base.size(itr::TdObsIterator) = (size(itr.td, 1)*size(itr.td, 2), )
Base.length(itr::TdObsIterator) = size(itr.td, 1)*size(itr.td, 2)
function Base.getindex(itr::TdObsIterator, i::Any)
    rowInd, colInd = ind2sub(size(itr.td), i)
    return itr.td[rowInd, colInd]
end

