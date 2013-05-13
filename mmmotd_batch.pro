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
spawn,'echo $WORKING_PATH',pathworking
spawn,'echo $TEMP_PATH',pathtemp
spawn,'echo $OUTPUT_PATH',pathoutput
spawn,'echo $todays_date',envdate

;Get intensitygram
fint=pathtemp+'fint.fits'
fintremote='http://sdowww.lmsal.com/sdomedia/SunInTime/mostrecent/f4500.fits'
;spawn,'curl '+fintremote+' -o '+fint
;spawn,'&/Users/phiggins/bin/wget/src/wget '+fintremote+' -O '+fint
;wait,600

;Get magnetogram
fmag=pathtemp+'fmag.fits'
fmagremote='http://sdowww.lmsal.com/sdomedia/SunInTime/mostrecent/fblos.fits'
;spawn,'curl '+fmagremote+' -o '+fmag
;spawn,'&/Users/phiggins/bin/wget/src/wget '+fmagremote+' -O '+fmag
;wait,600

;Check if files downloaded
existmag=file_exist(fmag) & print,'existmag',existmag
if existmag ne 1 then message,'MAGNETOGRAM FITS FILE MISSING: '+fmag+' from: '+fmagremote
existint=file_exist(fint) & print,'existint',existint
if existint ne 1 then message,'INTENSITYGRAM FITS FILE MISSING: '+fint+' from: '+fintremote

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
ftpinfofile=pathworking+'ftp_info.txt'
if not debug then begin
	infiles=outarr[where(statusarr eq 1)]
	mmmotd_ftp_upload,infiles,ftpinfofile;,pathtemp+'ftp_transfer'
endif


end