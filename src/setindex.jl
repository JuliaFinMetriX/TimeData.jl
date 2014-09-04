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


function impute!(da::DataArray, with="last")
    ## impute NAs with last or next observation or zero

    nRow = length(da)
    
    rowInds = find(isna(da))
    nNAs = length(rowInds)
    
    if with == "last"
        for ii=1:nNAs
            if rowInds[ii] > 1
                da[rowInds[ii]] = da[rowInds[ii]-1]
            end
        end

    elseif with == "single last"
        for ii=1:nNAs
            if rowInds[ii] > 1
                ## only replace if next entry is not a NA or NA is
                ## in last row
                if (rowInds[ii] == nRow) || !isna(da[rowInds[ii]+1])
                    da[rowInds[ii]] = da[rowInds[ii]-1]
                end
            end
        end

    elseif with == "next"
        for ii=nNAs:-1:1                   # chronologic iterating
            if rowInds[ii] < nRow
                da[rowInds[ii]] = da[rowInds[ii]+1]
            end
        end

    elseif with == "zero"
        for ii=1:nNAs
            da[rowInds[ii]] = 0
        end
    end

    return da
end

function impute!(td::AbstractTimedata, with="last")
    ## apply impute! for DataArrays on each column, add metadata

    for (nam, col) in eachcol(td.vals)
        impute!(col, with)
    end
    return td
end

