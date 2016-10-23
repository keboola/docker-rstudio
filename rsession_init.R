
rscript <- Sys.getenv('SCRIPT')
fileName <- '/tmp/templatefile.json'
data <- readChar(fileName, file.info(fileName)$size)
configData <- jsonlite::fromJSON(data)
configData$contents <- rscript
jsonData <- jsonlite::toJSON(configData, auto_unbox = TRUE, pretty = TRUE)
writeChar(jsonData, '/data/.rstudio/sdb/per/t/AAAAAAA')
writeChar(rscript, '/data/main.R', eos = NULL)
