c
c Example analysis for "p p > t t~ [QCD]" process.
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      subroutine analysis_begin(nwgt,weights_info)
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      implicit none
      integer nwgt
      character*(*) weights_info(*)
      integer i,kk,l,nwgt_analysis
      common/c_analysis/nwgt_analysis
      character*6 cc(1)
      data cc/'|T@NLO'/
      include 'dbook.inc'
      call inihist
      nwgt_analysis=nwgt
      if (nwgt_analysis*18.gt.nplots/4) then
         write (*,*) 'error in analysis_begin: '/
     &        /'too many histograms, increase NPLOTS to',
     &        nwgt_analysis*18*4
         stop 1
      endif
      do i=1,2
      do kk=1,nwgt_analysis
        l=(kk-1)*18+(i-1)*9
        call bookup(l+ 1,'m t-tx        '//cc(i)//weights_info(kk),
     &       75d0,325d0,400d0)
        call bookup(l+ 2,'m t-tx        '//cc(i)//weights_info(kk),
     &       80d0,400d0,480d0)
        call bookup(l+ 3,'m t-tx        '//cc(i)//weights_info(kk),
     &       100d0,480d0,580d0)
        call bookup(l+ 4,'m t-tx        '//cc(i)//weights_info(kk),
     &       120d0,580d0,700d0)
        call bookup(l+ 5,'m t-tx        '//cc(i)//weights_info(kk),
     &       160d0,700d0,860d0)
        call bookup(l+ 6,'m t-tx        '//cc(i)//weights_info(kk),
     &       160d0,860d0,1020d0)
        call bookup(l+ 7,'m t-tx        '//cc(i)//weights_info(kk),
     &       230d0,1020d0,1250d0)
        call bookup(l+ 8,'m t-tx        '//cc(i)//weights_info(kk),
     &       250d0,1250d0,1500d0)
        call bookup(l+ 9,'m t-tx        '//cc(i)//weights_info(kk),
     &       500d0,1500d0,2000d0)
      enddo
      enddo
      return
      end


cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      subroutine analysis_end(xnorm)
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      implicit none
      character*14 ytit
      double precision xnorm
      integer i
      integer kk,l,nwgt_analysis
      common/c_analysis/nwgt_analysis
      include 'dbook.inc'
      call open_topdrawer_file
      call mclear
      do i=1,NPLOTS
         call mopera(i,'+',i,i,xnorm,0.d0)
         call mfinal(i)
      enddo
      ytit='sigma per bin '
      do i=1,2
      do kk=1,nwgt_analysis
         l=(kk-1)*18+(i-1)*9
        call multitop(l+ 1,3,2,'m t-tx       ',ytit,'LIN')
        call multitop(l+ 2,3,2,'m t-tx       ',ytit,'LOG')
        call multitop(l+ 3,3,2,'m t-tx       ',ytit,'LOG')
        call multitop(l+ 4,3,2,'m t-tx       ',ytit,'LOG')
        call multitop(l+ 5,3,2,'m t-tx       ',ytit,'LOG')
        call multitop(l+ 6,3,2,'m t-tx       ',ytit,'LOG')
        call multitop(l+ 7,3,2,'m t-tx       ',ytit,'LOG')
        call multitop(l+ 8,3,2,'m t-tx       ',ytit,'LOG')
        call multitop(l+ 9,3,2,'m t-tx       ',ytit,'LOG')
      enddo
      enddo
      call close_topdrawer_file
      return                
      end


cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      subroutine analysis_fill(p,istatus,ipdg,wgts,ibody)
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      implicit none
      include 'nexternal.inc'
      integer istatus(nexternal)
      integer iPDG(nexternal)
      double precision p(0:4,nexternal)
      double precision wgts(*)
      integer ibody
      double precision wgt,var
      integer i,kk,l,nwgt_analysis
      common/c_analysis/nwgt_analysis
      double precision pttx(0:3),www,mtt
      double precision getrapidity,dot
      external getrapidity,dot
      if (nexternal.ne.5) then
         write (*,*) 'error #1 in analysis_fill: '/
     &        /'only for process "p p > t t~ [QCD]"'
         stop 1
      endif
      if (.not. (abs(ipdg(1)).le.5 .or. ipdg(1).eq.21)) then
         write (*,*) 'error #2 in analysis_fill: '/
     &        /'only for process "p p > t t~ [QCD]"'
         stop 1
      endif
      if (.not. (abs(ipdg(2)).le.5 .or. ipdg(2).eq.21)) then
         write (*,*) 'error #3 in analysis_fill: '/
     &        /'only for process "p p > t t~ [QCD]"'
         stop 1
      endif
      if (.not. (abs(ipdg(5)).le.5 .or. ipdg(5).eq.21)) then
         write (*,*) 'error #4 in analysis_fill: '/
     &        /'only for process "p p > t t~ [QCD]"'
         stop 1
      endif
      if (ipdg(3).ne.6) then
         write (*,*) 'error #5 in analysis_fill: '/
     &        /'only for process "p p > t t~ [QCD]"'
         stop 1
      endif
      if (ipdg(4).ne.-6) then
         write (*,*) 'error #6 in analysis_fill: '/
     &        /'only for process "p p > t t~ [QCD]"'
         stop 1
      endif
      do i=0,3
        pttx(i)=p(i,3)+p(i,4)
      enddo
      mtt    = dsqrt(dot(pttx, pttx))
      var=1.d0
      do i=1,2
         do kk=1,nwgt_analysis
         www=wgts(kk)
            l=(kk-1)*18+(i-1)*9
            if (ibody.ne.3 .and.i.eq.2) cycle
            call mfill(l+1,mtt,www)
            call mfill(l+2,mtt,www)
            call mfill(l+3,mtt,www)
            call mfill(l+4,mtt,www)
            call mfill(l+5,mtt,www)
            call mfill(l+6,mtt,www)
            call mfill(l+7,mtt,www)
            call mfill(l+8,mtt,www)
            call mfill(l+9,mtt,www)
         enddo
      enddo
c
 999  return      
      end
