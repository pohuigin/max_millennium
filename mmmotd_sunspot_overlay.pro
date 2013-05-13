;make sunspot overlay images. if arposstr, a cut out centered on each AR will be created
;set OUTFILE to write PNGs of cutouts (e.g., '/Users/phiggins/data/magintoverlay_20130101') 
;	an AR number will be appended to each image name.
;OUTARR = the file names of the images written
pro mmmotd_sunspot_overlay,fmag,fint, $
	outfile=outfile,arposstr=arposstr,verb=verb, outarr=outarr
	
if keyword_set(verb) then verb=1 else verb=0

;read in int and mag images
mreadfits,fmag,mind,mdat
mreadfits,fint,iind,idat
if verb then help,mdat,idat

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
threshumb=medint*0.65
threshpen=medint*0.85

;determine WL plotting range
dran=[medint-12.*stdint,medint+2.*stdint]

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
	rothel2xy,arposstr[i].hgpos,arposstr[i].date,intmap.time,dum1,dum2,arhcpos

	;make sub maps
	sub_map,magmap,submagmap,xrange=[arhcpos[0]-300.,arhcpos[0]+300.],yrange=[arhcpos[1]-300.,arhcpos[1]+300.]
	sub_map,intmap,subintmap,ref_map=submagmap
	
;	;set dynamic range of maps
;	;set range to below that of named colors
;	submagmap.data=bytscl(submagmap.data,min=-500,max=500)
	
	
	;set up buffer plotting
	if keyword_set(outfile) then begin
		set_plot, 'z'
		resxy=[1600,800]
		device, set_resolution = resxy;, /color
		!p.background = 255
		!p.color = 0
		;device,decomp=1
	endif
	
	;make plot
	erase
	!p.multi=[2,2,1]
	loadct,0
	plot_map,submagmap,drange=[-500,500],/iso
	
	setcolors,/sys;,/decomp
	plot_map,subintmap,/over,level=threshpen,c_color=0,c_thick=3
	plot_map,subintmap,/over,level=threshumb,c_color=0,c_thick=3
	plot_map,subintmap,/over,level=threshpen,c_color=255
	plot_map,subintmap,/over,level=threshumb,c_color=255

	!p.multi=[1,2,1]
	loadct,0
	plot_map,subintmap,dran=dran,/noerase,/iso
	xyouts,0.6,0.15,strtrim(arposstr[i].ars,2),chars=3,charthick=2,color=0,/norm
	
	;write the buffer to an image
	if keyword_set(outfile) then begin
;;		tvlct,rr,gg,bb,/get
;;		zb_plot=tvrd(true=1)
;		zb1=bytscl(tvrd(channel=1,/words)) & zb2=bytscl(tvrd(channel=2,/words)) & zb3=bytscl(tvrd(channel=3,/words))
;		zb_plot=bytarr(3,resxy[0],resxy[1])
;		zb_plot[0,*,*]=zb1 & zb_plot[1,*,*]=zb2 & zb_plot[2,*,*]=zb3
;		write_png, outfile+'_'+strtrim(arposstr[i].ars,2)+'.png', zb_plot;, rr,gg,bb
		zb_plot = tvrd()
		thisimg=outfile+'_'+strtrim(arposstr[i].ars,2)+'.png'
		wr_png, thisimg, zb_plot
		set_plot, 'x'
		if n_elements(outarr) lt 1 then outarr=thisimg else outarr=[outarr,thisimg]
	endif else stop

	
endfor

end