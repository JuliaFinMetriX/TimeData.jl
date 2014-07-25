##########
## join ##
##########

function joinSortedIdx_inner(td1::AbstractTimedata,
                             td2::AbstractTimedata)
    ## only works for sorted and increasing index!

    if typeof(idx(td1)) != typeof(idx(td2))
        error("both indices must be of same type to join")
    end

    ## find common dates
    equalIds = findCommonDates(idx(td1), idx(td2))

    df = [td1.vals[equalIds[:, 1], :] td2.vals[equalIds[:, 2], :]]
    td = Timedata(df, idx(td1)[equalIds[:, 1]])
end

function joinSortedIdx_outer(td1::AbstractTimedata,
                             td2::AbstractTimedata)
    ## only works for sorted and increasing index!

    if typeof(idx(td1)) != typeof(idx(td2))
        error("both indices must be of same type to join")
    end

    equalIds = findAllOccurringDates(idx(td1), idx(td2))
    nObs = size(equalIds, 1)
    nVars1 = size(td1, 2)
    nVars2 = size(td2, 2)

    ## init output DataFrame with NAs
    df = DataFrame([eltypes(td1.vals), eltypes(td2.vals)],
                   [names(td1.vals), names(td2.vals)],
                   nObs)
    idxs = Array(eltype(idx(td1)), nObs)
    
    for ii=1:nObs
        if isna(equalIds[ii, 1]) & !isna(equalIds[ii, 2])
            rowInd = equalIds[ii, 2]
            idxs[ii] = idx(td2)[rowInd]
            for jj=1:nVars1
                df[ii, jj] = NA
            end
            for jj=(nVars1+1):(nVars1+nVars2)
                df[ii, jj] = td2.vals[rowInd, (jj-nVars1)]
            end
        elseif !isna(equalIds[ii, 1]) & isna(equalIds[ii, 2])
            rowInd = equalIds[ii, 1]
            idxs[ii] = idx(td1)[rowInd]
            for jj=1:nVars1
                df[ii, jj] = td1.vals[rowInd, jj]
            end
            for jj=(nVars1+1):(nVars1+nVars2)
                df[ii, jj] = NA
            end
        elseif !isna(equalIds[ii, 1]) & !isna(equalIds[ii, 2])
            rowInd1 = equalIds[ii, 1]
            rowInd2 = equalIds[ii, 2]
            idxs[ii] = idx(td1)[rowInd1]
            for jj=1:nVars1
                df[ii, jj] = td1.vals[rowInd1, jj]
            end
            for jj=(nVars1+1):(nVars1+nVars2)
                df[ii, jj] = td2.vals[rowInd2, (jj-nVars1)]
            end
        end
    end

    td = Timedata(df, idxs)
end

function joinSortedIdx_right(td1::AbstractTimedata,
                             td2::AbstractTimedata)

    ## only works for sorted and increasing index!
    td = joinSortedIdx_left(td2, td1)
    nVars2 = size(td2, 2)
    td2 = [td[:, (nVars2+1):end] td[:, 1:nVars2]]
end

function joinSortedIdx_left(td1::AbstractTimedata,
                            td2::AbstractTimedata)
    ## only works for sorted and increasing index!
    
    if typeof(idx(td1)) != typeof(idx(td2))
        error("both indices must be of same type to join")
    end

    nIds1 = size(td1, 1)
    
    ## find dates of 1 in 2
    equalIds = findDatesOfLeftInRight(idx(td1), idx(td2))

    ## get number of variables
    (nVars1, nVars2) = (size(td1, 2), size(td2, 2))

    ## init output DataFrame with NAs
    df = DataFrame([eltypes(td1.vals), eltypes(td2.vals)],
                   [names(td1.vals), names(td2.vals)],
                   nIds1)

    ## successively fill values: run through rows and columns
    for ii=1:nIds1
        for jj=1:nVars1
            df[ii, jj] = td1.vals[ii, jj] # values of 1 must be filled
                                        # always 
        end

        if !isna(equalIds[ii])
            ## append values of 2
            for jj=1:nVars2
                df[ii, (nVars1 + jj)] = td2.vals[equalIds[ii], jj]
            end
        end
    end
    tdJoint = Timedata(df, idx(td1))        # contains NAs
end

##################################
## sorted join helper functions ##
##################################

function findAllOccurringDates(idx1, idx2)
    (nIds1, nIds2) = (length(idx1), length(idx2))

    ## some preallocation
    equalIds = DataArray(Int, max(nIds1, nIds2), 2)
    ii = 1; jj = 1; nDatesFound = 1

    ## find none of both indices is completely used
    while (ii <= nIds1) & (jj <= nIds2)
        ## test for equality
        if idx1[ii] == idx2[jj]
            ## note down respective index
            equalIds = addValueToDataArray!(equalIds, @data([ii jj]),
                                 nDatesFound) 
            ii += 1; jj += 1; nDatesFound += 1

            ## if no equality: increase smaller index 
        elseif idx1[ii] < idx2[jj]
            equalIds = addValueToDataArray!(equalIds, @data([ii NA]),
                                 nDatesFound)
            ii += 1; nDatesFound += 1
        elseif idx1[ii] > idx2[jj]
            equalIds = addValueToDataArray!(equalIds, @data([NA jj]),
                                nDatesFound)
            jj += 1; nDatesFound += 1

        end
    end

    ## append rest
    if jj > nIds2
        while ii <= nIds1
            equalIds = addValueToDataArray!(equalIds, @data([ii NA]),
                                nDatesFound)
            ii += 1; nDatesFound += 1
        end
    elseif ii < nIds1
        while jj <= nIds2
            equalIds = addValueToDataArray!(equalIds, @data([NA jj]),
                                nDatesFound)
            jj += 1; nDatesFound += 1
        end
    end
    return equalIds
end

function addValueToDataArray!(equalIds, DArow, nDatesFound)
    if nDatesFound > size(equalIds, 1)
        equalIds = vcat(equalIds, DArow)
    else
        equalIds[nDatesFound, :] = DArow
    end
    equalIds
end

function getIndices(equalIds, idx1, idx2)
    nObs = size(equalIds, 1)
    ids = Array(eltype(idx1), nObs)

    for ii=1:nObs
        if !isna(equalIds[ii, 1])
            ids[ii] = idx1[equalIds[ii, 1]]
        else
            ids[ii] = idx2[equalIds[ii, 2]]
        end
    end
    ids
end

function getIndices(equalIds, idx)
    nObs = size(equalIds, 1)
    ids = DataArray(eltype(idx), nObs)

    for ii=1:nObs
        if !isna(equalIds[ii])
            ids[ii] = idx[equalIds[ii]]
        end
    end
    ids
end

function findDatesOfLeftInRight(idx1, idx2)
    ## for each date in idx1, find its entry in idx2. If date does not
    ## exist, mark it with NA.
    
    nIds1 = length(idx1)
    nIds2 = length(idx2)

    ## running variables
    ii = 1
    jj = 1

    ## preallocation with NAs
    equalIds = DataArray(typeof(ii), nIds1)    

    ## find common dates
    while ii <= nIds1
        ## test for equality
        if idx1[ii] == idx2[jj]
            ## note down respective index
            equalIds[ii] = jj
            ii += 1
            jj += 1
            if jj > nIds2
                break
            end
            ## if no equality: increase smaller index 
        elseif idx1[ii] < idx2[jj]
            equalIds[ii] = NA
            ii += 1
        elseif idx1[ii] > idx2[jj]
            jj += 1
            if jj > nIds2
                break
            end
        end
    end
    return equalIds
end

function findCommonDates(idx1, idx2)
    
    nIds1 = length(idx1)
    nIds2 = length(idx2)

    ## running variables
    ii = 1
    jj = 1

    ## preallocation with NAs
    equalIds = [[] []]

    ## find common dates
    while ii <= nIds1
        ## test for equality
        if idx1[ii] == idx2[jj]
            ## note down respective index
            equalIds = vcat(equalIds, [ii jj])
            ii += 1
            jj += 1
            if jj > nIds2
                break
            end
            ## if no equality: increase smaller index 
        elseif idx1[ii] < idx2[jj]
            ii += 1
        elseif idx1[ii] > idx2[jj]
            jj += 1
            if jj > nIds2
                break
            end
        end
    end
    return equalIds
end

