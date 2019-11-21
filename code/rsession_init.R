tryCatch({
    if (file.exists('/data/main.R')) {
        print("Reading main.R")
        rscript = readChar('/data/main.R', file.info('/data/main.R')$size)
    } else {
        rscript = ''
    }
    fileName <- '/tmp-rstudio/templatefile.json'
    data <- readChar(fileName, file.info(fileName)$size)
    configData <- jsonlite::fromJSON(data)
    configData$contents <- rscript
    jsonData <- jsonlite::toJSON(configData, auto_unbox = TRUE, pretty = TRUE)
    writeChar(jsonData, paste0('/data/.rstudio/sdb/per/t/AAAAAAA'), eos = NULL)
}, error = function(e) {
    print("Failed to load script.")
    quit(151)
})

library('keboola.r.transformation')
print("creating R RTransformation")
app <- RTransformation$new('/data')

packages <- Sys.getenv('PACKAGES')
print(paste0("Processing packages from:", packages))
if (packages != "" && packages != "[]") {
    app$packages <- tryCatch({
        as.character(jsonlite::fromJSON(packages))
    }, error = function(e) {
        print(paste0("Packages is not a JSON array ", packages))
        quit(save = 'no', status = 152, runLast = FALSE)
    })
    tryCatch({
        app$installModulePackages()
    }, error = function(e) {
        print(paste0("Failed to install packages ", e))
        quit(save = 'no', status = 153, runLast = FALSE)
    })
}
tags <- Sys.getenv('TAGS')
print(paste0("Processing tagged files from:", tags))
if (tags != "" && tags != "[]") {
    app$tags <- tryCatch({
        as.character(jsonlite::fromJSON(tags))
    }, error = function(e) {
        print(paste0("Tags is not a JSON array ", tags))
        quit(save = 'no', status = 154, runLast = FALSE)
    })
    tryCatch({
        app$prepareTaggedFiles()
    }, error = function(e) {
        print(paste0("Failed to prepare files ", e))
        quit(save = 'no', status = 155, runLast = FALSE)
    })
}
