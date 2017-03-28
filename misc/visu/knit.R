#!/usr/bin/env Rscript

library(docopt)

'usage: tool.R <input>... [-o=<output1>]
        tool.R -h | --help

options:
 <input1>        The input data for truthful mcts.
 <input2>        The input data for cheating mcts.
 -o=<output>  Output file [Default: tmp.pdf]
 ' -> doc

args<- docopt(doc)

print(getwd())

library(knitr)
knit('misc/visu/means.Rtex',args$o)
