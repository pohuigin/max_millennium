;make sunspot overlay images. if arposstr, a cut out centered on each AR will be created
;set OUTFILE to write PNGs of cutouts (e.g., '/Users/phiggins/data/magintoverlay_20130101') 
;	an AR number will be appended to each image name.
;OUTARR = the file names of the images written
pro mmmotd_delta_overlay,fmag,fint, $
	outfile=outfile,arposstr=arposstr,verb=verb, outarr=outarr, $
        magind=inhmiind, intind=inaiaind,dodark=dodark, doaiaprep=doaiaprep ; , magreadsdo=magreadsdo, intreadsdo=intreadsdo
	
if keyword_set(verb) then verb=1 else verb=0

;read in int and mag images
read_sdo,fmag,mind,mdat
;if keyword_set(magreadsdo) then read_sdo,fmag,mind,mdat else mreadfits,fmag,mind,mdat
read_sdo,fint,iind,idat
;if keyword_set(intreadsdo) then read_sdo,fint,iind,idat else mreadfits,fint,iind,idat
if verb then help,mdat,idat

if n_elements(mdat) lt 1 then return

;Check for input alternate index structures
if n_elements(inhmiind) eq 1 then mind=inhmiind
if n_elements(inaiaind) eq 1 then iind=inaiaind

;UN ROTATE THE HMI IMAGE!!!!!!
mdat=rot(mdat,-mind.crota2)
mind.crota2=0

;Run AIA prep to co-align the two images
if keyword_set(doaiaprep) then begin
   aia_prep,iind,idat,piind,pidat 
   aia_prep,mind,mdat,pmind,pmdat
   iind=piind & idat=pidat
   mind=pmind & mdat=pmdat
endif else begin
;Un-rotate the Igram
   idat=rot(idat,-iind.crota2)
   iind.crota2=0
endelse

;Run limb dark correction for WL image
if keyword_set(dodark) then begin
   xyz = [ iind.crpix1, iind.crpix2, iind.rsun_obs/iind.CDELT1 ]
   darklimb_correct, idat, lidat, lambda = iind.WAVELNTH, limbxyr = xyz
   idat=lidat
endif

;determine WL statistical moments
;medint=median(pidat[1500:2500,1500:2500])
;stdint=stddev(pidat[1500:2500,1500:2500])

;determine WL thresholds for umbrae and penumbrae
;threshumb=medint*[0.60,0.65]
;threshpen=medint*[0.85,0.90]

;determine WL plotting range
;dran=[medint-13.*stdint,medint+2.*stdint]
intrange=[0.1,1.2]

;create map structures out of them
mindex2map,iind,idat,intmap
mindex2map,mind,mdat,magmap

;differentially rotate the magnetic field map to the WL
;magmap=drot_map(magmap,/fast,ref_map=intmap)
magmap=drot_map(magmap,time=intmap.time)

;Run over every AR and make overlay cutouts
nars=n_elements(arposstr)
for i=0,nars-1 do begin

	;differentially rotate the AR positions to the WL
	rothel2xy,arposstr[i].hgpos,arposstr[i].date,intmap.time,dum1,arhcpos0,arhcpos
        if arhcpos[0] eq -9999 or arhcpos[1] eq -9999 then arhcpos=arhcpos0

print,'DOING SUBMAP:'
print,'xr='+strjoin(strtrim([arhcpos[0]-200.,arhcpos[0]+200.],2),',')
print,'yr='+strjoin(strtrim([arhcpos[1]-200.,arhcpos[1]+200.],2),',')

	;make sub maps
	sub_map,magmap,submagmap,xrange=[arhcpos[0]-200.,arhcpos[0]+200.],yrange=[arhcpos[1]-200.,arhcpos[1]+200.],/noplot
	sub_map,intmap,subintmap,/noplot,xrange=[arhcpos[0]-200.,arhcpos[0]+200.],yrange=[arhcpos[1]-200.,arhcpos[1]+200.] ;,ref_map=submagmap

        ;get the cut-out indexes
        map2index,subintmap,subintind
        map2index,submagmap,submagind

        ;update the full indexes with these processed indexes
        mindex_update, subintind, iind, subiindfull,/nozero
        mindex_update, submagind, mind, submindfull,/nozero

        ;Run the delta spot finder
        which,'find_delta'
        delta=find_delta(cimg=subintmap.data,mimg=submagmap.data,cindex=subiindfull,mindex=submindfull)

;Thought I needed to change the numbers around, but maybe not...
;128 150 200        
;deltamsk=delta.mskmap.data
;wnumb=where()
;wpumb=
;wpen=
;delta.mskmap.data=deltamsk

;	;set dynamic range of maps
;	;set range to below that of named colors
;	submagmap.data=bytscl(submagmap.data,min=-500,max=500)
	
        ;Define the dimensions of the plot window
        resxy=[1600,800]

	;set up buffer plotting
	if keyword_set(outfile) then begin
		set_plot, 'z'
		
		thisimg=outfile+'_'+strtrim(arposstr[i].ars,2)

		;Save the delta structure
		delta_struct=delta
		save,delta_struct,file=thisimg+'_struct.sav'

		device, set_resolution = resxy, decomp=0, set_pixel_depth=24

;		psopen,thisimg+'.eps', $
;                       XSIZE=36, YSIZE=18, /color, /encapsulated
		!p.background = 255
		!p.color = 0

             endif else window,xs=resxy[0],ys=resxy[1]
	
	;make plot
	erase
	!p.multi=[2,2,1]

        loadct,0,/sil
        plot_map,delta.mmap,drange=[-500,500],/iso
        setcolors,/sil,/sys
        plot_map,delta.mskmap,level=[130,131],/over,color=!blue,thick=2
;       plot_map,delta.mskmap,level=[130,131],/over,color=!gray,thick=1
        plot_map,delta.mskmap,level=[151,152],/over,color=!red,thick=2
        plot_map,delta.mskmap,level=[100,101],/over,color=!green,thick=2

        xyouts,0.1,0.15,strtrim(arposstr[i].hgpos,2),chars=3,charthick=2,color=0,/norm

	!p.multi=[1,2,1]
	loadct,0,/sil
	plot_map,subintmap,dran=dran,/noerase,/iso,drange=intrange
	xyouts,0.6,0.15,strtrim(arposstr[i].ars,2),chars=3,charthick=2,color=0,/norm
        setcolors,/sys,/sil
        ndelta=delta.ndelta
        for j=0,ndelta-1 do draw_circle,(delta.DLTCEN)[0,j],(delta.DLTCEN)[1,j],20,color=!Red,thick=2
        for j=0,ndelta-1 do plots,(delta.DLTCEN)[0,j],(delta.DLTCEN)[1,j],color=!Red,ps=4
        for j=0,ndelta-1 do xyouts,0.6,0.85-j/20.,strtrim(j,2)+' HCPos='+strtrim((delta.DLTCEN)[0,j],2)+','+strtrim((delta.DLTCEN)[1,j],2)+'; UmFluxN='+strtrim((delta.DLTUNFLX)[j],2)+'; UmFluxP='+strtrim((delta.DLTUPFLX)[j],2),color=0,chars=1,/norm
        xyouts,0.6,0.9,'N Delta='+strtrim(fix(ndelta),2),chars=3,charthick=2,color=0,/norm


	;write the buffer to an image
	if keyword_set(outfile) then begin
;;		tvlct,rr,gg,bb,/get
		zb_plot=tvrd(true=1)
;;		zb1=bytscl(tvrd(channel=1,/words)) & zb2=bytscl(tvrd(channel=2,/words)) & zb3=bytscl(tvrd(channel=3,/words))
;;		zb_plot=bytarr(3,resxy[0],resxy[1])
;;		zb_plot[0,*,*]=zb1 & zb_plot[1,*,*]=zb2 & zb_plot[2,*,*]=zb3

		write_png, thisimg+'.png', zb_plot;, rr,gg,bb
		set_plot, 'x'

;Make thumbnail images
		set_plot, 'z'
                erase
		resxy=[150,150]
 		device, set_resolution = resxy, decomp=0;, set_pixel_depth=24
                
                !p.multi=0
                loadct,0,/sil
                plot_image,bytscl(congrid(delta.mmap.data,resxy[0],resxy[1]),min=-500,max=500),position=[0,0,1,1],xticklen=0.0001,yticklen=0.0001
                zb_plot=tvrd()

               	write_png, thisimg+'.thumb.png', zb_plot
		set_plot, 'x'

		if n_elements(outarr) lt 1 then outarr=thisimg else outarr=[outarr,thisimg+'.png']
	endif else stop
	
endfor

end
