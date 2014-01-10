## possible delegation operators
## f(tn) = f(tn.vals)
## f(tn, args...) = f(tn.vals, args...)
## f(tn1, tn2) = f(tn1.vals, tn2.vals)
## f(args1..., tn, args2...) = f(args1..., tn.vals, args2...)
## Never define f(x::Any, tn): this will lead to method ambiguities


#########################################
## Swappable operators preserving type ##
#########################################
## Swappable operators come with five possible calls: 
## .^(a::DataFrame,b::DataFrame)
## .^(a::DataFrame,b::Union(String,Number))
## .^(b::Union(String,Number),a::DataFrame)
## .^(a::DataFrame,b::NAtype)
## .^(b::NAtype,a::DataFrame)

## elementwise: * and / excluded -> should mean matrix multiplication
## for Timenum
const element_wise_operators = [:(+), :(.+), :(-), :(.-), :(*), :(.*),
                                     :(/), :(./), :(.^)]
const element_wise_operators_ext = [:(div), :(mod), :(fld), :(rem)]

## $(f)(td::Timedata, td2::Timedata) =
##     Timedata($(f)(td.vals, td2.vals))
macro swap_type(f, myType)
    esc(quote
        $(f)(inst::$(myType), inst2::$(myType)) =
            $(myType)($(f)(inst.vals, inst2.vals), dates(inst))

        $(f)(inst::$(myType),b::Union(String,Number)) =
            $(myType)($(f)(inst.val,b), dates(inst))
        
        $(f)(b::Union(String,Number),inst::$(myType)) =
            $(myType)($(f)(b,inst.val), dates(inst))

        $(f)(inst::$(myType),b::NAtype) =
            $(myType)($(f)(inst.val,b), dates(inst))
        
        $(f)(b::NAtype,inst::$(myType)) =
            $(myType)($(f)(b,inst.val), dates(inst))
    end)
end

swap_type_operators = [element_wise_operators,
                       element_wise_operators_ext]

importall Base

for t = (:Timedata, :Timenum, :Timematr)
    for f in swap_type_operators
        ## print(macroexpand(:(@swap_type($f, $t))))
        eval(macroexpand(:(@swap_type($f, $t))))        
        ## @eval begin
        ##     @swap_type $(f) $(t)
        ## end
    end
end

## function +(inst::Timedata,inst2::Timedata) # none, line 3:
##     Timedata(+(inst.vals,inst2.vals),dates(inst))
## end # line 6:


############################################
## no function arguments, preserving type ##
############################################

const unary_operators = [:(+), :(-)]    # [:(*), :(/)]

const mathematical_functions = [:abs, :sign,
                                :acos, :acosh, :asin, :asinh,
                                :atan, :atanh, :sin, :sinh, :cos, 
                                :cosh, :tan, :tanh, :exp, :exp2,
                                :expm1, :log, :log10, :log1p,
                                :log2, :exponent, :sqrt, :gamma,
                                :lgamma, :digamma, :erf, :erfc]

## $(f)(td::Timedata) = Timedata($(f)(td.vals, dates(td))
macro timedata_unary(f, myType)
    esc(quote
        $(f)(inst::$(myType)) =
            $(myType)($(f)(inst.vals), dates(inst))
    end)
end

unary_type_operators = [unary_operators, mathematical_functions]

for t = (:Timedata, :Timenum, :Timematr)
    for f in unary_type_operators
        ## @timedata_unary f t
        eval(macroexpand(:(@timedata_unary($f, $t))))                
    end
end

##########################################################
## Swappable operators, returning logical type Timedata ##
##########################################################

const element_wise_comparisons = [:(.==), :(.!=), :(.>), :(.>=),
                                     :(.<), :(.<=)]

const element_wise_logicals = [:(&), :(|), :($)]

macro logical_ops(f)
    esc(quote
        $(f)(inst::AbstractTimedata, inst2::AbstractTimedata) =
            Timedata($(f)(inst.vals, inst2.vals), dates(inst))

        $(f)(inst::AbstractTimedata,b::Union(String,Number)) =
            Timedata($(f)(inst.val,b), dates(inst))
        
        $(f)(b::Union(String,Number),inst::AbstractTimedata) =
            Timedata($(f)(b,inst.val), dates(inst))

        $(f)(inst::AbstractTimedata,b::NAtype) =
            Timedata($(f)(inst.val,b), dates(inst))
        
        $(f)(b::NAtype,inst::AbstractTimedata) =
            Timedata($(f)(b,inst.val), dates(inst))
    end)
end

swap_operators_timedata = [element_wise_comparisons,
                           element_wise_logicals]

for f in swap_operators_timedata
    eval(macroexpand(:(@logical_ops($f))))                    
    ## @logical_ops f
end

########################################
## varargs functions, preserving type ##
########################################

const rounding_operators = [:round, :ceil, :floor, :trunc] 

## $(f)(td::Timedata, args...) = Timedata($(f)(td.vals, args...), dates(td))
macro varargs_type(f, myType)
    esc(quote
        $(f)(inst::$(myType), args...) =
            $(myType)($(f)(inst.vals, args...), dates(inst))
    end)
end

varargs_type_functions = rounding_operators

## for t = (:Timedata, :Timenum, :Timematr)
##     for f in varargs_type_functions
##         ## @varargs_type f t
##         eval(macroexpand(:(@varargs_type($f, $t))))                        
##     end
## end

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
