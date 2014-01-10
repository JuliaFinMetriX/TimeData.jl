##############################
## TimeData display methods ##
##############################

function str(tn::AbstractTimeData)
    ## display information about an array
    
    ## set display parameters
    maxDispRows = 5;
    maxDispCols = 5;
    
    ## get type and field information
    ## TODO: print subtype
    println("\ntype: TimeData")    
    nms = names(tn)
    ## types = DataType[]
    for fieldname in nms
        tp = fieldtype(tn, fieldname)
        ## push!(types, fieldtype(tn, fieldname))
        println(":$fieldname  \t\t  $tp")
    end

    print("\ndimensions: ")
    print(size(tn.vals))

    
    ## get min and max
    ## minVal = minimum(tn.vals);
    ## maxVal = maximum(tn.vals);

    fromDate = tn.dates[1];
    toDate = tn.dates[end];
    
    println("\n\n-------------------------------------------")
    println("From: $fromDate, To: $toDate")
    println("-------------------------------------------\n")
    
    ## get first entries
    nrow = length(tn.vals[:, 1]);
    ncol = length(tn.vals[1, :]);

    showRows = minimum([maxDispRows nrow]);
    showCols = minimum([maxDispCols ncol]);

    Peekdates = DataFrame(dates = tn.dates[1:showRows]);
    Peek = [Peekdates tn.vals[1:showRows, 1:showCols]];
    display(Peek)
end

import Base.Multimedia.display
function display(tn::AbstractTimeData)
    ## display information about an array
    
    ## set display parameters
    maxDispRows = 5;
    maxDispCols = 5;
    
    ## get type and field information
    println("\ntype: TimeData")
    print("dimensions: ")
    print(size(tn.vals))
    print("\n")
    
    ## get first entries
    nrow = length(tn.vals[:, 1]);
    ncol = length(tn.vals[1, :]);

    showRows = minimum([maxDispRows nrow]);
    showCols = minimum([maxDispCols ncol]);

    Peekdates = DataFrame(dates = tn.dates[1:showRows]);
    Peek = [Peekdates tn.vals[1:showRows, 1:showCols]];
    display(Peek)
end

####################################
## TimeData information retrieval ##
####################################

function dates(tn::AbstractTimeData)
    return tn.dates
end

function vars(tn::AbstractTimeData)
    return colnames(tn.vals)
end

import DataFrames.colnames
function colnames(tn::AbstractTimeData)
    return colnames(tn.vals)
end

###################
## TimeData size ##
###################

import Base.size
function size(tn::AbstractTimeData)
    return size(tn.vals)
end

function size(tn::AbstractTimeData, ind::Int)
    return size(tn.vals, ind)
end

import Base.ndims
function ndims(tn::AbstractTimeData)
    return ndims(tn.vals)
end

######################
## isequal function ##
######################

import Base.isequal
function isequal(tn::AbstractTimeData, tn2::AbstractTimeData)
    typeEqu = isequal(typeof(tn), typeof(tn2))
    valsEqu = isequal(tn.vals, tn2.vals)
    datesEqu = isequal(tn.dates, tn2.dates)
    equ = (valsEqu & datesEqu & typeEqu)
    ## check for equal type
    return equ
end

##########
## isna ##
##########

import DataFrames.isna
function isna(tn::AbstractTimeData)
    Timedata(isna(tn.vals), dates(tn))
    return isna(tn.vals)
end
