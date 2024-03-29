==============================
ErrorLineNumber package
==============================

The purpose of this package to address one or more unfixed bugs
in Julia 0.4 that cause the run-time error system to report the
location of the error at the
wrong source-file line number in some cases.  Suppose a source
file has a function ``reduceMatrix`` that generates an ``BoundsError``
due to an array subscript out of range.  Suppose you suspect that Julia 
displays the wrong line number for the error.  This
package instruments a source file with a second scheme for
tracking line numbers.  To use it, first install the package via::

    Pkg.clone("https://github.com/StephenVavasis/ErrorLineNumber.jl")
   
and then declare::

   using ErrorLineNumber.@errorlinenumber

somewhere
at the beginning of your source file.
Next replace your ``function`` declaration, e.g.,::

    function reduceMatrix(a::Array{Float64,2}, i::Int)
    . . .
    end

by::

    @errorlinenumber function reduceMatrix(a::Array{Float64,2}, i::Int)
    . . .
    end

and re-run the code. The macro will cause the line with the error
message to be displayed, encased with rows of exclamation points, before
the Julia backtrace error message.

The additional statements for instrumentation 
degrade performance, so once the debugging is
finished, the macro call ``@errorlinenumber`` should be removed.

Here is an example of an actual printout (not included in the test cases)
showing that the (correct) line number (359) reported by this macro differs
from the erroneous line number (236) reported by the backtrace system::


  julia> Meshgen.testcase1()
      !!!!!!!!!!!!!!!!!
  ERROR LINE number = geometryPreprocess.359
      !!!!!!!!!!!!!!!!!
      !!!!!!!!!!!!!!!!!
  ERROR LINE number = testcase1.1169
      !!!!!!!!!!!!!!!!!
  ERROR: BoundsError: attempt to access 0-element Array{Meshgen.PCAGarcaux,1}
    at index [3]
   [inlined code] from c:\Users\vavasis\Documents\Projects\qmg21\src_jl\meshgen\..
  /geo/geo_pcag.jl:239
   in geometryPreprocess at no file:236
   [inlined code] from c:\Users\vavasis\Documents\Projects\qmg21\src_jl\meshgen\me
  shgen.jl:1169
   in testcase1 at no file:1168

Note that if function ``f1`` invokes ``f2``, which generates
the run-time error, and both are instrumented by this
macro, then both functions print the line number of the error (in the case
of ``f1``, it is the location of the call to ``f2``).



