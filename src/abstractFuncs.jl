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

import Base.isequal
function isequal(tn::AbstractTimedata, tn2::AbstractTimedata)
    isequal(typeof(tn), typeof(tn2)) || return false
    isequal(tn.vals, tn2.vals) || return false
    isequal(tn.idx, tn2.idx) || return false
    return true
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
function isna(td::AbstractTimedata)
    ## elementwise test for NA
    naArr = [isna(get(td, ii, jj)) for ii=1:size(td, 1),
             jj=1:size(td, 2)] 
    return Timedata(naArr, names(td), idx(td))
end

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

##########
## hcat ##
##########

## hcat requires completely equal indices and equal types
## hcat preserves type
import Base.hcat
macro pres_hcat(myType)
    esc(quote
        function hcat(inst::$(myType), inst2::$(myType))
            ## check for equal indices
            if idx(inst) != idx(inst2)
                error("indices must coincide for hcat")
            end
            
            instNew = $(myType)(hcat(inst.vals, inst2.vals), idx(inst))
            return instNew
        end
    end)
end

for t = (:Timedata, :Timenum, :Timematr, :Timecop)
    eval(macroexpand(:(@pres_hcat($t))))
end

macro pres_hcat_varargs(myType)
    esc(quote
        function hcat(tds::$(myType)...)
            nArgs = length(tds)

            res = deepcopy(tds[1])
            for ii=2:nArgs
                res = hcat(res, tds[ii])
            end
            res
        end
    end)
end

for t = (:Timedata, :Timenum, :Timematr, :Timecop)
    eval(macroexpand(:(@pres_hcat_varargs($t))))
end

function hcat(inst1::AbstractTimedata, inst2::AbstractTimedata)
    ## not defined for different types
    error("objects must be of equal type for hcat")
end

function hcat(inst::AbstractTimedata...)
    ## not defined for different types
    error("objects must be of equal type for hcat")
end

##########
## vcat ##
##########

import Base.vcat
macro pres_vcat(myType)
    esc(quote

        function vcat(inst::$(myType), inst2::$(myType))
            ## check for equal names
            if names(inst) != names(inst2)
                error("variable names must coincide for vcat")
            end
            
            if idxtype(inst) != idxtype(inst2)
                error("time index must be of same type for vcat")
            end
    
            catVals = vcat(inst.vals, inst2.vals)
            return $(myType)(catVals, [idx(inst), idx(inst2)])
        end
    end)
end

for t = (:Timedata, :Timenum, :Timematr, :Timecop)
    eval(macroexpand(:(@pres_vcat($t))))
end

macro pres_vcat_varargs(myType)
    esc(quote
        function vcat(tds::$(myType)...)
            ## all components must have equal names
            colnames = names(tds[1])
            nTds = length(tds)

            res = deepcopy(tds[1])
            for ii=2:nTds
                res = vcat(res, tds[ii])
            end
            res
        end
    end)
end

for t = (:Timedata, :Timenum, :Timematr, :Timecop)
    eval(macroexpand(:(@pres_vcat_varargs($t))))
end

function vcat(inst1::AbstractTimedata, inst2::AbstractTimedata)
    ## not defined for different types
    error("objects must be of equal type for vcat")
end

function vcat(inst::AbstractTimedata...)
    ## not defined for different types
    error("objects must be of equal type for vcat")
end


############
## flipud ##
############

import Base.flipud

macro pres_flipud(myType)
    esc(quote
        function flipud(inst::$(myType))
            ## flip data upside down

            flippedVals = DataFrame()
            for colName in names(inst.vals)
                flippedVals[colName] = flipud(inst.vals[colName])
            end
            dats = flipud(idx(inst))
            return $(myType)(flippedVals, dats)
        end
    end)
end

for t = (:Timedata, :Timenum, :Timematr, :Timecop)
    eval(macroexpand(:(@pres_flipud($t))))
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

##########
## narm ##
##########

function narm(td::AbstractTimedata)
    ## return days without NA
    smallTd = td[complete_cases(td), :]
    return smallTd
end

function narm(tm::AbstractTimematr)
    ## no NAs allowed
    return deepcopy(tm)
end

########################
## asTd / asTm / asTn ##
########################

function isaRowVector(x::Array)
    isa(x, Matrix) & (size(x, 1) == 1 )
end

function isaRowVector(x::Any)
    error("isaRowVector only is defined for Arrays")
end


function asArrayOfEqualDimensions(arr::Array, td::AbstractTimedata)
    if !isa(arr, Vector) & !isaRowVector(arr)
        error("array must be either row or column vector for
    conversion")
    end

    (nObs, nVars) = size(td)
    nElem = length(arr)
    
    if isaRowVector(arr)
        # interpretation as row vector
        if nElem != nVars
            error("wrong dimensions: number of columns not equal")
        end
        resVals = repmat(arr, nObs, 1)
    else # column vector
        if nElem == nObs
            resVals = repmat(arr, 1, nVars)
        elseif nElem == nVars
            resVals = repmat(arr', nObs, 1)
        else
            error("wrong dimensions: array can not be converted")    
        end
    end
    resVals
end

function asArrayOfEqualDimensions(val::Any, td::AbstractTimedata)
    (nObs, nVars) = size(td)
    
    resVals = repmat([val], nObs, nVars)
    return resVals
end

function asTd(arr::Array, td::Timedata)
    resVals = asArrayOfEqualDimensions(arr, td)
    td = Timedata(resVals, names(td), idx(td))
end

function asTn(arr::Array, td::Timenum)
    resVals = asArrayOfEqualDimensions(arr, td)
    td = Timenum(resVals, names(td), idx(td))
end

function asTm(arr::Array, td::Timematr)
    resVals = asArrayOfEqualDimensions(arr, td)
    td = Timenum(resVals, names(td), idx(td))
end
