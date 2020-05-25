<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">
<link rel="shortcut icon" href="images/favicon.png">
<link rel="icon" href="images/favicon.png">
<title>spdMerlin - Internet Speedtest Stats</title>
<link rel="stylesheet" type="text/css" href="index_style.css">
<link rel="stylesheet" type="text/css" href="form_style.css">
<style>
p {
  font-weight: bolder;
}

thead.collapsible {
  color: white;
  padding: 0px;
  width: 100%;
  border: none;
  text-align: left;
  outline: none;
  cursor: pointer;
}

thead.collapsibleparent {
  color: white;
  padding: 0px;
  width: 100%;
  border: none;
  text-align: left;
  outline: none;
  cursor: pointer;
}

thead.collapsible-jquery {
  color: white;
  padding: 0px;
  width: 100%;
  border: none;
  text-align: left;
  outline: none;
  cursor: pointer;
}

th.keystatsnumber {
  font-size: 20px !important;
  font-weight: bolder !important;
}

td.keystatsnumber {
  font-size: 20px !important;
  font-weight: bolder !important;
}

td.nodata {
  font-size: 48px !important;
  font-weight: bolder !important;
  height: 65px !important;
  font-family: Arial !important;
}

.StatsTable {
  table-layout: fixed !important;
  width: 747px !important;
  text-align: center !important;
}

.StatsTable th {
  background-color:#1F2D35 !important;
  background:#2F3A3E !important;
  border-bottom:none !important;
  border-top:none !important;
  font-size: 12px !important;
  color: white !important;
  padding: 4px !important;
  width: 740px !important;
}

.StatsTable td {
  padding: 2px !important;
  word-wrap: break-word !important;
  overflow-wrap: break-word !important;
}

.StatsTable a {
  font-weight: bolder !important;
  text-decoration: underline !important;
}

.StatsTable th:first-child,
.StatsTable td:first-child {
  border-left: none !important;
}

.StatsTable th:last-child ,
.StatsTable td:last-child {
  border-right: none !important;
}

.collapsiblecontent {
  padding: 0px;
  max-height: 0;
  overflow: hidden;
  border: none;
  transition: max-height 0.2s ease-out;
}
</style>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/jquery.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/moment.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/chart.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/hammerjs.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/chartjs-plugin-zoom.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/chartjs-plugin-annotation.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/chartjs-plugin-deferred.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/d3.js"></script>
<script language="JavaScript" type="text/javascript" src="/state.js"></script>
<script language="JavaScript" type="text/javascript" src="/general.js"></script>
<script language="JavaScript" type="text/javascript" src="/popup.js"></script>
<script language="JavaScript" type="text/javascript" src="/help.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/detect.js"></script>
<script language="JavaScript" type="text/javascript" src="/tmhist.js"></script>
<script language="JavaScript" type="text/javascript" src="/tmmenu.js"></script>
<script language="JavaScript" type="text/javascript" src="/client_function.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/validator.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/spdmerlin/spdjs.js"></script>
<script>
var custom_settings = <% get_custom_settings(); %>;
var $j=jQuery.noConflict(),maxNoCharts=0,currentNoCharts=0,ShowLines=GetCookie("ShowLines","string"),ShowFill=GetCookie("ShowFill","string");""==ShowFill&&(ShowFill="origin");var DragZoom=!0,ChartPan=!1;Chart.defaults.global.defaultFontColor="#CCC",Chart.Tooltip.positioners.cursor=function(a,b){return b};var chartlist=["daily","weekly","monthly"],timeunitlist=["hour","day","day"],intervallist=[24,7,30],bordercolourlist=["#fc8500","#42ecf5"],backgroundcolourlist=["rgba(252,133,0,0.5)","rgba(66,236,245,0.5)"];function keyHandler(a){27==a.keyCode&&($j(document).off("keydown"),ResetZoom())}$j(document).keydown(function(a){keyHandler(a)}),$j(document).keyup(function(){$j(document).keydown(function(a){keyHandler(a)})});function Draw_Chart_NoData(a){document.getElementById("divLineChart_"+a).width="730",document.getElementById("divLineChart_"+a).height="500",document.getElementById("divLineChart_"+a).style.width="730px",document.getElementById("divLineChart_"+a).style.height="500px";var b=document.getElementById("divLineChart_"+a).getContext("2d");b.save(),b.textAlign="center",b.textBaseline="middle",b.font="normal normal bolder 48px Arial",b.fillStyle="white",b.fillText("No data to display",365,250),b.restore()}function Draw_Chart(a){var b=getChartPeriod($j("#"+a+"_Period option:selected").val()),c="Mbps",d=timeunitlist[$j("#"+a+"_Period option:selected").val()],e=intervallist[$j("#"+a+"_Period option:selected").val()],f=window[b+"_"+a];if("undefined"==typeof f||null===f)return void Draw_Chart_NoData(a);if(0==f.length)return void Draw_Chart_NoData(a);var g=f.map(function(a){return{x:a.Time,y:a.Value}}),h=[],j=[];for(let b=0;b<f.length;b++)h[f[b].Metric]||(j.push(f[b].Metric),h[f[b].Metric]=1);var k=f.filter(function(a){return"Download"==a.Metric}).map(function(a){return{x:a.Time,y:a.Value}}),l=f.filter(function(a){return"Upload"==a.Metric}).map(function(a){return{x:a.Time,y:a.Value}}),m=window["LineChart_"+a],n=getTimeFormat($j("#Time_Format option:selected").val(),"axis"),o=getTimeFormat($j("#Time_Format option:selected").val(),"tooltip");factor=0,"hour"==d?factor=3600000:"day"==d&&(factor=86400000),m!=null&&m.destroy();var p=document.getElementById("divLineChart_"+a).getContext("2d"),q={segmentShowStroke:!1,segmentStrokeColor:"#000",animationEasing:"easeOutQuart",animationSteps:100,maintainAspectRatio:!1,animateScale:!0,hover:{mode:"point"},legend:{display:!0,position:"top",reverse:!0,onClick:function(a,b){var c=b.datasetIndex,d=this.chart,e=d.getDatasetMeta(c);if(e.hidden=null===e.hidden?!d.data.datasets[c].hidden:null,"line"==ShowLines){var f="";if(!0!=e.hidden&&(f="line"),0==c)for(aindex=3;6>aindex;aindex++)d.options.annotation.annotations[aindex].type=f;else if(1==c)for(aindex=0;3>aindex;aindex++)d.options.annotation.annotations[aindex].type=f}d.update()}},title:{display:!0,text:"Bandwidth"},tooltips:{callbacks:{title:function(a){return moment(a[0].xLabel,"X").format(o)},label:function(a,b){return round(b.datasets[a.datasetIndex].data[a.index].y,2).toFixed(2)+" "+c}},itemSort:function(c,a){return a.datasetIndex-c.datasetIndex},mode:"x",position:"nearest",intersect:!1},scales:{xAxes:[{type:"time",gridLines:{display:!0,color:"#282828"},ticks:{min:moment().subtract(e,d+"s"),display:!0},time:{parser:"X",unit:d,stepSize:1,displayFormats:n}}],yAxes:[{gridLines:{display:!1,color:"#282828"},scaleLabel:{display:!1,labelString:""},ticks:{display:!0,beginAtZero:!0,callback:function(a){return round(a,2).toFixed(2)+" "+c}}}]},plugins:{zoom:{pan:{enabled:ChartPan,mode:"xy",rangeMin:{x:new Date().getTime()-factor*e,y:0},rangeMax:{x:new Date().getTime(),y:getLimit(g,"y","max",!1)+.1*getLimit(g,"y","max",!1)}},zoom:{enabled:!0,drag:DragZoom,mode:"xy",rangeMin:{x:new Date().getTime()-factor*e,y:0},rangeMax:{x:new Date().getTime(),y:getLimit(g,"y","max",!1)+.1*getLimit(g,"y","max",!1)},speed:.1}},deferred:{delay:250}},annotation:{drawTime:"afterDatasetsDraw",annotations:[{type:ShowLines,mode:"horizontal",scaleID:"y-axis-0",value:getAverage(k),borderColor:bordercolourlist[0],borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"center",enabled:!0,xAdjust:0,yAdjust:0,content:"Avg. Download="+round(getAverage(k),2).toFixed(2)+c}},{type:ShowLines,mode:"horizontal",scaleID:"y-axis-0",value:getLimit(k,"y","max",!0),borderColor:bordercolourlist[0],borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"right",enabled:!0,xAdjust:0,yAdjust:0,content:"Max. Download="+round(getLimit(k,"y","max",!0),2).toFixed(2)+c}},{type:ShowLines,mode:"horizontal",scaleID:"y-axis-0",value:getLimit(k,"y","min",!0),borderColor:bordercolourlist[0],borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"left",enabled:!0,xAdjust:0,yAdjust:0,content:"Min. Download="+round(getLimit(k,"y","min",!0),2).toFixed(2)+c}},{type:ShowLines,mode:"horizontal",scaleID:"y-axis-0",value:getAverage(l),borderColor:bordercolourlist[0],borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"center",enabled:!0,xAdjust:0,yAdjust:0,content:"Avg. Upload="+round(getAverage(l),2).toFixed(2)+c}},{type:ShowLines,mode:"horizontal",scaleID:"y-axis-0",value:getLimit(l,"y","max",!0),borderColor:bordercolourlist[0],borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"right",enabled:!0,xAdjust:0,yAdjust:0,content:"Max. Upload="+round(getLimit(l,"y","max",!0),2).toFixed(2)+c}},{type:ShowLines,mode:"horizontal",scaleID:"y-axis-0",value:getLimit(l,"y","min",!0),borderColor:bordercolourlist[0],borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"left",enabled:!0,xAdjust:0,yAdjust:0,content:"Min. Upload="+round(getLimit(l,"y","min",!0),2).toFixed(2)+c}}]}},r={datasets:getDataSets(a,f,j)};m=new Chart(p,{type:"line",options:q,data:r}),window["LineChart_"+a]=m}function getDataSets(a,b,c){var d=[];colourname="#fc8500";for(var e,f=0;f<c.length;f++)e=b.filter(function(a){return a.Metric==c[f]}).map(function(a){return{x:a.Time,y:a.Value}}),d.push({label:c[f],data:e,borderWidth:1,pointRadius:1,lineTension:0,fill:!0,backgroundColor:backgroundcolourlist[f],borderColor:bordercolourlist[f]});return d.reverse(),d}function getLimit(a,b,c,d){var e,f=0;return e="x"==b?a.map(function(a){return a.x}):a.map(function(a){return a.y}),f="max"==c?Math.max.apply(Math,e):Math.min.apply(Math,e),"max"==c&&0==f&&!1==d&&(f=1),f}function getAverage(a){for(var b=0,c=0;c<a.length;c++)b+=1*a[c].y;var d=b/a.length;return d}function round(a,b){return+(Math.round(a+"e"+b)+"e-"+b)}function ToggleLines(){if(""!=interfacelist){var a=interfacelist.split(",");for(""==ShowLines?(ShowLines="line",SetCookie("ShowLines","line")):(ShowLines="",SetCookie("ShowLines","")),i3=0;i3<a.length;i3++){for(i4=0;6>i4;i4++)window["LineChart_"+a[i3]].options.annotation.annotations[i4].type=ShowLines;window["LineChart_"+a[i3]].update()}}}function ToggleFill(){if(""!=interfacelist){var a=interfacelist.split(",");for("origin"==ShowFill?(ShowFill="false",SetCookie("ShowFill","false")):(ShowFill="origin",SetCookie("ShowFill","origin")),i3=0;i3<a.length;i3++)window["LineChart_"+a[i3]].data.datasets[0].fill=ShowFill,window["LineChart_"+a[i3]].data.datasets[1].fill=ShowFill,window["LineChart_"+a[i3]].update()}}function RedrawAllCharts(){if(""!=interfacelist){var a=interfacelist.split(",");for(i2=0;i2<chartlist.length;i2++)for(i3=0;i3<a.length;i3++)$j("#"+a[i3]+"_Period").val(GetCookie(a[i3]+"_Period","number")),d3.csv("/ext/spdmerlin/csv/Combined"+chartlist[i2]+"_"+a[i3]+".htm").then(SetGlobalDataset.bind(null,chartlist[i2]+"_"+a[i3]))}}function getTimeFormat(a,b){var c;return"axis"==b?0==a?c={millisecond:"HH:mm:ss.SSS",second:"HH:mm:ss",minute:"HH:mm",hour:"HH:mm"}:1==a&&(c={millisecond:"h:mm:ss.SSS A",second:"h:mm:ss A",minute:"h:mm A",hour:"h A"}):"tooltip"==b&&(0==a?c="YYYY-MM-DD HH:mm:ss":1==a&&(c="YYYY-MM-DD h:mm:ss A")),c}function GetCookie(a,b){var c;if(null!=(c=cookie.get("spd_"+a)))return cookie.get("spd_"+a);return"string"==b?"":"number"==b?0:void 0}function SetCookie(a,b){cookie.set("spd_"+a,b,31)}function SetCurrentPage(){document.form.next_page.value=window.location.pathname.substring(1),document.form.current_page.value=window.location.pathname.substring(1)}function initial(){SetCurrentPage(),show_menu(),ScriptUpdateLayout(),SetSPDStatsTitle(),$j("#Time_Format").val(GetCookie("Time_Format","number")),get_conf_file()}function SetGlobalDataset(a,b){if(window[a]=b,currentNoCharts++,currentNoCharts==maxNoCharts&&""!=interfacelist){var c=interfacelist.split(",");for(i=0;i<c.length;i++)Draw_Chart(c[i])}}function ScriptUpdateLayout(){var a=GetVersionNumber("local"),b=GetVersionNumber("server");$j("#scripttitle").text($j("#scripttitle").text()+" - "+a),$j("#spdmerlin_version_local").text(a),a!=b&&"N/A"!=b&&($j("#spdmerlin_version_server").text("Updated version available: "+b),showhide("btnChkUpdate",!1),showhide("spdmerlin_version_server",!0),showhide("btnDoUpdate",!0))}function reload(){location.reload(!0)}function getChartPeriod(a){var b="daily";return 0==a?b="daily":1==a?b="weekly":2==a&&(b="monthly"),b}function ResetZoom(){if(""!=interfacelist){var a=interfacelist.split(",");for(i3=0;i3<a.length;i3++){var b=window["LineChart_"+a[i3]];"undefined"!=typeof b&&null!==b&&b.resetZoom()}}}function ToggleDragZoom(a){var b=!0,c=!1,d="";if(-1==a.value.indexOf("On")?(b=!0,c=!1,DragZoom=!0,ChartPan=!1,d="Drag Zoom On"):(b=!1,c=!0,DragZoom=!1,ChartPan=!0,d="Drag Zoom Off"),""!=interfacelist){var e=interfacelist.split(",");for(i3=0;i3<e.length;i3++){var f=window["LineChart_"+e[i3]];"undefined"!=typeof f&&null!==f&&(f.options.plugins.zoom.zoom.drag=b,f.options.plugins.zoom.pan.enabled=c,a.value=d,f.update())}}}function ExportCSV(){return location.href="ext/spdmerlin/csv/spdmerlindata.zip",0}function CheckUpdate(){document.form.action_script.value="start_spdmerlincheckupdate";document.form.action_wait.value=10,showLoading(),document.form.submit()}function DoUpdate(){document.form.action_script.value="start_spdmerlindoupdate";document.form.action_wait.value=20,showLoading(),document.form.submit()}function applyRule(){document.form.action_script.value="start_spdmerlin";document.form.action_wait.value=90,showLoading(),document.form.submit()}function GetVersionNumber(a){var b;return"local"==a?b=custom_settings.spdmerlin_version_local:"server"==a&&(b=custom_settings.spdmerlin_version_server),"undefined"==typeof b||null==b?"N/A":b}function get_conf_file(){$j.ajax({url:"/ext/spdmerlin/interfaces.htm",dataType:"text",error:function(){setTimeout("get_conf_file();",1e3)},success:function(a){var b=a.split("\n");b.reverse(),b=b.filter(Boolean),interfacelist="";for(var c,d=b.length,e=0;e<d;e++)if(c=b[e].indexOf("#"),-1==c){var f=b[e];$j("#table_buttons2").after(BuildInterfaceTable(f)),interfacelist+=e==d-1?f:f+","}""!=interfacelist&&(maxNoCharts=3*interfacelist.split(",").length,AddEventHandlers(),RedrawAllCharts())}})}function changeAllCharts(a){if(value=1*a.value,name=a.id.substring(0,a.id.indexOf("_")),SetCookie(a.id,value),""!=interfacelist){var b=interfacelist.split(",");for(i=0;i<b.length;i++)Draw_Chart(b[i])}}function changeChart(a){value=1*a.value,name=a.id.substring(0,a.id.indexOf("_")),SetCookie(a.id,value),Draw_Chart(name)}function BuildInterfaceTable(a){var b="<div style=\"line-height:10px;\">&nbsp;</div>";b+="<table width=\"100%\" border=\"1\" align=\"center\" cellpadding=\"4\" cellspacing=\"0\" bordercolor=\"#6b8fa3\" class=\"FormTable\" id=\"table_interfaces_"+a+"\">",b+="<thead class=\"collapsible-jquery\" id=\""+a+"\">",b+="<tr>",b+="<td colspan=\"2\">"+a+" (click to expand/collapse)</td>",b+="</tr>",b+="</thead>",b+="<div class=\"collapsiblecontent\">",b+="<tr>",b+="<td colspan=\"2\" align=\"center\" style=\"padding: 0px;\">",b+="<table width=\"100%\" border=\"1\" align=\"center\" cellpadding=\"4\" cellspacing=\"0\" bordercolor=\"#6b8fa3\" class=\"FormTable\">",b+="<thead class=\"collapsible-jquery\" id=\"resulttable_"+a+"\">",b+="<tr><td colspan=\"2\">Last 10 speedtest results (click to expand/collapse)</td></tr>",b+="</thead>",b+="<div class=\"collapsiblecontent\">",b+="<tr>",b+="<td colspan=\"2\" align=\"center\" style=\"padding: 0px;\">",b+="<table width=\"100%\" border=\"1\" align=\"center\" cellpadding=\"4\" cellspacing=\"0\" bordercolor=\"#6b8fa3\" class=\"FormTable StatsTable\">";var c="",d=window["DataTimestamp_"+a];if("undefined"==typeof d||null===d?c="true":0==d.length?c="true":1==d.length&&""==d[0]&&(c="true"),"true"==c)b+="<tr>",b+="<td colspan=\"3\" class=\"nodata\">",b+="No data to display",b+="</td>",b+="</tr>";else for(b+="<col style=\"width:240px;\">",b+="<col style=\"width:240px;\">",b+="<col style=\"width:240px;\">",b+="<thead>",b+="<tr>",b+="<th class=\"keystatsnumber\">Time</th>",b+="<th class=\"keystatsnumber\">Download (Mbps)</th>",b+="<th class=\"keystatsnumber\">Upload (Mbps)</th>",b+="</tr>",b+="</thead>",i=0;i<d.length;i++)b+="<tr>",b+="<td>"+moment.unix(window["DataTimestamp_"+a][i]).format("YYYY-MM-DD HH:mm:ss")+"</td>",b+="<td>"+window["DataDownload_"+a][i]+"</td>",b+="<td>"+window["DataUpload_"+a][i]+"</td>",b+="</tr>";return b+="</table>",b+="</td>",b+="</tr>",b+="</div>",b+="</table>",b+="<div style=\"line-height:10px;\">&nbsp;</div>",b+="<table width=\"100%\" border=\"1\" align=\"center\" cellpadding=\"4\" cellspacing=\"0\" bordercolor=\"#6b8fa3\" class=\"FormTable\">",b+="<thead class=\"collapsible-jquery\" id=\""+a+"_Chart\">",b+="<tr>",b+="<td colspan=\"2\">Chart (click to expand/collapse)</td>",b+="</tr>",b+="</thead>",b+="<div class=\"collapsiblecontent\">",b+="<tr class=\"even\">",b+="<th width=\"40%\">Period to display</th>",b+="<td>",b+="<select style=\"width:125px\" class=\"input_option\" onchange=\"changeChart(this)\" id=\""+a+"_Period\">",b+="<option value=0>Last 24 hours</option>",b+="<option value=1>Last 7 days</option>",b+="<option value=2>Last 30 days</option>",b+="</select>",b+="</td>",b+="</tr>",b+="<tr>",b+="<td colspan=\"2\" align=\"center\" style=\"padding: 0px;\">",b+="<div style=\"background-color:#2f3e44;border-radius:10px;width:730px;height:500px;padding-left:5px;\"><canvas id=\"divLineChart_"+a+"\" height=\"500\" /></div>",b+="</td>",b+="</tr>",b+="</div>",b+="</table>",b+="</td>",b+="</tr>",b+="</div>",b+="</table>",b+="<div style=\"line-height:10px;\">&nbsp;</div>",b}function AddEventHandlers(){$j(".collapsible-jquery").click(function(){$j(this).siblings().toggle("fast",function(){"none"==$j(this).css("display")?SetCookie($j(this).siblings()[0].id,"collapsed"):SetCookie($j(this).siblings()[0].id,"expanded")})}),$j(".collapsible-jquery").each(function(){"collapsed"==GetCookie($j(this)[0].id,"string")?$j(this).siblings().toggle(!1):$j(this).siblings().toggle(!0)})}
</script>
</head>
<body onload="initial();" onunload="return unload_body();">
<div id="TopBanner"></div>
<div id="Loading" class="popup_bg"></div>
<iframe name="hidden_frame" id="hidden_frame" src="about:blank" width="0" height="0" frameborder="0"></iframe>
<form method="post" name="form" id="ruleForm" action="/start_apply.htm" target="hidden_frame">
<input type="hidden" name="action_script" value="start_spdmerlin">
<input type="hidden" name="current_page" value="">
<input type="hidden" name="next_page" value="">
<input type="hidden" name="modified" value="0">
<input type="hidden" name="action_mode" value="apply">
<input type="hidden" name="action_wait" value="90">
<input type="hidden" name="first_time" value="">
<input type="hidden" name="SystemCmd" value="">
<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>">
<input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>">
<input type="hidden" name="amng_custom" id="amng_custom" value="">
<table class="content" align="center" cellpadding="0" cellspacing="0">
<tr>
<td width="17">&nbsp;</td>
<td valign="top" width="202">
<div id="mainMenu"></div>
<div id="subMenu"></div></td>
<td valign="top">
<div id="tabMenu" class="submenuBlock"></div>
<table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
<tr>
<td valign="top">
<table width="760px" border="0" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTitle" id="FormTitle">
<tbody>
<tr bgcolor="#4D595D">
<td valign="top">
<div>&nbsp;</div>
<div class="formfonttitle" id="scripttitle" style="text-align:center;">spdMerlin</div>
<div id="statstitle" style="text-align:center;">Stats last updated:</div>
<div style="margin:10px 0 10px 5px;" class="splitLine"></div>
<div class="formfontdesc">spdMerlin is an automatic speedtest tool for AsusWRT Merlin - with charts.</div>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="border:0px;" id="table_buttons">
<thead class="collapsible-jquery" id="scripttools">
<tr><td colspan="2">Script Utilities (click to expand/collapse)</td></tr>
</thead>
<div class="collapsiblecontent">
<tr>
<th width="20%">Version information</th>
<td>
<span id="spdmerlin_version_local" style="color:#FFFFFF;"></span>
&nbsp;&nbsp;&nbsp;
<span id="spdmerlin_version_server" style="display:none;">Update version</span>
&nbsp;&nbsp;&nbsp;
<input type="button" class="button_gen" onclick="CheckUpdate();" value="Check" id="btnChkUpdate">
<input type="button" class="button_gen" onclick="DoUpdate();" value="Update" id="btnDoUpdate" style="display:none;">
&nbsp;&nbsp;&nbsp;
</td>
</tr>
<tr>
<th width="20%">Update stats</th>
<td>
<input type="button" onclick="applyRule();" value="Run speedtest" class="button_gen" name="btnRunSpeedtest">
</td>
</tr>
<tr>
<th width="20%">Export</th>
<td>
<input type="button" onclick="ExportCSV();" value="Export to CSV" class="button_gen" name="btnExport">
</td>
</tr>
</div>
</table>
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="border:0px;" id="table_buttons2">
<thead class="collapsible-jquery" id="charttools">
<tr><td colspan="2">Chart Configuration (click to expand/collapse)</td></tr>
</thead>
<div class="collapsiblecontent">
<tr>
<th width="20%"><span style="color:#FFFFFF;">Time format</span><br /><span style="color:#FFFFFF;">for tooltips and Last 24h chart axis</span></th>
<td>
<select style="width:100px" class="input_option" onchange="changeAllCharts(this)" id="Time_Format">
<option value="0">24h</option>
<option value="1">12h</option>
</select>
</td>
</tr>
<tr class="apply_gen" valign="top">
<td colspan="2" style="background-color:rgb(77, 89, 93);">
<input type="button" onclick="ToggleDragZoom(this);" value="Drag Zoom On" class="button_gen" name="btnDragZoom">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="button" onclick="ResetZoom();" value="Reset Zoom" class="button_gen" name="btnResetZoom">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="button" onclick="ToggleLines();" value="Toggle Lines" class="button_gen" name="btnToggleLines">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="button" onclick="ToggleFill();" value="Toggle Fill" class="button_gen" name="btnToggleFill">
</td>
</tr>
</div>
</table>

<!-- Charts inserted here -->

</td>
</tr>
</tbody>
</table>
</td>
</tr>
</table>
</td>
</tr>
</table>
</form>
<div id="footer">
</div>
</body>
</html>
