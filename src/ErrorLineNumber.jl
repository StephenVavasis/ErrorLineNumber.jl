module ErrorLineNumber


## insert_line_numbers
## Take an expression inprogram,
##
## Produce an outprogram, which is the rewritten inprogram
## with statements to update line number variable.
##
## There are three versions of routine; the correct one is
## selected by multiple dispatch on the first argument.


insert_line_numbers(inprogram::Any,
                             ::ASCIIString,
                             ::Symbol) = inprogram


insert_line_numbers(inprogram::LineNumberNode,
                             fnname::ASCIIString,
                             specialsym::Symbol) = 
    Expr(:block,
         Expr(:(=), specialsym, fnname * "." * string(inprogram.line)),
         inprogram)





function insert_line_numbers(inprogram::Expr,
                             fnname::ASCIIString,
                             specialsym::Symbol)
    if inprogram.head == :line
        # If the expression is an expression of type :line, i.e., 
        # a new line number in the source code,
        # replace it with a block that consists of the
        # the line number and a tracking array incrementer
        outprogram =  Expr(:block,
                           Expr(:(=), specialsym, fnname * "." * 
                                string(inprogram.args[1])),
                           inprogram)
    else
        outprogram = Expr(inprogram.head)
        for arg in inprogram.args
            push!(outprogram.args, insert_line_numbers(arg, fnname, specialsym))
        end
    end
    return outprogram
end


macro errorlinenumber(fn)
    fn.head != :function && error("errorlinenumber macro only available for functions")
    @assert fn.args[1].head == :call
    @assert fn.args[2].head == :block
    fnname = fn.args[1].args[1]
    g = gensym()
    g2 = gensym()
    newfn = Expr(:function,
                 fn.args[1],
                 Expr(:block,
                      :($g = ""),
                      Expr(:try,
                           insert_line_numbers(fn.args[2], string(fnname), g),
                           g2,
                           Expr(:block,
                                :(println(STDERR, "    !!!!!!!!!!!!!!!!!")),
                                :(println(STDERR, "ERROR LINE number = ", $g)),
                                :(println(STDERR, "    !!!!!!!!!!!!!!!!!")),
                                :(rethrow($g2))))))
    esc(newfn)
end

end # module
