#!/usr/bin/env nextflow

params.ncores = "1"
params.debug = false
params.analysis_cfg = "null_model.config"
params.pipeline_cfg = "pipeline.cfg"
params.pipeline_job = params.analysis_cfg.split("\\.")[0]

def analysis_driver = ""

analysis_cfg_ch = Channel.fromPath(params.analysis_cfg)
pipeline_ch = Channel.fromPath(params.pipeline_cfg)

process pcfg_to_map {
    input:
    file pipeline from pipeline_ch

    output:
    val themap into pcfg_map

    exec:
    def pcfg_map=[:]
    pcfg = pipeline.text
    pcfg.split("\n").each {
        param-> def kv=param.split("=")
        pcfg_map[kv[0]]=kv[1]
    }
    if ( params.debug ) {
        println pcfg_map
    }
    themap = pcfg_map

}

process convert_analysis_cfg {
    input:
    file acfg from analysis_cfg_ch

    output:
    stdout nf_analysis_cfg

    """
    cat $acfg | sed 's/ /=/'
    """
}

process acfg_to_map {
    input:
    val acfg from nf_analysis_cfg

    output:
    val themap into acfg_map

    exec:
    def cfg_map=[:]
    acfg.split("\n").each {
        param-> def kv=param.split('=')
        cfg_map[kv[0]]=kv[1]
    }
    if ( params.debug ) {
        println cfg_map
    }
    themap = cfg_map
}

process analysis_init {
    input:
    val analysis_cfg_map from acfg_map
    val pipeline_cfg_map from pcfg_map

    output:
    val ai into analysis_info

    exec:
    println "Entering analysis init ..."
    key = "analysis_driver"
    ai = [:]
    ai[key] = pipeline_cfg_map["code_path"] + pipeline_cfg_map[key]
    key = "null_model"
    rp = "R_path"
    ai[key] = pipeline_cfg_map[rp] + pipeline_cfg_map[key]
    key = "null_model_report"
    ai[key] = pipeline_cfg_map[rp] + pipeline_cfg_map[key]

}

process null_model {
    echo true
    input:
    val ai from analysis_info

    output:
    file status into null_model_status

    script:
//    println "Entering null_model ..."
//    if ( params.debug ) {
//        println ai
//    }
    """
    echo sleeping for 10 secs > status
    sleep 2
    """
//    status = true

}
null_model_status.view { it }

/*
process null_model_report {
    echo true

    input:
    file x from track.flatten()

//    output:
//    stdout result

    """
    cat $x
    echo process track `date`
    """
}
*/
//result.view { it.trim() }
//track.println{"track: $it"}
//result.subscribe { println "track: $it" }
//result
//    .flatMap()
//    .subscribe { println "File: ${it.name} = ${it.text}"  }
