# R Studio
Docker image with [RStudio Sandbox](https://help.keboola.com/manipulation/transformations/sandbox/) based on Keboola [R for Custom Science](https://github.com/keboola/docker-custom-r). To run locally set `KBC_TOKEN` environment variable and run `docker-compose up`. Public image is available on [Quay](https://quay.io/repository/keboola/docker-rstudio).

### Running Locally

* Create a .env file in the root dir from the sample .env.dist and fill in the appropriate values
* `docker-compose build`
* `docker-compose up data-loader sandbox` and wait for it to setup
* Visit `http://localhost:8787` in your browser and login with the creds set in your env vars 

## License

MIT licensed, see [LICENSE](./LICENSE) file.
