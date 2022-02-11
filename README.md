# applgrid_docker
Builds a docker image for APPLgrid production.

## Build instructions
From inside the repo, run:

```
docker build -t applgrids .
```

You should then be able to run the docker image with:

```
docker run -it applgrids
```

## Known issues
MG5 does not come with all the tools required for NLO analysis (namely ninja, collier) in this docker image, 
and they must be downloaded on a first use of MG5. This is to be fixed in the Dockerfile
eventually.
