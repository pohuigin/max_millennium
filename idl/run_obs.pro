;Make a real-time plot of the GOES light curve
;Also plot EVE?

pro obs_flares

wset,0
!p.multi=0

;Set goes data file location
fname='Gp_xr_1m.txt'
furl='http://www.swpc.noaa.gov/ftpdir/lists/xray/'

;Download the data
spawn,'curl -O '+furl+fname,/sh

;Read in the data file
;#                 Modified Seconds
;# UTC Date  Time   Julian  of the
;# YR MO DA  HHMM    Day     Day       Short       Long
;#-------------------------------------------------------
;2014 03 22  2057   56738  75420     6.56e-09    8.13e-07

;readcol,fname,yy,mo,dd,hhmm,jd,secd,short,long,comment='#',form='A,A,A,A,X,X,X,F'
;readcol,fname,yy,mo,dd,hhmm,ilong,comment='#',form='A',delim='£'
;'A,A,A,A,X,X,X,F'

readcol,fname,yy,mo,dd,hhmm,ishort,ilong,comment='#',form='A,A,A,A,X,X,F,F',count=ngood

if ngood lt 2 then return

;Determine anytim date
tim=anytim(yy+'-'+mo+'-'+dd+'T'+strmid(hhmm,0,2)+':'+strmid(hhmm,2,2)+':00.0Z')

;Find UTC offset
tshift=0. ;anytim(systim())-anytim(systim(/utc))

;Plot the data
mint=min(tim)+tshift
utplot,tim-mint,ilong,mint,ps=4,/ylog,chars=2,lines=2,xtit='Last Datum: '+(reverse(hhmm))[0] ;,yran=[1d-7,1d-3]
oplot,tim-mint,ishort+1d-7,color=150
hline,[1d-4,1d-5,1d-6,1d-7]
xyouts,60.*20.,[1d-4,1d-5,1d-6],['X','M','C'],/data

vline, anytim(systim(/utc)), lines=2,color=150,/ylog

end

;----------------------------------------------------------------------------->

pro obs_euv,arpos,params=params, default=default

wset,2
;!p.multi=[0,2,2]

if data_type(params) ne 8 and not keyword_set(default) then params=ar_loadparam(fparam='mmmotd_obs_param.txt')

if not keyword_set(default) then begin
	locdir=params.flarelocdir
	wave1=params.flarewave1
	wave2=params.flarewave2
endif else begin
	locdir='~/science/projects/max_millennium/data/aia_synop/'
	wave1='1600'
	wave2='0131'
endelse

furl='http://jsoc.stanford.edu/data/aia/synoptic/nrt/'

tim=systim(/utc)
date=time2file(anytim(tim,/vms))
yyyy=strmid(date,0,4)
mo=strmid(date,4,2)
dd=strmid(date,6,2)
hh='H'+strmid(date,9,2)+'00'

fdir=yyyy+'/'+mo+'/'+dd+'/'+hh+'/'

flist=sock_find(furl+fdir)

if flist[0] eq '' then return

;Make list of 131 and 1600
;w1600=where(strpos(flist,'_'+wave1+'.') ne -1)
;f1600=reverse(flist[(reverse(w1600))[0:2]])
;t1600=file2time(f1600)

w131=where(strpos(flist,'_'+wave2+'.') ne -1)

if n_elements(w131) lt 3 then return

f131=reverse(flist[(reverse(w131))[0:2]])
t131=file2time(f131)

for i=0,2 do begin
	floc131=locdir+'aia131_'+t131[i]
	is131=file_exist(floc131)
;	floc1600=locdir+'aia1600_'+t1600[i]	
;	is1600=file_exist(locdir+'aia1600_'+t1600[i])
	
;	if not is1600 then begin
;		spawn,'curl -O '+f1600[i],/sh
;		fdl1600=(reverse(str_sep(f1600[i],'/')))[0]
;		spawn,'mv '+fdl1600+' '+locdir+'aia1600_'+t1600[i],/sh
;	endif

	if not is131 then begin
		spawn,'curl -O '+f131[i],/sh
		fdl131=(reverse(str_sep(f131[i],'/')))[0]
		spawn,'mv '+fdl131+' '+locdir+'aia131_'+t131[i],/sh
	endif

	mreadfits,floc131,ind131,dat131
;	mreadfits,floc1600,ind1600,dat1600

	if n_elements(arr131) eq 0 then arr131=dat131 else arr131=[[[arr131]],[[dat131]]]
;	if n_elements(arr1600) eq 0 then arr1600=dat1600 else arr1600=[[[arr1600]],[[dat1600]]]

endfor

index2map,ind131,dat131,map

erase

map131_1=map
map131_1.data=(ar_grow(arr131[*,*,1],rad=5,/gaus)-ar_grow(arr131[*,*,0],rad=5,/gaus))/ar_grow(arr131[*,*,0],rad=5,/gaus)
plot_map,map131_1,dran=[-0.5,0.5],/limb,grid=10,fov=33,position=[0,0,0.5,1],xtit='',ytit='',tit=''

xyouts,0.1,0.1,'131A: '+strmid(t131[1],11,10)+' - '+strmid(t131[0],11,10),/norm

if n_elements(arpos) gt 0 then xyouts,(arpos.hcpos)[0,*],(arpos.hcpos)[1,*],arpos.ars,/data

map131_2=map
map131_2.data=(ar_grow(arr131[*,*,2],rad=5,/gaus)-ar_grow(arr131[*,*,1],rad=5,/gaus))/ar_grow(arr131[*,*,1],rad=5,/gaus)
plot_map,map131_2,dran=[-0.5,0.5],/limb,grid=10,fov=33,position=[0.5,0,1,1],/noerase,xtit='',ytit='',tit=''

xyouts,0.5,0.1,'131A: '+strmid(t131[2],11,10)+' - '+strmid(t131[1],11,10),/norm

if n_elements(arpos) gt 0 then xyouts,(arpos.hcpos)[0,*],(arpos.hcpos)[1,*],arpos.ars,/data

;map1600_1=map
;map1600_1.data=(ar_grow(arr1600[*,*,1],rad=5,/gaus)-ar_grow(arr1600[*,*,0],rad=5,/gaus))/ar_grow(arr1600[*,*,0],rad=5,/gaus)
;plot_map,map1600_2,dran=[-0.5,0.5],/limb,grid=10,fov=33,position=[0,0,0.5,0.5],/noerase,xtit='',ytit='',tit=''

;if n_elements(arpos) gt 0 then xyouts,(arpos.hcpos)[0,*],(arpos.hcpos)[1,*],arpos.ars,/data

;map1600_2=map
;map1600_2.data=(ar_grow(arr1600[*,*,2],rad=5,/gaus)-ar_grow(arr1600[*,*,1],rad=5,/gaus))/ar_grow(arr1600[*,*,1],rad=5,/gaus)
;plot_map,map1600_2,dran=[-0.5,0.5],/limb,grid=10,fov=33,position=[0.5,0,1,0.5],/noerase,xtit='',ytit='',tit=''

;if n_elements(arpos) gt 0 then xyouts,(arpos.hcpos)[0,*],(arpos.hcpos)[1,*],arpos.ars,/data

end

;----------------------------------------------------------------------------->

pro obs_halpha,arpos,params=params,default=default

wset,3
;!p.multi=[0,2,1]

if data_type(params) ne 8 and not keyword_set(default) then params=ar_loadparam(fparam='mmmotd_obs_param.txt')

if not keyword_set(default) then begin
	obskey=params.halphaobskey
	locdir=params.halphalocdir
endif else begin
	obskey='Bh'
	locdir='~/science/projects/max_millennium/data/gonghalpha_synop/'
endelse

tim=systim(/utc)
date=time2file(anytim(tim,/vms))
yyyy=strmid(date,0,4)
mo=strmid(date,4,2)
dd=strmid(date,6,2)

;Get EVE centroid
feve='http://lasp.colorado.edu/eve/data_access/evewebdata/quicklook/L0CS/LATEST15m_EVE_L0CS_DIODES_1m.txt'
fname=(reverse(str_sep(feve,'/')))[0]

;Download the EVE data
spawn,'curl -O '+feve,/sh

;Read EVE data
readcol,fname,xrhh,xrprox,xrlat,xrlon,form='A,A,X,X,X,X,X,X,X,X,X,X,X,X,X,X,A,A',comment=';'

nline=n_elements(xrlat)
hcpos=fltarr(2,nline)
for n=0,nline-1 do hcpos[*,n]=hel2arcmin(xrlat[n],xrlon[n],date=tim)

;Get Halpha files
furl='http://halpha.nso.edu/keep/haf/'+yyyy+mo+'/'+yyyy+mo+dd+'/'

flist=sock_find(furl+'*'+obskey+'.*')

if n_elements(flist) lt 3 then return

flast=reverse((reverse(flist))[0:2])

tlast=strmid(flast,strpos(flast[0],obskey)-14,8)+'_'+strmid(flast,strpos(flast[0],obskey)-6,6)

for i=0,2 do begin
	floc=locdir+'ghalph_'+tlast[i]+'.fits.fz'
	flocunpack=locdir+'ghalph_'+tlast[i]+'.fits'
	isdata=file_exist(flocunpack)
	
	if not isdata then begin
		spawn,'curl -O '+flast[i],/sh
		fdl=(reverse(str_sep(flast[i],'/')))[0]
		spawn,'mv '+fdl+' '+floc,/sh

		spawn,'funpack '+floc,fpackstatus
	endif



	mreadfits,flocunpack,ind,dat
	index2map,ind,dat,thismap
	if n_elements(maparr) eq 0 then maparr=thismap else maparr=[maparr,thismap]

	if n_elements(arrdat) eq 0 then arrdat=dat else arrdat=[[[arrdat]],[[dat]]]

endfor

index2map,ind,dat,map

erase

map_1=map
;map_1.data=(ar_grow(arrdat[*,*,1],rad=5,/gaus)-ar_grow(arrdat[*,*,0],rad=5,/gaus))/ar_grow(arrdat[*,*,0],rad=5,/gaus)
;plot_map,map_1,dran=[-0.5,0.5],/limb,grid=10,fov=33,position=[0,0,0.33,1],xtit='',ytit='',tit=''

map_1.data=maparr[1].data-maparr[0].data
plot_map,map_1,/limb,grid=10,fov=33,position=[0,0,0.33,1],xtit='',ytit='',tit='',dran=[-250,250]

if n_elements(arpos) gt 0 then xyouts,(arpos.hcpos)[0,*],(arpos.hcpos)[1,*],arpos.ars,/data

xyouts,0.01,0.05,strmid(tlast[1],9,4)+' - '+strmid(tlast[0],9,4),/norm

map_2=map
;map_2.data=(ar_grow(arrdat[*,*,2],rad=5,/gaus)-ar_grow(arrdat[*,*,1],rad=5,/gaus))/ar_grow(arrdat[*,*,1],rad=5,/gaus)
;plot_map,map_2,dran=[-0.5,0.5],/limb,grid=10,fov=33,position=[0.33,0,.66,1],xtit='',ytit='',tit='',/noerase

map_2.data=maparr[2].data-maparr[1].data
plot_map,map_2,/limb,grid=10,fov=33,position=[0.33,0,0.66,1],xtit='',ytit='',tit='',/noerase,dran=[-250,250]

if n_elements(arpos) gt 0 then xyouts,(arpos.hcpos)[0,*],(arpos.hcpos)[1,*],arpos.ars,/data

xyouts,0.34,0.05,strmid(tlast[2],9,4)+' - '+strmid(tlast[1],9,4),/norm

plot_map,maparr[2],/limb,grid=10,fov=33,position=[0.66,0,1,1],xtit='',ytit='',tit='',/noerase;,dran=[3000,4000]
plots,hcpos[0,*],hcpos[1,*],ps=1
plots,(reverse(hcpos[0,*]))[0],(reverse(hcpos[1,*]))[0],ps=4

if n_elements(arpos) gt 0 then xyouts,(arpos.hcpos)[0,*],(arpos.hcpos)[1,*],arpos.ars,/data

xyouts,0.67,0.05,strmid(tlast[2],9,4),/norm

xyouts,0.67,0.95,'EVE Lon,Lat: '+strtrim(fix(round(float((reverse(xrlon))[0]))),2)+','+strtrim(fix(round(fix((reverse(xrlat))[0]))),2),/norm

end

;----------------------------------------------------------------------------->

pro run_obs, flares=doflares, euv=doeuv, halpha=dohalpha

if keyword_set(doflares) then window,0,xs=700,ys=700
if keyword_set(doeuv) then window,2,xs=700,ys=350
if keyword_set(dohalpha) then window,3,xs=1050,ys=350

params=ar_loadparam(fparam='mmmotd_obs_param.txt')

mmmotd_getarpos,arpos

check=0
j=0l
while check ne 1 do begin

;Run goes plotting
	if keyword_set(doflares) then obs_flares

;Run halpha display
	if keyword_set(dohalpha) then obs_halpha,arpos,params=params


;Run EUV Display
	if j mod 3 eq 0 then begin
		if keyword_set(doeuv) then obs_euv,arpos,params=params
	endif else begin

		widget_control
		dum=execute('wait,60.')

	endelse

;Display latest SAM image
;http://lasp.colorado.edu/eve/data_access/quicklook/quicklook_data/L0CS/latest_sam.png


	j=j+1l

endwhile


stop

end


