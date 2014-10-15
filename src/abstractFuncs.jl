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
    ## in order to force output other than Array{Any}, use getAs
    return get(td)
end

function core(td::AbstractTimematr)
    ## return Float64
    return convert(Array{Float64}, array(td.vals))
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

###############
## floatcore ##
###############

function getAs(tn::AbstractTimedata, typ::Type=Any,
               replaceNA=NA)
    ## get data values only as Array
    ## in order to get something different than Array{Any}, determine
    ## type of array and replace NA values accordingly
    nObs, nAss = size(tn)
    vals = Array(typ, nObs, nAss)
    for ii=1:nAss
        if isa(tn.vals.columns[ii], DataArray)
            vals[:, ii] = tn.vals.columns[ii].data
            vals[tn.vals.columns[ii].na, ii] = replaceNA
        else
            vals[:, ii] = tn.vals.columns[ii]
        end
    end
    return vals    
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

import Base.(.==)
function .==(tn, tn2)
    if !equMeta(tn, tn2)
        error("Timedata object must be similar for elementwise
isequal")
    end
    (nObs, nVars) = size(tn)
    df = DataFrame()
    for (nam, col) in eachcol(tn)
        df[nam] = tn.vals[nam] .== tn2.vals[nam]
    end
    return Timedata(df, idx(tn))
end


function isequalElw(tn::AbstractTimedata, tn2::AbstractTimedata)
    ## return matrix with true / false elements
    if !equMeta(tn, tn2)
        error("Timedata object must be similar for elementwise
isequal") 
    end
    (nObs, nVars) = size(tn)
    vals = Bool[isequal(tn.vals[ii, jj], tn2.vals[ii, jj]) for
        ii=1:nObs, 
        jj=1:nVars] 
    return Timedata(vals, names(tn), idx(tn))
end

## isequal(NA, NA) -> true
import Base.isapprox
function isapprox(tn::AbstractTimedata, tn2::AbstractTimedata)
    ## return single true or false
    isequal(typeof(tn), typeof(tn2)) || return false

    (nObs, nVars) = size(tn)
    for ii=1:nObs
        for jj=1:nVars
            if !isequal(get(tn, ii, jj), get(tn2, ii, jj))
                if !isapprox(get(tn, ii, jj), get(tn2, ii, jj))
                    return false
                end
            end
        end
    end
    isequal(tn.idx, tn2.idx) || return false
    return true
end

##########
## isna ##
##########

function isnaElw(td::AbstractTimedata)
    ## elementwise test for NA
    df = DataFrame()
    for (nam, col) in eachcol(td.vals)
        df[nam] = [isna(col)...]
    end
    return Timedata(df, idx(td))
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

function equMeta(td1::AbstractTimedata, td2::AbstractTimedata)
    isequal(typeof(td1), typeof(td2)) || return false
    isequal(names(td1), names(td2)) || return false
    isequal(td1.idx, td2.idx) || return false
end

function equColMeta(td1::AbstractTimedata, td2::AbstractTimedata)
    isequal(super(typeof(td1)), super(typeof(td2))) || return false
    isequal(names(td1), names(td2)) || return false
end
    
    
