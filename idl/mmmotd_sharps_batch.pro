;MMMOTD_SHARPS_BATCH IDL FILE
;Generate SHARPs cut-out magnetogram images with sunspot overlays.
;
;Call using IDL> mmmotd_sharps_batch
;DEBUG = to plot to screen and stop after every image
;STATUS = report whether images were creeated successfully
;FSHARP = load local data that has already been downloaded
;USETEMP = Don't download anything, use what is in the local temp folder

pro mmmotd_sharps_batch, debug=debug, status=status, fsharp=infsharps, requestid=inrequestid, usetemp=usetemp
err=0

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

pathlmsal='/sanhome/higgins/public_html/max_millennium/sharp_overlays/'
envdate = getenv('todays_date')

print, 'Images will be output to: '+pathoutput
print, 'And copied to: '+pathlmsal

;;oufiles are fsharps??? why?? keeps plotting to window and not the EPS...

if keyword_set(usetemp) then begin
   	fsharps=file_search(pathtemp+'hmi.*.fits')
        if fsharps[0] eq '' then begin
           print,'NO DATA FOUND: '+pathtemp+'hmi.*.fits'
           return
        endif
endif else begin
	if n_elements(infsharps) eq 0 then begin
;Get the latest SHARPs
	   get_jsoc_harps, outfiles=fsharps, err=err, /stagelocal, /clearold, requestid=inrequestid
	endif else infsharps=fsharps
endelse

if err ne 0 then return

;Run overlay code
print,'Running: mmmotd_sharp_overlay'
if not debug then outfile=pathoutput+'sharpoverlay_'+envdate

fint=fsharps[where(strpos(fsharps,'continuum') ne -1)]
fmag=fsharps[where(strpos(fsharps,'magnetogram') ne -1)]
fbr=fsharps[where(strpos(fsharps,'Br') ne -1)]

mmmotd_sharp_overlay,fmag,fint,fbr,outfile=outfile,/verb,outpngs=outpngs

if not debug then begin
	statusarr=file_exist(outpngs)
	print,outpngs+' exist='+strtrim(statusarr,2)
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
	infiles=outpngs[where(statusarr eq 1)]
        
;        print,'cp '+pathoutput+'*'+envdate+'*.png '+pathlmsal+'/'
;	spawn,'cp '+pathoutput+'*'+envdate+'*.png '+pathlmsal+'/',/sh

;Can't seem to FTP from LMSAL
	;mmmotd_ftp_upload,infiles,ftpinfofile;,pathtemp+'ftp_transfer'
endif


end
