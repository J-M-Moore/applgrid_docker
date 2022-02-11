/***************************************************************
* Small code to read in computed APPLgrids, and print out all 
* error replicas. This allows one to easily extend the code to 
* compute PDF uncertainties
* 
* Also plots the ratio of the convoluted grid with the MCFM numbers 
* To ensure the value is 1 (check bridge implementation ok)   
* 
* Emma Slade 2017
***************************************************************/
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <stdio.h>
#include <cstdlib>

#include "appl_grid/appl_grid.h"
#include "appl_grid/appl_timer.h"

#include <TCanvas.h>
#include <TH1D.h>
#include <TFile.h>
#include <TPad.h>

// lhapdf routines
#include "LHAPDF/LHAPDF.h"

extern "C" void evolvepdf_(const double& x, const double& Q, double* xf);
extern "C" double alphaspdf_(const double& Q);

TH1D* divide( const TH1D* h1, const TH1D* h2 ) {

  if ( h1==NULL || h2==NULL ) return NULL;

  TH1D* h = (TH1D*)h1->Clone();

  for ( int i=1 ; i<=h1->GetNbinsX() ; i++ ) {
    double b  = h2->GetBinContent(i);
    //double be = h2->GetBinError(i);
    double t  = h1->GetBinContent(i);
    //double te = h1->GetBinError(i);

    double r  = ( b!=0 ? t/b : 0 );
    //double re = ( b!=0 ? sqrt((r+1)*r/b) : 0 );
    double re = 0;

    h->SetBinContent( i, r );
    h->SetBinError( i, re ) ;
  }

  double hmin = h->GetBinContent(1);
  double hmax = h->GetBinContent(1);

  for ( int i=2 ; i<=h->GetNbinsX() ; i++ ) {
    double d = h->GetBinContent(i);
    if ( hmin>d ) hmin=d;
    if ( hmax<d ) hmax=d;
  }

  if ( h->GetMaximum()<1.001 ) h->SetMaximum(1.001);
  if ( h->GetMinimum()>0.999 ) h->SetMinimum(0.999);

  return h;
}

int main(int argc, char** argv) {

  if ( argc<3 ) {
    std::cout << "Usage: checkref <gridname> <pdfset>" << std::endl;
    return -1;
  }

  // Open grid
  std::string gridName(argv[1]);
  appl::grid g( gridName.c_str() );
  g.trim(); // trim away uneeded memory

 // print the grid documentation 
  std::cout << g.getDocumentation() << std::endl; 

  // get all the reference histograms

  TFile* f = new TFile(argv[1]);
  TH1D* reference = (TH1D*)f->Get("grid/reference");

  // PDF set (and member) set up:

  std::string _pdfname = argv[2];

  int Npdf = 0;
  if ( argc>3 ) Npdf = std::atoi(argv[3]);

  LHAPDF::initPDFSet(_pdfname.c_str(), Npdf );

  const int nLoops = g.nloops();

  int Nset = LHAPDF::numberPDF();
  std::vector<double>  vec_xsec = g.vconvolute( evolvepdf_, alphaspdf_, nLoops); 

  std::vector<double> xs;

  std::cout << "performing convolution ..." << std::endl;

  struct timeval mytimer = appl_timer_start();

  TH1D* xsec = g.convolute(evolvepdf_, alphaspdf_, nLoops);

  double mytime = appl_timer_stop(mytimer);

  std::cout << "done (" << mytime << " ms)" << std::endl;

  // Now write out all replica results 
  for (int i = 0; i <= Nset; ++i) {

    struct timeval atimer = appl_timer_start();
    LHAPDF::initPDFSet( _pdfname, i);
    double atime = appl_timer_stop(atimer);

    std::cout << "set" << i << "\tinitPDF time " << atime << " ms" << std::endl;

    atimer = appl_timer_start();
    xs = g.vconvolute( evolvepdf_, alphaspdf_, nLoops);
    atime = appl_timer_stop(atimer);
    std:: cout << "convolution time " << atime << " ms " << std::endl;

    for (int j = 0; j< vec_xsec.size(); ++j ) 
      std::cout << "xsec[" << j << "]\t= " << xs[j] << std::endl;
        
  }  

  // Plot cross-sections and ratio of APPLgrid results to MCFM 
  int nbins = xsec -> GetSize()-2;

  if ( nbins == 1 )
    {
      std::cout << "[" << xsec->GetBinLowEdge(1) << ";" << xsec->GetBinLowEdge(2) << "] = "
		<< xsec->GetBinContent(1)*(xsec->GetBinLowEdge(2)-xsec->GetBinLowEdge(1))
		<< std::endl;
    }
  else {
    for (int i = 1; i < xsec->GetSize()-1; i++ ) {
      std::cout << "[" << xsec->GetBinLowEdge(i) << ";" << xsec->GetBinLowEdge(i+1) << "] = "
		<< xsec->GetBinContent(i)//*(xsec->GetBinLowEdge(i+1)-xsec->GetBinLowEdge(i))
		<< std::endl;
    }
  }
  
  xsec->SetName("xsec");
  xsec->SetTitle(reference->GetTitle());

  xsec->SetLineColor(kBlue);
  xsec->DrawCopy();
  reference->SetLineColor(kBlack);
  reference->SetLineStyle(2);
  reference->DrawCopy("same");

  gPad->Print("xsec.pdf");

  // now take all the ratios etc

  TH1D* ratio = divide( xsec, reference );

  if ( ratio ) {
    ratio->SetName("ratio");
  }

  ratio->DrawCopy();
  gPad->Print("ratio.pdf");
  
  return 0;
}
