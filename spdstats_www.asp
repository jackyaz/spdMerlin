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
  color: white !important;
  padding: 4px !important;
  width: 740px !important;
  font-size: 11px !important;
}

.StatsTable td {
  padding: 2px !important;
  word-wrap: break-word !important;
  overflow-wrap: break-word !important;
  font-size: 12px !important;
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

.StatsTable tr.statsRow:nth-child(even) td {
  background-color: #2F3A3E !important;
}

.StatsTable tr.statsRow:nth-child(odd) td {
  background-color: #475A5F !important;
}

.SettingsTable {
  text-align: left;
}

.SettingsTable input {
  text-align: left;
  margin-left: 3px !important;
}

.SettingsTable input.savebutton {
  text-align: center;
  margin-top: 5px;
  margin-bottom: 5px;
  border-right: solid 1px black;
  border-left: solid 1px black;
  border-bottom: solid 1px black;
}

.SettingsTable td.savebutton {
  border-right: solid 1px black;
  border-left: solid 1px black;
  border-bottom: solid 1px black;
  background-color:rgb(77, 89, 93);
}

.SettingsTable .cronbutton {
  text-align: center;
  min-width: 50px;
  width: 50px;
  height: 23px;
  vertical-align: middle;
}

.SettingsTable select {
  margin-left: 3px !important;
}

.SettingsTable label {
  margin-right: 10px !important;
  vertical-align: top !important;
}

.SettingsTable th {
  background-color: #1F2D35 !important;
  background: #2F3A3E !important;
  border-bottom: none !important;
  border-top: none !important;
  font-size: 12px !important;
  color: white !important;
  padding: 4px !important;
  font-weight: bolder !important;
  padding: 0px !important;
}

.SettingsTable th.sectionheader {
  padding-left: 10px !important;
  border-right: solid 1px black !important;
  border-left: solid 1px black !important;
}

.SettingsTable td {
  word-wrap: break-word !important;
  overflow-wrap: break-word !important;
  border-right: none;
  border-left: none;
}

.SettingsTable span.settingname {
  background-color: #1F2D35 !important;
  background: #2F3A3E !important;
}

.SettingsTable td.settingname {
  border-right: solid 1px black;
  border-left: solid 1px black;
  background-color: #1F2D35 !important;
  background: #2F3A3E !important;
  width: 35% !important;
}

.SettingsTable td.settingvalue {
  text-align: left !important;
  border-right: solid 1px black;
}

.SettingsTable th:first-child{
  border-left: none;
}

.SettingsTable th:last-child {
  border-right: none;
}

.SettingsTable .invalid {
  background-color: darkred !important;
}

.SettingsTable .disabled {
  background-color: #CCCCCC !important;
  color: #888888 !important;
}

.removespacing {
  padding-left: 0px !important;
  margin-left: 0px !important;
  margin-bottom: 5px !important;
  text-align: center !important;
}

.schedulespan {
  display:inline-block !important;
  width:70px !important;
  color:#FFFFFF !important;
  font-weight: bold !important;
}

div.schedulesettings {
  margin-bottom: 5px;
}

.spdtest_output {
  border: solid 1px black;
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
<script>
var custom_settings;
function LoadCustomSettings(){
	custom_settings = <% get_custom_settings(); %>;
	for(var prop in custom_settings){
		if(Object.prototype.hasOwnProperty.call(custom_settings, prop)){
			if(prop.indexOf("spdmerlin") != -1 && prop.indexOf("spdmerlin_version") == -1){
				eval("delete custom_settings."+prop)
			}
		}
	}
}
var $j=jQuery.noConflict(),daysofweek=["Mon","Tues","Wed","Thurs","Fri","Sat","Sun"],maxNoCharts=0,currentNoCharts=0,interfacelist="",interfacescomplete=[],interfacesdisabled=[],ShowLines=GetCookie("ShowLines","string"),ShowFill=GetCookie("ShowFill","string");""==ShowFill&&(ShowFill="origin");var DragZoom=!0,ChartPan=!1;Chart.defaults.global.defaultFontColor="#CCC",Chart.Tooltip.positioners.cursor=function(e,t){return t};var chartlist=["daily","weekly","monthly"],timeunitlist=["hour","day","day"],intervallist=[24,7,30],bordercolourlist_Combined=["#fc8500","#42ecf5"],backgroundcolourlist_Combined=["rgba(252,133,0,0.5)","rgba(66,236,245,0.5)"],bordercolourlist_Quality=["#53047a","#07f242","#ffffff"],backgroundcolourlist_Quality=["rgba(83,4,122,0.5)","rgba(7,242,66,0.5)","rgba(255,255,255,0.5)"],typelist=["Combined","Quality"];function keyHandler(t){27==t.keyCode&&($j(document).off("keydown"),ResetZoom())}$j(document).keydown(function(t){keyHandler(t)}),$j(document).keyup(function(){$j(document).keydown(function(t){keyHandler(t)})});function Draw_Chart_NoData(e,t){document.getElementById("divLineChart_"+e+"_"+t).width="730",document.getElementById("divLineChart_"+e+"_"+t).height="500",document.getElementById("divLineChart_"+e+"_"+t).style.width="730px",document.getElementById("divLineChart_"+e+"_"+t).style.height="500px";var s=document.getElementById("divLineChart_"+e+"_"+t).getContext("2d");s.save(),s.textAlign="center",s.textBaseline="middle",s.font="normal normal bolder 48px Arial",s.fillStyle="white",s.fillText("No data to display",365,250),s.restore()}function Draw_Chart(e,t){var s="",a="",i="",l="",r="",n="",d=!1;"Combined"==t?(s="Mbps",i="Bandwidth",l="Download",r="Upload"):"Quality"==t&&(s="ms",a="%",i="Quality",l="Latency",r="Jitter",n="PktLoss",d=!0);var o=getChartPeriod($j("#"+e+"_Period_"+t+" option:selected").val()),p=timeunitlist[$j("#"+e+"_Period_"+t+" option:selected").val()],m=intervallist[$j("#"+e+"_Period_"+t+" option:selected").val()],c=window[o+"_"+e+"_"+t];if("undefined"==typeof c||null===c)return void Draw_Chart_NoData(e,t);if(0==c.length)return void Draw_Chart_NoData(e,t);var u=c.map(function(e){return{x:e.Time,y:e.Value}}),h=[],f=[];for(let s=0;s<c.length;s++)h[c[s].Metric]||(f.push(c[s].Metric),h[c[s].Metric]=1);var _=c.filter(function(e){return e.Metric==l}).map(function(e){return{x:e.Time,y:e.Value}}),b=c.filter(function(e){return e.Metric==r}).map(function(e){return{x:e.Time,y:e.Value}}),g=c.filter(function(e){return e.Metric==n}).map(function(e){return{x:e.Time,y:e.Value}}),v=window["LineChart_"+e+"_"+t],y=getTimeFormat($j("#Time_Format option:selected").val(),"axis"),x=getTimeFormat($j("#Time_Format option:selected").val(),"tooltip");factor=0,"hour"==p?factor=3600000:"day"==p&&(factor=86400000),v!=null&&v.destroy();var C=document.getElementById("divLineChart_"+e+"_"+t).getContext("2d"),w={segmentShowStroke:!1,segmentStrokeColor:"#000",animationEasing:"easeOutQuart",animationSteps:100,maintainAspectRatio:!1,animateScale:!0,hover:{mode:"point"},legend:{display:!0,position:"top",reverse:!0,onClick:function(t,e){var s=e.datasetIndex,a=this.chart,i=a.getDatasetMeta(s);if(i.hidden=null===i.hidden?!a.data.datasets[s].hidden:null,"line"==ShowLines){var l="";if(!0!=i.hidden&&(l="line"),"Latency"==a.data.datasets[s].label||"Download"==a.data.datasets[s].label)for(aindex=0;3>aindex;aindex++)a.options.annotation.annotations[aindex].type=l;else if("Jitter"==a.data.datasets[s].label||"Upload"==a.data.datasets[s].label)for(aindex=3;6>aindex;aindex++)a.options.annotation.annotations[aindex].type=l;else if("Packet Loss"==a.data.datasets[s].label)for(aindex=6;9>aindex;aindex++)a.options.annotation.annotations[aindex].type=l}if("Packet Loss"==a.data.datasets[s].label){var r=!1;!0!=i.hidden&&(r=!0),a.scales["right-y-axis"].options.display=r}a.update()}},title:{display:!0,text:i},tooltips:{callbacks:{title:function(e){return moment(e[0].xLabel,"X").format(x)},label:function(e,t){var i=s;return"Packet Loss"==t.datasets[e.datasetIndex].label&&(i=a),round(t.datasets[e.datasetIndex].data[e.index].y,2).toFixed(2)+" "+i}},itemSort:function(e,t){return t.datasetIndex-e.datasetIndex},mode:"point",position:"cursor",intersect:!0},scales:{xAxes:[{type:"time",gridLines:{display:!0,color:"#282828"},ticks:{min:moment().subtract(m,p+"s"),display:!0},time:{parser:"X",unit:p,stepSize:1,displayFormats:y}}],yAxes:[{type:getChartScale($j("#"+e+"_Scale_"+t+" option:selected").val()),gridLines:{display:!1,color:"#282828"},scaleLabel:{display:!1,labelString:s},id:"left-y-axis",position:"left",ticks:{display:!0,beginAtZero:!0,labels:{index:["min","max"],removeEmptyLines:!0},userCallback:LogarithmicFormatter}},{type:getChartScale($j("#"+e+"_Scale_"+t+" option:selected").val()),gridLines:{display:!1,color:"#282828"},scaleLabel:{display:!1,labelString:a},id:"right-y-axis",position:"right",ticks:{display:d,beginAtZero:!0,labels:{index:["min","max"],removeEmptyLines:!0},userCallback:LogarithmicFormatter}}]},plugins:{zoom:{pan:{enabled:ChartPan,mode:"xy",rangeMin:{x:new Date().getTime()-factor*m,y:0},rangeMax:{x:new Date().getTime()}},zoom:{enabled:!0,drag:DragZoom,mode:"xy",rangeMin:{x:new Date().getTime()-factor*m,y:0},rangeMax:{x:new Date().getTime()},speed:.1}}},annotation:{drawTime:"afterDatasetsDraw",annotations:[{type:ShowLines,mode:"horizontal",scaleID:"left-y-axis",value:getAverage(_),borderColor:window["bordercolourlist_"+t][0],borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"center",enabled:!0,xAdjust:0,yAdjust:0,content:"Avg. "+l+"="+round(getAverage(_),2).toFixed(2)+s}},{type:ShowLines,mode:"horizontal",scaleID:"left-y-axis",value:getLimit(_,"y","max",!0),borderColor:window["bordercolourlist_"+t][0],borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"right",enabled:!0,xAdjust:15,yAdjust:0,content:"Max. "+l+"="+round(getLimit(_,"y","max",!0),2).toFixed(2)+s}},{type:ShowLines,mode:"horizontal",scaleID:"left-y-axis",value:getLimit(_,"y","min",!0),borderColor:window["bordercolourlist_"+t][0],borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"left",enabled:!0,xAdjust:15,yAdjust:0,content:"Min. "+l+"="+round(getLimit(_,"y","min",!0),2).toFixed(2)+s}},{type:ShowLines,mode:"horizontal",scaleID:"left-y-axis",value:getAverage(b),borderColor:window["bordercolourlist_"+t][1],borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"center",enabled:!0,xAdjust:0,yAdjust:0,content:"Avg. "+r+"="+round(getAverage(b),2).toFixed(2)+s}},{type:ShowLines,mode:"horizontal",scaleID:"left-y-axis",value:getLimit(b,"y","max",!0),borderColor:window["bordercolourlist_"+t][1],borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"right",enabled:!0,xAdjust:15,yAdjust:0,content:"Max. "+r+"="+round(getLimit(b,"y","max",!0),2).toFixed(2)+s}},{type:ShowLines,mode:"horizontal",scaleID:"left-y-axis",value:getLimit(b,"y","min",!0),borderColor:window["bordercolourlist_"+t][1],borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"left",enabled:!0,xAdjust:15,yAdjust:0,content:"Min. "+r+"="+round(getLimit(b,"y","min",!0),2).toFixed(2)+s}},{type:ShowLines,mode:"horizontal",scaleID:"right-y-axis",value:getAverage(g),borderColor:window["bordercolourlist_"+t][2],borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"center",enabled:!0,xAdjust:0,yAdjust:0,content:"Avg. "+n+"="+round(getAverage(g),2).toFixed(2)+a}},{type:ShowLines,mode:"horizontal",scaleID:"right-y-axis",value:getLimit(g,"y","max",!0),borderColor:window["bordercolourlist_"+t][2],borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"right",enabled:!0,xAdjust:15,yAdjust:0,content:"Max. "+n+"="+round(getLimit(g,"y","max",!0),2).toFixed(2)+a}},{type:ShowLines,mode:"horizontal",scaleID:"right-y-axis",value:getLimit(g,"y","min",!0),borderColor:window["bordercolourlist_"+t][2],borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"left",enabled:!0,xAdjust:15,yAdjust:0,content:"Min. "+n+"="+round(getLimit(g,"y","min",!0),2).toFixed(2)+a}}]}},L={datasets:getDataSets(t,c,f)};v=new Chart(C,{type:"line",options:w,data:L}),window["LineChart_"+e+"_"+t]=v}function LogarithmicFormatter(e,t,s){var a=this.options.scaleLabel.labelString;if("logarithmic"!=this.type)return isNaN(e)?e+" "+a:round(e,2).toFixed(2)+" "+a;var i=this.options.ticks.labels||{},l=i.index||["min","max"],r=i.significand||[1,2,5],n=e/Math.pow(10,Math.floor(Chart.helpers.log10(e))),d=!0===i.removeEmptyLines?void 0:"",o="";return 0===t?o="min":t==s.length-1&&(o="max"),"all"===i||-1!==r.indexOf(n)||-1!==l.indexOf(t)||-1!==l.indexOf(o)?0===e?"0 "+a:isNaN(e)?e+" "+a:round(e,2).toFixed(2)+" "+a:d}function getDataSets(e,t,s){var a=[];colourname="#fc8500";for(var l=0;l<s.length;l++){var r=t.filter(function(e){return e.Metric==s[l]}).map(function(e){return{x:e.Time,y:e.Value}}),n="left-y-axis";"PktLoss"==s[l]&&(n="right-y-axis"),a.push({label:s[l].replace("PktLoss","Packet Loss"),data:r,yAxisID:n,borderWidth:1,pointRadius:1,lineTension:0,fill:ShowFill,backgroundColor:window["backgroundcolourlist_"+e][l],borderColor:window["bordercolourlist_"+e][l]})}return a.reverse(),a}function getLimit(e,t,s,a){var i,l=0;return i="x"==t?e.map(function(e){return e.x}):e.map(function(e){return e.y}),l="max"==s?Math.max.apply(Math,i):Math.min.apply(Math,i),"max"==s&&0==l&&!1==a&&(l=1),l}function getAverage(e){for(var t=0,s=0;s<e.length;s++)t+=1*e[s].y;var a=t/e.length;return a}function round(e,t){return+(Math.round(e+"e"+t)+"e-"+t)}function ToggleLines(){var e=interfacelist.split(",");""==ShowLines?(ShowLines="line",SetCookie("ShowLines","line")):(ShowLines="",SetCookie("ShowLines",""));for(var t=0;t<e.length;t++)for(var s,a=0;a<typelist.length;a++)if(s=window["LineChart_"+e[t]+"_"+typelist[a]],"undefined"!=typeof s&&null!==s){var l=6;"Quality"==typelist[a]&&(l=9);for(var r=0;r<l;r++)s.options.annotation.annotations[r].type=ShowLines;s.update()}}function ToggleFill(){var e=interfacelist.split(",");"origin"==ShowFill?(ShowFill="false",SetCookie("ShowFill","false")):(ShowFill="origin",SetCookie("ShowFill","origin"));for(var t=0;t<e.length;t++)for(var s,a=0;a<typelist.length;a++)(s=window["LineChart_"+e[t]+"_"+typelist[a]],"undefined"!=typeof s&&null!==s)&&(s.data.datasets[0].fill=ShowFill,s.data.datasets[1].fill=ShowFill,"Quality"==typelist[a]&&(s.data.datasets[2].fill=ShowFill),s.update())}function RedrawAllCharts(){for(var e=interfacelist.split(","),t=0;t<chartlist.length;t++)for(var s=0;s<e.length;s++)$j("#"+e[s]+"_Period_Combined").val(GetCookie(e[s]+"_Period_Combined","number")),$j("#"+e[s]+"_Period_Quality").val(GetCookie(e[s]+"_Period_Quality","number")),$j("#"+e[s]+"_Scale_Combined").val(GetCookie(e[s]+"_Scale_Combined","number")),$j("#"+e[s]+"_Scale_Quality").val(GetCookie(e[s]+"_Scale_Quality","number")),d3.csv("/ext/spdmerlin/csv/Combined"+chartlist[t]+"_"+e[s]+".htm").then(SetGlobalDataset.bind(null,chartlist[t]+"_"+e[s]+"_Combined")),d3.csv("/ext/spdmerlin/csv/Quality"+chartlist[t]+"_"+e[s]+".htm").then(SetGlobalDataset.bind(null,chartlist[t]+"_"+e[s]+"_Quality"))}function SetGlobalDataset(e,t){if(window[e]=t,currentNoCharts++,currentNoCharts==maxNoCharts)for(var s=interfacelist.split(","),a=0;a<s.length;a++)Draw_Chart(s[a],"Combined"),Draw_Chart(s[a],"Quality")}function getTimeFormat(e,t){var s;return"axis"==t?0==e?s={millisecond:"HH:mm:ss.SSS",second:"HH:mm:ss",minute:"HH:mm",hour:"HH:mm"}:1==e&&(s={millisecond:"h:mm:ss.SSS A",second:"h:mm:ss A",minute:"h:mm A",hour:"h A"}):"tooltip"==t&&(0==e?s="YYYY-MM-DD HH:mm:ss":1==e&&(s="YYYY-MM-DD h:mm:ss A")),s}function GetCookie(e,t){var a;if(null!=(a=cookie.get("spd_"+e)))return cookie.get("spd_"+e);return"string"==t?"":"number"==t?0:void 0}function SetCookie(e,t){cookie.set("spd_"+e,t,3650)}$j.fn.serializeObject=function(){var e=custom_settings,t=this.serializeArray();$j.each(t,function(){void 0!==e[this.name]&&-1!=this.name.indexOf("spdmerlin")&&-1==this.name.indexOf("version")&&-1==this.name.indexOf("spdmerlin_iface_enabled")&&-1==this.name.indexOf("spdmerlin_usepreferred")&&-1==this.name.indexOf("schdays")?(!e[this.name].push&&(e[this.name]=[e[this.name]]),e[this.name].push(this.value||"")):-1!=this.name.indexOf("spdmerlin")&&-1==this.name.indexOf("version")&&-1==this.name.indexOf("spdmerlin_iface_enabled")&&-1==this.name.indexOf("spdmerlin_usepreferred")&&-1==this.name.indexOf("schdays")&&(e[this.name]=this.value||"")});var s=[];$j.each($j("input[name='spdmerlin_schdays']:checked"),function(){s.push($j(this).val())});var a=s.join(",");"Mon,Tues,Wed,Thurs,Fri,Sat,Sun"==a&&(a="*"),e.spdmerlin_schdays=a,$j.each($j("input[name^='spdmerlin_usepreferred']"),function(){e[this.id]=this.checked.toString()});var i=[];$j.each($j("input[name='spdmerlin_iface_enabled']:checked"),function(){i.push(this.value)});var l=i.join(",");return e.spdmerlin_ifaces_enabled=l,e};function SetCurrentPage(){document.form.next_page.value=window.location.pathname.substring(1),document.form.current_page.value=window.location.pathname.substring(1)}function initial(){SetCurrentPage(),LoadCustomSettings(),show_menu(),$j("#Time_Format").val(GetCookie("Time_Format","number")),ScriptUpdateLayout(),get_statstitle_file(),get_interfaces_file()}function ScriptUpdateLayout(){var e=GetVersionNumber("local"),t=GetVersionNumber("server");$j("#spdmerlin_version_local").text(e),e!=t&&"N/A"!=t&&($j("#spdmerlin_version_server").text("Updated version available: "+t),showhide("btnChkUpdate",!1),showhide("spdmerlin_version_server",!0),showhide("btnDoUpdate",!0))}function reload(){location.reload(!0)}function getYAxisMax(e){if(-1!=e.indexOf("Quality"))return 100}function getChartPeriod(e){var t="daily";return 0==e?t="daily":1==e?t="weekly":2==e&&(t="monthly"),t}function getChartScale(e){var t="";return 0==e?t="linear":1==e&&(t="logarithmic"),t}function ResetZoom(){for(var e=interfacelist.split(","),t=0;t<e.length;t++)for(var s,a=0;a<typelist.length;a++)(s=window["LineChart_"+e[t]+"_"+typelist[a]],"undefined"!=typeof s&&null!==s)&&s.resetZoom()}function ToggleDragZoom(e){var t=!0,s=!1,a="";-1==e.value.indexOf("On")?(t=!0,s=!1,DragZoom=!0,ChartPan=!1,a="Drag Zoom On"):(t=!1,s=!0,DragZoom=!1,ChartPan=!0,a="Drag Zoom Off");for(var l=interfacelist.split(","),r=0;r<l.length;r++){for(var n,d=0;d<typelist.length;d++)(n=window["LineChart_"+l[r]+"_"+typelist[d]],"undefined"!=typeof n&&null!==n)&&(n.options.plugins.zoom.zoom.drag=t,n.options.plugins.zoom.pan.enabled=s,n.update());e.value=a}}function ExportCSV(){return location.href="/ext/spdmerlin/csv/spdmerlindata.zip",0}function update_status(){$j.ajax({url:"/ext/spdmerlin/detect_update.js",dataType:"script",timeout:3e3,error:function(){setTimeout(update_status,1e3)},success:function(){"InProgress"==updatestatus?setTimeout(update_status,1e3):(document.getElementById("imgChkUpdate").style.display="none",showhide("spdmerlin_version_server",!0),"None"==updatestatus?($j("#spdmerlin_version_server").text("No update available"),showhide("btnChkUpdate",!0),showhide("btnDoUpdate",!1)):($j("#spdmerlin_version_server").text("Updated version available: "+updatestatus),showhide("btnChkUpdate",!1),showhide("btnDoUpdate",!0)))}})}function CheckUpdate(){showhide("btnChkUpdate",!1),document.formScriptActions.action_script.value="start_spdmerlincheckupdate",document.formScriptActions.submit(),document.getElementById("imgChkUpdate").style.display="",setTimeout(update_status,2e3)}function DoUpdate(){document.form.action_script.value="start_spdmerlindoupdate",document.form.action_wait.value=10,showLoading(),document.form.submit()}function getAllIndexes(e,t){for(var s=[],a=0;a<e.length;a++)e[a].id==t&&s.push(a);return s}function get_spdtestservers_file(e){$j.ajax({url:"/ext/spdmerlin/spdmerlin_serverlist_"+e.toUpperCase()+".htm?cachebuster="+new Date().getTime(),dataType:"text",timeout:2e3,error:function(){setTimeout(get_spdtestservers_file,1e3,e)},success:function(t){var s=[];$j.each(t.split("\n").filter(Boolean),function(e,t){var a={};a.id=t.split("|")[0],a.name=t.split("|")[1],s.push(a)}),$j("#spdmerlin_preferredserver_"+e).prop("disabled",!1),$j("#spdmerlin_preferredserver_"+e).removeClass("disabled");let a=$j("#spdmerlin_preferredserver_"+e);a.empty(),$j.each(s,function(e,t){a.append($j("<option></option>").attr("value",t.id+"|"+t.name).text(t.id+"|"+t.name))}),a.prop("selectedIndex",0),$j("#spdmerlin_preferredserver_"+e)[0].style.display="",showhide("imgServerList_"+e,!1)}})}function get_manualspdtestservers_file(){$j.ajax({url:"/ext/spdmerlin/spdmerlin_manual_serverlist.htm?cachebuster="+new Date().getTime(),dataType:"text",timeout:2e3,error:function(){setTimeout(get_manualspdtestservers_file,2e3)},success:function(e){var t=[];if($j.each(e.split("\n").filter(Boolean),function(e,s){var a={};a.id=s.split("|")[0],a.name=s.split("|")[1],t.push(a)}),"All"==document.form.spdtest_enabled.value){for(var s=getAllIndexes(t,"-----"),a=0;a<s.length;a++){let e=$j($j("select[name^=spdtest_serverprefselect]")[a]);e.empty();var l=[];l=0==a?t.slice(0,s[a]):a==s.length-1?t.slice(s[a-1]+1,t.length-1):t.slice(s[a-1]+1,s[a]),$j.each(l,function(t,s){e.append($j("<option></option>").attr("value",s.id+"|"+s.name).text(s.id+"|"+s.name))}),e.prop("selectedIndex",0)}$j.each($j("select[name^=spdtest_serverprefselect]"),function(){this.style.display="inline-block"}),$j.each($j("span[id^=spdtest_serverprefselectspan]"),function(){this.style.display="inline-block"}),showhide("imgManualServerList",!1)}else{let e=$j("select[name=spdtest_serverprefselect]");e.empty(),$j.each(t,function(t,s){e.append($j("<option></option>").attr("value",s.id+"|"+s.name).text(s.id+"|"+s.name))}),e.prop("selectedIndex",0),showhide("spdtest_serverprefselect",!0),showhide("imgManualServerList",!1)}for(var a=0;a<interfacescomplete.length;a++)!1==interfacesdisabled.includes(interfacescomplete[a])&&($j("#spdtest_enabled_"+interfacescomplete[a].toLowerCase()).prop("disabled",!1),$j("#spdtest_enabled_"+interfacescomplete[a].toLowerCase()).removeClass("disabled"));$j.each($j("input[name=spdtest_serverpref]"),function(){$j(this).prop("disabled",!1),$j(this).removeClass("disabled")})}})}function get_spdtestresult_file(){$j.ajax({url:"/ext/spdmerlin/spd-result.htm",dataType:"text",timeout:1e3,error:function(){setTimeout(get_spdtestresult_file,500)},success:function(e){var t=e.trim().split("\n");e=t.join("\n"),$j("#spdtest_output").html(e)}})}function get_spdtest_file(){$j.ajax({url:"/ext/spdmerlin/spd-stats.htm",dataType:"text",timeout:1e3,error:function(){},success:function(e){var t=e.trim().split("\n"),s=t.slice(-1)[0].split("%").filter(Boolean);5<t.length?$j("#spdtest_output").html(t[0]+"\n"+t[1]+"\n"+t[2]+"\n"+t[3]+"\n"+t[4]+"\n"+s[s.length-1]+"%"):$j("#spdtest_output").html("")}})}function update_spdtest(){$j.ajax({url:"/ext/spdmerlin/detect_spdtest.js",dataType:"script",timeout:1e3,error:function(){},success:function(){-1==spdteststatus.indexOf("InProgress")?"Done"==spdteststatus?(get_spdtestresult_file(),document.getElementById("spdtest_text").innerHTML="Refreshing tables and charts...",clearInterval(myinterval),PostSpeedTest()):"LOCKED"==spdteststatus?(showhide("imgSpdTest",!1),document.getElementById("spdtest_text").innerHTML="Scheduled speedtest already running!",showhide("spdtest_text",!0),document.getElementById("spdtest_output").parentElement.parentElement.style.display="none",showhide("btnRunSpeedtest",!0),clearInterval(myinterval)):"NoLicense"==spdteststatus?(showhide("imgSpdTest",!1),document.getElementById("spdtest_text").innerHTML="Please accept Ookla license at command line via spdmerlin",showhide("spdtest_text",!0),document.getElementById("spdtest_output").parentElement.parentElement.style.display="none",showhide("btnRunSpeedtest",!0),clearInterval(myinterval)):"Error"==spdteststatus?(showhide("imgSpdTest",!1),document.getElementById("spdtest_text").innerHTML="Error running speedtest",showhide("spdtest_text",!0),document.getElementById("spdtest_output").parentElement.parentElement.style.display="none",showhide("btnRunSpeedtest",!0),clearInterval(myinterval)):"NoSwap"==spdteststatus&&(showhide("imgSpdTest",!1),document.getElementById("spdtest_text").innerHTML="No Swap file configured/detected",showhide("spdtest_text",!0),document.getElementById("spdtest_output").parentElement.parentElement.style.display="none",showhide("btnRunSpeedtest",!0),clearInterval(myinterval)):-1!=spdteststatus.indexOf("_")&&(showhide("imgSpdTest",!0),showhide("spdtest_text",!0),document.getElementById("spdtest_text").innerHTML="Speedtest in progress for "+spdteststatus.substring(spdteststatus.indexOf("_")+1),document.getElementById("spdtest_output").parentElement.parentElement.style.display="",get_spdtest_file())}})}function PostSpeedTest(){$j("#table_allinterfaces").remove(),$j("#rowautomaticspdtest").remove(),$j("#rowautospdprefserver").remove(),$j("#rowautospdprefserverselect").remove(),$j("#rowmanualspdtest").remove(),currentNoCharts=0,$j("#Time_Format").val(GetCookie("Time_Format","number")),get_statstitle_file(),setTimeout(get_interfaces_file,3e3)}function RunSpeedtest(){showhide("btnRunSpeedtest",!1),$j("#spdtest_output").html("");var e="";"onetime"==document.form.spdtest_serverpref.value&&("All"==document.form.spdtest_enabled.value?($j.each($j("select[name^=spdtest_serverprefselect]"),function(){e+=this.value.substring(0,this.value.indexOf("|"))+"+"}),e=e.slice(0,-1)):e=document.form.spdtest_serverprefselect.value.substring(0,document.form.spdtest_serverprefselect.value.indexOf("|"))),document.formScriptActions.action_script.value="start_spdmerlinspdtest_"+document.form.spdtest_serverpref.value+"_"+document.form.spdtest_enabled.value+"_"+e.replace(/ /g,"%"),document.formScriptActions.submit(),showhide("imgSpdTest",!0),showhide("spdtest_text",!1),setTimeout(StartSpeedTestInterval,1500)}var myinterval;function StartSpeedTestInterval(){myinterval=setInterval("update_spdtest();",500)}function SaveConfig(){if(Validate_All()){$j("[name*=spdmerlin_]").prop("disabled",!1);for(var e=0;e<interfacescomplete.length;e++)$j("#spdmerlin_iface_enabled_"+interfacescomplete[e].toLowerCase()).prop("disabled",!1),$j("#spdmerlin_iface_enabled_"+interfacescomplete[e].toLowerCase()).removeClass("disabled"),$j("#spdmerlin_usepreferred_"+interfacescomplete[e].toLowerCase()).prop("disabled",!1),$j("#spdmerlin_usepreferred_"+interfacescomplete[e].toLowerCase()).removeClass("disabled"),$j("#changepref_"+interfacescomplete[e].toLowerCase()).prop("disabled",!1),$j("#changepref_"+interfacescomplete[e].toLowerCase()).removeClass("disabled");if("EveryX"==document.form.schedulemode.value)if("hours"==document.form.everyxselect.value){var t=1*document.form.everyxvalue.value;document.form.spdmerlin_schmins.value=0,document.form.spdmerlin_schhours.value=24==t?0:"*/"+t}else if("minutes"==document.form.everyxselect.value){document.form.spdmerlin_schhours.value="*";var t=1*document.form.everyxvalue.value;document.form.spdmerlin_schmins.value="*/"+t}document.getElementById("amng_custom").value=JSON.stringify($j("form").serializeObject()),document.form.action_script.value="start_spdmerlinconfig",document.form.action_wait.value=10,showLoading(),document.form.submit()}else return!1}function GetVersionNumber(e){var t;return"local"==e?t=custom_settings.spdmerlin_version_local:"server"==e&&(t=custom_settings.spdmerlin_version_server),"undefined"==typeof t||null==t?"N/A":t}function get_conf_file(){$j.ajax({url:"/ext/spdmerlin/config.htm",dataType:"text",error:function(){setTimeout(get_conf_file,1e3)},success:function(data){var configdata=data.split("\n");configdata=configdata.filter(Boolean);for(var i=0;i<configdata.length;i++){let settingname=configdata[i].split("=")[0].toLowerCase(),settingvalue=configdata[i].split("=")[1].replace(/(\r\n|\n|\r)/gm,"");if(!(-1!=configdata[i].indexOf("SCHDAYS")))-1==configdata[i].indexOf("USEPREFERRED")?-1==configdata[i].indexOf("PREFERREDSERVER")?-1==configdata[i].indexOf("PREFERRED")&&(eval("document.form.spdmerlin_"+settingname).value=settingvalue):$j("#span_spdmerlin_"+settingname).html(configdata[i].split("=")[0].split("_")[1]+" - "+settingvalue):"true"==settingvalue?eval("document.form.spdmerlin_"+settingname).checked=!0:"false"==settingvalue&&(eval("document.form.spdmerlin_"+settingname).checked=!1);else if("*"==settingvalue)for(var i2=0;i2<daysofweek.length;i2++)$j("#spdmerlin_"+daysofweek[i2].toLowerCase()).prop("checked",!0);else for(var schdayarray=settingvalue.split(","),i2=0;i2<schdayarray.length;i2++)$j("#spdmerlin_"+schdayarray[i2].toLowerCase()).prop("checked",!0);-1!=configdata[i].indexOf("AUTOMATED")&&AutomaticInterfaceEnableDisable($j("#spdmerlin_auto_"+document.form.spdmerlin_automated.value)[0]),-1!=configdata[i].indexOf("AUTOBW")&&AutoBWEnableDisable($j("#spdmerlin_autobw_"+document.form.spdmerlin_autobw_enabled.value)[0])}-1!=$j("[name=spdmerlin_schhours]").val().indexOf("/")&&0==$j("[name=spdmerlin_schmins]").val()?(document.form.schedulemode.value="EveryX",document.form.everyxselect.value="hours",document.form.everyxvalue.value=$j("[name=spdmerlin_schhours]").val().split("/")[1]):-1!=$j("[name=spdmerlin_schmins]").val().indexOf("/")&&"*"==$j("[name=spdmerlin_schhours]").val()?(document.form.schedulemode.value="EveryX",document.form.everyxselect.value="minutes",document.form.everyxvalue.value=$j("[name=spdmerlin_schmins]").val().split("/")[1]):document.form.schedulemode.value="Custom",ScheduleModeToggle($j("#schmode_"+$j("[name=schedulemode]:checked").val().toLowerCase())[0])}})}function get_interfaces_file(){$j.ajax({url:"/ext/spdmerlin/interfaces_user.htm",dataType:"text",error:function(){setTimeout(get_interfaces_file,1e3)},success:function(e){showhide("spdtest_text",!1),showhide("imgSpdTest",!1),showhide("btnRunSpeedtest",!0);var t=e.split("\n");t=t.filter(Boolean),interfacelist="",interfacescomplete=[],interfacesdisabled=[];var s="<div style=\"line-height:10px;\">&nbsp;</div>";s+="<table width=\"100%\" border=\"1\" align=\"center\" cellpadding=\"4\" cellspacing=\"0\" bordercolor=\"#6b8fa3\" class=\"FormTable\" id=\"table_allinterfaces\">",s+="<thead class=\"collapsible-jquery\" id=\"thead_allinterfaces\">",s+="<tr><td>Interfaces (click to expand/collapse)</td></tr>",s+="</thead>",s+="<tr><td align=\"center\" style=\"padding: 0px;\">";var a="<tr id=\"rowautomaticspdtest\"><td class=\"settingname\">Interfaces to use for automatic speedtests</th><td class=\"settingvalue\">",l="<tr id=\"rowautospdprefserver\"><td class=\"settingname\">Interfaces that use a preferred server</th><td class=\"settingvalue\">",r="<tr id=\"rowautospdprefserverselect\"><td class=\"settingname\">Preferred servers for interfaces</th><td class=\"settingvalue\">",n="<tr id=\"rowmanualspdtest\"><td class=\"settingname\">Interfaces to use for manual speedtest</th><td class=\"settingvalue\">";n+="<input type=\"radio\" name=\"spdtest_enabled\" id=\"spdtest_enabled_all\" onchange=\"Change_SpdTestInterface(this)\" class=\"input\" settingvalueradio\" value=\"All\" checked>",n+="<label for=\"spdtest_enabled_all\">All</label>";for(var d,o=t.length,p=0;p<o;p++){if(d="",-1!=t[p].indexOf("#")){d=t[p].substring(0,t[p].indexOf("#")).trim(),interfacescomplete.push(d);var m="",c=d.toUpperCase(),u="Change?";-1!=t[p].indexOf("interface not up")&&(interfacesdisabled.push(d),m="disabled",c="<a class=\"hintstyle\" href=\"javascript:void(0);\" onclick=\"SettingHint(1);\">"+d.toUpperCase()+"</a>",u="<a class=\"hintstyle\" href=\"javascript:void(0);\" onclick=\"SettingHint(1);\">Change?</a>"),a+="<input type=\"checkbox\" name=\"spdmerlin_iface_enabled\" id=\"spdmerlin_iface_enabled_"+d.toLowerCase()+"\" class=\"input "+m+" settingvalue\" value=\""+d.toUpperCase()+"\" "+m+">",a+="<label for=\"spdmerlin_iface_enabled_"+d.toLowerCase()+"\">"+c+"</label>",l+="<input type=\"checkbox\" name=\"spdmerlin_usepreferred_"+d.toLowerCase()+"\" id=\"spdmerlin_usepreferred_"+d.toLowerCase()+"\" class=\"input "+m+" settingvalue\" value=\""+d.toUpperCase()+"\" "+m+">",l+="<label for=\"spdmerlin_usepreferred_"+d.toLowerCase()+"\">"+c+"</label>",r+="<span style=\"margin-left:4px;vertical-align:top;max-width:465px;display:inline-block;\" id=\"span_spdmerlin_preferredserver_"+d.toLowerCase()+"\">"+d.toUpperCase()+":</span><br />",r+="<input type=\"checkbox\" name=\"changepref_"+d.toLowerCase()+"\" id=\"changepref_"+d.toLowerCase()+"\" class=\"input settingvalue "+m+"\" "+m+" onchange=\"Toggle_ChangePrefServer(this)\">",r+="<label for=\"changepref_"+d.toLowerCase()+"\">"+u+"</label>",r+="<img id=\"imgServerList_"+d.toLowerCase()+"\" style=\"display:none;vertical-align:middle;\" src=\"images/InternetScan.gif\"/>",r+="<select class=\"disabled\" name=\"spdmerlin_preferredserver_"+d.toLowerCase()+"\" id=\"spdmerlin_preferredserver_"+d.toLowerCase()+"\" style=\"min-width:100px;max-width:400px;display:none;vertical-align:top;\" disabled></select><br />",n+="<input autocomplete=\"off\" autocapitalize=\"off\" type=\"radio\" name=\"spdtest_enabled\" id=\"spdtest_enabled_"+d.toLowerCase()+"\" onchange=\"Change_SpdTestInterface(this)\" class=\"input "+m+" settingvalueradio\" value=\""+d.toUpperCase()+"\" "+m+">",n+="<label for=\"spdtest_enabled_"+d.toLowerCase()+"\">"+c+"</label>"}else d=t[p].trim(),interfacescomplete.push(d),a+="<input type=\"checkbox\" name=\"spdmerlin_iface_enabled\" id=\"spdmerlin_iface_enabled_"+d.toLowerCase()+"\" class=\"input settingvalue\" value=\""+d.toUpperCase()+"\" checked>",a+="<label for=\"spdmerlin_iface_enabled_"+d.toLowerCase()+"\">"+d.toUpperCase()+"</label>",l+="<input type=\"checkbox\" name=\"spdmerlin_usepreferred_"+d.toLowerCase()+"\" id=\"spdmerlin_usepreferred_"+d.toLowerCase()+"\" class=\"input settingvalue\" value=\""+d.toUpperCase()+"\" checked>",l+="<label for=\"spdmerlin_usepreferred_"+d.toLowerCase()+"\">"+d.toUpperCase()+"</label>",r+="<span style=\"margin-left:4px;vertical-align:top;max-width:465px;display:inline-block;\" id=\"span_spdmerlin_preferredserver_"+d.toLowerCase()+"\">"+d.toUpperCase()+":</span><br />",r+="<input type=\"checkbox\" name=\"changepref_"+d.toLowerCase()+"\" id=\"changepref_"+d.toLowerCase()+"\" class=\"input settingvalue\" onchange=\"Toggle_ChangePrefServer(this)\">",r+="<label for=\"changepref_"+d.toLowerCase()+"\">Change?</label>",r+="<img id=\"imgServerList_"+d.toLowerCase()+"\" style=\"display:none;vertical-align:middle;\" src=\"images/InternetScan.gif\"/>",r+="<select class=\"disabled\" name=\"spdmerlin_preferredserver_"+d.toLowerCase()+"\" id=\"spdmerlin_preferredserver_"+d.toLowerCase()+"\" style=\"min-width:100px;max-width:400px;display:none;vertical-align:top;\" disabled></select><br />",n+="<input type=\"radio\" name=\"spdtest_enabled\" id=\"spdtest_enabled_"+d.toLowerCase()+"\" onchange=\"Change_SpdTestInterface(this)\" class=\"input settingvalueradio\" value=\""+d.toUpperCase()+"\">",n+="<label for=\"spdtest_enabled_"+d.toLowerCase()+"\">"+d.toUpperCase()+"</label>";s+=BuildInterfaceTable(d),interfacelist+=d+","}s+="</td></tr></table>",a+="</td></tr>",l+="</td></tr>",r+="</td></tr>",n+="</td></tr>",$j("#rowautomatedtests").after(r),$j("#rowautomatedtests").after(l),$j("#rowautomatedtests").after(a),$j("#thead_manualspeedtests").after(n),GenerateManualSpdTestServerPrefSelect(),document.form.spdtest_serverpref.value="auto",","==interfacelist.charAt(interfacelist.length-1)&&(interfacelist=interfacelist.slice(0,-1)),$j("#table_buttons2").after(s),maxNoCharts=2*(3*interfacelist.split(",").length),RedrawAllCharts(),AddEventHandlers(),get_lastx_file(),get_conf_file()}})}function get_statstitle_file(){$j.ajax({url:"/ext/spdmerlin/spdtitletext.js",dataType:"script",timeout:3e3,error:function(){setTimeout(get_statstitle_file,1e3)},success:function(){SetSPDStatsTitle()}})}function get_lastx_file(){$j.ajax({url:"/ext/spdmerlin/spdjs.js",dataType:"script",timeout:3e3,error:function(){setTimeout(get_lastx_file,1e3)},success:function(){for(var e=0;e<interfacescomplete.length;e++){var t=interfacescomplete[e],s="",a=window["DataTimestamp_"+t];"undefined"==typeof a||null===a?s="true":0==a.length?s="true":1==a.length&&""==a[0]&&(s="true");var l="<table width=\"100%\" border=\"1\" align=\"center\" cellpadding=\"4\" cellspacing=\"0\" bordercolor=\"#6b8fa3\" class=\"FormTable StatsTable\">";if("true"==s)l+="<tr>",l+="<td colspan=\"6\" class=\"nodata\">",l+="No data to display",l+="</td>",l+="</tr>";else{l+="<col style=\"width:120px;\">",l+="<col style=\"width:75px;\">",l+="<col style=\"width:65px;\">",l+="<col style=\"width:65px;\">",l+="<col style=\"width:65px;\">",l+="<col style=\"width:65px;\">",l+="<col style=\"width:80px;\">",l+="<col style=\"width:80px;\">",l+="<col style=\"width:135px;\">",l+="<thead>",l+="<tr>",l+="<th class=\"keystatsnumber\">Time</th>",l+="<th class=\"keystatsnumber\">Download<br />(Mbps)</th>",l+="<th class=\"keystatsnumber\">Upload<br />(Mbps)</th>",l+="<th class=\"keystatsnumber\">Latency<br />(ms)</th>",l+="<th class=\"keystatsnumber\">Jitter<br />(ms)</th>",l+="<th class=\"keystatsnumber\">Packet<br />Loss (%)</th>",l+="<th class=\"keystatsnumber\">Download<br />Data (MB)</th>",l+="<th class=\"keystatsnumber\">Upload<br />Data (MB)</th>",l+="<th class=\"keystatsnumber\">Result URL</th>",l+="</tr>",l+="</thead>";for(var r=0;r<a.length;r++)l+="<tr class=\"statsRow\">",l+="<td>"+moment.unix(window["DataTimestamp_"+t][r]).format("YYYY-MM-DD HH:mm:ss")+"</td>",l+="<td>"+window["DataDownload_"+t][r]+"</td>",l+="<td>"+window["DataUpload_"+t][r]+"</td>",l+="<td>"+window["DataLatency_"+t][r]+"</td>",l+="<td>"+window["DataJitter_"+t][r]+"</td>",l+="<td>"+window["DataPktLoss_"+t][r].replace("null","N/A")+"</td>",l+="<td>"+window["DataDataDownload_"+t][r]+"</td>",l+="<td>"+window["DataDataUpload_"+t][r]+"</td>",l+=""==window["DataResultURL_"+t][r]?"<td>No result URL</td>":"<td><a href=\""+window["DataResultURL_"+t][r]+"\" target=\"_blank\">Speedtest result URL</a></td>",l+="</tr>"}l+="</table>",$j("#"+t+"_tablelastxresults").empty(),$j("#"+t+"_tablelastxresults").append(l)}}})}function changeAllCharts(t){value=1*t.value,name=t.id.substring(0,t.id.indexOf("_")),SetCookie(t.id,value);for(var e=interfacelist.split(","),s=0;s<e.length;s++)Draw_Chart(e[s],"Combined"),Draw_Chart(e[s],"Quality")}function changeChart(t){value=1*t.value,name=t.id.substring(0,t.id.indexOf("_")),SetCookie(t.id,value),-1==t.id.indexOf("Combined")?-1!=t.id.indexOf("Quality")&&Draw_Chart(name,"Quality"):Draw_Chart(name,"Combined")}function SettingHint(e){for(var t=document.getElementsByTagName("a"),s=0;s<t.length;s++)t[s].onmouseout=nd;return hinttext="My text goes here",1==e&&(hinttext="Interface not enabled"),2==e&&(hinttext="Hour(s) of day to run speedtest<br />* for all<br />Valid numbers between 0 and 23<br />comma (,) separate for multiple<br />dash (-) separate for a range"),3==e&&(hinttext="Minute(s) of day to run speedtest<br />(* for all<br />Valid numbers between 0 and 59<br />comma (,) separate for multiple<br />dash (-) separate for a range"),overlib(hinttext,0,0)}function BuildInterfaceTable(e){var t="<div style=\"line-height:10px;\">&nbsp;</div>";return t+="<table width=\"100%\" border=\"1\" align=\"center\" cellpadding=\"4\" cellspacing=\"0\" bordercolor=\"#6b8fa3\" class=\"FormTable\" id=\"table_interfaces_"+e+"\">",t+="<thead class=\"collapsible-jquery\" id=\""+e+"\">",t+="<tr>",t+="<td colspan=\"2\">"+e+" (click to expand/collapse)</td>",t+="</tr>",t+="</thead>",t+="<tr>",t+="<td colspan=\"2\" align=\"center\" style=\"padding: 0px;\">",t+="<table width=\"100%\" border=\"1\" align=\"center\" cellpadding=\"4\" cellspacing=\"0\" bordercolor=\"#6b8fa3\" class=\"FormTable\">",t+="<thead class=\"collapsible-jquery\" id=\"resulttable_"+e+"\">",t+="<tr><td colspan=\"2\">Last 10 speedtest results (click to expand/collapse)</td></tr>",t+="</thead>",t+="<tr>",t+="<td colspan=\"2\" align=\"center\" style=\"padding: 0px;\" id=\""+e+"_tablelastxresults\">",t+="</td>",t+="</tr>",t+="</table>",t+="<div style=\"line-height:10px;\">&nbsp;</div>",t+="<table width=\"100%\" border=\"1\" align=\"center\" cellpadding=\"4\" cellspacing=\"0\" bordercolor=\"#6b8fa3\" class=\"FormTable\">",t+="<thead class=\"collapsible-jquery\" id=\"table_charts\">",t+="<tr>",t+="<td>Tables and Charts (click to expand/collapse)</td>",t+="</tr>",t+="</thead>",t+="<tr><td align=\"center\" style=\"padding: 0px;\">",t+="<table width=\"100%\" border=\"1\" align=\"center\" cellpadding=\"4\" cellspacing=\"0\" bordercolor=\"#6b8fa3\" class=\"FormTable\">",t+="<thead class=\"collapsible-jquery\" id=\""+e+"_ChartCombined\">",t+="<tr>",t+="<td colspan=\"2\">Bandwidth (click to expand/collapse)</td>",t+="</tr>",t+="</thead>",t+="<tr class=\"even\">",t+="<th width=\"40%\">Period to display</th>",t+="<td>",t+="<select style=\"width:150px\" class=\"input_option\" onchange=\"changeChart(this)\" id=\""+e+"_Period_Combined\">",t+="<option value=0>Last 24 hours</option>",t+="<option value=1>Last 7 days</option>",t+="<option value=2>Last 30 days</option>",t+="</select>",t+="</td>",t+="</tr>",t+="<tr class=\"even\">",t+="<th width=\"40%\">Scale type</th>",t+="<td>",t+="<select style=\"width:150px\" class=\"input_option\" onchange=\"changeChart(this)\" id=\""+e+"_Scale_Combined\">",t+="<option value=\"0\">Linear</option>",t+="<option value=\"1\">Logarithmic</option>",t+="</select>",t+="</td>",t+="</tr>",t+="<tr>",t+="<td colspan=\"2\" align=\"center\" style=\"padding: 0px;\">",t+="<div style=\"background-color:#2f3e44;border-radius:10px;width:730px;height:500px;padding-left:5px;\"><canvas id=\"divLineChart_"+e+"_Combined\" height=\"500\" /></div>",t+="</td>",t+="</tr>",t+="</table>",t+="<div style=\"line-height:10px;\">&nbsp;</div>",t+="<table width=\"100%\" border=\"1\" align=\"center\" cellpadding=\"4\" cellspacing=\"0\" bordercolor=\"#6b8fa3\" class=\"FormTable\">",t+="<thead class=\"collapsible-jquery\" id=\""+e+"_ChartQuality\">",t+="<tr>",t+="<td colspan=\"2\">Quality (click to expand/collapse)</td>",t+="</tr>",t+="</thead>",t+="<tr class=\"even\">",t+="<th width=\"40%\">Period to display</th>",t+="<td>",t+="<select style=\"width:150px\" class=\"input_option\" onchange=\"changeChart(this)\" id=\""+e+"_Period_Quality\">",t+="<option value=0>Last 24 hours</option>",t+="<option value=1>Last 7 days</option>",t+="<option value=2>Last 30 days</option>",t+="</select>",t+="</td>",t+="</tr>",t+="<tr class=\"even\">",t+="<th width=\"40%\">Scale type</th>",t+="<td>",t+="<select style=\"width:150px\" class=\"input_option\" onchange=\"changeChart(this)\" id=\""+e+"_Scale_Quality\">",t+="<option value=\"0\">Linear</option>",t+="<option value=\"1\">Logarithmic</option>",t+="</select>",t+="</td>",t+="</tr>",t+="<tr>",t+="<td colspan=\"2\" align=\"center\" style=\"padding: 0px;\">",t+="<div style=\"background-color:#2f3e44;border-radius:10px;width:730px;height:500px;padding-left:5px;\"><canvas id=\"divLineChart_"+e+"_Quality\" height=\"500\" /></div>",t+="</td>",t+="</tr>",t+="</table>",t+="</td>",t+="</tr>",t+="</table>",t+="</td>",t+="</tr>",t+="</table>",t}function AutomaticInterfaceEnableDisable(e){var t=e.name,s=e.value,a=t.substring(0,t.lastIndexOf("_")),l=["schhours","schmins"],r=["schedulemode","everyxselect","everyxvalue"];if("false"==s){for(var n=0;n<interfacescomplete.length;n++)$j("#"+a+"_iface_enabled_"+interfacescomplete[n].toLowerCase()).prop("disabled",!0),$j("#"+a+"_iface_enabled_"+interfacescomplete[n].toLowerCase()).addClass("disabled"),$j("#"+a+"_usepreferred_"+interfacescomplete[n].toLowerCase()).prop("disabled",!0),$j("#"+a+"_usepreferred_"+interfacescomplete[n].toLowerCase()).addClass("disabled"),$j("#changepref_"+interfacescomplete[n].toLowerCase()).prop("disabled",!0),$j("#changepref_"+interfacescomplete[n].toLowerCase()).addClass("disabled");for(var n=0;n<l.length;n++)$j("input[name="+a+"_"+l[n]+"]").addClass("disabled"),$j("input[name="+a+"_"+l[n]+"]").prop("disabled",!0);for(var n=0;n<daysofweek.length;n++)$j("#"+a+"_"+daysofweek[n].toLowerCase()).prop("disabled",!0);for(var n=0;n<r.length;n++)$j("[name="+r[n]+"]").addClass("disabled"),$j("[name="+r[n]+"]").prop("disabled",!0)}else if("true"==s){for(var n=0;n<interfacescomplete.length;n++)!1==interfacesdisabled.includes(interfacescomplete[n])&&($j("#"+a+"_iface_enabled_"+interfacescomplete[n].toLowerCase()).prop("disabled",!1),$j("#"+a+"_iface_enabled_"+interfacescomplete[n].toLowerCase()).removeClass("disabled"),$j("#"+a+"_usepreferred_"+interfacescomplete[n].toLowerCase()).prop("disabled",!1),$j("#"+a+"_usepreferred_"+interfacescomplete[n].toLowerCase()).removeClass("disabled"),$j("#changepref_"+interfacescomplete[n].toLowerCase()).prop("disabled",!1),$j("#changepref_"+interfacescomplete[n].toLowerCase()).removeClass("disabled"));for(var n=0;n<l.length;n++)$j("input[name="+a+"_"+l[n]+"]").removeClass("disabled"),$j("input[name="+a+"_"+l[n]+"]").prop("disabled",!1);for(var n=0;n<daysofweek.length;n++)$j("#"+a+"_"+daysofweek[n].toLowerCase()).prop("disabled",!1);for(var n=0;n<r.length;n++)$j("[name="+r[n]+"]").removeClass("disabled"),$j("[name="+r[n]+"]").prop("disabled",!1)}}function ScheduleModeToggle(e){var t=e.name,s=e.value;"EveryX"==s?(showhide("schfrequency",!0),showhide("schcustom",!1),"hours"==$j("#everyxselect").val()?(showhide("spanxhours",!0),showhide("spanxminutes",!1)):"minutes"==$j("#everyxselect").val()&&(showhide("spanxhours",!1),showhide("spanxminutes",!0))):"Custom"==s&&(showhide("schfrequency",!1),showhide("schcustom",!0))}function EveryXToggle(e){var t=e.name,s=e.value;"hours"==s?(showhide("spanxhours",!0),showhide("spanxminutes",!1)):"minutes"==s&&(showhide("spanxhours",!1),showhide("spanxminutes",!0)),Validate_ScheduleValue($j("[name=everyxvalue]")[0])}function AutoBWEnableDisable(e){var t=e.name,s=e.value,a=t.substring(0,t.indexOf("_")),l=["autobw_ulimit","autobw_llimit","autobw_sf","autobw_threshold","autobw_average"];if("false"==s){for(var r=0;r<l.length;r++)$j("input[name^="+a+"_"+l[r]+"]").addClass("disabled"),$j("input[name^="+a+"_"+l[r]+"]").prop("disabled",!0);$j("input[name^="+a+"_excludefromqos]").removeClass("disabled"),$j("input[name^="+a+"_excludefromqos]").prop("disabled",!1)}else if("true"==s){for(var r=0;r<l.length;r++)$j("input[name^="+a+"_"+l[r]+"]").removeClass("disabled"),$j("input[name^="+a+"_"+l[r]+"]").prop("disabled",!1);document.form.spdmerlin_excludefromqos.value=!0,$j("input[name^="+a+"_excludefromqos]").addClass("disabled"),$j("input[name^="+a+"_excludefromqos]").prop("disabled",!0)}}function Toggle_ChangePrefServer(e){var t=e.name,s=e.checked,a=t.split("_")[1];!0==s?(document.formScriptActions.action_script.value="start_spdmerlinserverlist_"+a,document.formScriptActions.submit(),showhide("imgServerList_"+a,!0),setTimeout(get_spdtestservers_file,2e3,a)):($j("#spdmerlin_preferredserver_"+a)[0].style.display="none",$j("#spdmerlin_preferredserver_"+a).prop("disabled",!0),$j("#spdmerlin_preferredserver_"+a).addClass("disabled"))}function Change_SpdTestInterface(e){var t=e.name,s=e.value;GenerateManualSpdTestServerPrefSelect(),Toggle_SpdTestServerPref(document.form.spdtest_serverpref)}function Toggle_SpdTestServerPref(e){var t=e.name,s=e.value;if("onetime"==s){document.formScriptActions.action_script.value="start_spdmerlinserverlistmanual_"+document.form.spdtest_enabled.value,document.formScriptActions.submit();for(var a=0;a<interfacescomplete.length;a++)$j("#spdtest_enabled_"+interfacescomplete[a].toLowerCase()).prop("disabled",!0),$j("#spdtest_enabled_"+interfacescomplete[a].toLowerCase()).addClass("disabled");$j.each($j("input[name=spdtest_serverpref]"),function(){$j(this).prop("disabled",!0),$j(this).addClass("disabled")}),showhide("rowmanualserverprefselect",!0),showhide("imgManualServerList",!0),"All"==document.form.spdtest_enabled.value?$j.each($j("select[name^=spdtest_serverprefselect]"),function(){$j(this).empty()}):$j("select[name=spdtest_serverprefselect]").empty(),setTimeout(get_manualspdtestservers_file,2e3)}else showhide("rowmanualserverprefselect",!1),"All"==document.form.spdtest_enabled.value?($j.each($j("select[name^=spdtest_serverprefselect]"),function(){showhide(this.id,!1)}),$j.each($j("span[id^=spdtest_serverprefselectspan]"),function(){showhide(this.id,!1)})):showhide("spdtest_serverprefselect",!1),showhide("imgManualServerList",!1)}function GenerateManualSpdTestServerPrefSelect(){$j("#rowmanualserverprefselect").remove();var e="<tr class=\"even\" id=\"rowmanualserverprefselect\" style=\"display:none;\">";if(e+="<td class=\"settingname\">Choose a server</th><td class=\"settingvalue\"><img id=\"imgManualServerList\" style=\"display:none;vertical-align:middle;\" src=\"images/InternetScan.gif\"/>","All"==document.form.spdtest_enabled.value){for(var t=0;t<interfacescomplete.length;t++)if(!1==interfacesdisabled.includes(interfacescomplete[t])){var s=interfacescomplete[t].toLowerCase();e+="<span style=\"width:50px;display:none;\" id=\"spdtest_serverprefselectspan_"+s+"\">"+interfacescomplete[t]+":</span><select name=\"spdtest_serverprefselect_"+s+"\" id=\"spdtest_serverprefselect_"+s+"\" style=\"display:none;max-width:415px;\"></select><br />"}}else e+="<select name=\"spdtest_serverprefselect\" id=\"spdtest_serverprefselect\" style=\"display:none;\"></select>";e+="</td></tr>",$j("#rowmanualserverpref").after(e)}function Validate_All(){var e=!1;return Validate_PercentRange(document.form.spdmerlin_autobw_sf_down)||(e=!0),Validate_PercentRange(document.form.spdmerlin_autobw_sf_up)||(e=!0),Validate_PercentRange(document.form.spdmerlin_autobw_threshold_down)||(e=!0),Validate_PercentRange(document.form.spdmerlin_autobw_threshold_up)||(e=!0),"EveryX"==document.form.schedulemode.value?!Validate_ScheduleValue(document.form.everyxvalue)&&(e=!0):"Custom"==document.form.schedulemode.value&&(!Validate_Schedule(document.form.spdmerlin_schhours,"hours")&&(e=!0),!Validate_Schedule(document.form.spdmerlin_schmins,"mins")&&(e=!0)),!e||(alert("Validation for some fields failed. Please correct invalid values and try again."),!1)}function Validate_Schedule(e,t){var s=e.name,a=e.value.split(","),l=0;"hours"==t?l=23:"mins"==t&&(l=59),showhide("btnfixhours",!1),showhide("btnfixmins",!1);for(var r="false",n=0;n<a.length;n++)if("*"==a[n]&&0==n)r="false";else if("*"==a[n]&&0!=n)r="true";else if("*"==a[0]&&0<n)r="true";else if(""==a[n])r="true";else if(a[n].startsWith("*/"))isNaN(1*a[n].replace("*/",""))?r="true":(1*a[n].replace("*/","")>l||0>1*a[n].replace("*/",""))&&(r="true");else if(!(-1!=a[n].indexOf("-")))isNaN(1*a[n])?r="true":(1*a[n]>l||0>1*a[n])&&(r="true");else if(a[n].startsWith("-"))r="true";else for(var d=a[n].split("-"),o=0;o<d.length;o++)""==d[o]?r="true":isNaN(1*d[o])?r="true":1*d[o]>l||0>1*d[o]?r="true":1*d[o+1]<1*d[o]&&(r="true","hours"==t?showhide("btnfixhours",!0):"mins"==t&&showhide("btnfixmins",!0));return"true"==r?($j(e).addClass("invalid"),!1):($j(e).removeClass("invalid"),!0)}function Validate_ScheduleValue(e){var t=e.name,s=1*e.value,a=0,i=$j("#everyxselect").val();return"hours"==i?a=24:"minutes"==i&&(a=30),s>a||s<1||1>e.value.length?($j(e).addClass("invalid"),!1):($j(e).removeClass("invalid"),!0)}function Validate_PercentRange(e){var t=e.name,s=1*e.value;return 100<s||0>s||1>e.value.length?($j(e).addClass("invalid"),!1):($j(e).removeClass("invalid"),!0)}function Validate_AverageCalc(e){var t=e.name,s=1*e.value;return 30<s||1>s||1>e.value.length?($j(e).addClass("invalid"),!1):($j(e).removeClass("invalid"),!0)}function FixCron(e){if("hours"==e){var t=document.form.spdmerlin_schhours.value;document.form.spdmerlin_schhours.value=t.split("-")[0]+"-23,0-"+t.split("-")[1],Validate_Schedule(document.form.spdmerlin_schhours,"hours")}else if("mins"==e){var t=document.form.spdmerlin_schmins.value;document.form.spdmerlin_schmins.value=t.split("-")[0]+"-59,0-"+t.split("-")[1],Validate_Schedule(document.form.spdmerlin_schmins,"mins")}}function AddEventHandlers(){$j(".collapsible-jquery").off("click").on("click",function(){$j(this).siblings().toggle("fast",function(){"none"==$j(this).css("display")?SetCookie($j(this).siblings()[0].id,"collapsed"):SetCookie($j(this).siblings()[0].id,"expanded")})}),$j(".collapsible-jquery").each(function(){"collapsed"==GetCookie($j(this)[0].id,"string")?$j(this).siblings().toggle(!1):$j(this).siblings().toggle(!0)})}
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
<th width="20%">Export</th>
<td>
<input type="button" onclick="ExportCSV();" value="Export to CSV" class="button_gen" name="btnExport">
</td>
</tr>
</table>
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable SettingsTable" style="border:0px;" id="table_manualspeedtests">
<thead class="collapsible-jquery" id="thead_manualspeedtests">
<tr><td colspan="2">Manual Speedtest (click to expand/collapse)</td></tr>
</thead>
<tr class="even" id="rowmanualserverpref">
<td class="settingname">Mode for speedtest</td>
<td class="settingvalue">
<input type="radio" name="spdtest_serverpref" id="spdtest_serverpref_auto" class="input" value="auto" onchange="Toggle_SpdTestServerPref(this)" checked>
<label for="spdtest_serverpref_auto">Auto-select server</label>
<input type="radio" name="spdtest_serverpref" id="spdtest_serverpref_user" class="input" value="user" onchange="Toggle_SpdTestServerPref(this)">
<label for="spdtest_serverpref_user">Preferred server</label>
<input type="radio" name="spdtest_serverpref" id="spdtest_serverpref_onetime" class="input" value="onetime" onchange="Toggle_SpdTestServerPref(this)">
<label for="spdtest_serverpref_onetime">Choose a server</label>
</td>
</tr>
<tr class="apply_gen" valign="top" height="35px">
<td colspan="2" class="savebutton">
<input type="button" onclick="RunSpeedtest();" value="Run speedtest" class="button_gen savebutton" name="btnRunSpeedtest" id="btnRunSpeedtest">
<img id="imgSpdTest" style="display:none;vertical-align:middle;" src="images/InternetScan.gif"/>
&nbsp;&nbsp;&nbsp;
<span id="spdtest_text" style="display:none;"></span>
</td>
</tr>
<tr style="display:none;" class="spdtest_output"><td colspan="2" style="padding: 0px;">
<textarea cols="63" rows="8" wrap="off" readonly="readonly" id="spdtest_output" class="textarea_log_table" style="border:0px;font-family:Courier New, Courier, mono; font-size:11px;overflow-y:auto;overflow-x:hidden;">Speedtest output</textarea>
</td></tr>
</table>
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="2" cellspacing="0" bordercolor="#6b8fa3" class="FormTable SettingsTable" style="border:0px;" id="table_config">
<thead class="collapsible-jquery" id="scriptconfig">
<tr><td colspan="2">General Configuration (click to expand/collapse)</td></tr>
</thead>
<tr class="even" valign="middle">
<th colspan="2" class="sectionheader">Automatic speedtest configuration</th>
</tr>
<tr class="even" id="rowautomatedtests">
<td class="settingname">Enable automatic speedtests</td>
<td class="settingvalue">
<input type="radio" name="spdmerlin_automated" id="spdmerlin_auto_true" onchange="AutomaticInterfaceEnableDisable(this)" class="input" value="true" checked>
<label for="spdmerlin_auto_true">Yes</label>
<input type="radio" name="spdmerlin_automated" id="spdmerlin_auto_false" onchange="AutomaticInterfaceEnableDisable(this)" class="input" value="false">
<label for="spdmerlin_auto_false">No</label>
</td>
</tr>
<tr class="even" id="rowschedule">
<td class="settingname">Schedule for automatic speedtests</td>
<td class="settingvalue">
<div class="schedulesettings" id="schdays">
<span class="schedulespan" style="vertical-align:top;">Day(s)</span>
<input type="checkbox" name="spdmerlin_schdays" id="spdmerlin_mon" class="input" value="Mon" style="margin-left:0px;"><label for="spdmerlin_mon">Mon</label>
<input type="checkbox" name="spdmerlin_schdays" id="spdmerlin_tues" class="input" value="Tues"><label for="spdmerlin_tues">Tues</label>
<input type="checkbox" name="spdmerlin_schdays" id="spdmerlin_wed" class="input" value="Wed"><label for="spdmerlin_wed">Wed</label>
<input type="checkbox" name="spdmerlin_schdays" id="spdmerlin_thurs" class="input" value="Thurs"><label for="spdmerlin_thurs">Thurs</label>
<input type="checkbox" name="spdmerlin_schdays" id="spdmerlin_fri" class="input" value="Fri"><label for="spdmerlin_fri">Fri</label>
<input type="checkbox" name="spdmerlin_schdays" id="spdmerlin_sat" class="input" value="Sat"><label for="spdmerlin_sat">Sat</label>
<input type="checkbox" name="spdmerlin_schdays" id="spdmerlin_sun" class="input" value="Sun"><label for="spdmerlin_sun">Sun</label>
</div>
<div class="schedulesettings" id="schmode">
<span class="schedulespan" style="vertical-align:top;">Mode</span>
<input type="radio" onchange="ScheduleModeToggle(this)" name="schedulemode" id="schmode_everyx" class="input" value="EveryX"><label for="schmode_everyx">Every X hours/minutes</label>
<input type="radio" onchange="ScheduleModeToggle(this)" name="schedulemode" id="schmode_custom" class="input" value="Custom" checked><label for="schmode_custom">Custom</label>
</div>
<div style="margin-bottom:0px;" class="schedulesettings" id="schfrequency">
<span class="schedulespan">Frequency</span>
<span style="color:#FFFFFF;margin-left:3px;">Every </span>
<input autocomplete="off" style="text-align:center;padding-left:2px;" type="text" maxlength="2" class="input_3_table removespacing" name="everyxvalue" id="everyxvalue" value="30" onkeypress="return validator.isNumber(this, event)" onkeyup="Validate_ScheduleValue(this)" onblur="Validate_ScheduleValue(this)" />
&nbsp;<select name="everyxselect" id="everyxselect" class="input_option" onchange="EveryXToggle(this)">
<option value="hours">hours</option><option value="minutes" selected>minutes</option></select>
<span id="spanxhours" style="color:#FFCC00;"> (between 1 and 24)</span>
<span id="spanxminutes" style="color:#FFCC00;"> (between 1 and 30, default: 30)</span>
</div>
<div id="schcustom">
<div class="schedulesettings">
<a class="hintstyle" href="javascript:void(0);" onclick="SettingHint(2);">
<span class="schedulespan">Hours</span>
</a>
<input data-lpignore="true" autocomplete="off" autocapitalize="off" type="text" class="input_25_table" name="spdmerlin_schhours" value="*" onkeyup="Validate_Schedule(this,'hours')" onblur="Validate_Schedule(this,'hours')" />
<input id="btnfixhours" type="button" onclick="FixCron('hours');" value="Fix?" class="button_gen cronbutton" name="button" style="display:none;">
</div>
<div class="schedulesettings">
<a class="hintstyle" href="javascript:void(0);" onclick="SettingHint(3);">
<span class="schedulespan">Minutes</span>
</a>
<input data-lpignore="true" autocomplete="off" autocapitalize="off" type="text" class="input_25_table" name="spdmerlin_schmins" value="*" onkeyup="Validate_Schedule(this,'mins')" onblur="Validate_Schedule(this,'mins')" />
<input id="btnfixmins" type="button" onclick="FixCron('mins');" value="Fix?" class="button_gen cronbutton" name="button" style="display:none;">
</div>
</div>
</td>
</tr>
<tr class="even" valign="middle">
<th colspan="2" class="sectionheader">AutoBW configuration</th>
</tr>
<tr class="even" id="rowautobwenabled">
<td class="settingname">Enable AutoBW?<br/><span style="color:#FFCC00;background:#2F3A3E;">Automatically adjust QoS bandwidth limits using automatic speedtest data</span></td>
<td class="settingvalue">
<input type="radio" name="spdmerlin_autobw_enabled" id="spdmerlin_autobw_true" onchange="AutoBWEnableDisable(this)" class="input" value="true">
<label for="spdmerlin_autobw_true">Yes</label>
<input type="radio" name="spdmerlin_autobw_enabled" id="spdmerlin_autobw_false" onchange="AutoBWEnableDisable(this)" class="input" value="false" checked>
<label for="spdmerlin_autobw_false">No</label>
</td>
</tr>
<tr class="even" id="rowautobwavgcalc">
<td class="settingname">Number of speedtests to use to calculate average bandwidth</td>
<td class="settingvalue">
<input autocomplete="off" type="text" maxlength="2" class="input_3_table removespacing" name="spdmerlin_autobw_average_calc" value="10" onkeypress="return validator.isNumber(this, event)" onkeyup="Validate_AverageCalc(this)" onblur="Validate_AverageCalc(this)" /><span style="color:#FFFFFF;">&nbsp;&nbsp;speedtest(s)&nbsp;&nbsp;</span><span style="color:#FFCC00;">(between 1 and 30, default: 10)</span>
</td>
</tr>
<tr class="even" id="rowautobwsf">
<td class="settingname">Scale factor to use for speedtest results</td>
<td class="settingvalue">
<span class="schedulespan">Download</span><input autocomplete="off" type="text" maxlength="3" class="input_6_table removespacing" name="spdmerlin_autobw_sf_down" value="100" onkeypress="return validator.isNumber(this, event)" onkeyup="Validate_PercentRange(this)" onblur="Validate_PercentRange(this)" /><span style="color:#FFFFFF;"> %</span>
&nbsp;&nbsp;&nbsp;&nbsp;
<span class="schedulespan">Upload</span><input autocomplete="off" type="text" maxlength="3" class="input_6_table removespacing" name="spdmerlin_autobw_sf_up" value="100" onkeypress="return validator.isNumber(this, event)" onkeyup="Validate_PercentRange(this)" onblur="Validate_PercentRange(this)" /><span style="color:#FFFFFF;"> %</span>
</td>
</tr>
<tr class="even" id="rowautobwlimits">
<td class="settingname">Bandwidth limits for AutoBW calculations<br/><span style="color:#FFCC00;background:#2F3A3E;">(for Upper Limit 0 = Unlimited)</span></td>
<td class="settingvalue"><span style="font-weight:bolder;color:#FFFFFF;">Upper Limit:&nbsp;&nbsp;&nbsp;&nbsp;</span>
<span class="schedulespan">Download</span><input autocomplete="off" type="text" maxlength="4" class="input_6_table removespacing" name="spdmerlin_autobw_ulimit_down" value="100" onkeypress="return validator.isNumber(this, event)" /><span style="color:#FFFFFF;"> Mbps</span>
&nbsp;&nbsp;&nbsp;&nbsp;
<span class="schedulespan">Upload</span><input autocomplete="off" type="text" maxlength="4" class="input_6_table removespacing" name="spdmerlin_autobw_ulimit_up" value="20" onkeypress="return validator.isNumber(this, event)" /><span style="color:#FFFFFF;"> Mbps</span><br />
<span style="font-weight:bolder;color:#FFFFFF;">Lower Limit:&nbsp;&nbsp;&nbsp;&nbsp;</span>
<span class="schedulespan">Download</span><input autocomplete="off" type="text" maxlength="4" class="input_6_table removespacing" name="spdmerlin_autobw_llimit_down" value="50" onkeypress="return validator.isNumber(this, event)" /><span style="color:#FFFFFF;"> Mbps</span>
&nbsp;&nbsp;&nbsp;&nbsp;
<span class="schedulespan">Upload</span><input autocomplete="off" type="text" maxlength="4" class="input_6_table removespacing" name="spdmerlin_autobw_llimit_up" value="10" onkeypress="return validator.isNumber(this, event)" /><span style="color:#FFFFFF;"> Mbps</span><br />
</td>
</tr>
<tr class="even" id="rowautobwth">
<td class="settingname">Threshold for updating QoS bandwidth values</td>
<td class="settingvalue">
<span class="schedulespan">Download</span><input autocomplete="off" type="text" maxlength="3" class="input_6_table removespacing" name="spdmerlin_autobw_threshold_down" value="10" onkeypress="return validator.isNumber(this, event)" onkeyup="Validate_PercentRange(this)" onblur="Validate_PercentRange(this)" /><span style="color:#FFFFFF;"> %</span>
&nbsp;&nbsp;&nbsp;&nbsp;
<span class="schedulespan">Upload</span><input autocomplete="off" type="text" maxlength="3" class="input_6_table removespacing" name="spdmerlin_autobw_threshold_up" value="10" onkeypress="return validator.isNumber(this, event)" onkeyup="Validate_PercentRange(this)" onblur="Validate_PercentRange(this)" /><span style="color:#FFFFFF;"> %</span>
</td>
</tr>
<tr class="even" valign="middle">
<th colspan="2" class="sectionheader">Script configuration</th>
</tr>
<tr class="even" id="rowdataoutput">
<td class="settingname">Data Output Mode<br/><span style="color:#FFCC00;background:#2F3A3E;">(for weekly and monthly charts)</span></td>
<td class="settingvalue">
<input type="radio" name="spdmerlin_outputdatamode" id="spdmerlin_dataoutput_average" class="input" value="average" checked>
<label for="spdmerlin_dataoutput_average">Average</label>
<input type="radio" name="spdmerlin_outputdatamode" id="spdmerlin_dataoutput_raw" class="input" value="raw">
<label for="spdmerlin_dataoutput_raw">Raw</label>
</td>
</tr>
<tr class="even" id="rowtimeoutput">
<td class="settingname">Time Output Mode<br/><span style="color:#FFCC00;background:#2F3A3E;">(for CSV export)</span></td>
<td class="settingvalue">
<input type="radio" name="spdmerlin_outputtimemode" id="spdmerlin_timeoutput_non-unix" class="input" value="non-unix" checked>
<label for="spdmerlin_timeoutput_non-unix">Non-Unix</label>
<input type="radio" name="spdmerlin_outputtimemode" id="spdmerlin_timeoutput_unix" class="input" value="unix">
<label for="spdmerlin_timeoutput_unix">Unix</label>
</td>
</tr>
<tr class="even" id="rowstorageloc">
<td class="settingname">Data Storage Location</td>
<td class="settingvalue">
<input type="radio" name="spdmerlin_storagelocation" id="spdmerlin_storageloc_jffs" class="input" value="jffs" checked>
<label for="spdmerlin_storageloc_jffs">JFFS</label>
<input type="radio" name="spdmerlin_storagelocation" id="spdmerlin_storageloc_usb" class="input" value="usb">
<label for="spdmerlin_storageloc_usb">USB</label>
</td>
</tr>
<tr class="even" id="rowstoreresulturl">
<td class="settingname">Save speedtest URLs to database</td>
<td class="settingvalue">
<input type="radio" name="spdmerlin_storeresulturl" id="spdmerlin_store_true" class="input" value="true">
<label for="spdmerlin_store_true">Yes</label>
<input type="radio" name="spdmerlin_storeresulturl" id="spdmerlin_store_false" class="input" value="false" checked>
<label for="spdmerlin_store_false">No</label>
</td>
</tr>
<tr class="even" id="rowexcludefromqos">
<td class="settingname">Exclude speedtests from QoS</td>
<td class="settingvalue">
<input type="radio" name="spdmerlin_excludefromqos" id="spdmerlin_exclude_true" class="input" value="true" checked>
<label for="spdmerlin_exclude_true">Yes</label>
<input type="radio" name="spdmerlin_excludefromqos" id="spdmerlin_exclude_false" class="input" value="false">
<label for="spdmerlin_exclude_false">No</label>
</td>
</tr>
<tr class="apply_gen" valign="top" height="35px">
<td colspan="2" class="savebutton">
<input type="button" onclick="SaveConfig();" value="Save" class="button_gen savebutton" name="button">
</td>
</tr>
</table>
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="border:0px;" id="table_buttons2">
<thead class="collapsible-jquery" id="charttools">
<tr><td colspan="2">Chart Display Options (click to expand/collapse)</td></tr>
</thead>
<tr>
<th width="20%"><span style="color:#FFFFFF;background:#2F3A3E;">Time format</span><br /><span style="color:#FFCC00;background:#2F3A3E;">(for tooltips and Last 24h chart axis)</span></th>
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
