#######################################################
## type preserving symmetric operators and functions ##
#######################################################

## function headers
## f(inst::NewType, inst2::NewType)
## f(inst::NewType, b::Number)
## f(b::Number, inst::NewType)

## - mathematical operators, defined for Timenum and Timematr only
## - mathematical functions

const element_wise_operators = [:(.+), :(.-), :(.*), :(./), :(.^)]
const element_wise_operators_ext = [:(div), :(mod), :(fld), :(rem)]
const matrix_mult = [:(*), :(/)] # not implemented for Timenum yet


pres_msSymmetric_functions = [element_wise_operators,
                              matrix_mult,
                              element_wise_operators_ext]

macro pres_msSymmetric(f, myType)
    esc(quote
        $(f)(inst::$(myType), inst2::$(myType)) =
            $(myType)($(f)(core(inst), core(inst2)),
                      names(inst), idx(inst))

        $(f)(inst::$(myType),b::Number) =
            $(myType)($(f)(core(inst), b), names(inst), idx(inst)) 
        
        $(f)(b::Number,inst::$(myType)) =
            $(myType)($(f)(b,core(inst)), names(inst), idx(inst))
    end)
end


importall Base
for t = (:Timematr, :AbstractTimematr)
    for f in pres_msSymmetric_functions
        eval(macroexpand(:(@pres_msSymmetric($f, $t))))        
    end
end

macro pres_msSymmetric_Timenum(f)
    esc(quote
        function $(f)(inst::Timenum, inst2::Timenum)

            dfResult = DataFrame()
            for col in names(inst)
                dfResult[col] = $(f)(inst.vals[col], inst2.vals[col])
            end
            return Timenum(dfResult, idx(inst))
        end

        function $(f)(inst::Timenum, val::Number)
            
            dfResult = DataFrame()
            for col in names(inst)
                dfResult[col] = $(f)(inst.vals[col], val)
            end
            return Timenum(dfResult, idx(inst))
        end

        function $(f)(val::Number, inst::Timenum)
            
            dfResult = DataFrame()
            for col in names(inst)
                dfResult[col] = $(f)(val, inst.vals[col])
            end
            return Timenum(dfResult, idx(inst))
        end

    end)
end

## no matrix multiplication implemented yet for Timenum
pres_msSymmetric_functions = [element_wise_operators,
                              element_wise_operators_ext]

for f in pres_msSymmetric_functions
    eval(macroexpand(:(@pres_msSymmetric_Timenum($f))))        
end


#################################################
## type preserving functions without arguments ##
#################################################

## f(inst::NewType)
const unary_operators = [:(+), :(-)]    # [:(*), :(/)]

const mathematical_functions = [:abs, :sign,
                                :acos, :acosh, :asin, :asinh,
                                :atan, :atanh, :sin, :sinh, :cos, 
                                :cosh, :tan, :tanh, :exp, :exp2,
                                :expm1, :log, :log10, :log1p,
                                :log2, :exponent, :sqrt, :gamma,
                                :lgamma, :digamma, :erf, :erfc]

pres_msUnitary_functions = [unary_operators, mathematical_functions]

macro pres_msUnitary(f, myType)
    esc(quote
        $(f)(inst::$(myType)) =
            $(myType)($(f)(core(inst)), names(inst), idx(inst))
    end)
end

for t = (:Timematr)
    for f in pres_msUnitary_functions
        eval(macroexpand(:(@pres_msUnitary($f, $t))))                
    end
end

macro pres_msUnitary_Timenum(f)
    esc(quote
        function $(f)(inst::Timenum)

            dfResult = DataFrame()
            for col in names(inst)
                dfResult[col] = $(f)(inst.vals[col])
            end

            Timenum(dfResult, idx(inst))
        end
    end)
end

for f in pres_msUnitary_functions
    eval(macroexpand(:(@pres_msUnitary_Timenum($f))))
end

######################################################
## non-preserving symmetric functions and operators ##
######################################################

## f(inst::NewType, inst2::NewType)
## f(inst::NewType, b::Number)
## f(b::Number, inst::NewType)

const element_wise_comparisons = [:(.==), :(.!=), :(.>), :(.>=),
                                     :(.<), :(.<=)]

nonpres_msSymmetric_functions = [element_wise_comparisons]

macro nonpres_msSymmetric(f)
    esc(quote
        function $(f)(inst::AbstractTimedata, inst2::AbstractTimedata)
            if idx(inst) != idx(inst2)
                error("indices must be equal for logical comparison")
            end
            df2 = DataFrame()
            for nam in names(inst)
                df2[:nam] = $(f)(inst.vals[:nam], inst2.vals[:nam])
            end
            return Timedata(df2, idx(inst))
        end

        function $(f)(inst::AbstractTimedata,b::Union(String,Number,NAtype))
            df2 = DataFrame()
            for col in eachcol(df)
                df2[col[1]] = $(f)(col[2], b)
            end
            return Timedata(df2, idx(inst))
        end

        function $(f)(b::Union(String,Number,NAtype),inst::AbstractTimedata)
            df2 = DataFrame()
            for col in eachcol(df)
                df2[col[1]] = $(f)(col[2], b)
            end
            return Timedata(df2, idx(inst))
        end
    end)
end

macro nonpres_msSymmetric_timematr(f)
    esc(quote
        $(f)(inst::Timematr, inst2::Timematr) =
            Timedata(convert(Array{Bool, 2}, $(f)(core(inst), core(inst2))),
                     names(inst), idx(inst)) 

        $(f)(inst::Timematr, b::Union(String,Number)) =
            Timedata(convert(Array{Bool, 2}, $(f)(core(inst),b)),
                     names(inst), idx(inst)) 
        
        $(f)(b::Union(String,Number),inst::AbstractTimedata) =
            Timedata(convert(Array{Bool, 2}, $(f)(b,core(inst))),
                     names(inst), idx(inst))
    end)
end

for f in nonpres_msSymmetric_functions
    eval(macroexpand(:(@nonpres_msSymmetric($f))))
    eval(macroexpand(:(@nonpres_msSymmetric_timematr($f))))
end

#########################################################
## type preserving functions, single or extra argument ##
#########################################################

## f(td::NewType)
## f(td::NewType, i::Integer)

const rounding_operators = [:round, :ceil, :floor, :trunc]

pres_msSingle_or_extra_functions = rounding_operators

macro pres_msSingle_or_extra(f, myType)
    esc(quote
        $(f)(inst::$(myType)) =
            $(myType)($(f)(core(inst)), names(inst), idx(inst))
        $(f)(inst::$(myType), i::Integer) =
            $(myType)($(f)(core(inst), i), names(inst), idx(inst))
    end)
end

for t = (:Timematr)
    for f in pres_msSingle_or_extra_functions
        ## @varargs_type f t
        eval(macroexpand(:(@pres_msSingle_or_extra($f, $t))))
    end
end

macro pres_msSingle_or_extra_Timenum(f)
    esc(quote
        function $(f)(inst::Timenum)

            dfResult = DataFrame()
            for col in names(inst)
                dfResult[col] = $(f)(inst.vals[col])
            end
            return Timenum(dfResult, idx(inst))
        end

        function $(f)(inst::Timenum, i::Integer)

            dfResult = DataFrame()
            for col in names(inst)
                dfResult[col] = $(f)(inst.vals[col], i)
            end
            return Timenum(dfResult, idx(inst))
        end

    end)
end

for f in pres_msSingle_or_extra_functions
    eval(macroexpand(:(@pres_msSingle_or_extra_Timenum($f))))
end

######################################################
## non-preserving comparison operators for timedata ##
######################################################

const element_wise_logicals = [:(&), :(|), :($)]

macro time_data_comparison(f)
    esc(quote
        $(f)(td1::Timedata, td2::Timedata) =
            Timedata($(f)(array(td1.vals), array(td2.vals)),
                     names(td1), idx(td2))
    end)
end

for f in element_wise_logicals
    eval(macroexpand(:(@time_data_comparison($f))))
end
