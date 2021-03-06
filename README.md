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
For the Cambridge PBSP group, you can run Docker commands on the HPC using Singularity. You will need to use a slightly modified version of the Docker image that allows MG5 to interface nicely with the slurm-based cluster.

If you would like to build things yourself, checkout the appropriate branch in this repository first:

```
git checkout cambridge_hpc
```

and then build the Docker image from scratch as per the instructions above. 

Alternatively, you can obtain the image from Docker Hub. If running on the HPC, the correct command to use is:

```
singularity pull docker://jamesmmoore/applgrids:cambridge_hpc
```

Once you have obtained the image, you can run it using Singularity:

```
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
FK-tables can be produced using `apfelcomb`. It's best to start the docker image in bind-mount mode, bound to a folder which you will read and write FK-tables from, and will be accessible outside of the docker image. Once you have started the docker image in bind-mount mode, enter the `/hepsoftware/apfelcomb` directory. Currently, we need to do some technical fiddling before FK-tables can be produced; run:

```
apt-get update
apt-get install git
export LD_LIBRARY_PATH=/usr/local/lib
```

You should now be able to produce FK-tables by following the instructions in `apfelcomb`.
