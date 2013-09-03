;Convert html files to a structure array with the info pulled out

pro parse_mmmotd_archive


;paths
root='~/science/projects/max_millennium/'
dpath='~/science/data/mmmotd_archive/'

restore,root+'data/mmmotd_html_archive_files.sav',/ver

stop


;initialise structure
msgstructblank={datestr:'',recieved:'',msg:'',target:'',position:'',forecast:'',mmco:''}

nmsg=5000

msgstructarr=replicate(msgstructblank,nmsg)

for i=0,nmsg-1 do begin

	thisnum=string(i,form='(I04)')


;read in each saved html file

readcol,dpath+thisloc,msglist,form='A',delim='$&'

	msglist=strtrim(msglist,2)

;Pull out the meat of the message
	msgbody=msglist[where(msglist eq '<!-- body="start" -->'):where(msglist eq '<!-- body="end" -->')]
	
	wdate=where(strpos(msgbody,'<span id="date">') ne -1)
	
	
	msgstructarr[i].datestr=
	msgstructarr[i].recieved=
	msgstructarr[i].msg=
	msgstructarr[i].target=
	msgstructarr[i].position=
	msgstructarr[i].forecast=
	msgstructarr[i].mmco=
	


stop

endfor












end