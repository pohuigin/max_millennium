<html>
<style>
iframe{
width: 100%; height: 100%;
}
iframe.normal{
width: 100%; height: 100%;
}
iframe.double{
width: 50%; height: 100%;
}
iframe.placeholder{
width: 50%; height: 5%;
}

table{
width: 100%; height: 100%; 
//	border-collapse:collapse; border-spacing: 0; margin: 0; padding: 0; border: 0;
}
table.double{
width: 200%; height: 100%; 
//	border-collapse:collapse; border-spacing: 0; margin: 0; padding: 0; border: 0;
}
td
{
//border-collapse:collapse; border-spacing: 0; margin: 0; padding: 0; border: 0;
}
td.title
{
//border-collapse:collapse; border-spacing: 0; margin: 0; padding: 0; border: 0;
vertical-align: baseline; line-height: 16px; font-size: 16px; height: 16px;
}
//tr
//{
//border-collapse:collapse; border-spacing: 0; margin: 0; padding: 0; border: 0;
//}

img{
height: 100%;
}
img.double{
width: 100%;
}

img.noscl{
height: 4096px; width: 4096px;
}


img.cutouts{
}
</style>
<script type="text/javascript">
function changeiframe(loadiframe){

	if (loadiframe=='helioviewer')
	  {
	  var link = 'http://delphi.nascom.nasa.gov';
	  }
	else if (loadiframe=='ssdrawing')
	  {
	  var link = 'http://obs.astro.ucla.edu/images/cur_drw.jpg';
	  }
	else if (loadiframe=='sximovie')
	  {
	  var link = 'http://www.swpc.noaa.gov/sxi/goes15/ar_be12a_1'; 
	  }
	else if (loadiframe=='solarmonitor')
	  {
	  var link = 'http://solarmonitor.org/index.php'; 
	  }
	else if (loadiframe=='lastevents')
	  {
	  var link = 'http://www.lmsal.com/solarsoft/last_events/index.html'; 
	  }
	else if (loadiframe=='smforecast')
	  {
	  var link = 'http://www.solarmonitor.org/forecast.php'; 
	  }
	else
	  {}
	
	document.getElementById(loadiframe).src = link;
	document.getElementById(loadiframe).style = 'width: 100%;height: 100%;';
	
}
function closeiframe(loadiframe){

	document.getElementById(loadiframe).src = 'null';
	document.getElementById(loadiframe).style = 'width: 50%;height: 5%;';
	
}
</script>
<body>

<? 
//ini_set('allow_url_include', 1);
//ini_set('allow_url_fopen', 1);

//$curlSession = curl_init();
//curl_setopt($curlSession, CURLOPT_URL, 'http://www.swpc.noaa.gov/ftpdir/latest/SRS.txt');
//curl_setopt($curlSession, CURLOPT_BINARYTRANSFER, true);
//curl_setopt($curlSession, CURLOPT_RETURNTRANSFER, true);

//$Data = curl_exec($curlSession);

//echo $Data;


//curl_close($curlSession);

//get current date and time
date_default_timezone_set('GMT');
$yyyy = gmdate('Y');
$mmdd = gmdate('md');
$yyyyy = gmdate('Y', vsprintf('%d.%06d', gettimeofday()) - 60 * 60 * 24);
$ymmdd = gmdate('md', vsprintf('%d.%06d', gettimeofday()) - 60 * 60 * 24);

$datestr = gmdate('Ymd_His', vsprintf('%d.%06d', gettimeofday())); 
$ydatestr = gmdate('Ymd_His', vsprintf('%d.%06d', gettimeofday()) - 60 * 60 * 24); 

$mmmotdnum = number_format(floor(vsprintf('%d.%06d', gettimeofday())/24./3600.)-11121,0,'.','');
$ymmmotdnum = number_format(floor(vsprintf('%d.%06d', gettimeofday())/24./3600.)-11122,0,'.','');

echo 'today= '.$datestr.'<br>';
echo 'yesterday= '.$ydatestr.'<br>';

//echo number_format(vsprintf('%d.%06d', gettimeofday())-17.8*3600)/3600./24.,2,'.','');

?>

<hr>

<table><tr><td class=title>TODAY #<? echo $mmmotdnum ?></td><td class=title>YESTERDAY #<? echo $ymmmotdnum ?></td></tr><tr>
<td><iframe class="noscl" src=<? echo 'http://solar.physics.montana.edu/hypermail/mmmotd/'.$mmmotdnum.'.html' ?>></iframe></td>
<td><iframe class="noscl" src=<? echo 'http://solar.physics.montana.edu/hypermail/mmmotd/'.$ymmmotdnum.'.html' ?>></iframe></td>
</tr></table>
<br><br>

<hr>

<!--<img class=noscl width=4096px height=4096px src='http://sdowww.lmsal.com/sdomedia/SunInTime/mostrecent/f4500.jpg'> -->
<!--<img class="noscl" width=4096px height=4096px src='http://sdowww.lmsal.com/sdomedia/SunInTime/mostrecent/f_HMImag.jpg'> -->
<table><tr>
<td><iframe class="noscl" src="http://sdowww.lmsal.com/sdomedia/SunInTime/mostrecent/f4500.jpg"></iframe></td>
<td><iframe class="noscl" src='http://sdowww.lmsal.com/sdomedia/SunInTime/mostrecent/f_HMImag.jpg'></iframe></td>
</tr></table>
<br><br>

<hr>

<table class=double><tr><td class=title>3-DAY ------> 6-HOUR</td></tr><tr>
<td><img src='http://www.swpc.noaa.gov/rt_plots/Xray.gif'>&nbsp;<img src='http://www.swpc.noaa.gov/rt_plots/Xray_1m.gif'></td>
</tr></table>
<br><br>

<hr>

<!--<? include('http://www.lmsal.com/solarsoft/last_events/index.html'); ?>
<iframe src="http://www.lmsal.com/solarsoft/last_events/index.html"></iframe> 
<br><br>-->
<iframe style='width: 50%;height: 5%;' id='lastevents'></iframe><br>
<input type='button' onclick='changeiframe("lastevents")' value='Load Latest Events'/>
<input type='button' onclick='closeiframe("lastevents")' value='Close Latest Events'/>
<br><br>

<hr>

<!--<? include('http://solarmonitor.org/index.php'); ?>-->
<iframe style='width: 50%;height: 5%;' id='solarmonitor'></iframe><br>
<input type='button' onclick='changeiframe("solarmonitor")' value='Load SolarMonitor'/>
<input type='button' onclick='closeiframe("solarmonitor")' value='Close SolarMonitor'/>
<br><br>

<hr>

<!--<iframe src="http://delphi.nascom.nasa.gov"></iframe>-->
<iframe style='width: 50%;height: 5%;' id='helioviewer'></iframe><br>
<input type='button' onclick='changeiframe("helioviewer")' value='Load HelioViewer'/>
<input type='button' onclick='closeiframe("helioviewer")' value='Close HelioViewer'/>
<br><br>

<hr>

<!--<table><tr>
<td><? include('http://www.swpc.noaa.gov/ftpdir/latest/SRS.txt'); ?></td>
<td><? include('http://www.swpc.noaa.gov/ftpdir/warehouse/'.$yyyyy.'/SRS/'.$yyyyy.$ymmdd.'SRS.txt'); ?></td>
</tr></table>
<br><br>-->
<table><tr><td class=title>TODAY</td><td class=title>YESTERDAY</td></tr><tr>
<td><iframe src="http://www.swpc.noaa.gov/ftpdir/latest/SRS.txt"></iframe></td>
<td><? echo '<iframe src="http://www.swpc.noaa.gov/ftpdir/warehouse/'.$yyyyy.'/SRS/'.$yyyyy.$ymmdd.'SRS.txt"></iframe>'; ?></td>
</tr></table>
<br><br>

<!--<? include('http://www.swpc.noaa.gov/ftpdir/indices/events/events.txt'); ?>-->
<table><tr><td class=title>TODAY</td><td class=title>YESTERDAY</td></tr><tr>
<td><iframe src="http://www.swpc.noaa.gov/ftpdir/indices/events/events.txt"></iframe></td>
<td><? echo '<iframe src="http://www.swpc.noaa.gov/ftpdir/warehouse/'.$yyyyy.'/'.$yyyyy.'_events/'.$yyyyy.$ymmdd.'events.txt"></iframe>'; ?></td>
</tr></table>
<br><br>

<hr>

<table class=double><tr><td class=title>HMI Overlays ------> SHARPS Overlays</td></tr><tr>
<td><iframe src="sunspot_overlays.php"></iframe></td>
<td><iframe src="sharp_overlays.php"></iframe></td>
</tr></table>
<br><br>

<hr>

<iframe style='width: 50%;height: 5%;' id='sximovie'></iframe><br>
<input type='button' onclick='changeiframe("sximovie")' value='Load SXI X-ray Movie'/>
<input type='button' onclick='closeiframe("sximovie")' value='Close SXI X-ray Movie'/>
<br><br>

<hr>

<img style='width: 50%;height: 5%;' id='ssdrawing'><br>
<input type='button' onclick='changeiframe("ssdrawing")' value='Load SunSpot Drawing'/>
<input type='button' onclick='closeiframe("ssdrawing")' value='Close SunSpot Drawing'/>
<br><br>

<hr>

<!--<? include('http://www.swpc.noaa.gov/forecast.html'); ?>-->
<table><tr>
<td><iframe src="http://www.swpc.noaa.gov/ftpdir/latest/daypre.txt"></iframe></td>
<td><iframe src="http://www.swpc.noaa.gov/ftpdir/latest/forecast_discussion.txt"></iframe></td> 
</tr></table>
<br><br>


<!--<? include('http://www.solarmonitor.org/forecast.php'); ?>
<iframe src="http://www.solarmonitor.org/forecast.php"></iframe> 
<br><br>-->
<iframe style='width: 50%;height: 5%;' id='smforecast'></iframe><br>
<input type='button' onclick='changeiframe("smforecast")' value='Load SolarMonitor Forecast'/>
<input type='button' onclick='closeiframe("smforecast")' value='Close SolarMonitor Forecast''/>
<br><br>








</body>
</html>
