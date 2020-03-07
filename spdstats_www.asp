<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">
<link rel="shortcut icon" href="images/favicon.png">
<link rel="icon" href="images/favicon.png">
<title>Internet Speedtest</title>
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
<script language="JavaScript" type="text/javascript" src="/js/jquery.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/moment.js"></script>
<script language="JavaScript" type="text/javascript" src="/js/chart.min.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/chart.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/hammerjs.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/chartjs-plugin-zoom.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/chartjs-plugin-annotation.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/chartjs-plugin-datasource.js"></script>
<script language="JavaScript" type="text/javascript" src="/state.js"></script>
<script language="JavaScript" type="text/javascript" src="/general.js"></script>
<script language="JavaScript" type="text/javascript" src="/popup.js"></script>
<script language="JavaScript" type="text/javascript" src="/help.js"></script>
<script language="JavaScript" type="text/javascript" src="/tmhist.js"></script>
<script language="JavaScript" type="text/javascript" src="/tmmenu.js"></script>
<script language="JavaScript" type="text/javascript" src="/client_function.js"></script>
<script language="JavaScript" type="text/javascript" src="/validator.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/spdmerlin/spdstatsdata.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/spdmerlin/spdstatstext.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/spdmerlin/spdlastx.js"></script>
<script>
// Keep the real data in a seperate object called allData
// Put only that part of allData in the dataset to optimize zoom/pan performance
// Author: Evert van der Weit - 2018
function filterData(chartInstance) {
	var datasets = chartInstance.data.datasets;
	var originalDatasets = chartInstance.data.allData;
	var chartOptions = chartInstance.options.scales.xAxes[0];
	
	var startX = chartOptions.time.min;
	var endX = chartOptions.time.max;
	if(typeof originalDatasets === 'undefined' || originalDatasets === null) { return; }
	for(var i = 0; i < originalDatasets.length; i++) {
		var dataset = datasets[i];
		var originalData = originalDatasets[i];
		
		if (!originalData.length) break
		
		var s = startX;
		var e = endX;
		var sI = null;
		var eI = null;
		
		for (var j = 0; j < originalData.length; j++) {
			if ((sI==null) && originalData[j].x > s) {
				sI = j;
			}
			if ((eI==null) && originalData[j].x > e) {
				eI = j;
			}
		}
		if (sI==null) sI = 0;
		if (originalData[originalData.length - 1].x < s) eI = 0
			else if (eI==null) eI = originalData.length
		
		dataset.data = originalData.slice(sI, eI);
	}
}
var datafilterPlugin = {
	beforeUpdate: function(chartInstance) {
		filterData(chartInstance);
	}
}
</script>
<script>
var ShowLines=GetCookie("ShowLines");
var ShowFill=GetCookie("ShowFill");
Chart.defaults.global.defaultFontColor = "#CCC";
Chart.Tooltip.positioners.cursor = function(chartElements, coordinates) {
	return coordinates;
};

var metriclist = ["Download","Upload"];
var titlelist = ["Download","Upload"];
var measureunitlist = ["Mbps","Mbps"];
var chartlist = ["daily","weekly","monthly"];
var timeunitlist = ["hour","day","day"];
var intervallist = [24,7,30];
var colourlist = ["#fc8500","#42ecf5"];

var timer;

$(document).keydown(function(e){
	if (e.ctrlKey) {
		if(timer) return;
		timer = setInterval(EnableZoom, 4);
	}
});

$(document).keyup(function(e){
	if (e.ctrlKey){
		clearInterval(timer);
		timer = null;
		chartobj.options.plugins.zoom.zoom.enabled = false;
	}
});

function EnableZoom(){
	if(interfacelist != ""){
		var interfacetextarray = interfacelist.split(',');
		for(i = 0; i < metriclist.length; i++){
			for (i2 = 0; i2 < chartlist.length; i2++) {
				for (i3 = 0; i3 < interfacetextarray.length; i3++) {
					var chartobj = window["LineChart"+metriclist[i]+chartlist[i2]+"_"+interfacetextarray[i3]];
					if(typeof chartobj === 'undefined' || chartobj === null) { continue; }
					chartobj.options.plugins.zoom.zoom.enabled = true;
				}
			}
		}
	}
}

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

function Draw_Chart(txtchartname,txttitle,txtunity,txtunitx,numunitx,colourname){
	var objchartname=window["LineChart"+txtchartname];
	var objdataname=window[txtchartname+"size"];
	if(typeof objdataname === 'undefined' || objdataname === null) { Draw_Chart_NoData(txtchartname); return; }
	if (objdataname == 0) { Draw_Chart_NoData(txtchartname); return; }
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
		//animationEasing : "easeOutQuart",
		//animationSteps : 100,
		animation: {
			duration: 0 // general animation time
		},
		responsiveAnimationDuration: 0, // animation duration after a resize
		maintainAspectRatio: false,
		animateScale : true,
		hover: { mode: "point" },
		legend: { display: false, position: "bottom", onClick: null },
		title: { display: true, text: txttitle },
		tooltips: {
			callbacks: {
					title: function (tooltipItem, data) { return (moment(tooltipItem[0].xLabel,"X").format('YYYY-MM-DD HH:mm:ss')); },
					label: function (tooltipItem, data) { return data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].y.toString() + ' ' + txtunity;}
				},
				mode: 'point',
				position: 'cursor',
				intersect: true
		},
		scales: {
			xAxes: [{
				type: "time",
				gridLines: { display: true, color: "#282828" },
				ticks: {
					min: moment().subtract(numunitx, txtunitx+"s"),
					display: true
				},
				time: { parser: "X", unit: txtunitx, stepSize: 1 }
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
					enabled: true,
					mode: 'xy',
					rangeMin: {
						x: new Date().getTime() - (factor * numunitx),
						y: getLimit(txtchartname,"y","min",false) - Math.sqrt(Math.pow(getLimit(txtchartname,"y","min",false),2))*0.1,
					},
					rangeMax: {
						x: new Date().getTime(),
						y: getLimit(txtchartname,"y","max",false) + getLimit(txtchartname,"y","max",false)*0.1,
					},
				},
				zoom: {
					enabled: false,
					mode: 'xy',
					rangeMin: {
						x: new Date().getTime() - (factor * numunitx),
						y: getLimit(txtchartname,"y","min",false) - Math.sqrt(Math.pow(getLimit(txtchartname,"y","min",false),2))*0.1,
					},
					rangeMax: {
						x: new Date().getTime(),
						y: getLimit(txtchartname,"y","max",false) + getLimit(txtchartname,"y","max",false)*0.1,
					},
					speed: 0.1
				},
			},
			datasource: {
				type: 'csv',
				url: '/ext/spdmerlin/csv/'+txtchartname+'.htm',
				delimiter: ',',
				rowMapping: 'datapoint',
				datapointLabelMapping: {
					_dataset: 'Metric',
					x: 'Time',
					y: 'Value'
				}
			},
		},
		annotation: {
			drawTime: 'afterDatasetsDraw',
			annotations: [{
				//id: 'avgline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'y-axis-0',
				value: getAverage(txtchartname),
				borderColor: colourname,
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
					content: "Avg=" + round(getAverage(txtchartname),3).toFixed(3)+txtunity,
				}
			},
			{
				//id: 'maxline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'y-axis-0',
				value: getLimit(txtchartname,"y","max",true),
				borderColor: colourname,
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
					content: "Max=" + round(getLimit(txtchartname,"y","max",true),3).toFixed(3)+txtunity,
				}
			},
			{
				//id: 'minline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'y-axis-0',
				value: getLimit(txtchartname,"y","min",true),
				borderColor: colourname,
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
					content: "Min=" + round(getLimit(txtchartname,"y","min",true),3).toFixed(3)+txtunity,
				}
			}]
		}
	};
	var lineDataset = {
		datasets: [{label: txttitle,
			borderWidth: 1,
			pointRadius: 1,
			lineTension: 0,
			fill: ShowFill,
			backgroundColor: colourname,
			borderColor: colourname,
		}]
	};
	objchartname = new Chart(ctx, {
		type: 'line',
		plugins: [ChartDataSource,datafilterPlugin],
		options: lineOptions,
		data: lineDataset
	});
	window["LineChart"+txtchartname]=objchartname;
}

function getLimit(datasetname,axis,maxmin) {
	var limit = 0;
	var objdataname=window[datasetname+maxmin];
	if(typeof objdataname === 'undefined' || objdataname === null) { limit = 0; }
	else {limit = objdataname;}
	if(maxmin == "max" && limit == 0 && isannotation == false){
		limit = 1;
	}
	return limit;
}

function getAverage(datasetname) {
	var avg = 0;
	var objdataname=window[datasetname+"avg"];
	if(typeof objdataname === 'undefined' || objdataname === null) { avg = 0; }
	else {avg = objdataname;}
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
					Draw_Chart(metriclist[i]+chartlist[i2]+"_"+interfacetextarray[i3],titlelist[i],measureunitlist[i],timeunitlist[i2],intervallist[i2],colourlist[i]);
				}
			}
		}
		ResetZoom();
	}
}

function GetCookie(cookiename) {
	var s;
	if ((s = cookie.get("spd_"+cookiename)) != null) {
		return cookie.get("spd_"+cookiename);
	}
	else {
		return "";
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
	get_conf_file();
	SetSPDStatsTitle();
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
					window["LineChart"+metriclist[i]+chartlist[i2]+"_"+interfacetextarray[i3]].resetZoom();
				}
			}
		}
	}
}

function applyRule() {
	var action_script_tmp = "start_spdmerlin";
	document.form.action_script.value = action_script_tmp;
	var restart_time = document.form.action_wait.value*1;
	showLoading();
	document.form.submit();
}

function get_conf_file(){
	$.ajax({
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
				$("#table_buttons").after(BuildInterfaceTable(interfacename));
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
			charthtml+='<td>'+moment(window["DataTimestamp_"+name][i]*1000).format('YYYY-MM-DD HH:mm:ss')+'</td>';
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
		
		if(GetCookie(coll[i].id) == "expanded" || GetCookie(coll[i].id) == ""){
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
		if(GetCookie(coll[i].id) == "expanded" || GetCookie(coll[i].id) == ""){
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
<div class="formfonttitle" id="statstitle">Internet Speedtest Stats</div>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="border:0px;" id="table_buttons">
<tr class="apply_gen" valign="top" height="35px">
<td style="background-color:rgb(77, 89, 93);border:0px;">
<input type="button" onclick="applyRule();" value="Run speedtest now" class="button_gen" name="button">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="button" onclick="ResetZoom();" value="Reset Zoom" class="button_gen" name="button">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="button" onclick="ToggleLines();" value="Toggle Lines" class="button_gen" name="button">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="button" onclick="ToggleFill();" value="Toggle Fill" class="button_gen" name="button">
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
<div id="footer">
</div>
</body>
</html>
