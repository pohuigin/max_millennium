;MMMOTD_BATCH IDL FILE
;Call using IDL> @mmmotd_batch.pro

;Get environment variables
spawn,'echo $WORKING_PATH',pathworking
spawn,'echo $TEMP_PATH',pathtemp
spawn,'echo $OUTPUT_PATH',pathoutput
spawn,'echo $todays_date',envdate

;Get intensitygram
fint=pathtemp+'fint.fits'
fintremote='http://sdowww.lmsal.com/sdomedia/SunInTime/mostrecent/f4500.fits'
spawn,'curl '+fintremote+' -o '+fint

;Get magnetogram
fmag=pathtemp+'fmag.fits'
fmagremote='http://sdowww.lmsal.com/sdomedia/SunInTime/mostrecent/fblos.fits'
spawn,'curl '+fmagremote+' -o '+fmag

;Check if files downloaded
existmag=file_exist(fmag) & print,'existmag',existmag
if existmag ne 1 then message,'MAGNETOGRAM FITS FILE MISSING: '+fmag+' from: '+fmagremote
existint=file_exist(fint) & print,'existint',existint
if existint ne 1 then message,'INTENSITYGRAM FITS FILE MISSING: '+fint+' from: '+fintremote

;Get AR positions
mmmotd_getarpos,arposstr

;Run overlay code
mmmotd_sunspot_overlay,fmag,fint,outfile=pathoutput+'magintoverlay_'+envdate,arposstr=arposstr


























;end