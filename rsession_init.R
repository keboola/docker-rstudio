
rscript <- Sys.getenv('SCRIPT')
user <- Sys.getenv('USER')
# because EOS is null, rscript mustn't be empty
if (nchar(rscript) == 0) {
    rscript = ' '
}
fileName <- '/tmp/templatefile.json'
data <- readChar(fileName, file.info(fileName)$size)
configData <- jsonlite::fromJSON(data)
configData$contents <- rscript
jsonData <- jsonlite::toJSON(configData, auto_unbox = TRUE, pretty = TRUE)
writeChar(jsonData, paste0('/data/.rstudio/sdb/per/t/AAAAAAA'))
writeChar(rscript, '/data/main.R', eos = NULL)
