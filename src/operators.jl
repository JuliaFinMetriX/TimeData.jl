#######################################################
## type preserving symmetric operators and functions ##
#######################################################

## type preserving symmetric operations and functions
##
## f(b::NAtype, inst::NewType) = NewType(f(b, inst.vals), dates(inst)) 
## f(inst::NewType, b::NAtype) = NewType(f(inst.vals, b), dates(inst))
## f(inst::NewType, inst2::NewType) = NewType(f(inst1.vals, inst2.vals), dates(inst))
## f(inst::NewType, b::Union(String,Number)) = NewType(f(inst.vals, b), dates(inst))
## f(b::Union(String,Number), inst::NewType) = NewType(f(b, inst.vals), dates(inst))
macro pres_msSymmetric(f, myType)
    esc(quote
        $(f)(inst::$(myType),b::NAtype) =
            $(myType)($(f)(inst.val,b), dates(inst))
        
        $(f)(b::NAtype,inst::$(myType)) =
            $(myType)($(f)(b,inst.val), dates(inst))

        $(f)(inst::$(myType), inst2::$(myType)) =
            $(myType)($(f)(inst.vals, inst2.vals), dates(inst))

        $(f)(inst::$(myType),b::Union(String,Number)) =
            $(myType)($(f)(inst.val,b), dates(inst))
        
        $(f)(b::Union(String,Number),inst::$(myType)) =
            $(myType)($(f)(b,inst.val), dates(inst))
    end)
end

## elementwise: * and / excluded -> should mean matrix multiplication
## for Timenum
const element_wise_operators = [:(+), :(.+), :(-), :(.-), :(*), :(.*),
                                     :(/), :(./), :(.^)]
const element_wise_operators_ext = [:(div), :(mod), :(fld), :(rem)]

pres_msSymmetric_functions = [element_wise_operators,
                              element_wise_operators_ext]

importall Base
for t = (:Timedata, :Timenum, :Timematr)
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

## type preserving functions with method signature:
## f(inst::NewType) = NewType(f(inst.vals), dates(inst))
macro pres_msUnitary(f, myType)
    esc(quote
        $(f)(inst::$(myType)) =
            $(myType)($(f)(inst.vals), dates(inst))
    end)
end


const unary_operators = [:(+), :(-)]    # [:(*), :(/)]

const mathematical_functions = [:abs, :sign,
                                :acos, :acosh, :asin, :asinh,
                                :atan, :atanh, :sin, :sinh, :cos, 
                                :cosh, :tan, :tanh, :exp, :exp2,
                                :expm1, :log, :log10, :log1p,
                                :log2, :exponent, :sqrt, :gamma,
                                :lgamma, :digamma, :erf, :erfc]

pres_msUnitary_functions = [unary_operators, mathematical_functions]




for t = (:Timedata, :Timenum, :Timematr)
    for f in unary_type_operators
        ## @timedata_unary f t
        eval(macroexpand(:(@pres_msUnitary($f, $t))))                
    end
end

######################################################
## non-preserving symmetric functions and operators ##
######################################################

## symmetric operators and functions with method signatures: 
## f(b::NAtype, inst::NewType) = NewType(f(b, inst.vals), dates(inst))
## f(inst::NewType, b::NAtype) = NewType(f(inst.vals, b), dates(inst))
## f(inst::NewType, inst2::NewType) = NewType(f(inst.vals, inst2.vals), dates(inst))
## f(inst::NewType, b::Union(String,Number)) = NewType(f(inst.vals, b), dates(inst))
## f(b::Union(String,Number), inst::NewType) = NewType(f(b, inst.vals), dates(inst))
macro nonpres_msSymmetric(f)
    esc(quote
        $(f)(b::NAtype,inst::AbstractTimedata) =
            Timedata($(f)(b,inst.val), dates(inst))

        $(f)(inst::AbstractTimedata,b::NAtype) =
            Timedata($(f)(inst.val,b), dates(inst))
        
        $(f)(inst::AbstractTimedata, inst2::AbstractTimedata) =
            Timedata($(f)(inst.vals, inst2.vals), dates(inst))

        $(f)(inst::AbstractTimedata,b::Union(String,Number)) =
            Timedata($(f)(inst.val,b), dates(inst))
        
        $(f)(b::Union(String,Number),inst::AbstractTimedata) =
            Timedata($(f)(b,inst.val), dates(inst))
    end)
end

const element_wise_comparisons = [:(.==), :(.!=), :(.>), :(.>=),
                                     :(.<), :(.<=)]

const element_wise_logicals = [:(&), :(|), :($)]

nonpres_msSymmetric_functions = [element_wise_comparisons,
                           element_wise_logicals]



for f in nonpres_msSymmetric_functions
    eval(macroexpand(:(@nonpres_msSymmetric($f))))                    
    ## @logical_ops f
end

#########################################################
## type preserving functions, single or extra argument ##
#########################################################

## symmetric operators and functions with method signatures:
## f(td::NewType) = NewType(f(td.vals), dates(td))
## f(td::NewType, i::Integer) = NewType(f(td.vals, i), dates(td))
macro pres_msSingle_or_extra(f, myType)
    esc(quote
        $(f)(inst::$(myType), args...) =
            $(myType)($(f)(inst.vals, args...), dates(inst))
    end)
end

const rounding_operators = [:round, :ceil, :floor, :trunc]

pres_msSingle_or_extra_functions = rounding_operators

for t = (:Timedata, :Timenum, :Timematr)
    for f in pres_msSingle_or_extra_functions
        ## @varargs_type f t
        eval(macroexpand(:(@pres_msSingle_or_extra($f, $t))))
    end
end

###########################
## statistical functions ##
###########################

## some need additional input for dimension
## const stat_functions = [:(mean), :(cov)]
## const unary_vector_operators = [:minimum, :maximum, :prod, :sum, :mean, :median, :std,
##                                 :var, :mad, :norm, :skewness, :kurtosis]
## const pairwise_vector_operators = [:diff, :reldiff]#, :percent_change]
## const cumulative_vector_operators = [:cumprod, :cumsum, :cumsum_kbn, :cummin, :cummax]
## const rowwise_operators = [:rowmins, :rowmaxs, :rowprods, :rowsums,
##                            :rowmeans, :rowmedians, :rowstds, :rowvars,
##                            :rowffts, :rownorms]
## const columnar_operators = [:colmins, :colmaxs, :colprods, :colsums,
##                             :colmeans, :colmedians, :colstds, :colvars,
##                             :colffts, :colnorms]
## const boolean_operators = [:any, :all]


## still missing:
## assign, ref, sub, copy, %, merge, flipud, delete!, deepcopy, similar, empty!
