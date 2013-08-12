;make sunspot overlay images. if arposstr, a cut out centered on each AR will be created
;set OUTFILE to write PNGs of cutouts (e.g., '/Users/phiggins/data/magintoverlay_20130101') 
;	an AR number will be appended to each image name.
;OUTARR = the file names of the images written
pro mmmotd_sharp_overlay,fmag,fint,fbr, $
	outfile=outfile,verb=verb, outpngs=outpngs
	
if keyword_set(verb) then verb=1 else verb=0

nf=n_elements(fmag)

outpngs=strarr(nf)

;Get a list of NOAA numbers
mreadfits,fmag,indmag,/nodata
arlist=strtrim(indmag.NOAA_AR,2)

arlon=(indmag.LON_MIN+indmag.LON_MAX)/2.
arlat=(indmag.LAT_MIN+indmag.LAT_MAX)/2.

;Fill in missing NOAA numbers with place holders
noname=string(indgen(nf),form='(I05)')
w0=where(arlist eq '0')
if w0[0] ne -1 then arlist[w0]=noname[w0] 

for i=0,nf-1 do begin

;read in int and mag images
   read_sdo,fmag[i],mind,mdat
   read_sdo,fint[i],iind,idat
   read_sdo,fbr[i],bind,bdat

   if verb then help,mdat,idat,bdat

   mindex2map,mind,mdat,mmap
   mindex2map,iind,idat,imap
   mindex2map,bind,bdat,bmap

;determine WL statistical moments
   medint=median(idat)
   stdint=stddev(idat)

;determine WL thresholds for umbrae and penumbrae
   threshumb=medint*[0.60,0.65]
   threshpen=medint*[0.85,0.90]

;determine WL plotting range
   idran=[medint-7.5*stdint,medint+2.*stdint]

;If no NOAA ARs are present, then skip on...
;   if iind.NOAA_NUM eq 0 then continue

 ;  xyz = [ iind.crpix1, iind.crpix2, iind.rsun_obs/iind.CDELT1 ]
 ;  darklimb_correct, idat, lidat, lambda = 6173, limbxyr = xyz
 ;  idat=lidat

;stop

   if n_elements(outfile) eq 1 then begin
      
		thisimg=outfile+'_'+strtrim(arlist[i],2)
                
                imgsz=float(size(idat,/dim))
                ysize=(imgsz[1]/imgsz[0])*54./3.

                !p.color=0
                !p.background=255

		psopen,thisimg+'.eps', $
                        XSIZE=48., YSIZE=ysize, /color, /encapsulated

   endif

   !p.multi=[0,3,1]
   loadct,0 

   plot_map,mmap,drange=[-500,500]

   xyouts,0.05,0.15,strtrim(arlist[i],2),color=0,/norm,chars=1.5,charthick=2

   xyouts,0.25,0.15,'BLOS',color=0,/norm,chars=1.5,charthick=2

   xyouts,0.05,0.75,'LAT:'+strtrim(arlat[i],2)+' , LON:'+strtrim(arlon[i],2),color=0,/norm,chars=1.5,charthick=2

   plot_map,imap, dran=idran

   xyouts,0.56,0.15,'IGRAM',color=0,/norm,chars=1.5,charthick=2

   setcolors,/sys
   plot_map,bmap,level=[500,1000],color=!red,/over
   plot_map,bmap,level=[-1000,-500],color=!blue,/over
   
   loadct,0
   plot_map,bmap,drange=[-500,500]

   xyouts,0.85,0.15,'BRAD',color=0,/norm,chars=1.5,charthick=2

   setcolors,/sys

   plot_map,imap,level=threshumb,color=!red,/over
   plot_map,imap,level=threshpen,color=!blue,/over



;   plot_map,imap,level=0.65*median(imap.data),color=!red,/over

;   plot_map,imap,level=0.85*median(imap.data),color=!blue,/over

   if n_elements(outfile) eq 1 then begin
   
   		psclose		
 ;               print,'convert -density 150 '+thisimg+'.eps '+thisimg+'.png'
  ;              spawn,'convert -density 150 '+thisimg+'.eps '+thisimg+'.png',/sh

                outpngs[i]=thisimg+'.png'

   endif
   

   
endfor

return

end
