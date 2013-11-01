;Get data for running mmmotd data product batch routines
;set /LMSAL if running locally to pull data from mounted SUMS, otherwise download the data locally to read-in
;set fdate to 'yyyymmdd' if the date to retrieve data is different than the current date
;set /getmag or /getint to choose the data type
;set status to empty variable to determine if:
;    status=0 -> program did not complete/crashed
;    status=1 -> jsoc data was found (index keyword should output a structure)
;    status=2 -> SunToday fits file was found (index keyword will be an empty string)
;    status=3 -> SunToday/mostrecent/... fits file was found (index keyword will be an empty string)
;    status=-1 -> No data was found 

function mmmotd_find_data, fdate=infdate, lmsal=lmsal, index=outindex, getmag=getmag, getint=getint, verbose=verbose, status=status
status=0

if n_elements(infdate) ne 1 then begin
   time=systim(/utc)
   tim=anytim(time)
   fdate=time2file(time)
   tran=24.*3600.;7200
endif else begin
   fdate=infdate
   time=file2time(fdate)
   if time eq '' then begin & time=fdate & fdate=time2file(time) & endif
   tran=24.*3600.
   tim=anytim(time)+tran
endelse

if keyword_set(lmsal) then lmsal=1 else lmsal=0

if keyword_set(verbose) then verbose=1 else verbose=0

if not keyword_set(getmag) then getmag=0
if not keyword_set(getint) then getint=0
if not (getmag) and not (getint) then getmag=1

;Move these into a configuration file to read in------------------------------->
urlsunintime='http://sdowww.lmsal.com/sdomedia/SunInTime/'
dirsunintime='/viz2/media/SunInTime/'
fnamemag='fblos.fits'
fnameint='f4500.fits'
intdseries='hmi.Ic_noLimbDark_720s_nrt'
magdseries='hmi.m_720s_nrt'
;------------------------------------------------------------------------------>

yyyy=strmid(fdate,0,4)
mm=strmid(fdate,4,2)
dd=strmid(fdate,6,2)

if yyyy+mm+dd eq strmid(time2file(systim(/utc)),0,8) then today=1 else today=0

if (getint) then begin

   ssw_jsoc_time2data,tim-tran,tim,intind,fintremote,ds=intdseries,/url
   nint=n_elements(fintremote)
   if nint eq 0 then fintremote=''
   fintremote=fintremote[nint-1]
   intind=intind[nint-1]

;Check to see if it is a FITS file:
   if (strpos(strlowcase(fintremote),'.fts'))[0] eq -1 and (strpos(strlowcase(fintremote),'.fits'))[0] eq -1 then fintremote=''

;Check if in SUMS directory
   wsums=strpos(fintremote,'/SUM')
   if wsums[0] eq -1 then wsums=0

   if lmsal then fint=strtrim(strmid(fintremote,(wsums)[0],200),2) $
                       else fint=fintremote

   if lmsal then fint2=dirsunintime+yyyy+'/'+mm+'/'+dd+'/'+fnameint $
                       else fint2=urlsunintime+yyyy+'/'+mm+'/'+dd+'/'+fnameint

;Only for when today's data is desired.
   if lmsal then fint3=dirsunintime+'mostrecent/'+fnameint $
                       else fint3=urlsunintime+'mostrecent/'+fnameint

   if lmsal then begin
      existint=file_exist(fint)
      if existint ne 1 then begin
         existint2=file_exist(fint2)
         if existint2 ne 1 then begin
            existint3=file_exist(fint3)
            if existint3 and today then begin
               fint=fint3
               intind=''
               status=3
            endif else status=-1 
         endif else begin
            fint=fint2
            intind=''
            status=2
         endelse
      endif else status=1
   endif else begin
      if (sock_find(fint))[0] eq '' then begin
         if (sock_find(fint2))[0] eq '' then begin
            if (sock_find(fint3))[0] ne '' and today then begin
               fint=fint3
               intind=''
               status=3
            endif else status=-1
         endif else begin
            fint=fint2
            intind=''
            status=2
         endelse
      endif else status=1
   endelse

   outindex=intind
   return,fint

endif

if (getmag) then begin

   ssw_jsoc_time2data,tim-tran,tim,magind,fmagremote,ds=magdseries,/url
   nmag=n_elements(fmagremote)
   if nmag eq 0 then fmagremote=''
   fmagremote=fmagremote[nmag-1]
   magind=magind[nmag-1]

;Check to see if it is a FITS file:
   if (strpos(strlowcase(fmagremote),'.fts'))[0] eq -1 and (strpos(strlowcase(fmagremote),'.fits'))[0] eq -1 then fmagremote=''

;Check if in SUMS directory
   wsums=strpos(fmagremote,'/SUM')
   if wsums[0] eq -1 then wsums=0

   if lmsal then fmag=strtrim(strmid(fmagremote,(wsums)[0],200),2) $
                       else fmag=fmagremote

   if lmsal then fmag2=dirsunintime+yyyy+'/'+mm+'/'+dd+'/'+fnamemag $
                       else fmag2=urlsunintime+yyyy+'/'+mm+'/'+dd+'/'+fnamemag

   if lmsal then fmag3=dirsunintime+'mostrecent/'+fnamemag $
                       else fmag2=urlsunintime+'mostrecent/'+fnamemag

   if lmsal then begin
      existmag=file_exist(fmag)
      if existmag ne 1 then begin
         existmag2=file_exist(fmag2)
         if existmag2 ne 1 then begin
            existmag3=file_exist(fmag3)
            if existmag3 and today then begin
               fmag=fmag3
               magind=''
               status=3
            endif else status=-1 
         endif else begin
            fmag=fmag2
            magind=''
            status=2
         endelse
      endif else status=1
   endif else begin
      if (sock_find(fmag))[0] eq '' then begin
         if (sock_find(fmag))[0] eq '' then begin
            if (sock_find(fmag3))[0] ne '' and today then begin
               fmag=fmag3
               magind=''
               status=3
            endif else status=-1
         endif else begin
            fmag=fmag2
            magind=''
            status=2
         endelse
      endif else status=1
   endelse

   outindex=magind
   return,fmag

endif


















return,''

end
