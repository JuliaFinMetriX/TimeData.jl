############################
## read and write to disk ##
############################

function readTimedata(io::IO)

    df = readtable(io)
    td = convert(AbstractTimedata, df)
end



function readTimedata(filename::String)

    df = readtable(filename, nastrings=[".", "", "NA"])
    td = convert(AbstractTimedata, df)
end

function writeTimedata(filename::String, td::AbstractTimedata)
    ## create large dataframe
    idxDf = DataFrame(idx = idx(td));
    df = [idxDf td.vals];
    writetable(filename, df)
end

######################
## org-babel output ##
######################

function Base.writedlm(io::IO, td::AbstractTimedata, dlm; opts...)
    nams = [:idx, names(td)]
    vals = [idx(td) arrAny = get(td)]
    arrAny = [nams', vals]
    writedlm(io, arrAny, dlm; opts...)
end

