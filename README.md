# applgrid_docker
Builds a docker image for APPLgrid production.

## Build instructions
From inside the repo, run:

```
cd external && git checkout MG5_fixed && cd ..
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

A version that has all NLO tools is available from Docker Hub at <https://hub.docker.com/repository/docker/jamesmmoore/applgrids>.


## APPLgrid production
To make an APPLgrid, enter the MG5 directory, and run MG5.

```
cd /hepsoftware/external/MG5_aMC_v2_6_4
bin/mg5_aMC
```

Make sure to *refuse* any update! Generate, output and launch a process via:

```
generate p p > t t~ [QCD]
output nlo_test
launch nlo_test
```

Switch to fixed_order mode when prompted. You must also change the 
run_card so that pdlabel=lhapdf, and iappl=1 (at this stage, the APPLgrids are
being prepared, but are not being filled). You must also change the analysis
to topdrawer, since APPLgrids do not work with the standard HwU analysis.

Complete the run, then launch again:

```
launch nlo_test
```

This time, you must pick iappl=2 (at this stage, the grids you prepared 
on the first run are now being filled), but leave all other settings
untouched. After the run completes, you have made an APPLgrid!
