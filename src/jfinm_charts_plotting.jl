##################
## JFinM_Charts ##
##################

## handle data
##------------

import JFinM_Charts.writeData

@doc doc"""
Write data as .csv file. Hence, intended name needs not be modified.
"""->
function writeData(tm::AbstractTimenum,
                   chrt::MLineChart,
                   intendedFname::Array{ASCIIString, 1})

    if length(intendedFname) > 1
        error("Only a single data path is required.")
    end
    writeTimedata(intendedFname[1], tm)
end
