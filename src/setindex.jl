###########
## setNA ##
###########

function setNA!(td::AbstractTimedata, rowIdx::Int, colIdx::Int)
    ## set entry to NA - could require changing eltype of column to
    ## DataArray 
    if !isa(td.vals.columns[colIdx], DataArray)
        td.vals.columns[colIdx] = DataArray(td.vals.columns[colIdx])
    end        
    td.vals[rowIdx, colIdx] = NA
    return td
end

function setNA!(td::AbstractTimematr, rowIdx::Int, colIdx::Int)
    ## set entry to NA not allowed for Timematr
    error("Setting entries to NA is not allowed for AbstractTimematr types")
end

###############
## setindex! ##
###############

import Base.setindex!
function setindex!(td::Timedata, value::Any,
                   rowIdx::Int, colIdx::Int)

    if isna(value)
        setNA!(td, rowIdx, colIdx)
    else
        setindex!(td.vals, value, rowIdx, colIdx)
    end
end

function setindex!(td::AbstractTimenum, value::Any,
                   rowIdx::Int, colIdx::Int)

    if isna(value)
        setNA!(td, rowIdx, colIdx)
    else
        if !issubtype(typeof(value), Number)
            error("Entries of AbstractTimenum must be numeric")
        end
        setindex!(td.vals, value, rowIdx, colIdx)
    end
end

#############
## impute! ##
#############

## - impute with fixed value: 0
## - impute with last observation
## - impute with next observation
