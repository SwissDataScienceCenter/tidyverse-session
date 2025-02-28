# Tidyverse Session

This project builds an rocker-based image for an RStudio sessions in Renku V2. It uses the [rocker/tidyverse](https://rocker-project.org/images/versioned/rstudio.html) Docker base image and makes some modifications necessary for compatibility with Renku sessions.

## Customizing the environment

The image built by this project can be used to get a RenkuV2 session with RStudio as the front end. The image includes many widely-used packages (see [package-list](https://rocker-project.org/images/versioned/rstudio.html#overview)), but you may want to customize it further.

### Making changes

Clone this repo and make any changes you want in the Dockerfile.

After doing that, you should build the image and test that the app works. This requires Docker installed on your machine, but it will help you debug problems quickly.

For example, you can build and run with the following commands on Macs with Apple Silicon processors (for other machines, the build command might be different):

```
docker buildx build -t renku/rstudio-session --platform linux/amd64 .
docker run --rm -ti -p 8787:8787 renku/rstudio-session
```

If everything worked correctly, you will be able to connect a web browser to

http://localhost:3838/test-app/

And you should see your app there.
