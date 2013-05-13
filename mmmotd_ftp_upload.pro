pro mmmotd_ftp_upload,infiles,fileftpinfo;,outscript

spawn,'less '+fileftpinfo,ftpinfoarr

site=ftpinfoarr[0]
username=ftpinfoarr[1]
password=ftpinfoarr[2]

directory='webspace/httpdocs/mmmotd/sunspot_overlays/'

openw, 1, 'ftp_transfer'

printf, 1, '#! /bin/csh -f'
printf, 1, 'ftp -n ' + site + '<< EOF > /tmp/temp'
printf, 1, 'user ' + username + ' ' + password
printf, 1, 'prompt off'
printf, 1, 'binary'

printf, 1, 'cd ' + directory

printf, 1, 'mdelete magintoverlay_*.png'

for i = 0, n_elements( infiles ) - 1 do begin
	thisfile=(reverse(str_sep(infiles[i],'/')))[0]
	printf, 1, 'put ' + infiles[i] + ' ./'+thisfile
endfor

printf, 1, 'bye'
printf, 1, 'EOF'

close,1

spawn, 'chmod 777 ftp_transfer'
spawn, './ftp_transfer'

end