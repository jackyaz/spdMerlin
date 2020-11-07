<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">
<link rel="shortcut icon" href="images/favicon.png">
<link rel="icon" href="images/favicon.png">
<title>spdMerlin</title>
<link rel="stylesheet" type="text/css" href="index_style.css">
<link rel="stylesheet" type="text/css" href="form_style.css">
<style>
p {
  font-weight: bolder;
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
</style>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/jquery.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/moment.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/chart.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/hammerjs.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/chartjs-plugin-zoom.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/chartjs-plugin-annotation.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/d3.js"></script>
<script language="JavaScript" type="text/javascript" src="/state.js"></script>
<script language="JavaScript" type="text/javascript" src="/general.js"></script>
<script language="JavaScript" type="text/javascript" src="/popup.js"></script>
<script language="JavaScript" type="text/javascript" src="/help.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/detect.js"></script>
<script language="JavaScript" type="text/javascript" src="/tmhist.js"></script>
<script language="JavaScript" type="text/javascript" src="/tmmenu.js"></script>
<script language="JavaScript" type="text/javascript" src="/client_function.js"></script>
<script language="JavaScript" type="text/javascript" src="/validator.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/spdmerlin/spdjs.js"></script>
<script>
var custom_settings;
function LoadCustomSettings(){
	custom_settings = <% get_custom_settings(); %>;
	for (var prop in custom_settings){
		if (Object.prototype.hasOwnProperty.call(custom_settings, prop)){
			if(prop.indexOf("spdmerlin") != -1 && prop.indexOf("spdmerlin_version") == -1){
				eval("delete custom_settings."+prop)
			}
		}
	}
}
var $j=jQuery.noConflict(),maxNoCharts=0,currentNoCharts=0,ShowLines=GetCookie("ShowLines","string"),ShowFill=GetCookie("ShowFill","string");""==ShowFill&&(ShowFill="origin");var DragZoom=!0,ChartPan=!1;Chart.defaults.global.defaultFontColor="#CCC",Chart.Tooltip.positioners.cursor=function(a,b){return b};var chartlist=["daily","weekly","monthly"],timeunitlist=["hour","day","day"],intervallist=[24,7,30],bordercolourlist_Combined=["#fc8500","#42ecf5"],backgroundcolourlist_Combined=["rgba(252,133,0,0.5)","rgba(66,236,245,0.5)"],bordercolourlist_Quality=["#53047a","#07f242","#ffffff"],backgroundcolourlist_Quality=["rgba(83,4,122,0.5)","rgba(7,242,66,0.5)","rgba(255,255,255,0.5)"],typelist=["Combined","Quality"];function keyHandler(a){27==a.keyCode&&($j(document).off("keydown"),ResetZoom())}$j(document).keydown(function(a){keyHandler(a)}),$j(document).keyup(function(){$j(document).keydown(function(a){keyHandler(a)})});function Draw_Chart_NoData(a,b){document.getElementById("divLineChart_"+a+"_"+b).width="730",document.getElementById("divLineChart_"+a+"_"+b).height="500",document.getElementById("divLineChart_"+a+"_"+b).style.width="730px",document.getElementById("divLineChart_"+a+"_"+b).style.height="500px";var c=document.getElementById("divLineChart_"+a+"_"+b).getContext("2d");c.save(),c.textAlign="center",c.textBaseline="middle",c.font="normal normal bolder 48px Arial",c.fillStyle="white",c.fillText("No data to display",365,250),c.restore()}function Draw_Chart(a,b){var c="",d="",e="",f="",g="",h="",j=!1;"Combined"==b?(c="Mbps",e="Bandwidth",f="Download",g="Upload"):"Quality"==b&&(c="ms",d="%",e="Quality",f="Latency",g="Jitter",h="PktLoss",j=!0);var k=getChartPeriod($j("#"+a+"_Period_"+b+" option:selected").val()),l=timeunitlist[$j("#"+a+"_Period_"+b+" option:selected").val()],m=intervallist[$j("#"+a+"_Period_"+b+" option:selected").val()],n=window[k+"_"+a+"_"+b];if("undefined"==typeof n||null===n)return void Draw_Chart_NoData(a,b);if(0==n.length)return void Draw_Chart_NoData(a,b);var o=n.map(function(a){return{x:a.Time,y:a.Value}}),p=[],q=[];for(let c=0;c<n.length;c++)p[n[c].Metric]||(q.push(n[c].Metric),p[n[c].Metric]=1);var r=n.filter(function(a){return a.Metric==f}).map(function(a){return{x:a.Time,y:a.Value}}),s=n.filter(function(a){return a.Metric==g}).map(function(a){return{x:a.Time,y:a.Value}}),t=n.filter(function(a){return a.Metric==h}).map(function(a){return{x:a.Time,y:a.Value}}),u=window["LineChart_"+a+"_"+b],v=getTimeFormat($j("#Time_Format option:selected").val(),"axis"),w=getTimeFormat($j("#Time_Format option:selected").val(),"tooltip");factor=0,"hour"==l?factor=3600000:"day"==l&&(factor=86400000),u!=null&&u.destroy();var x=document.getElementById("divLineChart_"+a+"_"+b).getContext("2d"),y={segmentShowStroke:!1,segmentStrokeColor:"#000",animationEasing:"easeOutQuart",animationSteps:100,maintainAspectRatio:!1,animateScale:!0,hover:{mode:"point"},legend:{display:!0,position:"top",reverse:!0,onClick:function(a,b){var c=b.datasetIndex,d=this.chart,e=d.getDatasetMeta(c);if(e.hidden=null===e.hidden?!d.data.datasets[c].hidden:null,"line"==ShowLines){var f="";if(!0!=e.hidden&&(f="line"),"Latency"==d.data.datasets[c].label||"Download"==d.data.datasets[c].label)for(aindex=0;3>aindex;aindex++)d.options.annotation.annotations[aindex].type=f;else if("Jitter"==d.data.datasets[c].label||"Upload"==d.data.datasets[c].label)for(aindex=3;6>aindex;aindex++)d.options.annotation.annotations[aindex].type=f;else if("Packet Loss"==d.data.datasets[c].label)for(aindex=6;9>aindex;aindex++)d.options.annotation.annotations[aindex].type=f}if("Packet Loss"==d.data.datasets[c].label){var g=!1;!0!=e.hidden&&(g=!0),d.scales["right-y-axis"].options.display=g}d.update()}},title:{display:!0,text:e},tooltips:{callbacks:{title:function(a){return moment(a[0].xLabel,"X").format(w)},label:function(a,b){var e=c;return"Packet Loss"==b.datasets[a.datasetIndex].label&&(e=d),round(b.datasets[a.datasetIndex].data[a.index].y,2).toFixed(2)+" "+e}},itemSort:function(c,a){return a.datasetIndex-c.datasetIndex},mode:"point",position:"cursor",intersect:!0},scales:{xAxes:[{type:"time",gridLines:{display:!0,color:"#282828"},ticks:{min:moment().subtract(m,l+"s"),display:!0},time:{parser:"X",unit:l,stepSize:1,displayFormats:v}}],yAxes:[{gridLines:{display:!1,color:"#282828"},scaleLabel:{display:!1,labelString:""},id:"left-y-axis",position:"left",ticks:{display:!0,beginAtZero:!0,callback:function(a){return round(a,2).toFixed(2)+" "+c}}},{gridLines:{display:!1,color:"#282828"},scaleLabel:{display:!1,labelString:""},id:"right-y-axis",position:"right",ticks:{display:j,beginAtZero:!0,callback:function(a){return round(a,2).toFixed(2)+" "+d}}}]},plugins:{zoom:{pan:{enabled:ChartPan,mode:"xy",rangeMin:{x:new Date().getTime()-factor*m,y:0},rangeMax:{x:new Date().getTime()}},zoom:{enabled:!0,drag:DragZoom,mode:"xy",rangeMin:{x:new Date().getTime()-factor*m,y:0},rangeMax:{x:new Date().getTime()},speed:.1}}},annotation:{drawTime:"afterDatasetsDraw",annotations:[{type:ShowLines,mode:"horizontal",scaleID:"left-y-axis",value:getAverage(r),borderColor:window["bordercolourlist_"+b][0],borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"center",enabled:!0,xAdjust:0,yAdjust:0,content:"Avg. "+f+"="+round(getAverage(r),2).toFixed(2)+c}},{type:ShowLines,mode:"horizontal",scaleID:"left-y-axis",value:getLimit(r,"y","max",!0),borderColor:window["bordercolourlist_"+b][0],borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"right",enabled:!0,xAdjust:15,yAdjust:0,content:"Max. "+f+"="+round(getLimit(r,"y","max",!0),2).toFixed(2)+c}},{type:ShowLines,mode:"horizontal",scaleID:"left-y-axis",value:getLimit(r,"y","min",!0),borderColor:window["bordercolourlist_"+b][0],borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"left",enabled:!0,xAdjust:15,yAdjust:0,content:"Min. "+f+"="+round(getLimit(r,"y","min",!0),2).toFixed(2)+c}},{type:ShowLines,mode:"horizontal",scaleID:"left-y-axis",value:getAverage(s),borderColor:window["bordercolourlist_"+b][1],borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"center",enabled:!0,xAdjust:0,yAdjust:0,content:"Avg. "+g+"="+round(getAverage(s),2).toFixed(2)+c}},{type:ShowLines,mode:"horizontal",scaleID:"left-y-axis",value:getLimit(s,"y","max",!0),borderColor:window["bordercolourlist_"+b][1],borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"right",enabled:!0,xAdjust:15,yAdjust:0,content:"Max. "+g+"="+round(getLimit(s,"y","max",!0),2).toFixed(2)+c}},{type:ShowLines,mode:"horizontal",scaleID:"left-y-axis",value:getLimit(s,"y","min",!0),borderColor:window["bordercolourlist_"+b][1],borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"left",enabled:!0,xAdjust:15,yAdjust:0,content:"Min. "+g+"="+round(getLimit(s,"y","min",!0),2).toFixed(2)+c}},{type:ShowLines,mode:"horizontal",scaleID:"right-y-axis",value:getAverage(t),borderColor:window["bordercolourlist_"+b][2],borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"center",enabled:!0,xAdjust:0,yAdjust:0,content:"Avg. "+h+"="+round(getAverage(t),2).toFixed(2)+d}},{type:ShowLines,mode:"horizontal",scaleID:"right-y-axis",value:getLimit(t,"y","max",!0),borderColor:window["bordercolourlist_"+b][2],borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"right",enabled:!0,xAdjust:15,yAdjust:0,content:"Max. "+h+"="+round(getLimit(t,"y","max",!0),2).toFixed(2)+d}},{type:ShowLines,mode:"horizontal",scaleID:"right-y-axis",value:getLimit(t,"y","min",!0),borderColor:window["bordercolourlist_"+b][2],borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"left",enabled:!0,xAdjust:15,yAdjust:0,content:"Min. "+h+"="+round(getLimit(t,"y","min",!0),2).toFixed(2)+d}}]}},z={datasets:getDataSets(b,n,q)};u=new Chart(x,{type:"line",options:y,data:z}),window["LineChart_"+a+"_"+b]=u}function getDataSets(a,b,c){var d=[];colourname="#fc8500";for(var e=0;e<c.length;e++){var f=b.filter(function(a){return a.Metric==c[e]}).map(function(a){return{x:a.Time,y:a.Value}}),g="left-y-axis";"PktLoss"==c[e]&&(g="right-y-axis"),d.push({label:c[e].replace("PktLoss","Packet Loss"),data:f,yAxisID:g,borderWidth:1,pointRadius:1,lineTension:0,fill:!0,backgroundColor:window["backgroundcolourlist_"+a][e],borderColor:window["bordercolourlist_"+a][e]})}return d.reverse(),d}function getLimit(a,b,c,d){var e,f=0;return e="x"==b?a.map(function(a){return a.x}):a.map(function(a){return a.y}),f="max"==c?Math.max.apply(Math,e):Math.min.apply(Math,e),"max"==c&&0==f&&!1==d&&(f=1),f}function getAverage(a){for(var b=0,c=0;c<a.length;c++)b+=1*a[c].y;var d=b/a.length;return d}function round(a,b){return+(Math.round(a+"e"+b)+"e-"+b)}function ToggleLines(){if(""!=interfacelist){var a=interfacelist.split(",");for(""==ShowLines?(ShowLines="line",SetCookie("ShowLines","line")):(ShowLines="",SetCookie("ShowLines","")),i=0;i<a.length;i++)for(i2=0;i2<typelist.length;i2++){var b=6;for("Quality"==typelist[i2]&&(b=9),i3=0;i3<b;i3++)window["LineChart_"+a[i]+"_"+typelist[i2]].options.annotation.annotations[i3].type=ShowLines;window["LineChart_"+a[i]+"_"+typelist[i2]].update()}}}function ToggleFill(){if(""!=interfacelist){var a=interfacelist.split(",");for("origin"==ShowFill?(ShowFill=!1,SetCookie("ShowFill",!1)):(ShowFill="origin",SetCookie("ShowFill","origin")),i=0;i<a.length;i++)for(i2=0;i2<typelist.length;i2++)window["LineChart_"+a[i]+"_"+typelist[i2]].data.datasets[0].fill=ShowFill,window["LineChart_"+a[i]+"_"+typelist[i2]].data.datasets[1].fill=ShowFill,"Quality"==typelist[i2]&&(window["LineChart_"+a[i]+"_"+typelist[i2]].data.datasets[2].fill=ShowFill),window["LineChart_"+a[i]+"_"+typelist[i2]].update()}}function RedrawAllCharts(){if(""!=interfacelist){var a=interfacelist.split(",");for(i2=0;i2<chartlist.length;i2++)for(i3=0;i3<a.length;i3++)$j("#"+a[i3]+"_Period_Combined").val(GetCookie(a[i3]+"_Period_Combined","number")),$j("#"+a[i3]+"_Period_Quality").val(GetCookie(a[i3]+"_Period_Quality","number")),d3.csv("/ext/spdmerlin/csv/Combined"+chartlist[i2]+"_"+a[i3]+".htm").then(SetGlobalDataset.bind(null,chartlist[i2]+"_"+a[i3]+"_Combined")),d3.csv("/ext/spdmerlin/csv/Quality"+chartlist[i2]+"_"+a[i3]+".htm").then(SetGlobalDataset.bind(null,chartlist[i2]+"_"+a[i3]+"_Quality"))}}function getTimeFormat(a,b){var c;return"axis"==b?0==a?c={millisecond:"HH:mm:ss.SSS",second:"HH:mm:ss",minute:"HH:mm",hour:"HH:mm"}:1==a&&(c={millisecond:"h:mm:ss.SSS A",second:"h:mm:ss A",minute:"h:mm A",hour:"h A"}):"tooltip"==b&&(0==a?c="YYYY-MM-DD HH:mm:ss":1==a&&(c="YYYY-MM-DD h:mm:ss A")),c}function GetCookie(a,b){var c;if(null!=(c=cookie.get("spd_"+a)))return cookie.get("spd_"+a);return"string"==b?"":"number"==b?0:void 0}function SetCookie(a,b){cookie.set("spd_"+a,b,31)}$j.fn.serializeObject=function(){var b=custom_settings,c=this.serializeArray();return $j.each(c,function(){void 0!==b[this.name]&&-1!=this.name.indexOf("spdmerlin")&&-1==this.name.indexOf("version")?(!b[this.name].push&&(b[this.name]=[b[this.name]]),b[this.name].push(this.value||"")):-1!=this.name.indexOf("spdmerlin")&&-1==this.name.indexOf("version")&&(b[this.name]=this.value||"")}),b};function SetCurrentPage(){document.form.next_page.value=window.location.pathname.substring(1),document.form.current_page.value=window.location.pathname.substring(1)}function initial(){SetCurrentPage(),LoadCustomSettings(),show_menu(),get_conf_file(),$j("#Time_Format").val(GetCookie("Time_Format","number")),ScriptUpdateLayout(),SetSPDStatsTitle(),get_interfaces_file()}function SetGlobalDataset(a,b){if(window[a]=b,currentNoCharts++,currentNoCharts==maxNoCharts&&""!=interfacelist){var c=interfacelist.split(",");for(i=0;i<c.length;i++)Draw_Chart(c[i],"Combined"),Draw_Chart(c[i],"Quality")}}function ScriptUpdateLayout(){var a=GetVersionNumber("local"),b=GetVersionNumber("server");$j("#scripttitle").text($j("#scripttitle").text()+" - "+a),$j("#spdmerlin_version_local").text(a),a!=b&&"N/A"!=b&&($j("#spdmerlin_version_server").text("Updated version available: "+b),showhide("btnChkUpdate",!1),showhide("spdmerlin_version_server",!0),showhide("btnDoUpdate",!0))}function reload(){location.reload(!0)}function getChartPeriod(a){var b="daily";return 0==a?b="daily":1==a?b="weekly":2==a&&(b="monthly"),b}function ResetZoom(){if(""!=interfacelist){var a=interfacelist.split(",");for(i=0;i<a.length;i++)for(i2=0;i2<typelist.length;i2++){var b=window["LineChart_"+a[i]+"_"+typelist[i2]];"undefined"!=typeof b&&null!==b&&b.resetZoom()}}}function ToggleDragZoom(a){var b=!0,c=!1,d="";if(-1==a.value.indexOf("On")?(b=!0,c=!1,DragZoom=!0,ChartPan=!1,d="Drag Zoom On"):(b=!1,c=!0,DragZoom=!1,ChartPan=!0,d="Drag Zoom Off"),""!=interfacelist){var e=interfacelist.split(",");for(i=0;i<e.length;i++){for(i2=0;i2<typelist.length;i2++){var f=window["LineChart_"+e[i]+"_"+typelist[i2]];"undefined"!=typeof f&&null!==f&&(f.options.plugins.zoom.zoom.drag=b,f.options.plugins.zoom.pan.enabled=c,f.update())}a.value=d}}}function ExportCSV(){return location.href="/ext/spdmerlin/csv/spdmerlindata.zip",0}function update_status(){$j.ajax({url:"/ext/spdmerlin/detect_update.js",dataType:"script",timeout:3e3,error:function(){setTimeout("update_status();",1e3)},success:function(){"InProgress"==updatestatus?setTimeout("update_status();",1e3):(document.getElementById("imgChkUpdate").style.display="none",showhide("spdmerlin_version_server",!0),"None"==updatestatus?($j("#spdmerlin_version_server").text("No update available"),showhide("btnChkUpdate",!0),showhide("btnDoUpdate",!1)):($j("#spdmerlin_version_server").text("Updated version available: "+updatestatus),showhide("btnChkUpdate",!1),showhide("btnDoUpdate",!0)))}})}function CheckUpdate(){showhide("btnChkUpdate",!1),document.formScriptActions.action_script.value="start_spdmerlincheckupdate",document.formScriptActions.submit(),document.getElementById("imgChkUpdate").style.display="",setTimeout("update_status();",2e3)}function DoUpdate(){document.form.action_script.value="start_spdmerlindoupdate";document.form.action_wait.value=10,showLoading(),document.form.submit()}function get_spdtest_file(){$j.ajax({url:"/ext/spdmerlin/spd-stats.htm",dataType:"text",timeout:200,error:function(){},success:function(a){var b=a.trim().split("\n"),c=b.slice(-1)[0].split("%").filter(Boolean);5<b.length?$j("#spdtest_output").html(b[0]+"\n"+b[1]+"\n"+b[2]+"\n"+b[3]+"\n"+b[4]+"\n"+c[c.length-1]+"%"):$j("#spdtest_output").html("")}})}function update_spdtest(){$j.ajax({url:"/ext/spdmerlin/detect_spdtest.js",dataType:"script",timeout:1e3,error:function(){},success:function(){-1==spdteststatus.indexOf("InProgress")?"Done"==spdteststatus?(document.getElementById("spdtest_text").innerHTML="Refreshing tables and charts...",document.getElementById("spdtest_output").parentElement.parentElement.style.display="none",setTimeout("PostSpeedTest();",1e3),clearInterval(myinterval)):-1==spdteststatus.indexOf("LOCKED")?-1==spdteststatus.indexOf("NoLicense")?-1==spdteststatus.indexOf("Error")?-1!=spdteststatus.indexOf("NoSwap")&&(showhide("imgSpdTest",!1),document.getElementById("spdtest_text").innerHTML="No Swap file configured/detected",showhide("spdtest_text",!0),document.getElementById("spdtest_output").parentElement.parentElement.style.display="none",showhide("btnRunSpeedtest",!0),clearInterval(myinterval)):(showhide("imgSpdTest",!1),document.getElementById("spdtest_text").innerHTML="Error running speedtest",showhide("spdtest_text",!0),document.getElementById("spdtest_output").parentElement.parentElement.style.display="none",showhide("btnRunSpeedtest",!0),clearInterval(myinterval)):(showhide("imgSpdTest",!1),document.getElementById("spdtest_text").innerHTML="Please accept Ookla license at command line via spdmerlin",showhide("spdtest_text",!0),document.getElementById("spdtest_output").parentElement.parentElement.style.display="none",showhide("btnRunSpeedtest",!0),clearInterval(myinterval)):(showhide("imgSpdTest",!1),document.getElementById("spdtest_text").innerHTML="Scheduled speedtest already running!",showhide("spdtest_text",!0),document.getElementById("spdtest_output").parentElement.parentElement.style.display="none",showhide("btnRunSpeedtest",!0),clearInterval(myinterval)):-1!=spdteststatus.indexOf("_")&&(showhide("imgSpdTest",!0),showhide("spdtest_text",!0),document.getElementById("spdtest_text").innerHTML="Speedtest in progress for "+spdteststatus.substring(spdteststatus.indexOf("_")+1),document.getElementById("spdtest_output").parentElement.parentElement.style.display="",get_spdtest_file())}})}function PostSpeedTest(){showhide("imgSpdTest",!1),showhide("spdtest_text",!1),showhide("btnRunSpeedtest",!0),document.getElementById("table_allinterfaces").remove(),currentNoCharts=0,reload_js("/ext/spdmerlin/spdjs.js"),$j("#Time_Format").val(GetCookie("Time_Format","number")),SetSPDStatsTitle(),get_interfaces_file()}function RunSpeedtest(){showhide("btnRunSpeedtest",!1),document.formScriptActions.action_script.value="start_spdmerlin",document.formScriptActions.submit(),showhide("imgSpdTest",!0),showhide("spdtest_text",!1),setTimeout("StartSpeedTestInterval();",1500)}var myinterval;function StartSpeedTestInterval(){myinterval=setInterval("update_spdtest();",400)}function reload_js(a){$j("script[src=\""+a+"\"]").remove(),$j("<script>").attr("src",a+"?cachebuster="+new Date().getTime()).appendTo("head")}function applyRule(){document.getElementById("amng_custom").value=JSON.stringify($j("form").serializeObject());document.form.action_script.value="start_spdmerlinconfig";document.form.action_wait.value=15,showLoading(),document.form.submit()}function GetVersionNumber(a){var b;return"local"==a?b=custom_settings.spdmerlin_version_local:"server"==a&&(b=custom_settings.spdmerlin_version_server),"undefined"==typeof b||null==b?"N/A":b}function get_conf_file(){$j.ajax({url:"/ext/spdmerlin/config.htm",dataType:"text",error:function(){setTimeout("get_conf_file();",1e3)},success:function(a){var b=a.split("\n");b=b.filter(Boolean);for(var c=0;c<b.length;c++)-1==b[c].indexOf("OUTPUTDATAMODE")?-1==b[c].indexOf("OUTPUTTIMEMODE")?-1!=b[c].indexOf("STORAGELOCATION")&&(document.form.spdmerlin_storagelocation.value=b[c].split("=")[1].replace(/(\r\n|\n|\r)/gm,"")):document.form.spdmerlin_outputtimemode.value=b[c].split("=")[1].replace(/(\r\n|\n|\r)/gm,""):document.form.spdmerlin_outputdatamode.value=b[c].split("=")[1].replace(/(\r\n|\n|\r)/gm,"")}})}function get_interfaces_file(){$j.ajax({url:"/ext/spdmerlin/interfaces.htm",dataType:"text",error:function(){setTimeout("get_interfaces_file();",1e3)},success:function(a){var b=a.split("\n");b=b.filter(Boolean),interfacelist="";var c="<div style=\"line-height:10px;\">&nbsp;</div>";c+="<table width=\"100%\" border=\"1\" align=\"center\" cellpadding=\"4\" cellspacing=\"0\" bordercolor=\"#6b8fa3\" class=\"FormTable\" id=\"table_allinterfaces\">",c+="<thead class=\"collapsible-jquery\" id=\"thead_allinterfaces\">",c+="<tr>",c+="<td>Interfaces (click to expand/collapse)</td>",c+="</tr>",c+="</thead>",c+="<tr><td align=\"center\" style=\"padding: 0px;\">";for(var d,e=b.length,f=0;f<e;f++)if(d=b[f].indexOf("#"),-1==d){var g=b[f];c+=BuildInterfaceTable(g),interfacelist+=g+","}c+="</td>",c+="</tr>",c+="</table>",","==interfacelist.charAt(interfacelist.length-1)&&(interfacelist=interfacelist.slice(0,-1)),""!=interfacelist&&($j("#table_buttons2").after(c),maxNoCharts=2*(3*interfacelist.split(",").length),AddEventHandlers(),RedrawAllCharts())}})}function changeAllCharts(a){if(value=1*a.value,name=a.id.substring(0,a.id.indexOf("_")),SetCookie(a.id,value),""!=interfacelist){var b=interfacelist.split(",");for(i=0;i<b.length;i++)Draw_Chart(b[i],"Combined"),Draw_Chart(b[i],"Quality")}}function changeChart(a){value=1*a.value,name=a.id.substring(0,a.id.indexOf("_")),SetCookie(a.id,value),-1==a.id.indexOf("Combined")?-1!=a.id.indexOf("Quality")&&Draw_Chart(name,"Quality"):Draw_Chart(name,"Combined")}function BuildInterfaceTable(a){var b="<div style=\"line-height:10px;\">&nbsp;</div>";b+="<table width=\"100%\" border=\"1\" align=\"center\" cellpadding=\"4\" cellspacing=\"0\" bordercolor=\"#6b8fa3\" class=\"FormTable\" id=\"table_interfaces_"+a+"\">",b+="<thead class=\"collapsible-jquery\" id=\""+a+"\">",b+="<tr>",b+="<td colspan=\"2\">"+a+" (click to expand/collapse)</td>",b+="</tr>",b+="</thead>",b+="<tr>",b+="<td colspan=\"2\" align=\"center\" style=\"padding: 0px;\">",b+="<table width=\"100%\" border=\"1\" align=\"center\" cellpadding=\"4\" cellspacing=\"0\" bordercolor=\"#6b8fa3\" class=\"FormTable\">",b+="<thead class=\"collapsible-jquery\" id=\"resulttable_"+a+"\">",b+="<tr><td colspan=\"2\">Last 10 speedtest results (click to expand/collapse)</td></tr>",b+="</thead>",b+="<tr>",b+="<td colspan=\"2\" align=\"center\" style=\"padding: 0px;\">",b+="<table width=\"100%\" border=\"1\" align=\"center\" cellpadding=\"4\" cellspacing=\"0\" bordercolor=\"#6b8fa3\" class=\"FormTable StatsTable\">";var c="",d=window["DataTimestamp_"+a];if("undefined"==typeof d||null===d?c="true":0==d.length?c="true":1==d.length&&""==d[0]&&(c="true"),"true"==c)b+="<tr>",b+="<td colspan=\"6\" class=\"nodata\">",b+="No data to display",b+="</td>",b+="</tr>";else for(b+="<col style=\"width:120px;\">",b+="<col style=\"width:120px;\">",b+="<col style=\"width:120px;\">",b+="<col style=\"width:120px;\">",b+="<col style=\"width:120px;\">",b+="<col style=\"width:120px;\">",b+="<thead>",b+="<tr>",b+="<th class=\"keystatsnumber\">Time</th>",b+="<th class=\"keystatsnumber\">Download (Mbps)</th>",b+="<th class=\"keystatsnumber\">Upload (Mbps)</th>",b+="<th class=\"keystatsnumber\">Latency (ms)</th>",b+="<th class=\"keystatsnumber\">Jitter (ms)</th>",b+="<th class=\"keystatsnumber\">Packet Loss (%)</th>",b+="</tr>",b+="</thead>",i=0;i<d.length;i++)b+="<tr>",b+="<td>"+moment.unix(window["DataTimestamp_"+a][i]).format("YYYY-MM-DD HH:mm:ss")+"</td>",b+="<td>"+window["DataDownload_"+a][i]+"</td>",b+="<td>"+window["DataUpload_"+a][i]+"</td>",b+="<td>"+window["DataLatency_"+a][i]+"</td>",b+="<td>"+window["DataJitter_"+a][i]+"</td>",b+="<td>"+window["DataPktLoss_"+a][i]+"</td>",b+="</tr>";return b+="</table>",b+="</td>",b+="</tr>",b+="</table>",b+="<div style=\"line-height:10px;\">&nbsp;</div>",b+="<table width=\"100%\" border=\"1\" align=\"center\" cellpadding=\"4\" cellspacing=\"0\" bordercolor=\"#6b8fa3\" class=\"FormTable\">",b+="<thead class=\"collapsible-jquery\" id=\"table_charts\">",b+="<tr>",b+="<td>Charts (click to expand/collapse)</td>",b+="</tr>",b+="</thead>",b+="<tr><td align=\"center\" style=\"padding: 0px;\">",b+="<table width=\"100%\" border=\"1\" align=\"center\" cellpadding=\"4\" cellspacing=\"0\" bordercolor=\"#6b8fa3\" class=\"FormTable\">",b+="<thead class=\"collapsible-jquery\" id=\""+a+"_ChartCombined\">",b+="<tr>",b+="<td colspan=\"2\">Bandwidth (click to expand/collapse)</td>",b+="</tr>",b+="</thead>",b+="<tr class=\"even\">",b+="<th width=\"40%\">Period to display</th>",b+="<td>",b+="<select style=\"width:125px\" class=\"input_option\" onchange=\"changeChart(this)\" id=\""+a+"_Period_Combined\">",b+="<option value=0>Last 24 hours</option>",b+="<option value=1>Last 7 days</option>",b+="<option value=2>Last 30 days</option>",b+="</select>",b+="</td>",b+="</tr>",b+="<tr>",b+="<td colspan=\"2\" align=\"center\" style=\"padding: 0px;\">",b+="<div style=\"background-color:#2f3e44;border-radius:10px;width:730px;height:500px;padding-left:5px;\"><canvas id=\"divLineChart_"+a+"_Combined\" height=\"500\" /></div>",b+="</td>",b+="</tr>",b+="</table>",b+="<div style=\"line-height:10px;\">&nbsp;</div>",b+="<table width=\"100%\" border=\"1\" align=\"center\" cellpadding=\"4\" cellspacing=\"0\" bordercolor=\"#6b8fa3\" class=\"FormTable\">",b+="<thead class=\"collapsible-jquery\" id=\""+a+"_ChartQuality\">",b+="<tr>",b+="<td colspan=\"2\">Quality (click to expand/collapse)</td>",b+="</tr>",b+="</thead>",b+="<tr class=\"even\">",b+="<th width=\"40%\">Period to display</th>",b+="<td>",b+="<select style=\"width:125px\" class=\"input_option\" onchange=\"changeChart(this)\" id=\""+a+"_Period_Quality\">",b+="<option value=0>Last 24 hours</option>",b+="<option value=1>Last 7 days</option>",b+="<option value=2>Last 30 days</option>",b+="</select>",b+="</td>",b+="</tr>",b+="<tr>",b+="<td colspan=\"2\" align=\"center\" style=\"padding: 0px;\">",b+="<div style=\"background-color:#2f3e44;border-radius:10px;width:730px;height:500px;padding-left:5px;\"><canvas id=\"divLineChart_"+a+"_Quality\" height=\"500\" /></div>",b+="</td>",b+="</tr>",b+="</table>",b+="</td>",b+="</tr>",b+="</table>",b+="</td>",b+="</tr>",b+="</table>",b}function AddEventHandlers(){$j(".collapsible-jquery").click(function(){$j(this).siblings().toggle("fast",function(){"none"==$j(this).css("display")?SetCookie($j(this).siblings()[0].id,"collapsed"):SetCookie($j(this).siblings()[0].id,"expanded")})}),$j(".collapsible-jquery").each(function(){"collapsed"==GetCookie($j(this)[0].id,"string")?$j(this).siblings().toggle(!1):$j(this).siblings().toggle(!0)})}
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
<div class="formfontdesc">spdMerlin is an internet speedtest and monitoring tool for AsusWRT Merlin with charts for daily, weekly and monthly summaries. It tracks download/upload bandwidth as well as latency, jitter and packet loss.</div>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="border:0px;" id="table_buttons">
<thead class="collapsible-jquery" id="scripttools">
<tr><td colspan="2">Utilities (click to expand/collapse)</td></tr>
</thead>
<tr>
<th width="20%">Version information</th>
<td>
<span id="spdmerlin_version_local" style="color:#FFFFFF;"></span>
&nbsp;&nbsp;&nbsp;
<span id="spdmerlin_version_server" style="display:none;">Update version</span>
&nbsp;&nbsp;&nbsp;
<input type="button" class="button_gen" onclick="CheckUpdate();" value="Check" id="btnChkUpdate">
<img id="imgChkUpdate" style="display:none;vertical-align:middle;" src="images/InternetScan.gif"/>
<input type="button" class="button_gen" onclick="DoUpdate();" value="Update" id="btnDoUpdate" style="display:none;">
&nbsp;&nbsp;&nbsp;
</td>
</tr>
<tr>
<th width="20%">Speedtest</th>
<td>
<input type="button" onclick="RunSpeedtest();" value="Run speedtest" class="button_gen" name="btnRunSpeedtest" id="btnRunSpeedtest">
<img id="imgSpdTest" style="display:none;vertical-align:middle;" src="images/InternetScan.gif"/>
&nbsp;&nbsp;&nbsp;
<span id="spdtest_text" style="display:none;"></span>
</td>
</tr>
<tr style="display:none;"><th style="border-bottom:0px;border-top:0px;">&nbsp;</th><td style="padding: 0px;">
<textarea cols="63" rows="8" wrap="off" readonly="readonly" id="spdtest_output" class="textarea_log_table" style="border:0px;font-family:Courier New, Courier, mono; font-size:11px;overflow:hidden;">Speedtest output</textarea>
</td></tr>

<tr>
<th width="20%">Export</th>
<td>
<input type="button" onclick="ExportCSV();" value="Export to CSV" class="button_gen" name="btnExport">
</td>
</tr>
</table>
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="2" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="border:0px;" id="table_config">
<thead class="collapsible-jquery" id="scriptconfig">
<tr><td colspan="2">Configuration (click to expand/collapse)</td></tr>
</thead>
<tr class="even" id="rowdataoutput">
<th width="40%">Data Output Mode (for CSV export)</th>
<td class="settingvalue">
<input autocomplete="off" autocapitalize="off" type="radio" name="spdmerlin_outputdatamode" id="spdmerlin_dataoutput_average" class="input" value="average" checked>Average
<input autocomplete="off" autocapitalize="off" type="radio" name="spdmerlin_outputdatamode" id="spdmerlin_dataoutput_raw" class="input" value="raw">Raw
</td>
</tr>
<tr class="even" id="rowtimeoutput">
<th width="40%">Time Output Mode (for CSV export)</th>
<td class="settingvalue">
<input autocomplete="off" autocapitalize="off" type="radio" name="spdmerlin_outputtimemode" id="spdmerlin_timeoutput_non-unix" class="input" value="non-unix" checked>Non-Unix
<input autocomplete="off" autocapitalize="off" type="radio" name="spdmerlin_outputtimemode" id="spdmerlin_timeoutput_unix" class="input" value="unix">Unix
</td>
</tr>
<tr class="even" id="rowstorageloc">
<th width="40%">Data Storage Location</th>
<td class="settingvalue">
<input autocomplete="off" autocapitalize="off" type="radio" name="spdmerlin_storagelocation" id="spdmerlin_storageloc_jffs" class="input" value="jffs" checked>JFFS
<input autocomplete="off" autocapitalize="off" type="radio" name="spdmerlin_storagelocation" id="spdmerlin_storageloc_usb" class="input" value="usb">USB
</td>
</tr>
<tr class="apply_gen" valign="top" height="35px">
<td colspan="2" style="background-color:rgb(77, 89, 93);">
<input type="button" onclick="applyRule();" value="Save" class="button_gen" name="button">
</td>
</tr>
</table>

<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="border:0px;" id="table_buttons2">
<thead class="collapsible-jquery" id="charttools">
<tr><td colspan="2">Chart Display Options (click to expand/collapse)</td></tr>
</thead>
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
<form method="post" name="formScriptActions" action="/start_apply.htm" target="hidden_frame">
<input type="hidden" name="productid" value="<% nvram_get("productid"); %>">
<input type="hidden" name="current_page" value="">
<input type="hidden" name="next_page" value="">
<input type="hidden" name="action_mode" value="apply">
<input type="hidden" name="action_script" value="">
<input type="hidden" name="action_wait" value="">
</form>
<div id="footer">
</div>
</body>
</html>
