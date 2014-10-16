###############################
## getEntries with function ##
###############################

function getEntries(td::TimeData.AbstractTimedata, f::Function; sort="dates")
    ## show dates and variables fulfilling a criteria elementwise
    ##
    ## f returns true or false or NA
    
    (nObs, nVars) = size(td)
    nams = names(td)
    
    ## preallocation
    idxs = convert(typeof(td.idx), [])
    variables = Symbol[]
    values = Any[]
    
    if sort == "dates"
        for ii=1:nObs
            for jj=1:nVars
                singleEntry = get(td, ii, jj)
                
                testVal = f(singleEntry)
                if isna(testVal)
                    testVal = false
                end
                
                if testVal
                    push!(idxs, td.idx[ii])
                    push!(variables, nams[jj])
                    push!(values, singleEntry)
                end
            end
        end
    elseif sort == "variables"
        for jj=1:nVars
            for ii=1:nObs
                singleEntry = get(td, ii, jj)
                
                testVal = f(singleEntry)
                if isna(testVal)
                    testVal = false
                end
                
                if testVal
                    push!(idxs, td.idx[ii])
                    push!(variables, nams[jj])
                    push!(values, singleEntry)
                end
            end
        end
    else
        error("sort must either be dates or variables")
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

###################################
## getEntries, logical indexing ##
###################################


function getEntries(td::TimeData.AbstractTimedata,
                     td2::TimeData.AbstractTimedata)

    if size(td) != size(td2)
        error("TimeData objects must be of equal dimensions for
logical indexing")
    end

    if any(eltypes(td2.vals) .!= Bool)
        error("Logical indexing object must have columns of type
        Bool")
    end

    singleInds = find(td2)
    return getEntries(td, singleInds)
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
