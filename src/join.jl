##########
## join ##
##########

function joinIdx(tm1::Timematr, tm2::Timematr; kind=:outer)
    # join two Timematr objects on their idx

    if typeof(idx(tm1)) != typeof(idx(tm2))
        error("both indices must be of same type to join")
    end

    ids1 = idx(tm1)
    ids2 = idx(tm2)
    nIds1 = length(ids1)
    nIds2 = length(ids2)

    runId1 = 1
    runId2 = 1
    joinedIds = Array(typeof(id1), 1)

    while (runId1 < nIds1) | (runId2 < nIds2)

        # check current values
        if ids1[runId1] < ids2[runId2]
            
        end        
        id1 += 1
        id2 += 1
        println("$id1 and $id2")
    end
    
end

function jointIdx_left(tm1::Timematr, tm2::Timematr)
    if typeof(idx(tm1)) != typeof(idx(tm2))
        error("both indices must be of same type to join")
    end

    ids1 = idx(tm1)
    ids2 = idx(tm2)
    nIds1 = length(ids1)
    nIds2 = length(ids2)

    runId1 = 1
    runId2 = 1
    joinedIds = Array(typeof(id1), nIds1)

    while runId1 <= 3
        dkfj
    end
    
end

df1 = DataFrame(id = [1:10], a = rand(10))
df2 = DataFrame(id = [1:10], a = rand(10))
function renameIntersect!(df1::DataFrame, df2::DataFrame)
    toRename = intersect(names(df1), names(df2))
    for ii=1:length(toRename)
        rename!(df2, toRename[ii],
                convert(Symbol, string(toRename[ii], "_1")))
    end
end
renameIntersect!(df1, df2)

typealias Indices Union(Real, AbstractVector{Real})
function changeNames(df::DataFrame, nams::Array{Symbol,1})
    newLookup = Dict(Symbol, Indices)
end



function invertDict(dict::Dict)
    invDict = Dict()
    for val in unique(values(dict))
        ## for each possible value, find all keys
        ## @show val
        keysWithGivenValue = Array(Symbol, 0)
        ## counter = 1
        for key in dict
            ## @show key
            if key[2] == val
                push!(keysWithGivenValue, key[1])
                ## counter = counter + 1
            end
        end
        invDict[val] = keysWithGivenValue
    end
    return invDict
end

join(df1, df2, on=:id)
## import Base.join
## function join(inst1::Timematr, inst2::Timematr; kind=:inner)

##     df1 = convert(DataFrame, inst1)
##     df2 = convert(DataFrame, inst2)

##     df = join(df1, df2, on=:idx, kind=kind)
##     tm = Timematr(df[:, 2:end], array(df[:idx]))
## end

## import Base.join
## function join(inst1::Timedata, inst2::Timedata; kind=:inner)

##     df1 = convert(DataFrame, inst1)
##     df2 = convert(DataFrame, inst2)

##     df = join(df1, df2, on=:idx, kind=kind)
##     ## tm = Timedata(df[:, 2:end], array(df[:idx]))
## end

## ## tm1 = Timematr(rand(30, 3))
## ## tm2 = Timematr(rand(20, 6))

## ## tm = join(tm1, tm2)
## ## tmOuter = join(tm1, tm2, kind=:outer)

## td1 = Timedata(rand(30, 3))
## td2 = Timedata(rand(30, 6))
## tdOuter = join(td1, td2, kind=:outer)

## df1 = convert(DataFrame, td1)
## df2 = convert(DataFrame, td2)

## join(df1, df2, on=:idx, kind=:left)
