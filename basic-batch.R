library(BatchJobs)

conf = BatchJobs:::getBatchJobsConf()

conf$cluster.functions = makeClusterFunctionsLSF("/home/clusteradmin/batch.tmpl")

reg = makeRegistry(id = "BatchJobsExample", seed = 123)
f = function(x) Sys.sleep(x)
batchMap(reg, f, 5:9)
submitJobs(reg)
showStatus(reg)
waitForJobs(reg)
showStatus(reg)
