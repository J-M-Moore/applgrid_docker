# applgrid_docker
Builds a Docker image for APPLgrid and FK-table production.

## Build instructions
First acquire the dependencies. From the applgrid_docker repository, run:

```
git clone https://github.com/scarrazza/applgridphoton.git
git clone git@github.com:NNPDF/external.git
git clone git@github.com:NNPDF/nnpdf.git
git clone https://github.com/scarrazza/fiatlux.git
git clone https://github.com/scarrazza/apfel.git
git clone https://github.com/NNPDF/apfelcomb.git
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
For the Cambridge PBSP group, you can run Docker commands on the HPC using Singularity. First obtain, the image and run it:

```
singularity pull docker://jamesmmoore/applgrids
singularity run docker://jamesmmoore/applgrids
```

Once in the Singularity environment, we must redefine the $PATH variable so we avoid any conflicts with an existing conda installation (don't worry, this only affects the environment and is thus completely temporary):

```
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```

You should then be able to run the APPLgrid and FK-table generation as usual.

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

## FK-table production
TODO: write instructions for creating FK-tables from APPLgrids.
