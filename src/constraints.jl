####################################
## check for dataarray with idx ##
####################################

function chkIdx(idx)
    ## check for Array and entry type
    ## Array is already checked through Timedata definition itself
    if !isa(idx, Array)
        throw(TypeError(:chkIdx,
                        "passed time index: must be given as array\n",
                        Array,
                        typeof(idx)))
    end
    if !issubtype(eltype(idx), Union(Integer, Float64, Date, DateTime))
        throw(TypeError(:chkIdx,
                        "passed time index: entries must be either
Integer, Float64 or TimeType\n",
                        Union(Integer, Date, DateTime),
                        eltype(idx)))
    end
end

###########################################
## check for numeric values in dataframe ##
###########################################

function isNumericType(typ::Type)
    # numeric and NAtype allowed, boolean not
    valid = (issubtype(typ, Union(Number, NAtype))) &
               (!issubtype(typ, Bool))
    return valid
end

function chkNumDf(df::DataFrame)
    ## check for numeric values or NAs
    
    n = ncol(df)
    errMsg = "all columns must be numeric for conversion"
    typs = eltypes(df)
    for ii=1:n
        ## check for numeric values
        if !isNumericType(typs[ii])
            throw(ArgumentError(errMsg))
        end
    end
end

############################################
## check for numeric values only - no NAs ##
############################################

function chkNum(df::DataFrame)
    ## check for numeric values, no NAs allowed
    
    for ii=1:size(df, 2)
        if any(isna(df[ii]))
            throw(ArgumentError("no NAs allowed in Timematr"))
        end
    end
    chkNumDf(df)
end

###########################################
## check for values within unit interval ##
###########################################

function chkUnit(df::DataFrame)
    vals = convert(Array, df)
    if (any(vals .< 0) | any(vals .> 1))
        throw(ArgumentError("values must be inside of unit interval"))
    end
end
