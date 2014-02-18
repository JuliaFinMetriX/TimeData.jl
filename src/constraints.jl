####################################
## check for dataarray with idx ##
####################################

function chkIdx(idx)
    if !isa(idx, Array)
        error("time index must be given as array")
    end
    if !issubtype(eltype(idx), Union(Integer, Date, DateTime))
        error("time index must be either Integer or TimeType")
    end
end

###########################################
## check for numeric values in dataframe ##
###########################################

function chkNumDf(df::DataFrame)
    n = ncol(df)
    for ii=1:n
        ## check for numeric values
        if(!issubtype(eltypes(df)[ii], Number) &
    !isequal(eltypes(df)[ii], NAtype))
            error("all columns must be numeric for conversion")
        end
        if(issubtype(eltypes(df)[ii], Bool))
            error("all columns must be numeric for conversion")
        end
    end
end

############################################
## check for numeric values only - no NAs ##
############################################

function chkNum(df::DataFrame)
    for ii=1:size(df, 2)
        if any(isna(df[ii]))
            error("no NAs allowed in TimeMatr")
        end
    end
    chkNumDf(df)
end

###########################################
## check for values within unit interval ##
###########################################

function chkUnit(df::DataFrame)
    vals = array(df)
    if (any(vals .< 0) | any(vals .> 1))
        error("values must be inside of unit interval")
    end
end
