<html>
<body>

<!--<table><tr>-->

<?

$remoteimgdir="http://lmsal.com/~higgins/max_millennium/sunspot_overlays/";

//List files in a remote directory------------------------------->

function get_text($filename) {
    $fp_load = fopen("$filename", "rb");
    if ( $fp_load ) {
            while ( !feof($fp_load) ) {
                $content .= fgets($fp_load, 8192);
            }
            fclose($fp_load);
            return $content;
    }
}
$matches = array();
preg_match_all("/(a href\=\")([^\?\"]*)(\")/i", get_text($remoteimgdir), $matches);

//foreach($matches[2] as $match) {
//    echo $match . '<br>';
//}

//Instert the images in to the HTML------------------------------->

$datetime = new DateTime();
$date=$datetime->format("Ymd");
//$imglist=glob("lmsal.com/~higgins/max_millennium/sunspot_overlays/magintoverlay_".$date."*.png");

$imglist=$matches[2];

//Select only the current date
//$imglist = preg_grep("/".$date."/", $imglist);

//print "DATE = ".$date;
//print "<br>sunspot_overlays/magintoverlay_".$date."*.png";
//print "<br>IMGLIST = ".$imglist[0];

for($offset=1; $offset < count($imglist); $offset++) {
    $file=$imglist[$offset];
    print "<img width=100% src='".$remoteimgdir.$file."'>";
}


//foreach ($imglist as &$file) {
////    print "<td width=1600px height=800px><img class='cutouts' src='".$file."'></td>";
//    print "<img src='".$remoteimgdir.$file."'>";
//}

?>

<!--</tr></table>-->



</body>
</html>
