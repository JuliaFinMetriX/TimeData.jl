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
        if(!issubtype(coltypes(df)[ii], Number))
            error("all columns must be numeric for conversion")
        end
    end
end
