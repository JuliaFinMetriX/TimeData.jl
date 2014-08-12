function testcase(timedataType, number::Int)
    ## easily create TimeData objects for testing

    if number == 1
        dats = [Date(2010, 1, 1):Date(2010, 1, 4)]
        df = DataFrame()
        df[:prices1] = @data([100, 120, 110, 170])
        df[:prices2] = @data([110, 120, 100, 130])
        testInst = timedataType(df, dats)

    elseif number == 2
        dats = [Date(2010, 1, 1):Date(2010, 1, 5)]
        df = DataFrame()
        df[:prices1] = @data([NA, 120, 140, 170, 200])
        df[:prices2] = @data([110, 120, NA, 130, NA])
        testInst = timedataType(df, dats)

    elseif number == 3
        dats = [Date(2010, 1, 1):Date(2010, 1, 3)]
        df = DataFrame()
        df[:color] = @data([NA, "green", "red"])
        df[:value] = @data([110, 120, NA])
        testInst = timedataType(df, dats)
    elseif number == 4
        dats = [Date(2010, 1, 1):Date(2010, 1, 5)]
        df = DataFrame()
        df[:prices1] = @data([100, 120, 140, 170, 200])
        df[:prices2] = @data([110, 120, NA, 130, 150])
        testInst = timedataType(df, dats)

    else
        error("testInst number not implemented yet")
    end
    return deepcopy(testInst)
end
