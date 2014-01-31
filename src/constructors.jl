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
            dates = DataArray(Date, size(vals, 1))
            $(t)(DataFrame(vals), dates)
        end
        
        ## from core elements
        function $(t)(vals::FloatArray,
                      names::Array{Union(UTF8String,ASCIIString),1},
                      dates::DataArray)
            df = DataFrame(vals, names)
            return $(t)(df, dates)
        end
        function $(t)(vals::FloatArray,
                      names::Array{ASCIIString,1},
                      dates::DataArray)
            df = DataFrame(vals, names)
            return $(t)(df, dates)
        end
        
        ## comprehensive constructor: very general, all elements
        function $(t){T<:Array, K<:Array, S<:Array}(vals::T, names::K, dates::S) 
            df = DataFrame(vals)
            names!(df, names)
            return $(t)(df, DataArray(dates))
        end
        
        ## two inputs only, general form
        function $(t){T<:Array, S<:Array}(vals::T, names::S)
            if isa(names[1], Date)
                $(t)(DataFrame(vals), DataArray(names))
            else
                $(t)(DataFrame(vals, names))
            end
        end
        
        ###################
        ## NAs in values ##
        ###################
        
        ## no dates
        function $(t)(vals::DataFrame)
            dates = DataArray(Date, size(vals, 1))
            tn = $(t)(vals, dates)
        end

        ## dates as array
        function $(t)(vals::DataFrame, dates::Array)
            dates = DataArray(dates)
            tn = $(t)(vals, dates)
        end
        
        ##################
        ## NAs in dates ##
        ##################
        
        ## no names
        function $(t)(vals::FloatArray, dates::DataArray)
            $(t)(DataFrame(vals), dates)
        end
    end
end
