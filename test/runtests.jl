using ErrorLineNumber
using ErrorLineNumber.@errorlinenumber
using Base.Test


@errorlinenumber function erroneous()
    x = [1,2]
    return x[3]
end

function runtest3()
    (outRead, outWrite) = redirect_stderr()
    msg = ""
    try
        erroneous()
    catch
        msg = readavailable(outRead)
    finally
        close(outWrite)
        close(outRead)
    end
    matchstring = "    !!!!!!!!!!!!!!!!!"
    @test ASCIIString(msg[1:length(matchstring)]) == matchstring
end




runtest3()
