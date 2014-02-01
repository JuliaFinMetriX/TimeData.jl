####################################
## check for dataarray with dates ##
####################################

function chkDates(dates)
    if !isa(dates, Array)
        error("time index must be given as array")
    end
    if !issubtype(typeof(dates[1]), Union(Integer, Date, DateTime))
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
        if(!issubtype(types(df)[ii], Number) &
    !isequal(types(df)[ii], NAtype))
            error("all columns must be numeric for conversion")
        end
        if(issubtype(types(df)[ii], Bool))
            error("all columns must be numeric for conversion")
        end
    end
end

############################################
## check for numeric values only - no NAs ##
############################################

function chkNum(df::DataFrame)
    if any(isna(df))
        error("no NAs allowed in TimeMatr")
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
