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
var $j = jQuery.noConflict(); //avoid conflicts on John's fork (state.js)

var ShowLines=GetCookie("ShowLines","string");
var ShowFill=GetCookie("ShowFill","string");
Chart.defaults.global.defaultFontColor = "#CCC";
Chart.Tooltip.positioners.cursor = function(chartElements, coordinates) {
	return coordinates;
};

var custom_settings = <% get_custom_settings(); %>;

var metriclist = ["Download","Upload"];
var titlelist = ["Download","Upload"];
var measureunitlist = ["Mbps","Mbps"];
var chartlist = ["daily","weekly","monthly"];
var timeunitlist = ["hour","day","day"];
var intervallist = [24,7,30];
var bordercolourlist = ["#fc8500","#42ecf5"];
var backgroundcolourlist = ["rgba(252,133,0,0.5)","rgba(66,236,245,0.5)"];

function keyHandler(e) {
	if (e.keyCode == 27){
		$j(document).off("keydown");
		ResetZoom();
	}
}

$j(document).keydown(function(e){keyHandler(e);});
$j(document).keyup(function(e){
	$j(document).keydown(function(e){
		keyHandler(e);
	});
});

function Draw_Chart_NoData(txtchartname){
	document.getElementById("divLineChart"+txtchartname).width="730";
	document.getElementById("divLineChart"+txtchartname).height="300";
	document.getElementById("divLineChart"+txtchartname).style.width="730px";
	document.getElementById("divLineChart"+txtchartname).style.height="300px";
	var ctx = document.getElementById("divLineChart"+txtchartname).getContext("2d");
	ctx.save();
	ctx.textAlign = 'center';
	ctx.textBaseline = 'middle';
	ctx.font = "normal normal bolder 48px Arial";
	ctx.fillStyle = 'white';
	ctx.fillText('No data to display', 365, 150);
	ctx.restore();
}

function Draw_Chart(txtchartname,txttitle,txtunity,txtunitx,numunitx,bordercolourname,backgroundcolourname,dataobject){
	if(typeof dataobject === 'undefined' || dataobject === null) { Draw_Chart_NoData(txtchartname); return; }
	if (dataobject.length == 0) { Draw_Chart_NoData(txtchartname); return; }
	
	var chartLabels = dataobject.map(function(d) {return d.Metric});
	var chartData = dataobject.map(function(d) {return {x: d.Time, y: d.Value}});
	var objchartname=window["LineChart"+txtchartname];
	
	var timeaxisformat = getTimeFormat($j("#Time_Format option:selected").val(),"axis");
	var timetooltipformat = getTimeFormat($j("#Time_Format option:selected").val(),"tooltip");
	
	factor=0;
	if (txtunitx=="hour"){
		factor=60*60*1000;
	}
	else if (txtunitx=="day"){
		factor=60*60*24*1000;
	}
	if (objchartname != undefined) objchartname.destroy();
	var ctx = document.getElementById("divLineChart"+txtchartname).getContext("2d");
	var lineOptions = {
		segmentShowStroke : false,
		segmentStrokeColor : "#000",
		animationEasing : "easeOutQuart",
		animationSteps : 100,
		maintainAspectRatio: false,
		animateScale : true,
		hover: { mode: "point" },
		legend: { display: false, position: "bottom", onClick: null },
		title: { display: true, text: txttitle },
		tooltips: {
			callbacks: {
					title: function (tooltipItem, data) { return (moment(tooltipItem[0].xLabel,"X").format(timetooltipformat)); },
					label: function (tooltipItem, data) { return round(data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].y,3).toFixed(3) + ' ' + txtunity;}
				},
				mode: 'x',
				position: 'nearest',
				intersect: false
		},
		scales: {
			xAxes: [{
				type: "time",
				gridLines: { display: true, color: "#282828" },
				ticks: {
					min: moment().subtract(numunitx, txtunitx+"s"),
					display: true
				},
				time: {
					parser: "X",
					unit: txtunitx,
					stepSize: 1,
					displayFormats: timeaxisformat
				}
			}],
			yAxes: [{
				gridLines: { display: false, color: "#282828" },
				scaleLabel: { display: false, labelString: txttitle },
				ticks: {
					display: true,
					callback: function (value, index, values) {
						return round(value,3).toFixed(3) + ' ' + txtunity;
					}
				},
			}]
		},
		plugins: {
			zoom: {
				pan: {
					enabled: false,
					mode: 'xy',
					rangeMin: {
						x: new Date().getTime() - (factor * numunitx),
						y: getLimit(chartData,"y","min",false) - Math.sqrt(Math.pow(getLimit(chartData,"y","min",false),2))*0.1,
					},
					rangeMax: {
						x: new Date().getTime(),
						y: getLimit(chartData,"y","max",false) + getLimit(chartData,"y","max",false)*0.1,
					},
				},
				zoom: {
					enabled: true,
					drag: true,
					mode: 'xy',
					rangeMin: {
						x: new Date().getTime() - (factor * numunitx),
						y: getLimit(chartData,"y","min",false) - Math.sqrt(Math.pow(getLimit(chartData,"y","min",false),2))*0.1,
					},
					rangeMax: {
						x: new Date().getTime(),
						y: getLimit(chartData,"y","max",false) + getLimit(chartData,"y","max",false)*0.1,
					},
					speed: 0.1
				},
			},
			deferred: {
				delay: 250
			},
		},
		annotation: {
			drawTime: 'afterDatasetsDraw',
			annotations: [{
				//id: 'avgline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'y-axis-0',
				value: getAverage(chartData),
				borderColor: bordercolourname,
				borderWidth: 1,
				borderDash: [5, 5],
				label: {
					backgroundColor: 'rgba(0,0,0,0.3)',
					fontFamily: "sans-serif",
					fontSize: 10,
					fontStyle: "bold",
					fontColor: "#fff",
					xPadding: 6,
					yPadding: 6,
					cornerRadius: 6,
					position: "center",
					enabled: true,
					xAdjust: 0,
					yAdjust: 0,
					content: "Avg=" + round(getAverage(chartData),3).toFixed(3)+txtunity,
				}
			},
			{
				//id: 'maxline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'y-axis-0',
				value: getLimit(chartData,"y","max",true),
				borderColor: bordercolourname,
				borderWidth: 1,
				borderDash: [5, 5],
				label: {
					backgroundColor: 'rgba(0,0,0,0.3)',
					fontFamily: "sans-serif",
					fontSize: 10,
					fontStyle: "bold",
					fontColor: "#fff",
					xPadding: 6,
					yPadding: 6,
					cornerRadius: 6,
					position: "center",
					enabled: true,
					xAdjust: 0,
					yAdjust: 0,
					content: "Max=" + round(getLimit(chartData,"y","max",true),3).toFixed(3)+txtunity,
				}
			},
			{
				//id: 'minline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'y-axis-0',
				value: getLimit(chartData,"y","min",true),
				borderColor: bordercolourname,
				borderWidth: 1,
				borderDash: [5, 5],
				label: {
					backgroundColor: 'rgba(0,0,0,0.3)',
					fontFamily: "sans-serif",
					fontSize: 10,
					fontStyle: "bold",
					fontColor: "#fff",
					xPadding: 6,
					yPadding: 6,
					cornerRadius: 6,
					position: "center",
					enabled: true,
					xAdjust: 0,
					yAdjust: 0,
					content: "Min=" + round(getLimit(chartData,"y","min",true),3).toFixed(3)+txtunity,
				}
			}]
		}
	};
	var lineDataset = {
		labels: chartLabels,
		datasets: [{data: chartData,
			borderWidth: 1,
			pointRadius: 1,
			lineTension: 0,
			fill: ShowFill,
			backgroundColor: backgroundcolourname,
			borderColor: bordercolourname,
		}]
	};
	objchartname = new Chart(ctx, {
		type: 'line',
		options: lineOptions,
		data: lineDataset
	});
	window["LineChart"+txtchartname]=objchartname;
}

function getLimit(datasetname,axis,maxmin,isannotation) {
	var limit=0;
	var values;
	if(axis == "x"){
		values = datasetname.map(function(o) { return o.x } );
	}
	else{
		values = datasetname.map(function(o) { return o.y } );
	}
	
	if(maxmin == "max"){
		limit=Math.max.apply(Math, values);
	}
	else{
		limit=Math.min.apply(Math, values);
	}
	if(maxmin == "max" && limit == 0 && isannotation == false){
		limit = 1;
	}
	return limit;
}

function getAverage(datasetname) {
	var total = 0;
	for(var i = 0; i < datasetname.length; i++) {
		total += (datasetname[i].y*1);
	}
	var avg = total / datasetname.length;
	return avg;
}

function round(value, decimals) {
	return Number(Math.round(value+'e'+decimals)+'e-'+decimals);
}

function ToggleLines() {
	if(interfacelist != ""){
		var interfacetextarray = interfacelist.split(',');
		if(ShowLines == ""){
			ShowLines = "line";
			SetCookie("ShowLines","line");
		}
		else {
			ShowLines = "";
			SetCookie("ShowLines","");
		}
		for(i = 0; i < metriclist.length; i++){
			for (i2 = 0; i2 < chartlist.length; i2++) {
				for (i3 = 0; i3 < interfacetextarray.length; i3++) {
					for (i4 = 0; i4 < 3; i4++) {
						window["LineChart"+metriclist[i]+chartlist[i2]+"_"+interfacetextarray[i3]].options.annotation.annotations[i4].type=ShowLines;
					}
					window["LineChart"+metriclist[i]+chartlist[i2]+"_"+interfacetextarray[i3]].update();
				}
			}
		}
	}
}

function ToggleFill() {
	if(interfacelist != ""){
		var interfacetextarray = interfacelist.split(',');
		if(ShowFill == "origin"){
			ShowFill = "false";
			SetCookie("ShowFill","false");
		}
		else {
			ShowFill = "origin";
			SetCookie("ShowFill","origin");
		}
			for(i = 0; i < metriclist.length; i++){
			for (i2 = 0; i2 < chartlist.length; i2++) {
				for (i3 = 0; i3 < interfacetextarray.length; i3++) {
					window["LineChart"+metriclist[i]+chartlist[i2]+"_"+interfacetextarray[i3]].data.datasets[0].fill=ShowFill;
					window["LineChart"+metriclist[i]+chartlist[i2]+"_"+interfacetextarray[i3]].update();
				}
			}
		}
	}
}

function RedrawAllCharts() {
	if(interfacelist != ""){
		var interfacetextarray = interfacelist.split(',');
		var i;
		for(i = 0; i < metriclist.length; i++){
			for (i2 = 0; i2 < chartlist.length; i2++) {
				for (i3 = 0; i3 < interfacetextarray.length; i3++) {
					d3.csv('/ext/spdmerlin/csv/'+metriclist[i]+chartlist[i2]+"_"+interfacetextarray[i3]+'.htm').then(Draw_Chart.bind(null,metriclist[i]+chartlist[i2]+"_"+interfacetextarray[i3],titlelist[i],measureunitlist[i],timeunitlist[i2],intervallist[i2],bordercolourlist[i],backgroundcolourlist[i]));
				}
			}
		}
	}
}

function getTimeFormat(value,format) {
	var timeformat;
	
	if(format == "axis"){
		if (value == 0){
			timeformat = {
				millisecond: 'HH:mm:ss.SSS',
				second: 'HH:mm:ss',
				minute: 'HH:mm',
				hour: 'HH:mm'
			}
		}
		else if (value == 1){
			timeformat = {
				millisecond: 'h:mm:ss.SSS A',
				second: 'h:mm:ss A',
				minute: 'h:mm A',
				hour: 'h A'
			}
		}
	}
	else if(format == "tooltip"){
		if (value == 0){
			timeformat = "YYYY-MM-DD HH:mm:ss";
		}
		else if (value == 1){
			timeformat = "YYYY-MM-DD h:mm:ss A";
		}
	}
	
	return timeformat;
}

function GetCookie(cookiename,returntype) {
	var s;
	if ((s = cookie.get("spd_"+cookiename)) != null) {
		return cookie.get("spd_"+cookiename);
	}
	else {
		if(returntype == "string"){
			return "";
		}
		else if(returntype == "number"){
			return 0;
		}
	}
}

function SetCookie(cookiename,cookievalue) {
	cookie.set("spd_"+cookiename, cookievalue, 31);
}

function SetCurrentPage(){
	document.form.next_page.value = window.location.pathname.substring(1);
	document.form.current_page.value = window.location.pathname.substring(1);
}

function initial(){
	SetCurrentPage();
	show_menu();
	ScriptUpdateLayout();
	SetSPDStatsTitle();
	$j("#Time_Format").val(GetCookie("Time_Format","number"));
	get_conf_file();
}

function ScriptUpdateLayout(){
	var localver = GetVersionNumber("local");
	var serverver = GetVersionNumber("server");
	$j("#scripttitle").text($j("#scripttitle").text()+" - "+localver);
	$j("#spdmerlin_version_local").text(localver);
	
	if (localver != serverver && serverver != "N/A"){
		$j("#spdmerlin_version_server").text("Updated version available: "+serverver);
		showhide("btnChkUpdate", false);
		showhide("spdmerlin_version_server", true);
		showhide("btnDoUpdate", true);
	}
}

function reload() {
	location.reload(true);
}

function ResetZoom(){
	if(interfacelist != ""){
		var interfacetextarray = interfacelist.split(',');
		for(i = 0; i < metriclist.length; i++){
			for (i2 = 0; i2 < chartlist.length; i2++) {
				for (i3 = 0; i3 < interfacetextarray.length; i3++) {
					var chartobj = window["LineChart"+metriclist[i]+chartlist[i2]+"_"+interfacetextarray[i3]];
					if(typeof chartobj === 'undefined' || chartobj === null) { continue; }
					chartobj.resetZoom();
				}
			}
		}
	}
}

function DragZoom(button){
	var drag = true;
	var pan = false;
	var buttonvalue = "";
	if(button.value.indexOf("On") != -1){
		drag = false;
		pan = true;
		buttonvalue = "Drag Zoom Off";
	}
	else {
		drag = true;
		pan = false;
		buttonvalue = "Drag Zoom On";
	}
	
	if(interfacelist != ""){
		var interfacetextarray = interfacelist.split(',');
		for(i = 0; i < metriclist.length; i++){
			for (i2 = 0; i2 < chartlist.length; i2++) {
				for (i3 = 0; i3 < interfacetextarray.length; i3++) {
					var chartobj = window["LineChart"+metriclist[i]+chartlist[i2]+"_"+interfacetextarray[i3]];
					if(typeof chartobj === 'undefined' || chartobj === null) { continue; }
					chartobj.options.plugins.zoom.zoom.drag = drag;
					chartobj.options.plugins.zoom.pan.enabled = pan;
					button.value = buttonvalue;
					chartobj.update();
				}
			}
		}
	}
}

function ExportCSV() {
	location.href = "ext/spdmerlin/csv/spdmerlindata.zip";
	return 0;
}

function CheckUpdate(){
	var action_script_tmp = "start_spdmerlincheckupdate";
	document.form.action_script.value = action_script_tmp;
	var restart_time = 10;
	document.form.action_wait.value = restart_time;
	showLoading();
	document.form.submit();
}

function DoUpdate(){
	var action_script_tmp = "start_spdmerlindoupdate";
	document.form.action_script.value = action_script_tmp;
	var restart_time = 20;
	document.form.action_wait.value = restart_time;
	showLoading();
	document.form.submit();
}

function applyRule() {
	var action_script_tmp = "start_spdmerlin";
	document.form.action_script.value = action_script_tmp;
	var restart_time = 90;
	document.form.action_wait.value = restart_time;
	showLoading();
	document.form.submit();
}

function GetVersionNumber(versiontype)
{
	var versionprop;
	if(versiontype == "local"){
		versionprop = custom_settings.spdmerlin_version_local;
	}
	else if(versiontype == "server"){
		versionprop = custom_settings.spdmerlin_version_server;
	}
	
	if(typeof versionprop == 'undefined' || versionprop == null)
	{
		return "N/A";
	}
	else {
		return versionprop;
	}
}

function get_conf_file(){
	$j.ajax({
		url: '/ext/spdmerlin/interfaces.htm',
		dataType: 'text',
		error: function(xhr){
			setTimeout("get_conf_file();", 1000);
		},
		success: function(data){
			var interfaces=data.split("\n");
			interfaces.reverse();
			interfaces=interfaces.filter(Boolean);
			interfacelist="";
			var interfacecount=interfaces.length;
			for (var i = 0; i < interfacecount; i++) {
				var commentstart=interfaces[i].indexOf("#");
				if (commentstart != -1){
					continue
				}
				var interfacename=interfaces[i];
				$j("#table_buttons2").after(BuildInterfaceTable(interfacename));
				if(i == interfacecount-1){
					interfacelist+=interfacename;
				} else {
					interfacelist+=interfacename+',';
				}
			}
			
			if(interfacelist != ""){
				AddEventHandlers();
				RedrawAllCharts();
			}
		}
	});
}

function changeChart(e) {
	value = e.value * 1;
	name = e.id.substring(0, e.id.indexOf("_"));
	SetCookie(e.id,value);
	RedrawAllCharts();
}

function BuildInterfaceTable(name){
	var charthtml = '<div style="line-height:10px;">&nbsp;</div>';
	charthtml+='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="table_interfaces_'+name+'">';
	charthtml+='<thead class="collapsibleparent" id="'+name+'">';
	charthtml+='<tr>';
	charthtml+='<td colspan="2">'+name+' (click to expand/collapse)</td>';
	charthtml+='</tr>';
	charthtml+='</thead>';
	charthtml+='<tr>';
	charthtml+='<td colspan="2" align="center" style="padding: 0px;">';
	charthtml+='<div class="collapsiblecontent">';
	
	charthtml+='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">';
	charthtml+='<thead class="collapsible expanded" id="spd_resulttable_'+name+'">';
	charthtml+='<tr><td colspan="2">Last 10 speedtest results (click to expand/collapse)</td></tr>';
	charthtml+='</thead>';
	charthtml+='<tr>';
	charthtml+='<td colspan="2" align="center" style="padding: 0px;">';
	charthtml+='<div class="collapsiblecontent">';
	charthtml+='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable StatsTable">';
	var nodata="";
	var objdataname = window["DataTimestamp_"+name];
	if(typeof objdataname === 'undefined' || objdataname === null){nodata="true"}
	else if(objdataname.length == 0) {nodata="true"}
	else if(objdataname.length == 1 && objdataname[0] == "") {nodata="true"}
	
	if(nodata == "true") {
		charthtml+='<tr>';
		charthtml+='<td colspan="3" class="nodata">';
		charthtml+='No data to display';
		charthtml+='</td>';
		charthtml+='</tr>';
	} else {
		charthtml+='<col style="width:240px;">';
		charthtml+='<col style="width:240px;">';
		charthtml+='<col style="width:240px;">';
		charthtml+='<thead>';
		charthtml+='<tr>';
		charthtml+='<th class="keystatsnumber">Time</th>';
		charthtml+='<th class="keystatsnumber">Download (Mbps)</th>';
		charthtml+='<th class="keystatsnumber">Upload (Mbps)</th>';
		charthtml+='</tr>';
		charthtml+='</thead>';
		
		for(i = 0; i < objdataname.length; i++){
			charthtml+='<tr>';
			charthtml+='<td>'+moment.unix(window["DataTimestamp_"+name][i]).format('YYYY-MM-DD HH:mm:ss')+'</td>';
			charthtml+='<td>'+window["DataDownload_"+name][i]+'</td>';
			charthtml+='<td>'+window["DataUpload_"+name][i]+'</td>';
			charthtml+='</tr>';
		};
	}
	charthtml+='</table>';
	charthtml+='</div>';
	charthtml+='</td>';
	charthtml+='</tr>';
	charthtml+='</table>';
	charthtml+='<div style="line-height:10px;">&nbsp;</div>';
		
	charthtml+='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">';
	charthtml+='<tr>';
	charthtml+='<div style="line-height:10px;">&nbsp;</div>';
	charthtml+='</tr>';
	charthtml+='<thead class="collapsible" id="last24_'+name+'">';
	charthtml+='<tr>';
	charthtml+='<td colspan="2">Last 24 Hours (click to expand/collapse)</td>';
	charthtml+='</tr>';
	charthtml+='</thead>';
	charthtml+='<tr>';
	charthtml+='<td colspan="2" align="center" style="padding: 0px;">';
	charthtml+='<div class="collapsiblecontent">';
	charthtml+='<div style="background-color:#2f3e44;border-radius:10px;width:730px;padding-left:5px;"><canvas id="divLineChartDownloaddaily_'+name+'" height="300" /></div>';
	charthtml+='<div style="line-height:10px;">&nbsp;</div>';
	charthtml+='<div style="background-color:#2f3e44;border-radius:10px;width:730px;padding-left:5px;"><canvas id="divLineChartUploaddaily_'+name+'" height="300" /></div>';
	charthtml+='</div>';
	charthtml+='</td>';
	charthtml+='</tr>';
	charthtml+='</table>';
	charthtml+='<div style="line-height:10px;">&nbsp;</div>';
	charthtml+='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">';
	charthtml+='<thead class="collapsible" id="last7_'+name+'">';
	charthtml+='<tr>';
	charthtml+='<td colspan="2">Last 7 days (click to expand/collapse)</td>';
	charthtml+='</tr>';
	charthtml+='</thead>';
	charthtml+='<tr>';
	charthtml+='<td colspan="2" align="center" style="padding: 0px;">';
	charthtml+='<div class="collapsiblecontent">';
	charthtml+='<div style="background-color:#2f3e44;border-radius:10px;width:730px;padding-left:5px;"><canvas id="divLineChartDownloadweekly_'+name+'" height="300" /></div>';
	charthtml+='<div style="line-height:10px;">&nbsp;</div>';
	charthtml+='<div style="background-color:#2f3e44;border-radius:10px;width:730px;padding-left:5px;"><canvas id="divLineChartUploadweekly_'+name+'" height="300" /></div>';
	charthtml+='</div>';
	charthtml+='</td>';
	charthtml+='</tr>';
	charthtml+='</table>';
	charthtml+='<div style="line-height:10px;">&nbsp;</div>';
	charthtml+='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">';
	charthtml+='<thead class="collapsible" id="last30_'+name+'">';
	charthtml+='<tr>';
	charthtml+='<td colspan="2">Last 30 days (click to expand/collapse)</td>';
	charthtml+='</tr>';
	charthtml+='</thead>';
	charthtml+='<tr>';
	charthtml+='<td colspan="2" align="center" style="padding: 0px;">';
	charthtml+='<div class="collapsiblecontent">';
	charthtml+='<div style="background-color:#2f3e44;border-radius:10px;width:730px;padding-left:5px;"><canvas id="divLineChartDownloadmonthly_'+name+'" height="300" /></div>';
	charthtml+='<div style="line-height:10px;">&nbsp;</div>';
	charthtml+='<div style="background-color:#2f3e44;border-radius:10px;width:730px;padding-left:5px;"><canvas id="divLineChartUploadmonthly_'+name+'" height="300" /></div>';
	charthtml+='</div>';
	charthtml+='</td>';
	charthtml+='</tr>';
	charthtml+='</table>';
	charthtml+='</div>';
	charthtml+='</td>';
	charthtml+='</tr>';
	charthtml+='</table>';
	charthtml+='<div style="line-height:10px;">&nbsp;</div>';
	return charthtml;
}

function AddEventHandlers(){
	$j(".collapsible-jquery").click(function(){
		$j(this).siblings().toggle("fast")
	});
	
	var coll = document.getElementsByClassName("collapsible");
	var i;
	var height = 0;

	for (i = 0; i < coll.length; i++) {
		coll[i].addEventListener("click", function() {
			this.classList.toggle("active");
			var content = this.nextElementSibling.firstElementChild.firstElementChild.firstElementChild;
			if (content.style.maxHeight){
					content.style.maxHeight = null;
					SetCookie(this.id,"collapsed")
			} else {
					content.style.maxHeight = content.scrollHeight + "px";
					this.parentElement.parentElement.style.maxHeight = (this.parentElement.parentElement.style.maxHeight.substring(0,this.parentElement.parentElement.style.maxHeight.length-2)*1) + content.scrollHeight + "px";
					SetCookie(this.id,"expanded");
				}
		});
		
		if(GetCookie(coll[i].id,"string") == "expanded" || GetCookie(coll[i].id,"string") == ""){
			coll[i].click();
		}
		height=(coll[i].nextElementSibling.firstElementChild.firstElementChild.firstElementChild.style.maxHeight.substring(0,coll[i].nextElementSibling.firstElementChild.firstElementChild.firstElementChild.style.maxHeight.length-2)*1) + height + 21 + 10 + 10 + 10 + 10 + 10;
	}
	
	var coll = document.getElementsByClassName("collapsibleparent");
	var i;
	
	for (i = 0; i < coll.length; i++) {
		coll[i].addEventListener("click", function() {
			this.classList.toggle("active");
			var content = this.nextElementSibling.firstElementChild.firstElementChild.firstElementChild;
			if (content.style.maxHeight){
				content.style.maxHeight = null;
				SetCookie(this.id,"collapsed");
			} else {
				content.style.maxHeight = content.scrollHeight + "px";
				SetCookie(this.id,"expanded");
			}
		});
		if(GetCookie(coll[i].id,"string") == "expanded" || GetCookie(coll[i].id,"string") == ""){
			coll[i].nextElementSibling.firstElementChild.firstElementChild.firstElementChild.style.maxHeight = height + "px";
		} else {
			coll[i].nextElementSibling.firstElementChild.firstElementChild.firstElementChild.style.maxHeight = null;
		}
	}
}
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
<thead class="collapsible-jquery" id="spd_scripttools">
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
<thead class="collapsible-jquery" id="spd_charttools">
<tr><td colspan="2">Chart Configuration (click to expand/collapse)</td></tr>
</thead>
<div class="collapsiblecontent">
<tr>
<th width="20%"><span style="color:#FFFFFF;">Time format</span><br /><span style="color:#FFFFFF;">for tooltips and Last 24h chart axis</span></th>
<td>
<select style="width:100px" class="input_option" onchange="changeChart(this)" id="Time_Format">
<option value="0">24h</option>
<option value="1">12h</option>
</select>
</td>
</tr>
<tr class="apply_gen" valign="top">
<td colspan="2" style="background-color:rgb(77, 89, 93);">
<input type="button" onclick="DragZoom(this);" value="Drag Zoom On" class="button_gen" name="btnDragZoom">
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
