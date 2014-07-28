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

import Base.get
function get(td::AbstractTimedata, idx1::Int, idx2::Int)
    ## return entry of Timedata object
    return td.vals[idx1, idx2]
end

function get(td::AbstractTimenum, idx1::Int, idx2::Int)
    ## return entry of Timenum object
    return td.vals[idx1, idx2]
end

function get(td::AbstractTimedata)
    ## return all entries of Timedata object
    return [get(td, ii, jj) for ii=1:size(td, 1), jj=1:size(td, 2)]
end

function get(td::AbstractTimenum)
    ## return all entries of Timenum object
    return float64([get(td, ii, jj) for ii=1:size(td, 1), jj=1:size(td, 2)])
end

function core(td::AbstractTimedata)
    ## return all entries of Timedata object
    return [get(td, ii, jj) for ii=1:size(td, 1), jj=1:size(td, 2)]
end

function idxtype(td::AbstractTimedata)
    return typeof(idx(td))
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

############
## flipud ##
############

import Base.flipud

macro pres_flipud(myType)
    esc(quote
        function flipud(inst::$(myType))
            ## flip data upside down

            for colName in names(inst.vals)
                inst.vals[colName] = flipud(inst.vals[colName])
            end
            dats = flipud(idx(inst))
        
            flipped = $(myType)(inst.vals, dats)
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
    ## no NAs allowed
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
    return tm
end
