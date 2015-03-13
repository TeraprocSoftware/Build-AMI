library(BatchJobs)
library(BiocParallel)

setwd("./examples/")

FUN <- function(i) {
        system("hostname", intern=TRUE)
}

funs = makeClusterFunctionsLSF("../batch.tmpl")
param <- BatchJobsParam(4, cluster.functions=funs)
register(param)
## do work
xx <- bplapply(1:100, FUN)
table(unlist(xx))

