# We work in Ubuntu 20.04
FROM ubuntu:18.04
# Needed to use 'source' later on
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
# Add some new channels to the package manager
RUN echo deb http://dk.archive.ubuntu.com/ubuntu xenial main >> /etc/apt/sources.list && echo deb http://dk.archive.ubuntu.com/ubuntu xenial universe >> /etc/apt/sources.list
RUN apt-get update
# Install the old compilers
RUN apt-get install -y ca-certificates
# Install Python 2.7.18
RUN apt-get install -y python python-dev
# Install an old Fortran compiler and symlink it
RUN apt-get install -y gfortran-7 && ln -s /usr/bin/gfortran-7 /usr/bin/gfortran
# Install make, so we can actually compile anything at all
RUN apt-get install -y make
# Install Root 6.14/06.
RUN mkdir hepsoftware
RUN apt-get install -y wget
# Some root packages are stupid and require interactive answers during installation, so demand that we always pick the default response
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata
RUN apt-get install -y libx11-dev libxext-dev libxft-dev libxpm-dev cmake libssl-dev libtinfo5 libtbb-dev
RUN cd hepsoftware && wget https://root.cern/download/root_v6.14.06.Linux-ubuntu18-x86_64-gcc7.3.tar.gz&& tar -xf root_v6.14.06.Linux-ubuntu18-x86_64-gcc7.3.tar.gz && rm -r root_v6.14.06.Linux-ubuntu18-x86_64-gcc7.3.tar.gz
# Sort out the paths to root
RUN echo export PATH=$PATH:/hepsoftware/root/bin >> /root/.bashrc
RUN echo /hepsoftware/root/lib >> /etc/ld.so.conf && ldconfig
# Install the secret NNPDF repo.
COPY external /hepsoftware/external
# Compile old reliable, fastjet
RUN cd hepsoftware/external/fastjet-3.3.1 && ./configure && make && make check && make install
# Install the applgridphoton repository.
COPY applgridphoton /hepsoftware/applgridphoton
# Install the autotools and hence install applgridphoton
RUN apt-get install -y autoconf
RUN apt-get install -y libtool
RUN source hepsoftware/root/bin/thisroot.sh && cd hepsoftware/applgridphoton && autoreconf -i && ./configure && make && make install
# Install LHAPDF, needed for amcfast
RUN cd hepsoftware && wget https://lhapdf.hepforge.org/downloads/?f=LHAPDF-6.2.3.tar.gz -O LHAPDF-6.2.3.tar.gz && tar -xf LHAPDF-6.2.3.tar.gz && rm -r LHAPDF-6.2.3.tar.gz && cd LHAPDF-6.2.3 && ./configure && make && make install
# Install amcfast
RUN source hepsoftware/root/bin/thisroot.sh && cd hepsoftware/external/amcfast-2.0.0 && ./configure && make && make install
# Install vim so we can read stuff when we open MG5
RUN apt-get install -y vim
# Run MG5 at NLO to get ninja, collier, etc and do all compilations in advance
# Need to replace some files in MG5 first, to make LHAPDF compatible
COPY pdf_lhapdf62.cc /hepsoftware/external/MG5_aMC_v2_6_4/Template/LO/Source/PDF/pdf_lhapdf62.cc 
RUN rm /hepsoftware/external/MG5_aMC_v2_6_4/Template/LO/Source/PDF/makefile
COPY makefile /hepsoftware/external/MG5_aMC_v2_6_4/Template/LO/Source/PDF/makefile
RUN cd /hepsoftware/external/MG5_aMC_v2_6_4 && echo "generate p p > t t~ [QCD]" >> nlo_test.txt && echo "output nlo_test" >> nlo_test.txt && echo "launch nlo_test" >> nlo_test.txt && echo "2" >> nlo_test.txt && echo "set pdlabel=lhapdf" >> nlo_test.txt && bin/mg5_aMC nlo_test.txt
# Remove the test folder
RUN cd /hepsoftware/external/MG5_aMC_v2_6_4 && rm -r nlo_test
# Compile APPLgrid_check after copying the corrected file across
RUN rm /hepsoftware/external/APPLgrid_check/ratio_check.cxx
COPY ratio_check.cxx /hepsoftware/external/APPLgrid_check/ratio_check.cxx
RUN cd /hepsoftware/external/APPLgrid_check && make
