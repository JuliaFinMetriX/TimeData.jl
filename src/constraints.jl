####################################
## check for dataarray with dates ##
####################################

function chkDates(dates)
    if(!isa(dates, DataArray))
        error("dates must be of type DataArray")
    end
    if(!(issubtype(eltype(dates), Date)))
        error("entries in dates must be of type Date")
    end
end

###########################################
## check for numeric values in dataframe ##
###########################################

function chkNumDf(df::DataFrame)
    n = ncol(df)
    for ii=1:n
        ## check for numeric values
        if(!issubtype(coltypes(df)[ii], Number) &
    !isequal(coltypes(df)[ii], NAtype))
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
