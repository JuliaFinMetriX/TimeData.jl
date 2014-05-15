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
    nms = ["vals", "idx"]
    ## types = DataType[]
    for fieldname in nms
        tp = fieldtype(tn, symbol(fieldname))
        ## push!(types, fieldtype(tn, fieldname))
        println(":$fieldname  \t\t  $tp")
    end

    print("\ndimensions of vals: ")
    print(size(tn))

    
    ## get min and max
    ## minVal = minimum(tn.vals);
    ## maxVal = maximum(tn.vals);

    fromDate = tn.idx[1];
    toDate = tn.idx[end];
    
    println("\n\n-------------------------------------------")
    println("From: $fromDate, To: $toDate")
    println("-------------------------------------------\n")

    ## get first entries
    (nrow, ncol) = size(tn)    

    showCols = minimum([maxDispCols ncol]);

    Peekidx = DataFrame(idx = tn.idx);
    Peek = [Peekidx tn.vals[:, 1:showCols]];
    display(Peek)
end

import Base.Multimedia.display
function display(tn::AbstractTimedata)
    ## display information about an array
    
    ## set display parameters
    maxDispCols = 5;
    
    ## get type and field information
    typ = typeof(tn)
    println("\ntype: $typ")    
    print("dimensions: ")
    print(size(tn))
    print("\n")
    
    ## get first entries
    (nrow, ncol) = size(tn)    

    showCols = minimum([maxDispCols ncol]);

    Peekidx = DataFrame(idx = tn.idx);
    Peek = [Peekidx tn.vals[:, 1:showCols]];
    display(Peek)
end

####################################
## Timedata information retrieval ##
####################################

function idx(tn::AbstractTimedata)
    return tn.idx
end

import DataFrames.names
function names(tn::AbstractTimedata)
    return names(tn.vals)
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
    idxEqu = isequal(tn.idx, tn2.idx)
    equ = (valsEqu & idxEqu & typeEqu)
    return equ
end

import Base.==
function ==(tn::AbstractTimedata, tn2::AbstractTimedata)
    typeEqu = ==(typeof(tn), typeof(tn2))
    valsEqu = ==(tn.vals, tn2.vals)
    idxEqu = ==(tn.idx, tn2.idx)
    equ = (valsEqu & idxEqu & typeEqu)
    return equ
end

##########
## isna ##
##########

import DataFrames.isna
function isna(tn::AbstractTimedata)
    return Timedata(isna(tn.vals), idx(tn))
end

##########
## hcat ##
##########

import Base.hcat
function hcat(tm::Timematr, tm2::Timematr)
    ## check for equal indices
    if idx(tm) != idx(tm2)
        error("indices must coincide for hcat")
    end

    tmNew = Timematr(hcat(tm.vals, tm2.vals), idx(tm))
    return tmNew
end

function hcat(tm::Timedata, tm2::Timedata)
    ## check for equal indices
    if idx(tm) != idx(tm2)
        error("indices must coincide for hcat")
    end

    tmNew = Timedata(hcat(tm.vals, tm2.vals), idx(tm))
    return tmNew
end

########################
## DataFrame handling ##
########################

function composeDataFrame(vals, nams)
    ## compose DataFrame from data and column names
    ##
    ## Input:
    ## 	vals 		Array{Float64,2} of values
    ## 	nams		column names as Array{Symbol,1} as returned by
    ## 				names(df) 
    ## 
    ## Output:
    ## 	DataFrame with values given by vals and column names given by
    ## 	nams 

    if size(vals, 2) != length(nams)
        error("to compose DataFrame, number of columns and number of
names must match")
    end
    
    df = convert(DataFrame, vals)
    rename!(df, names(df), nams)

    return df
end

