;Get the whole mmmotd archive in an easy to read format

pro get_mmmotd_archive

root='~/science/projects/max_millennium/'

dpath='~/science/data/mmmotd_archive/'

urlindex='http://solar.physics.montana.edu/hypermail/mmmotd/index.html'


sock_list,urlindex,indexlist


urlroot='http://solar.physics.montana.edu/hypermail/mmmotd/'

nmsg=5000

locfiles=strarr(nmsg)

for i=0,nmsg-1 do begin

	thisnum=string(i,form='(I04)')

	sock_list,urlroot+thisnum+'.html',msglist

	nline=n_elements(msglist)

	if strjoin(msglist,'') eq '' then continue

	thislocfile=thisnum+'.html'

	locfiles[i]=thislocfile

	sock_copy,urlroot+thisnum+'.html',dpath+thislocfile

;	spawn,'echo "'+msglist[0]+'"
;	for j=1,nline-1 do 


;stop


endfor

save,locfiles,dpath,file=root+'data/mmmotd_html_archive_files.sav'











stop


end