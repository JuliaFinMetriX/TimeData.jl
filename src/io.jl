############################
## read and write to disk ##
############################

function readTimedata(filename::String)

    df = readtable(filename, nastrings=[".", "", "NA"])
    
    # find columns that have been parsed as Strings by readtable
    col_to_test = String[]

    for col_data in df[1,:]
        typeof(df[1,col_data[1]]) == UTF8String?
        push!(col_to_test, col_data[1]):
        nothing
    end

    # test each column's data to see if Datetime will parse it
    col_that_pass = String[]

    for colname in col_to_test
        d = match(r"[-|\s|\/|.]", df[1,colname])
        d !== nothing? (bar = split(df[1, colname], d.match)): (bar = [])
        if length(bar) == 3
            push!(col_that_pass, colname)
        end
    end

    # parse first column that passes the Datetime regex test
    idx = Date{ISOCalendar}[date(d) for d in
                                 df[col_that_pass[1]]] # without
                                        # Date it would fail chkIdx
                                        # in constructor
    
    delete!(df, [col_that_pass[1]])

    ## try whether DataFrame fits subtypes
    try
        td = Timematr(df, idx)
        return td        
    catch
        try
            td = Timenum(df, idx)
            return td
        catch
            td = Timedata(df, idx)
            return td
        end
    end
end

function writeTimedata(filename::String, td::AbstractTimedata)
    ## create large dataframe
    idxDf = DataFrame(idx = idx(td));
    df = [idxDf td.vals];
    writetable(filename, df)
end

