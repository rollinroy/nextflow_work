#!/usr/bin/env nextflow

params.analysis_cfg = "./null_model.config"
ac_list = params.analysis_cfg.split("\\.")
analysis_nf_cfg = params.analysis_cfg.split("\\.")[0] + ".config.nf"
//analysis_nf_cfg = ac_list[0] + ".config_nf"

//analysis_ch = Channel.fromPath(params.analysis_cfg)
analysis_ch = file(params.analysis_cfg)
x=file("x.cfg")


process convert_acfg {
    input:
    file acfg from analysis_ch

    output:
    stdout results

    """
    cat $acfg | sed 's/ /=/'
    """
}

process analysis_init {
    input:
    val acfg from results

    exec:
    def cfg_map=[:]
    acfg.split("\n").each {
        param-> def kv=param.split('=')
        cfg_map[kv[0]]=kv[1]
    }
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
