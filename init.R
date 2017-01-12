# install really required packages
install.packages(
	c('readr'), 
	dependencies = c("Depends", "Imports", "LinkingTo"), 
	INSTALL_opts = c("--no-html")
)
