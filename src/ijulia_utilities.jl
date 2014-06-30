type HTML
   s::String
end
import Base.writemime
writemime(io::IO, ::MIME"text/html", x::HTML) = print(io, x.s)

macro roundDf(expr)
    quote 
        res = $(esc(expr))
    
        function tryRound(x)
            try 
                round(x, 2)
            catch
                x
            end
        end
        
        #resRnd = Float64[round(res[ii, jj], 2) for ii=1:size(res, 1), jj=1:size(res, 2)] |>
        #         x -> composeDataFrame(x, names(res))
        resRnd = [tryRound(res[ii, jj]) for ii=1:size(res, 1), jj=1:size(res, 2)] |>
                 x -> composeDataFrame(x, names(res))
    
        display(resRnd)
    end
end

macro table(title, expr)
    quote
        titleString = $title
        htmlTitleString = string("<p><strong><font color=\"blue\">",
                                 titleString,
                                 "</font></strong></p>")
        display(HTML(htmlTitleString))
        @roundDf $(esc(expr))
    end
end
    
## macro table(title, expr)
##     display(HTML("<p><strong><font color=\"blue\">$title</font></strong></p>"))
##     eval(:(@roundDf $expr))
## end
