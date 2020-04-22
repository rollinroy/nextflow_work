#!/usr/bin/env nextflow

params.str = 'Hello world again!'
//params.rfile = "results.txt"
params.rfile = "results_"
cfile = params.rfile + "*"
rf = file(params.rfile)

process splitLetters {

    output:
    file 'chunk_*' into letters

    """
    printf '${params.str}' | split -b 6 - chunk_
    """
}


process convertToUpper {

    input:
//    file x from letters.flatten()
    file x from letters

    output:
    file 'results_*' into result

    """
    cat $x | tr '[a-z]' '[A-Z]' > results_
    # rev $x
    """
}

//result.view { it.trim() }
//result.subscribe { println "converted to upper: " + it.text}
result
    .flatMap()
    .subscribe { println "File: ${it.name} = ${it.text}"  }
