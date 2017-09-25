tryCatch({
	rscript <- Sys.getenv('SCRIPT')
	# because EOS is null, rscript mustn't be empty
	if (nchar(rscript) == 0) {
		if (file.exists('/data/main.R')) {
			rscript = readChar('/data/main.R', file.info('/data/main.R')$size)
		} else {
			rscript = ' '
		}
	}
	fileName <- '/code/templatefile.json'
	data <- readChar(fileName, file.info(fileName)$size)
	configData <- jsonlite::fromJSON(data)
	configData$contents <- rscript
	jsonData <- jsonlite::toJSON(configData, auto_unbox = TRUE, pretty = TRUE)
	writeChar(jsonData, paste0('/data/.rstudio/sdb/per/t/AAAAAAA'))
	writeChar(rscript, '/data/main.R', eos = NULL)
}, error = function(e) {
	print("Failed to load script.")
	quit(121)
})

library('keboola.r.transformation')
app <- RTransformation$new('/data/')

packages <- Sys.getenv('PACKAGES')
if (packages != "") {
	print(paste0("Processing packages from:", packages))
	app$packages <- tryCatch({
		as.character(jsonlite::fromJSON(packages))
	}, error = function(e) {
		print(paste0("Packages is not a JSON array ", packages))
		quit(save = 'no', status = 122, runLast = FALSE)
	})
	tryCatch({
		app$installModulePackages()
	}, error = function(e) {
		print(paste0("Faield to install packages ", e))
		quit(save = 'no', status = 123, runLast = FALSE)
	})
}

tags <- Sys.getenv('TAGS')
if (tags != "") {
	print(paste0("Processing tagged files from:", tags))
	app$tags <- tryCatch({
		as.character(jsonlite::fromJSON(tags))
	}, error = function(e) {
		print(paste0("Tags is not a JSON array ", tags))
		quit(save = 'no', status = 124, runLast = FALSE)
	})
	tryCatch({
		app$prepareTaggedFiles()
	}, error = function(e) {
		print(paste0("Failed to prepare files ", e))
		quit(save = 'no', status = 125, runLast = FALSE)
	})
}
