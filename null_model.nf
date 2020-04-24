#!/usr/bin/env nextflow

params.ncores = "1"
params.debug = false
params.analysis_cfg = "null_model.config"
params.pipeline_cfg = "pipeline.cfg"
params.pipeline_job = params.analysis_cfg.split("\\.")[0]
// job def file
//jobdef_file = file("jobdef_nullmodel.def")
//jobdef_file.text = ""

// work directories
work_dirs = [:]
work_dirs['log'] = file('./log')
work_dirs['data'] = file('./data')
work_dirs['config'] = file('./config')
work_dirs['report'] = file('./report')
work_dirs['plots'] = file('./plots')

analysis_driver = ""

analysis_cfg_ch = Channel.fromPath(params.analysis_cfg)
pipeline_ch = Channel.fromPath(params.pipeline_cfg)
acfg_map = Channel.value()
jbdef = Channel.value()

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
        cfg_map[kv[0]]=kv[1].replace('"',"")
    }
    if ( params.debug ) {
        println cfg_map
    }
    themap = cfg_map
}

process analysis_init {
    input:
    val pipeline_cfg_map from pcfg_map
    val analysis_cfg_map from acfg_map

    output:
    val ai_map into ai_results

    exec:
    println "Entering analysis init ..."
    // create sub directories
    work_dirs.keySet().each( {
        nd=work_dirs[it]
        if (!nd.exists() ) {
            res=work_dirs[it].mkdir()
            assert res  : "Error creating " + it
        }
    } )
    // update the analysis cfg file to include directories
    work_dirs.keySet().each( {
        fname=work_dirs[it].getName()
        analysis_cfg_map[fname+"_prefix"] = fname + "/" + analysis_cfg_map['out_prefix']
    } )
    // create the job def map
    jobdef_map = [:]
    key = "analysis_driver"
    jobdef_map[key] = pipeline_cfg_map["code_path"] + pipeline_cfg_map[key]
    key = "null_model"
    jobdef_map[key] = pipeline_cfg_map["R_path"] + pipeline_cfg_map[key]
    key = "null_model_report"
    jobdef_map[key] = pipeline_cfg_map["R_path"] + pipeline_cfg_map[key]
    if ( params.debug ) {
        println "analysis_init - jobdef map:"
        println "\t" + jobdef_map
    }
    // results map
    ai_map = [:]
    ai_map["jbd"] = jobdef_map
    ai_map["acfg"] = analysis_cfg_map

}
//jobdef.subscribe { println it.text }

process null_model_cfg {
    input:
    val ai_map from ai_results

    output:
    val nmc_map into nmc_results

    exec:
    println "Entering null_model_cfg ..."
    // create the jobs cfg file
    // contents
    analysis_cfg_map = ai_map["acfg"]
    println "acfg map: \n" + analysis_cfg_map
    analysis_cfg_map['out_prefix'] = analysis_cfg_map['data_prefix'] + "_null_model"
    analysis_cfg_map['out_phenotype_file'] = analysis_cfg_map['data_prefix'] + "_phenotypes.RData"
    nc = []
    analysis_cfg_map.each( {
        key, value -> nc.add(key + " " + value)
    } )
    // file
    fname = analysis_cfg_map['config_prefix'] + "_null_model.config"
    null_cfg_file = file(fname)
    null_cfg_file.text = ""
    nc.each{
        null_cfg_file.append(it + "\n")
    }
    if ( params.debug ) {
        println "null_model_cfg - cfg file:" + null_cfg_file.getName()
    }
    // results map
    nmc_map = [:]
    nmc_map["jbd"] = ai_map["jbd"]
    nmc_map["ncf"] = null_cfg_file
}
//ncfg.subscribe { println it.text }


process null_model_pre {
    input:
    val nmc_map from nmc_results

    exec:
    println "Entering null_model_pre ..."
    // create the command line to execute
    jobdef_map = nmc_map["jbd"]
    ncfg_file = nmc_map["ncf"]
    nm_cmd = jobdef_map["analysis_driver"] + " " + jobdef_map["null_model"] + " " + ncfg_file + " --version 2.7.4"
    if ( params.debug ) {
        println "null_model_cfg - cmd:"
        println "\t" + nm_cmd
    }

}

//nm_out.subscribe { println it }
/*
process null_model_rep_cfg {

}
process null_model_rep {
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
