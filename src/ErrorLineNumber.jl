module ErrorLineNumber


## insert_line_numbers
## Take an expression inprogram,
##
## Produce an outprogram, which is the rewritten inprogram
## with statements to update line number variable.
##
## There are three versions of routine; the correct one is
## selected by multiple dispatch on the first argument.

function insert_line_numbers(inprogram::LineNumberNode,
                             fnname::ASCIIString,
                             specialsym::Symbol)
    Expr(:block,
         Expr(:(=), specialsym, fnname * "." * string(inprogram.line)),
         inprogram)
end

function insert_line_numbers(inprogram::Any,
                             ::ASCIIString,
                             ::Symbol)
    inprogram
end



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
    newfn = Expr(:function)
    @assert fn.args[1].head == :call
    fnname = fn.args[1].args[1]
    push!(newfn.args, fn.args[1])
    @assert fn.args[2].head == :block
    block1 = Expr(:block)
    g = gensym()
    push!(block1.args, :($g = ""))
    tryexpr = Expr(:try)
    push!(tryexpr.args, insert_line_numbers(fn.args[2], string(fnname), g))
    g2 = gensym()
    push!(tryexpr.args, g2)
    block2 = Expr(:block)
    push!(block2.args, :(println(STDERR, "    !!!!!!!!!!!!!!!!!")))
    push!(block2.args, :(println(STDERR, "ERROR LINE number = ", $g)))
    push!(block2.args, :(println(STDERR, "    !!!!!!!!!!!!!!!!!")))
    push!(block2.args, :(rethrow($g2)))
    push!(tryexpr.args, block2)
    push!(block1.args, tryexpr)
    push!(newfn.args, block1)
    esc(newfn)
end





end # module
