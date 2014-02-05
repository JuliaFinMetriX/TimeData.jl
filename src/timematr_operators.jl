#######################################################
## type preserving symmetric operators and functions ##
#######################################################

## function headers
## f(inst::NewType, inst2::NewType)
## f(inst::NewType, b::Number)
## f(b::Number, inst::NewType)
    
const element_wise_operators = [:(+), :(.+), :(-), :(.-), :(*), :(.*),
                                     :(/), :(./), :(.^)]
const element_wise_operators_ext = [:(div), :(mod), :(fld), :(rem)]

pres_msSymmetric_functions = [element_wise_operators,
                              element_wise_operators_ext]

macro pres_msSymmetric(f, myType)
    esc(quote
        $(f)(inst::$(myType), inst2::$(myType)) =
            $(myType)($(f)(core(inst), core(inst2)),
                      names(inst), idx(inst))

        $(f)(inst::$(myType),b::Union(String,Number)) =
            $(myType)($(f)(core(inst), b), names(inst), idx(inst)) 
        
        $(f)(b::Union(String,Number),inst::$(myType)) =
            $(myType)($(f)(b,core(inst)), names(inst), idx(inst))
    end)
end

importall Base
for t = (:Timematr, :Timecop)
    for f in pres_msSymmetric_functions
        ## print(macroexpand(:(@swap_type($f, $t))))
        eval(macroexpand(:(@pres_msSymmetric($f, $t))))        
        ## @eval begin
        ##     @swap_type $(f) $(t)
        ## end

    end
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

for t = (:Timematr, :Timecop)
    for f in pres_msUnitary_functions
        ## @timedata_unary f t
        eval(macroexpand(:(@pres_msUnitary($f, $t))))                
    end
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
        $(f)(inst::AbstractTimedata, inst2::AbstractTimedata) =
            Timedata(convert(Array{Bool, 2}, $(f)(core(inst), core(inst2))),
                     names(inst), idx(inst)) 

        $(f)(inst::AbstractTimedata,b::Union(String,Number)) =
            Timedata(convert(Array{Bool, 2}, $(f)(core(inst),b)),
                     names(inst), idx(inst)) 
        
        $(f)(b::Union(String,Number),inst::AbstractTimedata) =
            Timedata(convert(Array{Bool, 2}, $(f)(b,core(inst))),
                     names(inst), idx(inst))
    end)
end

for f in nonpres_msSymmetric_functions
    eval(macroexpand(:(@nonpres_msSymmetric($f))))                    
    ## @logical_ops f
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

for t = (:Timematr, :Timecop)
    for f in pres_msSingle_or_extra_functions
        ## @varargs_type f t
        eval(macroexpand(:(@pres_msSingle_or_extra($f, $t))))
    end
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
