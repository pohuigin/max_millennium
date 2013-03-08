;gets latest AR positions in heliocentric coords.
;optionally set: inswpc to a specific remote SWPC AR SRS file URL
;				 indate to the date (e.g., '1-jan-2003') of the specific SRS file
pro mmmotd_getarpos, outarpos, $
	inswpc=inswpc, indate=indate, verb=verb

if keyword_set(verb) then verb=1 else verb=0

;read the latest SWPC AR file
if not keyword_set(inswpc) then swpcurl='http://www.swpc.noaa.gov/ftpdir/latest/SRS.txt' else swpcurl=inswpc
spawn,'curl '+swpcurl,rawars

;postions valid at time:
if not keyword_set(date) then date=anytim(systim(/utc),/date,/vms) else date=indate
datepos=date+' 00:00:00'
if verb then print,'DATEPOS',datepos

;select AR rows
wtop=where(strpos(rawars,'Nmbr Location  Lo  Area  Z   LL   NN Mag Type') ne -1)
wbottom=where(strpos(rawars,'IA. H-alpha Plages without Spots.') ne -1)
rawars=rawars[wtop+1:wbottom-1]
nars=n_elements(rawars)

;extract the names of each AR
hgarstr=strmid(rawars,0,4)
if verb then print,'HGARSTR',hgarstr

;extract the locations of each AR
hglocstr=strmid(rawars,5,6)
if verb then print,'HGLOCSTR',hglocstr

;convert the hg locations to hc
hclocstr=fltarr(2,nars)
for i=0,nars-1 do begin
	hclocstr[*,i]=hel2xy(hglocstr[i], date=datepos)
	
	;make structure from extracted data
	thisarpos={hcpos:hclocstr[*,i],ars:hgarstr[i],hgpos:hglocstr[i],date:datepos}
	
	;append structures
	if n_elements(arpos) lt 1 then arpos=thisarpos $
		else arpos=[arpos,thisarpos]
endfor
if verb then print,'HCLOCSTR',hclocstr

outarpos=arpos

end