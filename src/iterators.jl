######################
## rowwise iterator ##
######################

import Base.start
function start(tm::Timematr)
    return 1
end

import Base.next
function next(tm::Timematr, ii::Int)
    (nrows, ncol) = size(tm)
    ncolReal = ncol + 1

    df = convert(DataFrame, tm)
    return next(df, ii)
    ## return (df[ii, :], ii+1)
end

import Base.done
function done(tm::Timematr, ii::Int)
    df = convert(DataFrame, tm)
    return done(df, ii)
end

#########################
## columnwise iterator ##
#########################

import Base.start
function start(tm::Timematr)
    return 1
end

import Base.next
function next(tm::Timematr, ii::Int)
    (nrows, ncol) = size(tm)
    ncolReal = ncol + 1

    df = convert(DataFrame, tm)
    return (df[:, ii], ii+1)
end

import Base.done
function done(tm::Timematr, ii::Int)
    (nrows, ncol) = size(tm)
    ncolReal = ncol + 1

    isDone = false
    if ii >= ncolReal
        isDone = true
    end
    return isDone
end


##########################
## elementwise iterator ##
##########################

import Base.start
function start(tm::Timematr)
    return 1
end

import Base.next
function next(tm::Timematr, ii::Int)
    (nrows, ncol) = size(tm)
    ncolReal = ncol + 1

    rowInd = mod(ii, nrows)
    if rowInd == 0
        rowInd = nrows
    end
    colInd = int((ii - rowInd)/nrows + 1)

    if colInd == 1
        output = (idx(tm)[rowInd], ii+1)
    else
        output = (tm.vals[rowInd, colInd-1], ii+1)
    end
        
    return output
end

import Base.done
function done(tm::Timematr, ii::Int)
    (nrows, ncol) = size(tm)
    ncolReal = ncol + 1

    isDone = false
    if ii >= nrows*ncolReal
        isDone = true
    end
    return isDone
end


#############
## testing ##
#############

tm = Timematr(rand(10, 5))

state = start(tm);
while !done(tm, state)
    i, state = next(tm, state)
    println(i)
end
