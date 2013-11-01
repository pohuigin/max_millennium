;MMMOTD_BATCH IDL FILE
;Generate AR cut-out magnetogram images with sunspot overlays.
;
;Call using IDL> mmmotd_batch
;DEBUG = to plot to screen and stop after every image
;STATUS = report whether images were creeated successfully
pro mmmotd_batch, debug=debug, status=status

if keyword_set(debug) then begin
	debug=1
	verb=1
endif else debug=0

;Get environment variables
;spawn,'echo $WORKING_PATH',pathworking,/sh
pathworking = getenv('WORKING_PATH')
;spawn,'echo $TEMP_PATH',pathtemp,/sh
pathtemp = getenv('TEMP_PATH')
;spawn,'echo $OUTPUT_PATH',pathoutput,/sh
pathoutput = getenv('OUTPUT_PATH')
;spawn,'echo $todays_date',envdate,/sh

pathlmsal='/sanhome/higgins/public_html/max_millennium/sunspot_overlays/'
envdate = getenv('todays_date')
yyyy=strmid(envdate,0,4)
mm=strmid(envdate,4,2)
dd=strmid(envdate,6,2)

print, 'Images will be output to: '+pathoutput
print, 'And copied to: '+pathlmsal

;Get intensitygram
;fint=pathtemp+'fint.fits'
fintremote='http://sdowww.lmsal.com/sdomedia/SunInTime/mostrecent/f4500.fits'
fint='/viz2/media/SunInTime/mostrecent/f4500.fits' ;'/archive/sdo/media/SunInTime/mostrecent/f4500.fits'
fint2='/viz2/media/SunInTime/'+yyyy+'/'+mm+'/'+dd+'/f4500.fits'
;spawn,'curl '+fintremote+' -o '+fint
;spawn,'&/Users/phiggins/bin/wget/src/wget '+fintremote+' -O '+fint
;wait,600

;Get magnetogram
;fmag=pathtemp+'fmag.fits'
fmagremote='http://sdowww.lmsal.com/sdomedia/SunInTime/mostrecent/fblos.fits'
fmag='/viz2/media/SunInTime/mostrecent/fblos.fits' ;'/archive/sdo/media/SunInTime/mostrecent/fblos.fits'
fmag2='/viz2/media/SunInTime/'+yyyy+'/'+mm+'/'+dd+'/fblos.fits'
;spawn,'curl '+fmagremote+' -o '+fmag
;spawn,'&/Users/phiggins/bin/wget/src/wget '+fmagremote+' -O '+fmag
;wait,600

;Check if files exist in the 'Latest' directory, locally
existint=file_exist(fint) & print,'existint',existint
if existint ne 1 then message,'INTENSITYGRAM FITS FILE MISSING: '+fint+' from: '+fintremote
existmag=file_exist(fmag) & print,'existmag',existmag
if existmag ne 1 then message,'MAGNETOGRAM FITS FILE MISSING: '+fmag+' from: '+fmagremote

;If not, then check if files exist in the current date directory, locally
if not existint then begin
	existint2=file_exist(fint2)
	if existint2 then fint=fint2
endif
if not existmag then begin
	existmag2=file_exist(fmag2)
	if existmag2 then fmag=fmag2
endif

;Get AR positions
print,'Running: mmmotd_getarpos'
mmmotd_getarpos,arposstr,/verb ;verb=verb

;Run overlay code
print,'Running: mmmotd_sunspot_overlay'
if not debug then outfile=pathoutput+'magintoverlay_'+envdate

mmmotd_sunspot_overlay,fmag,fint,outfile=outfile,arposstr=arposstr,/verb, outarr=outarr

if not debug then begin
	statusarr=file_exist(outarr)
	print,outarr+' exist='+strtrim(statusarr,2)
	if (where(statusarr ne 1))[0] ne -1 then begin
		status=-1
		if (where(statusarr eq 1))[0] eq -1 then $
			message,'Images not written.' $
			else print,'Some images not written.'
	endif else status=1	
endif

;Write and run the FTP image transfer script
;ftpinfofile=pathworking+'ftp_info.txt'
if not debug then begin

	infiles=outarr[where(statusarr eq 1)]

spawn,'ls /Users/higgins/science/projects/max_millennium/images/sunspot_overlays/*$date*eps',listeps,/sh
print,'LISTEPS = ',listeps

if listeps[0] eq '' and n_elements(listeps) eq 1 then begin
   status=-1
   print,'EPS files not found!' & message,'EPS files not found!' 
   return
end

;neps=n_elements(listeps)
;for j=0,neps-1 do begin 
;   print,'convert '+listeps[j]+' '+listeps[j]+'.png'
;   spawn,'convert '+listeps[j]+' '+listeps[j]+'.png' ;,/sh
;endfor

;        print,'cp '+pathoutput+'*'+envdate+'*.png '+pathlmsal+'/'
;	spawn,'cp '+pathoutput+'*'+envdate+'*.png '+pathlmsal+'/',/sh

;Can't seem to FTP from LMSAL
	;mmmotd_ftp_upload,infiles,ftpinfofile;,pathtemp+'ftp_transfer'
endif


end
