## list packages that shall be automatically loaded
using DataFrames
using Dates

module TimeData

## list packages whos namespace is used
using Compat
using Docile
using DataArrays
using DataFrames
using Dates

using TimeSeries
using JFinM_Charts
## using Winston
## using Gadfly

importall Base
## importall Stats

export #
@roundDf,
@table,
AbstractTimedata,
AbstractTimenum,
AbstractTimematr,
aggrRets,
asArr,
asArrayOfEqualDimensions,
chkDates,
chkElw,
chkVars,
collapseDates,
collapseVars,
complete_cases,
composeDataFrame,
cor,
core,
cov,
cumprod,
cumsum,
dat2str,
dat2num,
eachcol,
eachentry,
eachdate,
eachobs,
eachrow,
eachvar,
find,
geomMean,
get,
asArr,
getDates,
hcat,
HTML,
idx,
impute!,
isaRowVector,
isequalElw,
isnaElw,
equMeta,
joinSortedIdx_inner,
joinSortedIdx_left,
joinSortedIdx_outer,
joinSortedIdx_right,
loadPlotting,
map,
mean,
minimum,
movAvg,
narm,
plot,
prod,
readTimedata,
resample,
narowrm,
round,
rowmeans,
rowprods,
rowstds,
rowsums,
setDfRow!,
setNA!,
getEntries,
std,
str,
sum,
testcase,
Timedata,
Timematr,
Timenum,
vcat,
writedlm,
writeTimedata

include("constraints.jl")
include("abstractTypes.jl")
include("timedata_type.jl")
include("timenum.jl")
include("timematr.jl")
include("constructors.jl")
include("getindex.jl")
include("setindex.jl")
include("display.jl")
include("abstractFuncs.jl")
include("preservingFuncs.jl")
include("iterators.jl")
include("map.jl")
include("getEntries.jl")
include("operators.jl")
include("stats.jl")
include("io.jl")
include("join.jl")
## include("plotting.jl")
include("jfinm_charts_plotting.jl")
include("dataframe_extensions.jl")
include("convert.jl")
include("utils.jl")

function loadPlotting()
    include(joinpath(Pkg.dir("TimeData"), "src/plotting.jl"))
end    

end
