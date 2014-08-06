## functions that work for AbstractTimedata types and return the same
## output for all types (Timematr, Timenum,...)

####################################
## Timedata information retrieval ##
####################################

function idx(tn::AbstractTimedata)
    return tn.idx
end

import DataFrames.names
function names(tn::AbstractTimedata)
    return names(tn.vals)
end

function core(td::AbstractTimedata)
    ## return all entries of Timedata object
    return get(td)
end

function idxtype(td::AbstractTimedata)
    return typeof(idx(td))
end

#########
## get ##
#########

import Base.get
function get(td::AbstractTimedata, idx1::Int, idx2::Int)
    ## return entry of Timedata object
    return td.vals[idx1, idx2]
end

function get(td::AbstractTimedata)
    ## return all entries of Timedata object
    return [get(td, ii, jj) for ii=1:size(td, 1), jj=1:size(td, 2)]
end

###################
## Timedata size ##
###################

import Base.size
function size(tn::AbstractTimedata)
    return size(tn.vals)
end

function size(tn::AbstractTimedata, ind::Int)
    return size(tn.vals, ind)
end

import Base.ndims
function ndims(tn::AbstractTimedata)
    return ndims(tn.vals)
end

######################
## isequal function ##
######################

## isequal(NA, NA) -> true
import Base.isequal
function isequal(tn::AbstractTimedata, tn2::AbstractTimedata)
    ## return single true or false
    isequal(typeof(tn), typeof(tn2)) || return false
    isequal(tn.vals, tn2.vals) || return false
    isequal(tn.idx, tn2.idx) || return false
    return true
end

## NA == NA -> NA
import Base.==
function ==(tn::AbstractTimedata, tn2::AbstractTimedata)
    ## return single true or false
    isequal(typeof(tn), typeof(tn2)) || return false
    isequal(tn.idx, tn2.idx) || return false
    return ==(tn.vals, tn2.vals)
end

function isequalElemwise(tn::AbstractTimedata, tn2::AbstractTimedata)
    ## return matrix with true / false elements
    if !issimilar(tn, tn2)
        error("Timedata object must be similar for elementwise
isequal") 
    end
    (nObs, nVars) = size(tn)
    vals = Bool[isequal(tn.vals[ii, jj], tn2.vals[ii, jj]) for
        ii=1:nObs, 
        jj=1:nVars] 
    return Timedata(vals, names(tn), idx(tn))
end

##########
## isna ##
##########

import DataFrames.isna
function isna(td::AbstractTimedata)
    ## elementwise test for NA
    naArr = [isna(get(td, ii, jj)) for ii=1:size(td, 1),
             jj=1:size(td, 2)] 
    return Timedata(naArr, names(td), idx(td))
end


####################
## complete_cases ##
####################

import DataFrames.complete_cases
function complete_cases(td::AbstractTimedata)
    ## find days without NA
    return complete_cases(td.vals)
end

function complete_cases(tm::AbstractTimematr)
    ## no NAs allowed anyways
    return bool(ones(size(tm, 1)))
end

#####################
## equal structure ##
#####################

function issimilar(td1::AbstractTimedata, td2::AbstractTimedata)
    isequal(typeof(td1), typeof(td2)) || return false
    isequal(names(td1), names(td2)) || return false
    isequal(td1.idx, td2.idx) || return false
end

function hasSimilarColumns(td1::AbstractTimedata, td2::AbstractTimedata)
    isequal(super(typeof(td1)), super(typeof(td2))) || return false
    isequal(names(td1), names(td2)) || return false
end
    
    
