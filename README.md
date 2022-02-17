# applgrid_docker
Builds a Docker image for APPLgrid production.

## Build instructions
First acquire the dependencies, applgridphoton and the NNPDF/external repo. Run:

```
git clone https://github.com/scarrazza/applgridphoton.git
git clone git@github.com:NNPDF/external.git
```

Check out the correct branch of the NNPDF/external repo, and build using the standard Docker command:

```
cd external && git checkout MG5_fixed && cd ..
docker build -t applgrids .
```

You should then be able to run the Docker image with:

```
docker run -it applgrids
```

## Docker Hub image
A pre-built image is available from Docker Hub, <https://hub.docker.com/r/jamesmmoore/applgrids>.

## Running on the Cambridge HPC
For the Cambridge PBSP group, you can run Docker commands on the HPC using Singularity. An example submit_file is included in the repository.

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
