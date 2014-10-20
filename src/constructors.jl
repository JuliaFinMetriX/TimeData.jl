#######################
## outer contructors ##
#######################

## concept:
## If no NA values are present, initialization could be done more
## easily with arrays.

FloatArray = Union(Array{Float64, 2}, Array{Float64, 1})
import DataFrames.convert
function convert(T::Type{DataFrame}, vals::Array{Float64, 1})
    df = convert(T, (vals')')
end

for t = (:Timedata, :Timenum, :Timematr, :Timecop)
    @eval begin
        
        ###########################
        ## shortcuts without NAs ##
        ###########################
        
        ## no names or dates (just simulated values)
        function $(t)(vals::FloatArray)
            idx = [1:size(vals, 1)]
            $(t)(convert(DataFrame, vals), idx)
        end
        
        ## from core elements
        function $(t)(vals::FloatArray,
                      nams::Array{Symbol, 1},
                      idx::Array)
            df = composeDataFrame(vals, nams)
            return $(t)(df, idx)
        end
        
        ## comprehensive constructor: very general, all elements
        ## required for Timedata type
        function $(t)(vals::Array, nams::Array, idx::Array) 
            df = composeDataFrame(vals, nams)
            return $(t)(df, idx)
        end
        
        ## two inputs only, general form
        function $(t)(vals::Array, nams::Array)
            if isa(nams[1], Symbol)
                df = composeDataFrame(vals, nams)
                $(t)(df)
            else
                df = convert(DataFrame, vals)
                $(t)(df, nams)
            end
        end

        function $(t)(vals::DataFrame, nams::Array)
            if isa(nams[1], Symbol)
                df = composeDataFrame(vals, nams)
                $(t)(df)
            else
                df = convert(DataFrame, vals)
                $(t)(df, nams)
            end
        end

        ###################
        ## NAs in values ##
        ###################
        
        ## no idx
        function $(t)(vals::DataFrame)
            idx = [1:size(vals, 1)]
            tn = $(t)(vals, idx)
        end

        ########################
        ## index as DataArray ##
        ########################

        function $(t)(vals::DataFrame, idx::DataVector) 
            if any(idx.na)
                error("Index values may not be missing")
            else
                return $(t)(vals, asArr(idx, eltype(idx)))
            end
        end


    end
end
