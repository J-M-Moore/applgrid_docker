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
For the Cambridge PBSP group, you can run Docker commands on the HPC using Singularity. Example submit files are included in the example folder on this branch. To make APPLgrids, run:

```
sbatch submit_prepare
```

from the example folder. Once the job is done (it should take a very short time), we are ready to fill the grids. Run:

```
sbatch --array=1-100 submit_fill
```

where --array=1-100 specifies that we want to make 100 different grids of a particular precision. To combine the grids, we run:

```
combine_grids 100 17
```

where 100 is the number of grids produced, and 17 is the index of the final bin. The results can then be found in the applgrids directory of the example folder.

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
