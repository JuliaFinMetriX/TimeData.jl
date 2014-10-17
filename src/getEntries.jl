######################################
## define getEntries, double index ##
######################################

function getEntries(td::TimeData.AbstractTimedata,
                    rowInds::Array{Int}, colInds::Array{Int})

    nObs = length(rowInds)
    nams = names(td)

    ## preallocation
    idxs = Array(typeof(td.idx[1]), nObs)
    variables = Array(Symbol, nObs)
    values = Array(Any, nObs)

    for ii=1:nObs
        values[ii] = get(td, rowInds[ii], colInds[ii])
        idxs[ii] = TimeData.idx(td)[rowInds[ii]]
        variables[ii] = nams[colInds[ii]]
    end
    df = DataFrame(variable = variables, value = values)
    return TimeData.Timedata(df, idxs)
end

######################################
## define getEntries, single index ##
######################################

function getEntries(td::TimeData.AbstractTimedata,
                    singleInd::Array{Int}) 
    (rowInds, colInds) = ind2sub(size(td), singleInd)
    return TimeData.getEntries(td, rowInds, colInds)
end

###################################
## getEntries, logical indexing ##
###################################

function getEntries(td::TimeData.AbstractTimedata,
                    logInds::Array{Bool, 2},
                    sortDates::Bool=false)

    if size(td) != size(logInds)
        error("TimeData and logical index array must be of equal
dimensions for logical indexing")
    end

    if sortDates
        singleInds = find(logInds')
        (colInds, rowInds) = ind2sub(size(logInds'), singleInds)
    else
        singleInds = find(logInds)
        (rowInds, colInds) = ind2sub(size(td), singleInds)
    end
    return getEntries(td, rowInds, colInds)
end

#######################################################
## getEntries, logical indexing with Timedata object ##
#######################################################

function getEntries(td::TimeData.AbstractTimedata,
                    td2::TimeData.AbstractTimedata;
                    getNAs::Bool=false,
                    sortDates::Bool=false)
    
    if size(td) != size(td2)
        error("TimeData objects must be of equal dimensions for
logical indexing")
    end

    logInds = asArr(td2, Bool, getNAs)
    return getEntries(td, logInds, sortDates)
end

