#################################
## definition of TimeData type ##
#################################

## constraints:
## - DataArray, where individual entries are subtype of Date
## - dates and vals must have same number of observations
## - values must be numeric

type TimeNum
    vals::DataFrame
    dates::DataArray

    function TimeNum(vals::DataFrame, dates::DataArray)
        chkDates(dates)
        chkNumericDataFrame(vals)
        if(size(vals, 1) != length(dates))
            error("number of dates must equal number of columns of data")
        end
        return new(vals, dates)
    end
end

################################
## TimeNum outer contructors ##
################################

function TimeNum(vals::DataFrame)
    nObs = size(vals)[1]
    dates = DataArray(Date, nObs)
    td = TimeNum(vals, dates)
end

## function TimeNum(core::Array, names::Array{String, 1}, dates::DataArray{Date})

#############################
## TimeNum dislay methods ##
#############################

function str(td::TimeNum)
    ## display information about an array
    
    ## set display parameters
    maxDispRows = 5;
    maxDispCols = 5;
    
    ## get type and dimensions
    println("\ntype: TimeNum")
    print("dimensions: ")
    print(size(td.vals))
    
    ## get min and max
    ## minVal = minimum(td.vals);
    ## maxVal = maximum(td.vals);

    fromDate = td.dates[1];
    toDate = td.dates[end];
    
    println("\n\n-------------------------------------------")
    println("From: $fromDate, To: $toDate")
    println("-------------------------------------------\n")
    
    ## get first entries
    nrow = length(td.vals[:, 1]);
    ncol = length(td.vals[1, :]);

    showRows = minimum([maxDispRows nrow]);
    showCols = minimum([maxDispCols ncol]);

    Peekdates = DataFrame(dates = td.dates[1:showRows]);
    Peek = [Peekdates td.vals[1:showRows, 1:showCols]];
    display(Peek)
end

import Base.Multimedia.display
display(td::TimeNum) = str(td)

#######################
## TimeNum get mean ##
#######################

import Base.mean
function mean(td::TimeNum)
    meanVals = colwise(mean, td.vals);
    means = DataFrame(meanVals, colnames(td.vals))
end

#######################
## TimeNum getindex ##
#######################

function getindex(td::TimeNum, ind::Array{Int, 1})
    vals = getindex(td.vals, ind)
    td = TimeNum(vals, td.dates)
    return td
end

#########################
## TimeNum covariance ##
#########################

import Base.cov
function cov(td::TimeNum)
    covMatr = cov(td.vals)
    covDf = DataFrame(cov(td.vals), colnames(td.vals))
    return covDf
end

###################
## TimeNum size ##
###################

function size(td::TimeNum)
    return size(td.vals)
end
