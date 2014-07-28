##############################
## Timedata display methods ##
##############################

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

function display(tn::AbstractTimedata, nCols::Int)
    ## display information about an array
    
    ## set display parameters
    maxDispCols = nCols;
    
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

#######################
## display in IJulia ##
#######################


### Remark: timematr has its own display function!!
import Base.writemime
function writemime(io::IO,
                        ::MIME"text/html",
                        td::AbstractTimedata)

    typ = typeof(td)

    ## set display parameters
    maxDispCols = 5;
    (nrow, ncol) = size(td)

    write(io, "<p><strong>$typ</strong></p>")
    ## write(io, "<p><strong>Dimensions</strong>: ($nrow, $ncol)</p>")
    write(io, "<p>Dimensions: <strong>($nrow, $ncol)</strong></p>")

    fromDate = td.idx[1];
    toDate = td.idx[end];
    
    ## write(io, "<p>-------------------------------------------</p>")
    ## write(io, "<p><strong>From</strong>: $fromDate,
    ## <strong>To</strong>: $toDate</p>")
    write(io, "<p>From: <strong>$fromDate</strong>, To: <strong>$toDate</strong></p>")    
    ## write(io, "<p>-------------------------------------------</p>")

    showCols = minimum([maxDispCols (ncol+1)]);

    df = convert(DataFrame, td)

    writemime(io, "text/html", df[:, 1:showCols])
end

function Base.writemime(io::IO,
                        ::MIME"text/html",
                        tm::AbstractTimematr)

    # show only rounded values
    signDigits = 3

    typ = typeof(tm)

    ## set display parameters
    maxDispCols = 8;
    (nrow, ncol) = size(tm)

    write(io, "<p><strong>$typ</strong></p>")
    ## write(io, "<p><strong>Dimensions</strong>: ($nrow, $ncol)</p>")
    write(io, "<p>Dimensions: <strong>($nrow, $ncol)</strong></p>")

    fromDate = tm.idx[1];
    toDate = tm.idx[end];
    
    ## write(io, "<p>-------------------------------------------</p>")
    ## write(io, "<p><strong>From</strong>: $fromDate,
    ## <strong>To</strong>: $toDate</p>")
    write(io, "<p>From: <strong>$fromDate</strong>, To: <strong>$toDate</strong></p>")    
    ## write(io, "<p>-------------------------------------------</p>")

    showCols = minimum([maxDispCols (ncol+1)]);

    rndVals = round(core(tm), signDigits)
    tm2 = Timematr(rndVals, names(tm), idx(tm))

    df = convert(DataFrame, tm2)

    writemime(io, "text/html", df[:, 1:showCols])
end

##################
## html display ##
##################

type HTML
   s::String
end
import Base.writemime
writemime(io::IO, ::MIME"text/html", x::HTML) = print(io, x.s)

macro table(title::String, expr::Union(Expr, Symbol))
    quote
        titleString = $title
        htmlTitleString = string("<p><strong><font color=\"blue\">",
                                 titleString,
                                 "</font></strong></p>")
        display(HTML(htmlTitleString))
        $(esc(expr))
    end
end

#########
## str ##
#########

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

