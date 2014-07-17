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

import Base.isequal
function isequal(tn::AbstractTimedata, tn2::AbstractTimedata)
    typeEqu = isequal(typeof(tn), typeof(tn2))
    valsEqu = isequal(tn.vals, tn2.vals)
    idxEqu = isequal(tn.idx, tn2.idx)
    equ = (valsEqu & idxEqu & typeEqu)
    return equ
end

import Base.==
function ==(tn::AbstractTimedata, tn2::AbstractTimedata)
    typeEqu = ==(typeof(tn), typeof(tn2))
    valsEqu = ==(tn.vals, tn2.vals)
    idxEqu = ==(tn.idx, tn2.idx)
    equ = (valsEqu & idxEqu & typeEqu)
    return equ
end

##########
## isna ##
##########

import DataFrames.isna
function isna(tn::AbstractTimedata)
    return Timedata(isna(tn.vals), idx(tn))
end

##########
## hcat ##
##########

import Base.hcat
function hcat(tm::Timematr, tm2::Timematr)
    ## check for equal indices
    if idx(tm) != idx(tm2)
        error("indices must coincide for hcat")
    end

    tmNew = Timematr(hcat(tm.vals, tm2.vals), idx(tm))
    return tmNew
end

function hcat(tm::Timedata, tm2::Timedata)
    ## check for equal indices
    if idx(tm) != idx(tm2)
        error("indices must coincide for hcat")
    end

    tmNew = Timedata(hcat(tm.vals, tm2.vals), idx(tm))
    return tmNew
end


