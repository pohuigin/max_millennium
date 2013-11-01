;make sunspot overlay images. if arposstr, a cut out centered on each AR will be created
;set OUTFILE to write PNGs of cutouts (e.g., '/Users/phiggins/data/magintoverlay_20130101') 
;	an AR number will be appended to each image name.
;OUTARR = the file names of the images written
pro mmmotd_sunspot_overlay,fmag,fint, $
	outfile=outfile,arposstr=arposstr,verb=verb, outarr=outarr, $
        readsdo=readsdo, hmiindex=inhmiind, aiaindex=inaiaind
	
if keyword_set(verb) then verb=1 else verb=0

;read in int and mag images
if keyword_set(readsdo) then read_sdo,fmag,mind,mdat else mreadfits,fmag,mind,mdat
if keyword_set(readsdo) then read_sdo,fint,iind,idat else mreadfits,fint,iind,idat
if verb then help,mdat,idat

if n_elements(mdat) lt 1 then return

;Check for input alternate index structures
if n_elements(inhmiind) eq 1 then mind=inhmiind
if n_elements(inaiaind) eq 1 then iind=inaiaind

;UN ROTATE THE HMI IMAGE!!!!!!
mdat=rot(mdat,-mind.crota2)
mind.crota2=0

;Run AIA prep to co-align the two images
aia_prep,iind,idat,piind,pidat 
aia_prep,mind,mdat,pmind,pmdat

;Run limb dark correction for WL image
xyz = [ piind.crpix1, piind.crpix2, piind.rsun_obs/piind.CDELT1 ]
darklimb_correct, pidat, plidat, lambda = 4500, limbxyr = xyz
pidat=plidat

;determine WL statistical moments
medint=median(pidat[1500:2500,1500:2500])
stdint=stddev(pidat[1500:2500,1500:2500])

;determine WL thresholds for umbrae and penumbrae
threshumb=medint*[0.60,0.65]
threshpen=medint*[0.85,0.90]

;determine WL plotting range
dran=[medint-13.*stdint,medint+2.*stdint]

;create map structures out of them
index2map,iind,pidat,intmap
index2map,mind,mdat,magmap

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
	sub_map,intmap,subintmap,/noplot,xrange=[arhcpos[0]-200.,arhcpos[0]+200.],yrange=[arhcpos[1]-200.,arhcpos[1]+200.] ;ref_map=submagmap
	
;	;set dynamic range of maps
;	;set range to below that of named colors
;	submagmap.data=bytscl(submagmap.data,min=-500,max=500)
	
	
	;set up buffer plotting
	if keyword_set(outfile) then begin
		set_plot, 'z'
		resxy=[1600,800]

		thisimg=outfile+'_'+strtrim(arposstr[i].ars,2)

		device, set_resolution = resxy, decomp=0, set_pixel_depth=24

;		psopen,thisimg+'.eps', $
;                       XSIZE=36, YSIZE=18, /color, /encapsulated
		!p.background = 255
		!p.color = 0

	endif
	
	;make plot
	erase
	!p.multi=[2,2,1]
	loadct,0
	plot_map,submagmap,drange=[-500,500],/iso
	
	setcolors,/sys;,/decomp
	plot_map,subintmap,/over,level=threshpen,c_color=!blue,c_thick=1
	plot_map,subintmap,/over,level=threshumb,c_color=!red,c_thick=1
        xyouts,0.1,0.15,strtrim(arposstr[i].hgpos,2),chars=3,charthick=2,color=0,/norm

	!p.multi=[1,2,1]
	loadct,0
	plot_map,subintmap,dran=dran,/noerase,/iso
	xyouts,0.6,0.15,strtrim(arposstr[i].ars,2),chars=3,charthick=2,color=0,/norm

	;write the buffer to an image
	if keyword_set(outfile) then begin
;;		tvlct,rr,gg,bb,/get
		zb_plot=tvrd(true=1)
;;		zb1=bytscl(tvrd(channel=1,/words)) & zb2=bytscl(tvrd(channel=2,/words)) & zb3=bytscl(tvrd(channel=3,/words))
;;		zb_plot=bytarr(3,resxy[0],resxy[1])
;;		zb_plot[0,*,*]=zb1 & zb_plot[1,*,*]=zb2 & zb_plot[2,*,*]=zb3

		write_png, thisimg+'.png', zb_plot;, rr,gg,bb

;;		zb_plot = tvrd()

;		psclose		               
;                print,'convert -density 200 '+thisimg+'.eps '+thisimg+'.png'
;                spawn,'convert -density 200 '+thisimg+'.eps '+thisimg+'.png',/sh
;                spawn,'convert '+thisimg+'.png -resize 10% '+thisimg+'.thumb.png'

;;		thisimg=outfile+'_'+strtrim(arposstr[i].ars,2)+'.png'
;;		wr_png, thisimg, zb_plot
;stop

;Make thumbnail images
               	write_png, thisimg+'.thumb.png', congrid(zb_plot,3.,200.,200.*resxy[1]/resxy[0])

		set_plot, 'x'
		if n_elements(outarr) lt 1 then outarr=thisimg else outarr=[outarr,thisimg+'.png']
	endif else stop
	
endfor

end
