##########################
## iteration by columns ##
##########################

immutable TdColumnIterator
    td::AbstractTimedata
end

import DataFrames.eachcol
eachcol(td::AbstractTimedata) = TdColumnIterator(td)

Base.start(itr::TdColumnIterator) = 1
Base.done(itr::TdColumnIterator, j::Int) = j > size(itr.td, 2)
Base.next(itr::TdColumnIterator, j::Int) = (itr.td[j], j + 1)
Base.size(itr::TdColumnIterator) = (size(itr.td, 2), )
Base.length(itr::TdColumnIterator) = size(itr.td, 2)
Base.getindex(itr::TdColumnIterator, j::Any) = itr.td[:, j]

import Base.map

## map function for column iterator always returns Timedata object of
## same size! Indices remain unchanged!
function map(f::Function, tdci::TdColumnIterator)
    # note: `f` must return a consistent length
    res = DataFrame()
    for (n, v) in eachcol(tdci.td.vals)
        res[n] = f(v)
    end
    
    td = Timedata(res, idx(tdci.td))
    if isa(tdci.td, AbstractTimematr)
        try
            td = convert(Timematr, td)
        catch
        end
    elseif isa(tdci.td, AbstractTimenum)
        try
            td = convert(Timenum, td)
        catch
        end
    end
    return td
end

## map function for column iterator always returns Timedata object of
## same size! Indices remain unchanged!
function map(f::Function, tdci::TdColumnIterator, x)
    # note: `f` must return a consistent length
    nIter1 = length(tdci)
    nIter2 = length(x)
    if nIter1 != nIter2
        error("length of iterators must be identical")
    end

    res = DataFrame()
    nams = names(tdci.td)
    state = start(x)
    for ii=1:nIter1
        val, state = next(x, state)
        res[nams[ii]] = f(tdci.td.vals[:, ii], val)
    end

    display(res)
    td = Timedata(res, idx(tdci.td))
    if isa(tdci.td, AbstractTimenum)
        try
            td = convert(Timenum, td)
        catch
        end
    elseif isa(tdci.td, AbstractTimenum)
        try
            td = convert(Timematr, td)
        catch
        end
    end
    return td
end

#######################
## iteration by rows ##
#######################

immutable TdRowIterator
    td::AbstractTimedata
end
import DataFrames.eachrow
eachrow(td::AbstractTimedata) = TdRowIterator(td)

Base.start(itr::TdRowIterator) = 1
Base.done(itr::TdRowIterator, i::Int) = i > size(itr.td, 1)
Base.next(itr::TdRowIterator, i::Int) = (itr.td[i, :], i + 1)
Base.size(itr::TdRowIterator) = (size(itr.td, 1), )
Base.length(itr::TdRowIterator) = size(itr.td, 1)
Base.getindex(itr::TdRowIterator, i::Any) = itr.td[i, :]

import Base.map
function map(f::Function, tdri::TdRowIterator)
    ret = deepcopy(tdri.td)
    for ii=1:size(tdri.td, 1)
        ret.vals[ii, :] = (f(tdri.td[ii, :])).vals
    end
    return ret
end


