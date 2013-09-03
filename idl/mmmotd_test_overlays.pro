pro mmmotd_test_overlays

pathoutput='/Users/higgins/science/projects/max_millennium/images/
pathrawhmi='/Users/higgins/science/data/raw/sdo/hmi/max_millennium_overlay_test/'
pathrawaia='/Users/higgins/science/data/raw/sdo/aia/max_millennium_overlay_test/'
pathsrs='/Users/higgins/science/data/srs_archive/2011/'

mfw0=['20110210_172241', $
'20110211_172241', $
'20110212_171641', $
'20110213_144641', $
'20110214_145241', $
'20110215_145241', $
'20110216_152241', $
'20110217_154641', $
'20110218_144041', $
'20110219_173441', $
'20110220_152241']

mfw1=['20110223_172241', $
'20110224_162841', $
'20110225_160441', $
'20110226_182841', $
'20110227_172241', $
'20110228_180441', $
'20110301_161041', $
'20110302_161041', $
'20110303_172241']

mfw2=['20110210_145241', $
'20110307_145241', $
'20110308_145241', $
'20110309_164041', $
'20110310_144641', $
'20110311_151641', $
'20110312_145241']

for i=0,2 do begin

	if i eq 0 then mfwt=mfw0
	if i eq 1 then mfwt=mfw1
	if i eq 2 then mfwt=mfw2

	times=file2time(mfwt)
	ntime=n_elements(times)

	for j=0,ntime-1 do begin
		outfile=pathoutput+'testmfw'+strtrim(i,2)+'/magintoverlay_'+mfwt[j]

		aiadum=getjsoc_sdo_read(times[j], /getaia, wavelength=4500, info_struct=aiainfo, /nodata, outindex=aiaindex)

		hmidum=getjsoc_sdo_read(times[j], /gethmi, info_struct=hmiinfo, /nodata, outindex=hmiindex)

                outrawhmi=pathrawhmi+'hmi_blos_'+time2file(hmiinfo.date_obs)+'.fits'
                outrawaia=pathrawaia+'aia_blos_'+time2file(aiainfo.date_obs)+'.fits'

                ;sock_copy,hmiinfo.flistrem,outrawhmi
                ;sock_copy,aiainfo.flistrem,outrawaia
                
                spawn,'cp '+hmiinfo.flistloc+' '+outrawhmi,/sh
                spawn,'cp '+aiainfo.flistloc+' '+outrawaia,/sh

                print,'File exists HMI: ',file_exist(outrawhmi)
                print,'File exists AIA: ',file_exist(outrawaia)
                if file_exist(outrawhmi) ne 1 then continue
                if file_exist(outrawaia) ne 1 then continue

;Pull an SRS file from the local archive for each date
                if file_exist(pathsrs+time2file(times[j],/date)+'SRS.txt') ne 1 then begin
                   print,'SRS FILE NOT FOUND: '+pathsrs+time2file(times[j],/date)+'SRS.txt'
                   continue
                endif
                readcol,pathsrs+time2file(times[j],/date)+'SRS.txt',form='A',delim='$',thissrs

                mmmotd_getarpos, arposstr, /verb, srsarr=thissrs,indate=anytim(times[j],/vms,/date)

                if data_type(arposstr) ne 8 then begin
                   print, 'Skipping date! data_type(arposstr) = '+strtrim(data_type(arposstr),2)
                   continue
                endif
;stop
;                mmmotd_getarpos, arposstr, /verb, indate=anytim(times[j],/vms,/date), /getnar


		mmmotd_sunspot_overlay,outrawhmi,outrawaia,outfile=outfile,arposstr=arposstr,/verb, outarr=outarr, /readsdo, hmiindex=hmiindex, aiaindex=aiaindex


	endfor


endfor






;stop

end
