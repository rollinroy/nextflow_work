#!/usr/bin/env nextflow

//params.in = "./nextflow/tests/data/sample.fa"
params.in = "null_model.config"

sequences = file(params.in)
//SPLIT = (System.properties['os.name'] == 'Mac OS X' ? 'gcsplit' : 'csplit')
SPLIT = 'gcsplit'
process splitSequences {

    input:
    file 'input.fa' from sequences
//    file acfg from sequences

    output:
//    file 'seq_*' into records
//   file 'seq_' into records
    stdout records

    """
    # $SPLIT input.fa '%^>%' '/^>/' '{*}' -f seq_
    #cat input.fa | sed 's/ /=/' > seq_
    cat input.fa | sed 's/ /=/'
    """

}

process reverse {

    input:
    file x from records

    output:
    stdout result

    """
    cat $x
    """
}

process analysis_init {
    input:
    val acfg from result

    exec:
    the_cfg = acfg
    def cfg_map=[:]
    the_cfg.split("\n").each {
        param-> def kv=param.split('=')
        cfg_map[kv[0]]=kv[1]
    }
    println cfg_map
}


result.subscribe { println it }
