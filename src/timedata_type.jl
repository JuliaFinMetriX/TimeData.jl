type Timedata{T} <: AbstractTimedata
    vals::DataFrame
    idx::Array{T, 1}

    function Timedata(vals::DataFrame, idx::Array{T, 1})
        chkIdx(idx)
        if(size(vals, 1) != length(idx))
            if (length(idx) == 0) | (size(vals, 1) == 0)
                df = convert(DataFrame, rand(2, 2))
                return new(df[1:2, []], Array{T, 1}[])
            end
            error(length(idx), " idx entries, but ", size(vals, 1), " rows of data")
        end
        return new(vals, idx)
    end
end

function Timedata{T}(vals::DataFrame, idx::Array{T, 1})
    return Timedata{T}(vals, idx)
end

#######################
## find boolean true ##
#######################

import Base.find
function find(td::TimeData.Timedata)
    ## apply find to column DataArrays
    allRowInds = Int[]
    allColInds = Int[]
    for (name, col) in eachcol(td.vals)
        rowInds = find(col)
        colInd = td.vals.colindex[name]
        colInds = repmat([colInd], length(rowInds))
        append!(allRowInds, [rowInds])
        append!(allColInds, [colInds])
    end
    return sub2ind(size(td), allRowInds, allColInds)
end

function find2sub(td::TimeData.Timedata)
    ## apply find to column DataArrays and return tuple of subscripts 
    allRowInds = Int[]
    allColInds = Int[]
    for (name, col) in eachcol(td.vals)
        rowInds = find(col)
        colInd = td.vals.colindex[name]
        colInds = repmat([colInd], length(rowInds))
        append!(allRowInds, [rowInds])
        append!(allColInds, [colInds])
    end
    return (allRowInds, allColInds)
end

function find(f::Function, td::TimeData.AbstractTimedata)
    ## apply function elementwise to td
    ## apply find to column DataArrays

    (nObs, nVars) = size(td)

    allRowInds = Int[]
    allColInds = Int[]
    
    for ii=1:nObs
        for jj=1:nVars
            if isequal(f(get(td, ii, jj)), true)
                push!(allRowInds, ii)
                push!(allColInds, jj)
            end
        end
    end
    return sub2ind(size(td), allRowInds, allColInds)
end

function find2sub(f::Function, td::TimeData.AbstractTimedata)
    ## apply function elementwise to td
    ## apply find to column DataArrays

    (nObs, nVars) = size(td)

    allRowInds = Int[]
    allColInds = Int[]
    
    for ii=1:nObs
        for jj=1:nVars
            if isequal(f(get(td, ii, jj)), true)
                push!(allRowInds, ii)
                push!(allColInds, jj)
            end
        end
    end
    return (allRowInds, allColInds)
end
