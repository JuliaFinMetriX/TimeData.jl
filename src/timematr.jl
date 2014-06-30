type Timematr{T} <: AbstractTimematr
    vals::DataFrame
    idx::Array{T, 1}

    function Timematr(vals::DataFrame, idx::Array{T, 1})
        chkIdx(idx)
        chkNum(vals)
        if(size(vals, 1) != length(idx))
            if (length(idx) == 0) | (size(vals, 1) == 0)
                df = convert(DataFrame, rand(2, 2))
                return new(df[1:2, []], Array{T, 1}[])
            end
            error(length(idx), " idx entries, but ", size(vals, 1), " rows of data")
        end
        return new(vals, idx)
    end
end

function Timematr{T}(vals::DataFrame, idx::Array{T, 1})
    return Timematr{T}(vals, idx)
end

    
#################
## Conversions ##
#################

## ## conversion upwards: always works
## function convert(::Type{Timedata}, tm::Timematr)
##     Timedata(tm.vals, tm.idx)
## end

## ## conversion upwards: always works
## function convert(::Type{Timenum}, tm::Timematr)
##     Timenum(tm.vals, tm.idx)
## end

#############################
## get numeric values only ##
#############################

## possible without NAs: extract values as Float64
## Will always return Array{Float64, 2}, since it is based on
## DataFrames. array only returns Array{Float, 1} for DataArrays. 
function core(tm::AbstractTimematr)
    return convert(Array{Float64}, array(tm.vals))
end
## alternative implementation not determining Float64
## function core(tm::AbstractTimematr)
##     return reshape([promote(array(tm.vals)...)...], size(tm))
## end

#######################
## Timematr get mean ##
#######################

import Base.mean
function mean(tm::Timematr, dim::Int = 1)
    ## output: DataFrame, since date dimension is lost
    if dim == 2
        error("For rowwise mean use rowmeans function")
    end
    meanVals = mean(core(tm), dim)
    means = composeDataFrame(meanVals, names(tm))
end

function rowmeans(tm::Timematr)
    ## output: Timematr
    meanVals = mean(core(tm), 2)
    means = Timematr(meanVals, idx(tm))
end

#######################
## Timematr get prod ##
#######################

import Base.prod
function prod(tm::Timematr, dim::Int = 1)
    ## output: DataFrame, since date dimension is lost
    if dim == 2
        error("For rowwise prod use rowprods function")
    end
    prodVals = prod(core(tm), dim)
    prods = composeDataFrame(prodVals, names(tm))
end

function rowprods(tm::Timematr)
    ## output: Timematr
    prodVals = prod(core(tm), 2)
    prods = Timematr(prodVals, idx(tm))
end

######################################
## Timematr get row and column sums ##
######################################

import Base.sum
function sum(tm::Timematr, dim::Int = 1)
    ## output: DataFrame, since date dimension is lost
    if dim == 2
        error("For rowwise sum use rowsums function")
    end
    sumVals = sum(core(tm), dim)
    sums = DataFrame(sumVals, names(tm))
end

function rowsums(tm::Timematr)
    ## output: Timematr
    sumVals = sum(core(tm), 2)
    sums = Timematr(sumVals, idx(tm))
end


#########################
## Timematr covariance ##
#########################

import Base.cov
function cov(tm::Timematr)
    ## output: DataFrame
    covDf = composeDataFrame(cov(core(tm)), names(tm.vals))
    return covDf
end

##########################
## Timematr correlation ##
##########################

import Base.cor
function cor(tm::Timematr)
    ## output: DataFrame
    corDf = DataFrame(cor(core(tm)), names(tm.vals))
    return corDf
end

##########################
## Timematr std ##
##########################

import Base.std
function std(tm::Timematr)
    ## output: DataFrame
    stdDf = composeDataFrame(std(core(tm), 1), names(tm.vals))
    return stdDf
end

function std(tm::Timematr, dim::Integer)
    ## output: DataFrame
    if dim == 2
        error("For rowwise standard deviations use rowstds")
    end
    stdDf = composeDataFrame(std(core(tm), 1), names(tm.vals))
    return stdDf
end

function rowstds(tm::Timematr)
    rowStd = Timematr(std(core(tm), 2), idx(tm))
    return rowStd
end
   
#########################
## minimum and maximum ##
#########################

import Base.minimum
function minimum(tm::Timematr)
    return minimum(core(tm))
end
function minimum(tm::Timematr, dim::Integer)
    if dim == 2
        error("For rowwise minimum use rowmin function")
    end
    return composeDataFrame(minimum(core(tm), 1), names(tm))
end

############
## cumsum ##
############

import Base.cumsum
function cumsum(tm::Timematr, dim::Integer)
    cumulated = cumsum(core(tm), dim)
    return Timematr(composeDataFrame(cumulated, names(tm)), idx(tm))
end

import Base.cumprod
function cumprod(tm::Timematr, dim::Integer)
    cumulated = cumprod(core(tm), dim)
    return Timematr(composeDataFrame(cumulated, names(tm)), idx(tm))
end


function getVars(tm::Timematr, mapF::Function, crit::Function)
    ## map each column to a value, and apply some condition on value
    ## e.g.: find variables with minimum value less than -30
    ncol = size(tm, 2)
    nrow = size(tm, 1)
    vals = TimeData.core(tm)

    values = ones(ncol)
    for ii=1:ncol
        values[ii] = mapF(vals[:, ii])
    end

    logics = crit(values)

    df = DataFrame(names=names(tm)[logics], values=values[logics])
    ## names!(df, names(tm)[logics])
    return df
end


####################
## geometric mean ##
####################

function geomMean(x::Timematr; percent = true)
    nObs = size(x, 1)
    if percent
        vals = (prod(1 + core(x)./100, 1).^(1/nObs) - 1)*100
    else
        vals = prod(1 + core(x), 1).^(1/nObs) - 1
    end
    return composeDataFrame(vals, names(x))
end

function geomMean(x; percent = true)
    nObs = size(x, 1)
    if percent
        vals = (prod(1 + x./100, 1).^(1/nObs) - 1)*100
    else
        vals = prod(1 + x./100, 1).^(1/nObs) - 1
    end
    return vals
end

#####################
## moving averages ##
#####################

function movAvg(tm::Timematr, nPeriods::Integer)
    (nObs, nAss) = size(tm)
    nMAs = nObs - nPeriods + 1
    vals = core(tm)
        
    ## get start and ending indices
    startInd = ceil(nPeriods/2)
    finInd = startInd + nMAs - 1
    
    ## preallocation
    movAvgs = ones(nMAs, nAss)

    movAvgs[1, :] = sum(vals[1:nPeriods, :], 1)

    for ii=2:nMAs
        movAvgs[ii, :] = movAvgs[ii-1, :] - vals[(ii-1), :] +
        vals[(ii-1)+nPeriods, :]
    end

    ## divide
    scaledVals = movAvgs / nPeriods
    dats = idx(tm)[startInd:finInd]

    movAvgTm = Timematr(scaledVals, names(tm), dats)
    return movAvgTm
end


#######################
## display in IJulia ##
#######################

import Base.writemime
function Base.writemime(io::IO,
                        ::MIME"text/html",
                        tm::Timematr)

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
