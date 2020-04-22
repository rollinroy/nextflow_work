#!/usr/bin/env nextflow

myMap = ["China": 1 , "India" : 2, "USA" : 3]
println "mymap is " + myMap
result = 0
myMap.keySet().each( { result+= myMap[it] } )
println result

Channel.from(1,2,3)
    .flatMap{ n -> [n*2, n*3] }
    .subscribe{println "value: $it"}
