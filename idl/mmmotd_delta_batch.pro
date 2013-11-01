;MMMOTD_BATCH IDL FILE
;Generate AR cut-out magnetogram images with sunspot overlays.
;
;Call using IDL> mmmotd_batch
;DEBUG = to plot to screen and stop after every image
;STATUS = report whether images were creeated successfully
;FDATE = set the date to run the delta overlays for
;LMSAL = run the 'local' version of the code, where data does not need
;        to be downloaded
pro mmmotd_delta_batch, debug=debug, status=status, fdate=fdate, lmsal=lmsal, $
                        workingpath = inpathworking, temppath = inpathtemp, outputpath = inpathoutput, pathlmsal = inpathlmsal

if keyword_set(debug) then begin
	debug=1
	verb=1
endif else debug=0

if keyword_set(lmsal) then lmsal=1 else lmsal=0

;Get environment variables
;spawn,'echo $WORKING_PATH',pathworking,/sh
if n_elements(inpathworking) eq 1 then pathworking=inpathworking else $
   pathworking = getenv('WORKING_PATH')
;spawn,'echo $TEMP_PATH',pathtemp,/sh
if n_elements(inpathtemp) eq 1 then pathtemp=inpathtemp else $
   pathtemp = getenv('TEMP_PATH')
;spawn,'echo $OUTPUT_PATH',pathoutput,/sh
if n_elements(inpathoutput) eq 1 then pathoutput=inpathoutput else $
   pathoutput = getenv('OUTPUT_PATH')
;spawn,'echo $todays_date',envdate,/sh
if n_elements(inpathlmsal) eq 1 then pathlmsal=inpathlmsal else $
   pathlmsal= getenv('LMSAL_PATH')

if n_elements(fdate) eq 1 then envdate = fdate else envdate = getenv('todays_date')

yyyy=strmid(envdate,0,4)
mm=strmid(envdate,4,2)
dd=strmid(envdate,6,2)

print, 'Images will be output to: '+pathoutput
print, 'And copied to: '+pathlmsal

;Get intensitygram
fint=mmmotd_find_data(ind=intind,/getint,/verb,stat=intstatus,lmsal=lmsal)
print,'IGRAM STATUS = '+strtrim(intstatus,2)
print,'this fint date_obs: '+intind.date_obs
if intstatus eq -1 then return

;if using fint2 then it is AIA data and the prep and dark subtract need to be run
if intstatus ne 1 then begin
   dodark=1 & doaiaprep=1
;   intreadsdo=0
endif else intreadsdo=1

;Get magnetogram
fmag=mmmotd_find_data(ind=magind,/getmag,/verb,stat=magstatus,lmsal=lmsal)
print,'MAG STATUS = '+strtrim(magstatus,2)
print,'this fmag date_obs: '+magind.date_obs
if magstatus eq -1 then return

;if magstatus ne 1 then begin
;   magreadsdo=1
;endif

;if not running locally at lmsal, need to download the files to local machine and rename the files to local path
if not lmsal then begin
   fintloc=pathtemp+(reverse(str_sep(fint,'/')))[0]
   sock_copy,fint,fintloc
   fint=fintloc
   
   fmagloc=pathtemp+(reverse(str_sep(fmag,'/')))[0]
   sock_copy,fmag,fmagloc
   fmag=fmagloc
endif

;;;fint=pathtemp+'fint.fits'
;;fintremote='http://sdowww.lmsal.com/sdomedia/SunInTime/mostrecent/f4500.fits'
;;fint='/viz2/media/SunInTime/mostrecent/f4500.fits' ;'/archive/sdo/media/SunInTime/mostrecent/f4500.fits'
;fint2='/viz2/media/SunInTime/'+yyyy+'/'+mm+'/'+dd+'/f4500.fits'
;;;spawn,'curl '+fintremote+' -o '+fint
;;;spawn,'&/Users/phiggins/bin/wget/src/wget '+fintremote+' -O '+fint
;;;wait,600
;ssw_jsoc_time2data,anytim(systim(/utc))-7200,anytim(systim(/utc)),intind,fintremote,ds='hmi.Ic_noLimbDark_720s_nrt',/url
;nint=n_elements(fintremote)
;fintremote=fintremote[nint-1]
;intind=intind[nint-1]
;fint=strtrim(strmid(fintremote,(strpos(fintremote,'/SUM'))[0],200),2)

;;fmag=pathtemp+'fmag.fits'
;;fmagremote='http://sdowww.lmsal.com/sdomedia/SunInTime/mostrecent/fblos.fits'
;;fmag='/viz2/media/SunInTime/mostrecent/fblos.fits' ;'/archive/sdo/media/SunInTime/mostrecent/fblos.fits'
;fmag2='/viz2/media/SunInTime/'+yyyy+'/'+mm+'/'+dd+'/fblos.fits'
;;;spawn,'curl '+fmagremote+' -o '+fmag
;;;spawn,'&/Users/phiggins/bin/wget/src/wget '+fmagremote+' -O '+fmag
;;;wait,600
;ssw_jsoc_time2data,anytim(systim(/utc))-7200,anytim(systim(/utc)),magind,fmagremote,ds='hmi.m_720s_nrt',/url
;nmag=n_elements(fmagremote)
;fmagremote=fmagremote[nmag-1]
;magind=magind[nmag-1]
;fmag=strtrim(strmid(fmagremote,(strpos(fmagremote,'/SUM'))[0],200),2)

;Check if files exist in the 'Latest' directory, locally
;existint=file_exist(fint) & print,'existint',existint
;if existint ne 1 then message,'INTENSITYGRAM FITS FILE MISSING: '+fint+' from: '+fintremote
;existmag=file_exist(fmag) & print,'existmag',existmag
;if existmag ne 1 then message,'MAGNETOGRAM FITS FILE MISSING: '+fmag+' from: '+fmagremote

;If not, then check if files exist in the current date directory,
;locally

;if not existint then begin
;	existint2=file_exist(fint2)
;	if existint2 then begin
;          fint=fint2
;
;if using fint2 then it is AIA data and the prep and dark subtract need to be run
;           dodark=1 & doaiaprep=1
;           
;        endif
;endif
;if not existmag then begin
;	existmag2=file_exist(fmag2)
;	if existmag2 then fmag=fmag2
;
;endif

;Get AR positions
print,'Running: mmmotd_getarpos'
mmmotd_getarpos,arposstr,/verb ;verb=verb

;Run overlay code
print,'Running: mmmotd_delta_overlay'
if not debug then outfile=pathoutput+'deltaoverlay_'+envdate

mmmotd_delta_overlay,fmag,fint,outfile=outfile,arposstr=arposstr,/verb, outarr=outarr, $
                     intind=intind, magind=magind, $ ;,intreadsdo=existint, magreadsdo=existmag, $
                     dodark=dodark, doaiaprep=doaiaprep

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

spawn,'ls '+pathoutput+'*$date*png',listpng,/sh
print,'LISTPNG = ',listpng

;List the delta structures output
spawn,'ls '+pathoutput+'*$date*_struct.sav',listsav,/sh
print,'LISTSAV = ',listsav

if listpng[0] eq '' and n_elements(listpng) eq 1 then begin
   status=-1
   print,'PNG files not found!' & message,'PNG files not found!' 
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
