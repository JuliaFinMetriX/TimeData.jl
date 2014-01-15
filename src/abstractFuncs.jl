##############################
## Timedata display methods ##
##############################

function str(tn::AbstractTimedata)
    ## display information about an array
    
    ## set display parameters
    maxDispRows = Inf;
    maxDispCols = 5;
    
    ## get type and field information
    typ = typeof(tn)
    println("\ntype: $typ")    
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
function display(tn::AbstractTimedata)
    ## display information about an array
    
    ## set display parameters
    maxDispRows = Inf;
    maxDispCols = 5;
    
    ## get type and field information
    typ = typeof(tn)
    println("\ntype: $typ")    
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
## Timedata information retrieval ##
####################################

function dates(tn::AbstractTimedata)
    return tn.dates
end

import DataFrames.colnames
function colnames(tn::AbstractTimedata)
    return colnames(tn.vals)
end

###################
## Timedata size ##
###################

import Base.size
function size(tn::AbstractTimedata)
    return size(tn.vals)
end

function size(tn::AbstractTimedata, ind::Int)
    return size(tn.vals, ind)
end

import Base.ndims
function ndims(tn::AbstractTimedata)
    return ndims(tn.vals)
end

######################
## isequal function ##
######################

import Base.isequal
function isequal(tn::AbstractTimedata, tn2::AbstractTimedata)
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
function isna(tn::AbstractTimedata)
    return Timedata(isna(tn.vals), dates(tn))
end
