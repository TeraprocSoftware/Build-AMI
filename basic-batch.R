library(BatchJobs)

conf = BatchJobs:::getBatchJobsConf()

conf$cluster.functions = makeClusterFunctionsOpenLava("../batch.tmpl")

reg = makeRegistry(id = "BatchJobsExample")
f = function(x) Sys.sleep(x)
batchMap(reg, f, 5:9)
submitJobs(reg)
showStatus(reg)
waitForJobs(reg)
showStatus(reg)
