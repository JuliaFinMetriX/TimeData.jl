#######################
## outer contructors ##
#######################

## concept:
## If no NA values are present, initialization could be done more
## easily with arrays.

FloatArray = Union(Array{Float64, 2}, Array{Float64, 1})

for t = (:Timedata, :Timenum, :Timematr, :Timecop)
    @eval begin
        
        ###########################
        ## shortcuts without NAs ##
        ###########################
        
        ## no names or dates (just simulated values)
        function $(t)(vals::FloatArray)
            idx = [1:size(vals, 1)]
            $(t)(DataFrame(vals), idx)
        end
        
        ## from core elements
        function $(t)(vals::FloatArray,
                      names::Array{Union(UTF8String,ASCIIString),1},
                      idx::Array)
            df = DataFrame(vals, names)
            return $(t)(df, idx)
        end
        function $(t)(vals::FloatArray,
                      names::Array{ASCIIString,1},
                      idx::Array)
            df = DataFrame(vals, names)
            return $(t)(df, idx)
        end
        
        ## comprehensive constructor: very general, all elements
        ## required for Timedata type
        function $(t)(vals::Array, names::Array, idx::Array) 
            df = DataFrame(vals)
            names!(df, names)
            return $(t)(df, idx)
        end
        
        ## two inputs only, general form
        function $(t)(vals::Array, names::Array)
            if isa(names[1], Union(UTF8String,ASCIIString))
                $(t)(DataFrame(vals, names))
            else
                $(t)(DataFrame(vals), names)
            end
        end

        function $(t)(vals::DataFrame, names::Array)
            if isa(names[1], Union(UTF8String,ASCIIString))
                $(t)(DataFrame(vals, names))
            else
                $(t)(DataFrame(vals), names)
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
    end
end
