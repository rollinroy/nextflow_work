#!/usr/bin/env nextflow

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
