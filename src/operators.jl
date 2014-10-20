## This file defines basic mathematical functions and operators for
## Timenum and Timemtr types. These operators and functions make sense
## only for objects that are restricted to numeric values. For type
## Timedata, they are not defined, similarly to DataFrames.
##
## Operators usually try to build on the same operator for DataArrays.
## Only where it makes sense, Timematr operators will be build on
## operators that are defined on numeric Arrays.

#######################################################
## type preserving symmetric operators and functions ##
#######################################################

## mathematical operators are defined elementwise
## 
## if two Timematr / Timenum objects are involved, indices and column
## names must coincide.
##
## elementwise operators involving two different TimeData types are
## not allowed.
## 
## function headers
## f(inst::NewType, inst2::NewType)
## f(inst::NewType, b::Number)
## f(b::Number, inst::NewType)


## type preserving: applied to Timematr, it will again return Timematr
## object 

## macro is parametrized with respect to type, because this way
## Timematr implementations involving core() can easily be re-defined
## and related to DataArray operators as well
## 
## if time indices do not coincide, time indices will be inferred from
## the first TimeData instance involved in the operation!
macro pres_symmetric_timenum(f, myType)
    esc(quote
        function $(f)(inst::$(myType), inst2::$(myType))
            if !similarMeta(inst, inst2)
                error("Timematr variables not similar")
            end
            
            dfResult = DataFrame()
            for col in names(inst)
                dfResult[col] = $(f)(inst.vals[col], inst2.vals[col])
            end
            return $(myType)(dfResult, idx(inst))
        end

        function $(f)(inst::$(myType), val::Number)
            
            dfResult = DataFrame()
            for col in names(inst)
                dfResult[col] = $(f)(inst.vals[col], val)
            end
            return $(myType)(dfResult, idx(inst))
        end

        function $(f)(val::Number, inst::$(myType))
            
            dfResult = DataFrame()
            for col in names(inst)
                dfResult[col] = $(f)(val, inst.vals[col])
            end
            return $(myType)(dfResult, idx(inst))
        end

    end)
end

macro pres_symmetric_timematr(f)
    ## can be related to Array operators through core function
    esc(quote
        ## tm1 .+ tm2
        function $(f)(inst::Timematr, inst2::Timematr)
            if !similarMeta(inst, inst2)
                error("Timematr variables not similar")
            end
            return Timematr($(f)(core(inst), core(inst2)),
                            names(inst), idx(inst))
        end

        ## tm .+ 3
        function $(f)(inst::Timematr,b::Number)
            return Timematr($(f)(core(inst), b), names(inst),
                            idx(inst))
        end

        ## 3 .+ tm
        function $(f)(b::Number,inst::Timematr)
            return Timematr($(f)(b,core(inst)), names(inst),
                            idx(inst))
        end
    end)
end

importall Base
t = :Timenum
for f in [:(.+), :(.-), :(.*), :(./), :(.^)]
    eval(macroexpand(:(@pres_symmetric_timematr($f))))
    eval(macroexpand(:(@pres_symmetric_timenum($f, $t))))
end

## other function with two numbers as input
for f in [:(div), :(mod), :(fld), :(rem)]
    eval(macroexpand(:(@pres_symmetric_timematr($f))))
    eval(macroexpand(:(@pres_symmetric_timenum($f, $t))))
end

## only implemented for Timematr
const matrix_mult = [:(*), :(/)]
for f in matrix_mult
    eval(macroexpand(:(@pres_symmetric_timematr($f))))
end


#################################################
## type preserving functions without arguments ##
#################################################

## f(inst::NewType)
const unary_operators = [:(+), :(-)]    # [:(*), :(/)]
const mathematical_functions = [:abs, :sign,
                                ## :acos, :acosh, :asin, :asinh,
                                ## :atan, :atanh, :sin, :sinh, :cos, 
                                ## :cosh, :tan, :tanh,
                                ## :exp2, :expm1, :log10, :log1p,
                                ## :log2, :exponent,
                                ## :lgamma, :digamma, :erf, :erfc,
                                :exp, :log, :sqrt, :gamma
                                ]

pres_msUnitary_functions = [unary_operators, mathematical_functions]

macro pres_msUnitary_timenum(f, myType)
    esc(quote
        function $(f)(inst::$(myType))

            dfResult = DataFrame()
            for col in names(inst)
                dfResult[col] = $(f)(inst.vals[col])
            end

            $(myType)(dfResult, idx(inst))
        end
    end)
end

macro pres_msUnitary_timematr(f)
    esc(quote
        $(f)(inst::Timematr) =
            Timematr($(f)(core(inst)), names(inst), idx(inst))
    end)
end

t = :Timenum
for f in pres_msUnitary_functions
    eval(macroexpand(:(@pres_msUnitary_timematr($f))))
    eval(macroexpand(:(@pres_msUnitary_timenum($f, $t))))
end

function !(td::Timedata)
    ## negate boolean values
    df = DataFrame()
    for (nam, col) in eachcol(td.vals)
        df[nam] = !col
    end
    return Timedata(df, td.idx)
end

######################################################
## non-preserving symmetric functions and operators ##
######################################################

## f(inst::NewType, inst2::NewType)
## f(inst::NewType, b::Number)
## f(b::Number, inst::NewType)

## for timedata and timenum objects apply function to DataArrays
macro nonpres_msSymmetric_timedata(f)
    esc(quote
        function $(f)(inst::AbstractTimedata, inst2::AbstractTimedata)
            if !equMeta(inst, inst2)
                error("TimeData objects not similar")
            end

            df2 = DataFrame()
            for nam in names(inst)
                df2[nam] = $(f)(inst.vals[nam], inst2.vals[nam])
            end
            return Timedata(df2, idx(inst))
        end

        function $(f)(inst::AbstractTimedata,b::Union(String,Number))
            df2 = DataFrame()
            for col in eachcol(inst.vals)
                df2[col[1]] = $(f)(col[2], b)
            end
            return Timedata(df2, idx(inst))
        end

        function $(f)(b::Union(String,Number),inst::AbstractTimedata)
            df2 = DataFrame()
            for col in eachcol(inst.vals)
                df2[col[1]] = $(f)(col[2], b)
            end
            return Timedata(df2, idx(inst))
        end
    end)
end

## for timematr objects apply function to Array
## for comparison, only Numbers need to be considered
macro nonpres_msSymmetric_timematr(f)
    esc(quote
        function $(f)(inst::Timematr, inst2::Timematr)
            if !equMeta(inst, inst2)
                error("Timematr objects not similar")
            end

            return Timedata(convert(Array{Bool, 2}, $(f)(core(inst), core(inst2))),
                            names(inst), idx(inst))
        end

        function $(f)(inst::Timematr, b::Number)
            return Timedata(convert(Array{Bool, 2}, $(f)(core(inst),b)),
                            names(inst), idx(inst))
        end
        
        function $(f)(b::Union(String,Number),inst::Timematr)
            return Timedata(convert(Array{Bool, 2}, $(f)(b,core(inst))),
                            names(inst), idx(inst))
        end
    end)
end

for f in [:(.==), :(.!=), :(.>), :(.>=), :(.<), :(.<=)]
    eval(macroexpand(:(@nonpres_msSymmetric_timematr($f))))
    eval(macroexpand(:(@nonpres_msSymmetric_timedata($f))))
end

#########################################################
## type preserving functions, single or extra argument ##
#########################################################

## f(td::NewType)
## f(td::NewType, i::Integer)

macro pres_msSingle_or_extra_timematr(f)
    esc(quote
        $(f)(inst::Timematr) =
            Timematr($(f)(core(inst)), names(inst), idx(inst))
        $(f)(inst::Timematr, i::Integer) =
            Timematr($(f)(core(inst), i), names(inst), idx(inst))
    end)
end

macro pres_msSingle_or_extra_timenum(f, myType)
    esc(quote
        function $(f)(inst::$(myType))
            dfResult = DataFrame()
            for col in names(inst)
                dfResult[col] = $(f)(inst.vals[col])
            end
            return $(myType)(dfResult, idx(inst))
        end

        function $(f)(inst::Timenum, i::Integer)
            dfResult = DataFrame()
            for col in names(inst)
                dfResult[col] = $(f)(inst.vals[col], i)
            end
            return $(myType)(dfResult, idx(inst))
        end
    end)
end

t = :Timenum
for f in [:round, :ceil, :floor, :trunc]
    eval(macroexpand(:(@pres_msSingle_or_extra_timematr($f))))
    eval(macroexpand(:(@pres_msSingle_or_extra_timenum($f, $t))))
end


######################################################
## non-preserving comparison operators for timedata ##
######################################################

macro time_data_comparison(f)
    esc(quote
        function $(f)(td1::Timedata, td2::Timedata)
            if !equMeta(td1, td2)
                error("Timedata objects not similar")
            end

            dfResult = DataFrame()
            for col in names(td1)
                dfResult[col] = $(f)(td1.vals[col], td2.vals[col])
            end
            return Timedata(dfResult, idx(td1))
        end
    end)
end

for f in [:(&), :(|), :($)]
    eval(macroexpand(:(@time_data_comparison($f))))
end
