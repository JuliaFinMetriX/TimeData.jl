## functions that work for all types but return output depending on
## the input type: Timematr for Timematr, Timenum for Timenum, ...

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

for t = (:Timedata, :Timenum, :Timematr)
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

for t = (:Timedata, :Timenum, :Timematr)
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

for t = (:Timedata, :Timenum, :Timematr)
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

for t = (:Timedata, :Timenum, :Timematr)
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

for t = (:Timedata, :Timenum, :Timematr)
    eval(macroexpand(:(@pres_flipud($t))))
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
    td = Timematr(resVals, names(td), idx(td))
end

