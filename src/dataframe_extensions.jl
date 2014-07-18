############################
## DataFrame construction ##
############################

function composeDataFrame(vals, nams)
    ## compose DataFrame from data and column names
    ##
    ## Input:
    ## 	vals 		Array{Float64,2} of values
    ## 	nams		column names as Array{Symbol,1} as returned by
    ## 				names(df) 
    ## 
    ## Output:
    ## 	DataFrame with values given by vals and column names given by
    ## 	nams 

    errMsg = "to compose a DataFrame, number of columns and number of
names must match"
    
    if size(vals, 2) != length(nams)
        println("size of values: $(size(vals))")
        println("number of names: $(length(nams))")
        error(errMsg)
    end
    
    df = convert(DataFrame, vals)
    try
        rename!(df, names(df), nams)
    catch
        # renaming didn't work - leave as is
    end

    return df
end

import Base.convert
function convert(::Type{DataFrame}, td::AbstractTimedata)
    df = [DataFrame(idx = td.idx) td.vals]
end

############################
## round dataframe values ##
############################

import Base.round
function round(df::DataFrame, nDgts::Int)
    vals = round(array(df), nDgts)
    return composeDataFrame(vals, names(df))
end

function round(df::DataFrame)
    vals = round(array(df), 2)
    return composeDataFrame(vals, names(df))
end


macro roundDf(expr::Expr)
    quote 
        res = $(esc(expr))
    
        function tryRound(x)
            try 
                round(x, 2)
            catch
                x
            end
        end

        resRnd = [tryRound(res[ii, jj]) for ii=1:size(res, 1), jj=1:size(res, 2)] |>
                 x -> composeDataFrame(x, names(res))
    
        display(resRnd)
    end
end


##################################
## basic mathematical operators ##
##################################

importall Base
for op = (:+, :.+, :-, :.-, :.*, :./)
  eval(quote
      function $op(df1::DataFrame, df2::DataFrame)
          res = $op(array(df1), array(df2))
          ## if size(res, 1) == 1
              ## df = composeDataFrame(res', names(df1))
          ## else
          df = composeDataFrame(res, names(df1))
          ## end
      end
  end)
end
