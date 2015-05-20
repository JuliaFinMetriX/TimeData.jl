##################
## JFinM_Charts ##
##################

## handle data
##------------

@doc doc"""
Write data as .csv file. Hence, intended name needs not be modified.
"""->
## write data to disk
function writeData(tm::AbstractTimenum,
                   chrt::JFinM_Charts.MLineChart,
                   intendedFname::String)
    writeTimedata(intendedFname, tm)
end
