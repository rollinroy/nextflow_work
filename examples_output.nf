#!/usr/bin/env nextflow

params.analysis_cfg = "null_model.config"
params.pipeline_cfg = "pipeline.cfg"
ac_list = params.analysis_cfg.split("\\.")
analysis_nf_cfg = ac_list[0] + ".config_nf"

analysis_ch = Channel.fromPath(params.analysis_cfg)
//analysis_nf_ch = Channel.fromPath(analysis_nf_cfg)
analysis_nf_ch = file(analysis_nf_cfg)
pipeline_ch = Channel.fromPath(params.pipeline_cfg)


process pipeline_init {
    input:
    file pipeline from pipeline_ch

    output:
    val themap into init_cfg

    exec:
    def pcfg_map=[:]
    pcfg = pipeline.text
    pcfg.split("\n").each {
        param-> def kv=param.split("=")
        pcfg_map[kv[0]]=kv[1]
    }
//    println pcfg_map
    themap = pcfg_map

}

process convert_acfg {
    input:
    file acfg from analysis_ch

    output:
//    stdout nf_cfg
    file 'nf.cfg' into nf_cfg

    """
    cat $acfg | sed 's/ /=/' > nf.cfg
    """
}

process analysis_init {
    input:
//    val x from init_cfg
    file acfg from nf_cfg

    exec:
    the_cfg = acfg.text
    def cfg_map=[:]
    the_cfg.split("\n").each {
        param-> def kv=param.split(' ')
        cfg_map[kv[0]]=kv[1]
    }
//    println pcfg_map
    println cfg_map
}

//init_cfg.view { println it }

/*
// create map from string
def data="null_model=null_model.R"
def map=[:]

def kv2=data.split("=")
map[kv2[0]]=kv2[1]

println map.null_model

// create a map of all the lines in file (each line is xxx=yyy)
cfile=file('pipeline.cfg')
pcfg=cfile.text

def pcfg_map=[:]
pcfg.split("\n").each {
    param-> def kv=param.split("=")
    pcfg_map[kv[0]]=kv[1]
}

println pcfg_map
*/
