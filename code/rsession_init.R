
rscript <- Sys.getenv('SCRIPT')
user <- Sys.getenv('USER')
# because EOS is null, rscript mustn't be empty
if (nchar(rscript) == 0) {
    rscript = ' '
}
fileName <- '/code/templatefile.json'
data <- readChar(fileName, file.info(fileName)$size)
configData <- jsonlite::fromJSON(data)
configData$contents <- rscript
jsonData <- jsonlite::toJSON(configData, auto_unbox = TRUE, pretty = TRUE)
writeChar(jsonData, paste0('/data/.rstudio/sdb/per/t/AAAAAAA'))
writeChar(rscript, '/data/main.R', eos = NULL)

library('keboola.r.transformation')
app <- RTransformation$new('/data/')

packages <- Sys.getenv('PACKAGES')
if (packages != "") {
	print(paste0("Processing packages from:", packages))
	app$packages <- tryCatch({
		as.character(jsonlite::fromJSON(packages))
	}, error = function(e) {
		print(paste0("Packages is not a JSON array ", packages))
	})
	app$installModulePackages()
}

tags <- Sys.getenv('TAGS')
if (tags != "") {
	print(paste0("Processing tagged files from:", tags))
	app$tags <- tryCatch({
		as.character(jsonlite::fromJSON(tags))
	}, error = function(e) {
		print(paste0("Tags is not a JSON array ", tags))
	})
	app$prepareTaggedFiles()
}