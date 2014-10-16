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
        error("TimeData objects must be of equal dimensions for
logical indexing")
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


##############
## getDates ##
##############

function getDates(f::Function, td::TimeData.AbstractTimedata)
    ## find dates where at least one entry fulfills a given condition

    (nObs, nVars) = size(td)
    
    ## preallocation
    idxs = convert(typeof(td.idx), [])
    
    for ii=1:nObs
        for jj=1:nVars
            singleEntry = get(td, ii, jj)
            
            testVal = f(singleEntry)
            if isna(testVal)
                testVal = false
            end
            
            if testVal
                push!(idxs, td.idx[ii])
                break # move to next date
            end
        end
    end
    return idxs
end
