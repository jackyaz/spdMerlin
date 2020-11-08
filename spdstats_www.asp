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

.SettingsTable input {
  margin-left: 3px !important;
}

.SettingsTable label {
  margin-right: 13px !important;
}

.SettingsTable th {
  background-color: #1F2D35 !important;
  background: #2F3A3E !important;
  border-bottom: none !important;
  border-top: none !important;
  font-size: 12px !important;
  color: white !important;
  padding: 4px !important;
  padding: 0px !important;
}

.SettingsTable td {
  word-wrap: break-word !important;
  overflow-wrap: break-word !important;
  border-right: none;
  border-left: none;
}

.SettingsTable td.settingname {
  border-right: solid 1px black;
  background-color: #1F2D35 !important;
  background: #2F3A3E !important;
  width: 35% !important;
}

.SettingsTable td.settingvalue {
  text-align: left !important;
  border-right: solid 1px black;
}

.SettingsTable th:first-child{
  border-left: none !important;
}

.SettingsTable th:last-child {
  border-right: none !important;
}

.SettingsTable .invalid {
  background-color: darkred !important;
}

.SettingsTable .disabled {
  background-color: #CCCCCC !important;
  color: #888888 !important;
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
<script language="JavaScript" type="text/javascript" src="/ext/spdmerlin/spdtitletext.js"></script>
<script>
var custom_settings;
function LoadCustomSettings(){
	custom_settings = <% get_custom_settings(); %>;
	for (var prop in custom_settings){
		if(Object.prototype.hasOwnProperty.call(custom_settings, prop)){
			if(prop.indexOf("spdmerlin") != -1 && prop.indexOf("spdmerlin_version") == -1){
				eval("delete custom_settings."+prop)
			}
		}
	}
}
var $j = jQuery.noConflict(); //avoid conflicts on John's fork (state.js)

var maxNoCharts = 0;
var currentNoCharts = 0;

var ShowLines = GetCookie("ShowLines","string");
var ShowFill = GetCookie("ShowFill","string");
if(ShowFill == ""){
	ShowFill = "origin";
}

var DragZoom = true;
var ChartPan = false;

Chart.defaults.global.defaultFontColor = "#CCC";
Chart.Tooltip.positioners.cursor = function(chartElements, coordinates){
	return coordinates;
};

var chartlist = ["daily","weekly","monthly"];
var timeunitlist = ["hour","day","day"];
var intervallist = [24,7,30];
var bordercolourlist_Combined = ["#fc8500","#42ecf5"];
var backgroundcolourlist_Combined = ["rgba(252,133,0,0.5)","rgba(66,236,245,0.5)"];
var bordercolourlist_Quality = ["#53047a","#07f242","#ffffff"];
var backgroundcolourlist_Quality = ["rgba(83,4,122,0.5)","rgba(7,242,66,0.5)","rgba(255,255,255,0.5)"];

var typelist = ["Combined","Quality"];

function keyHandler(e){
	if(e.keyCode == 27){
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

function Draw_Chart_NoData(txtchartname,txtcharttype){
	document.getElementById("divLineChart_"+txtchartname+"_"+txtcharttype).width="730";
	document.getElementById("divLineChart_"+txtchartname+"_"+txtcharttype).height="500";
	document.getElementById("divLineChart_"+txtchartname+"_"+txtcharttype).style.width="730px";
	document.getElementById("divLineChart_"+txtchartname+"_"+txtcharttype).style.height="500px";
	var ctx = document.getElementById("divLineChart_"+txtchartname+"_"+txtcharttype).getContext("2d");
	ctx.save();
	ctx.textAlign = 'center';
	ctx.textBaseline = 'middle';
	ctx.font = "normal normal bolder 48px Arial";
	ctx.fillStyle = 'white';
	ctx.fillText('No data to display', 365, 250);
	ctx.restore();
}

function Draw_Chart(txtchartname,txtcharttype){
	var txtunity = "";
	var txtunity2 = "";
	var txttitle = "";
	var metric0 = "";
	var metric1 = "";
	var metric2 = "";
	var showyaxis2 = false;
	
	if(txtcharttype == "Combined"){
		txtunity = "Mbps";
		txttitle = "Bandwidth";
		metric0 = "Download";
		metric1 = "Upload";
	}
	else if(txtcharttype == "Quality"){
		txtunity = "ms";
		txtunity2 = "%";
		txttitle = "Quality";
		metric0 = "Latency";
		metric1 = "Jitter";
		metric2 = "PktLoss";
		showyaxis2 = true;
	}
	
	var chartperiod = getChartPeriod($j("#" + txtchartname + "_Period_" + txtcharttype + " option:selected").val());
	var txtunitx = timeunitlist[$j("#" + txtchartname + "_Period_" + txtcharttype + " option:selected").val()];
	var numunitx = intervallist[$j("#" + txtchartname + "_Period_" + txtcharttype + " option:selected").val()];
	var dataobject = window[chartperiod+"_"+txtchartname+"_"+txtcharttype];
	if(typeof dataobject === 'undefined' || dataobject === null){ Draw_Chart_NoData(txtchartname,txtcharttype); return; }
	if(dataobject.length == 0){ Draw_Chart_NoData(txtchartname,txtcharttype); return; }
	
	var chartData = dataobject.map(function(d){return {x: d.Time, y: d.Value}});
	
	var unique = [];
	var chartTrafficTypes = [];
	for( let i = 0; i < dataobject.length; i++){
		if(!unique[dataobject[i].Metric]){
			chartTrafficTypes.push(dataobject[i].Metric);
			unique[dataobject[i].Metric] = 1;
		}
	}
	
	var chartData0 = dataobject.filter(function(item){
		return item.Metric == metric0;
	}).map(function(d){return {x: d.Time, y: d.Value}});
	
	var chartData1 = dataobject.filter(function(item){
		return item.Metric == metric1;
	}).map(function(d){return {x: d.Time, y: d.Value}});
	
	var chartData2 = dataobject.filter(function(item){
		return item.Metric == metric2;
	}).map(function(d){return {x: d.Time, y: d.Value}});
	
	var objchartname=window["LineChart_"+txtchartname+"_"+txtcharttype];
	
	var timeaxisformat = getTimeFormat($j("#Time_Format option:selected").val(),"axis");
	var timetooltipformat = getTimeFormat($j("#Time_Format option:selected").val(),"tooltip");
	
	factor=0;
	if(txtunitx=="hour"){
		factor=60*60*1000;
	}
	else if(txtunitx=="day"){
		factor=60*60*24*1000;
	}
	if(objchartname != undefined) objchartname.destroy();
	var ctx = document.getElementById("divLineChart_"+txtchartname+"_"+txtcharttype).getContext("2d");
	var lineOptions = {
		segmentShowStroke : false,
		segmentStrokeColor : "#000",
		animationEasing : "easeOutQuart",
		animationSteps : 100,
		maintainAspectRatio: false,
		animateScale : true,
		hover: { mode: "point" },
		legend: {
			display: true,
			position: "top",
			reverse: true,
			onClick: function (e, legendItem){
				var index = legendItem.datasetIndex;
				var ci = this.chart;
				var meta = ci.getDatasetMeta(index);
				
				meta.hidden = meta.hidden === null ? !ci.data.datasets[index].hidden : null;
				
				if(ShowLines == "line"){
					var annotationline = ""
					if(meta.hidden != true){
						annotationline = "line";
					}
					
					if(ci.data.datasets[index].label == "Latency" || ci.data.datasets[index].label == "Download"){
						for (aindex = 0; aindex < 3; aindex++){
							ci.options.annotation.annotations[aindex].type=annotationline;
						}
					}
					else if(ci.data.datasets[index].label == "Jitter" || ci.data.datasets[index].label == "Upload"){
						for (aindex = 3; aindex < 6; aindex++){
							ci.options.annotation.annotations[aindex].type=annotationline;
						}
					}
					else if(ci.data.datasets[index].label == "Packet Loss"){
						for (aindex = 6; aindex < 9; aindex++){
							ci.options.annotation.annotations[aindex].type=annotationline;
						}
					}
				}
				
				if(ci.data.datasets[index].label == "Packet Loss"){
					var showaxis = false;
					if(meta.hidden != true){
						showaxis = true;
					}
					ci.scales["right-y-axis"].options.display = showaxis;
				}
				
				ci.update();
			}
		},
		title: { display: true, text: txttitle },
		tooltips: {
			callbacks: {
					title: function (tooltipItem, data){ return (moment(tooltipItem[0].xLabel,"X").format(timetooltipformat)); },
					label: function (tooltipItem, data){ var txtunitytip=txtunity; if(data.datasets[tooltipItem.datasetIndex].label == "Packet Loss"){txtunitytip=txtunity2}; return round(data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].y,2).toFixed(2) + ' ' + txtunitytip;}
				},
			itemSort: function(a, b){
				return b.datasetIndex - a.datasetIndex;
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
				time: {
					parser: "X",
					unit: txtunitx,
					stepSize: 1,
					displayFormats: timeaxisformat
				}
			}],
			yAxes: [{
				gridLines: { display: false, color: "#282828" },
				scaleLabel: { display: false, labelString: "" },
				id: 'left-y-axis',
				position: 'left',
				ticks: {
					display: true,
					beginAtZero: true,
					callback: function (value, index, values){
						return round(value,2).toFixed(2) + ' ' + txtunity;
					}
				},
			},
			{
				gridLines: { display: false, color: "#282828" },
				scaleLabel: { display: false, labelString: "" },
				id: 'right-y-axis',
				position: 'right',
				ticks: {
					display: showyaxis2,
					beginAtZero: true,
					callback: function (value, index, values){
						return round(value,2).toFixed(2) + ' ' + txtunity2;
					}
				},
			}]
		},
		plugins: {
			zoom: {
				pan: {
					enabled: ChartPan,
					mode: 'xy',
					rangeMin: {
						x: new Date().getTime() - (factor * numunitx),
						y: 0,
					},
					rangeMax: {
						x: new Date().getTime()//,
						//y: getLimit(chartData,"y","max",false) + getLimit(chartData,"y","max",false)*0.1,
					},
				},
				zoom: {
					enabled: true,
					drag: DragZoom,
					mode: 'xy',
					rangeMin: {
						x: new Date().getTime() - (factor * numunitx),
						y: 0,
					},
					rangeMax: {
						x: new Date().getTime()//,
						//y: getLimit(chartData,"y","max",false) + getLimit(chartData,"y","max",false)*0.1,
					},
					speed: 0.1
				},
			},
		},
		annotation: {
			drawTime: 'afterDatasetsDraw',
			annotations: [{
				//id: 'avgline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'left-y-axis',
				value: getAverage(chartData0),
				borderColor: window["bordercolourlist_"+txtcharttype][0],
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
					content: "Avg. "+metric0+"=" + round(getAverage(chartData0),2).toFixed(2)+txtunity,
				}
			},
			{
				//id: 'maxline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'left-y-axis',
				value: getLimit(chartData0,"y","max",true),
				borderColor: window["bordercolourlist_"+txtcharttype][0],
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
					position: "right",
					enabled: true,
					xAdjust: 15,
					yAdjust: 0,
					content: "Max. "+metric0+"=" + round(getLimit(chartData0,"y","max",true),2).toFixed(2)+txtunity,
				}
			},
			{
				//id: 'minline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'left-y-axis',
				value: getLimit(chartData0,"y","min",true),
				borderColor: window["bordercolourlist_"+txtcharttype][0],
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
					position: "left",
					enabled: true,
					xAdjust: 15,
					yAdjust: 0,
					content: "Min. "+metric0+"=" + round(getLimit(chartData0,"y","min",true),2).toFixed(2)+txtunity,
				}
			},
			{
				//id: 'avgline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'left-y-axis',
				value: getAverage(chartData1),
				borderColor: window["bordercolourlist_"+txtcharttype][1],
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
					content: "Avg. "+metric1+"=" + round(getAverage(chartData1),2).toFixed(2)+txtunity,
				}
			},
			{
				//id: 'maxline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'left-y-axis',
				value: getLimit(chartData1,"y","max",true),
				borderColor: window["bordercolourlist_"+txtcharttype][1],
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
					position: "right",
					enabled: true,
					xAdjust: 15,
					yAdjust: 0,
					content: "Max. "+metric1+"=" + round(getLimit(chartData1,"y","max",true),2).toFixed(2)+txtunity,
				}
			},
			{
				//id: 'minline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'left-y-axis',
				value: getLimit(chartData1,"y","min",true),
				borderColor: window["bordercolourlist_"+txtcharttype][1],
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
					position: "left",
					enabled: true,
					xAdjust: 15,
					yAdjust: 0,
					content: "Min. "+metric1+"=" + round(getLimit(chartData1,"y","min",true),2).toFixed(2)+txtunity,
				}
			},
			{
				//id: 'avgline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'right-y-axis',
				value: getAverage(chartData2),
				borderColor: window["bordercolourlist_"+txtcharttype][2],
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
					content: "Avg. "+metric2+"=" + round(getAverage(chartData2),2).toFixed(2)+txtunity2,
				}
			},
			{
				//id: 'maxline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'right-y-axis',
				value: getLimit(chartData2,"y","max",true),
				borderColor: window["bordercolourlist_"+txtcharttype][2],
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
					position: "right",
					enabled: true,
					xAdjust: 15,
					yAdjust: 0,
					content: "Max. "+metric2+"=" + round(getLimit(chartData2,"y","max",true),2).toFixed(2)+txtunity2,
				}
			},
			{
				//id: 'minline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'right-y-axis',
				value: getLimit(chartData2,"y","min",true),
				borderColor: window["bordercolourlist_"+txtcharttype][2],
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
					position: "left",
					enabled: true,
					xAdjust: 15,
					yAdjust: 0,
					content: "Min. "+metric2+"=" + round(getLimit(chartData2,"y","min",true),2).toFixed(2)+txtunity2,
				}
			}
			
		]}
	};
	var lineDataset = {
		datasets: getDataSets(txtcharttype, dataobject, chartTrafficTypes)
	};
	objchartname = new Chart(ctx, {
		type: 'line',
		options: lineOptions,
		data: lineDataset
	});
	window["LineChart_"+txtchartname+"_"+txtcharttype]=objchartname;
}

function getDataSets(charttype, objdata, objTrafficTypes){
	var datasets = [];
	colourname="#fc8500";
	
	for(var i = 0; i < objTrafficTypes.length; i++){
		var traffictypedata = objdata.filter(function(item){
			return item.Metric == objTrafficTypes[i];
		}).map(function(d){return {x: d.Time, y: d.Value}});
		var axisid = "left-y-axis";
		if(objTrafficTypes[i] == "PktLoss"){
			axisid = "right-y-axis";
		}
		
		datasets.push({ label: objTrafficTypes[i].replace("PktLoss","Packet Loss"), data: traffictypedata, yAxisID: axisid, borderWidth: 1, pointRadius: 1, lineTension: 0, fill: true, backgroundColor: window["backgroundcolourlist_"+charttype][i], borderColor: window["bordercolourlist_"+charttype][i]});
	}
	datasets.reverse();
	return datasets;
}

function getLimit(datasetname,axis,maxmin,isannotation){
	var limit=0;
	var values;
	if(axis == "x"){
		values = datasetname.map(function(o){ return o.x } );
	}
	else{
		values = datasetname.map(function(o){ return o.y } );
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

function getAverage(datasetname){
	var total = 0;
	for(var i = 0; i < datasetname.length; i++){
		total += (datasetname[i].y*1);
	}
	var avg = total / datasetname.length;
	return avg;
}

function round(value, decimals){
	return Number(Math.round(value+'e'+decimals)+'e-'+decimals);
}

function ToggleLines(){
	if(interfacelist != ""){
		var interfacetextarray = interfacelist.split(',');
		if(ShowLines == ""){
			ShowLines = "line";
			SetCookie("ShowLines","line");
		}
		else{
			ShowLines = "";
			SetCookie("ShowLines","");
		}
		for (i = 0; i < interfacetextarray.length; i++){
			for (i2 = 0; i2 < typelist.length; i2++){
				var maxlines = 6;
				if(typelist[i2] == "Quality"){
					maxlines = 9;
				}
				for (i3 = 0; i3 < maxlines; i3++){
					window["LineChart_"+interfacetextarray[i]+"_"+typelist[i2]].options.annotation.annotations[i3].type=ShowLines;
				}
				window["LineChart_"+interfacetextarray[i]+"_"+typelist[i2]].update();
			}
		}
	}
}

function ToggleFill(){
	if(interfacelist != ""){
		var interfacetextarray = interfacelist.split(',');
		if(ShowFill == "origin"){
			ShowFill = false;
			SetCookie("ShowFill",false);
		}
		else{
			ShowFill = "origin";
			SetCookie("ShowFill","origin");
		}
		
		for (i = 0; i < interfacetextarray.length; i++){
			for (i2 = 0; i2 < typelist.length; i2++){
				window["LineChart_"+interfacetextarray[i]+"_"+typelist[i2]].data.datasets[0].fill=ShowFill;
				window["LineChart_"+interfacetextarray[i]+"_"+typelist[i2]].data.datasets[1].fill=ShowFill;
				if(typelist[i2] == "Quality"){
					window["LineChart_"+interfacetextarray[i]+"_"+typelist[i2]].data.datasets[2].fill=ShowFill;
				}
				window["LineChart_"+interfacetextarray[i]+"_"+typelist[i2]].update();
			}
		}
	}
}

function RedrawAllCharts(){
	if(interfacelist != ""){
		var interfacetextarray = interfacelist.split(',');
		var i;
		for (i2 = 0; i2 < chartlist.length; i2++){
			for (i3 = 0; i3 < interfacetextarray.length; i3++){
				$j("#"+interfacetextarray[i3]+"_Period_Combined").val(GetCookie(interfacetextarray[i3]+"_Period_Combined","number"));
				$j("#"+interfacetextarray[i3]+"_Period_Quality").val(GetCookie(interfacetextarray[i3]+"_Period_Quality","number"));
				d3.csv('/ext/spdmerlin/csv/Combined'+chartlist[i2]+"_"+interfacetextarray[i3]+'.htm').then(SetGlobalDataset.bind(null,chartlist[i2]+"_"+interfacetextarray[i3]+"_Combined"));
				d3.csv('/ext/spdmerlin/csv/Quality'+chartlist[i2]+"_"+interfacetextarray[i3]+'.htm').then(SetGlobalDataset.bind(null,chartlist[i2]+"_"+interfacetextarray[i3]+"_Quality"));
			}
		}
	}
}

function getTimeFormat(value,format){
	var timeformat;
	
	if(format == "axis"){
		if(value == 0){
			timeformat = {
				millisecond: 'HH:mm:ss.SSS',
				second: 'HH:mm:ss',
				minute: 'HH:mm',
				hour: 'HH:mm'
			}
		}
		else if(value == 1){
			timeformat = {
				millisecond: 'h:mm:ss.SSS A',
				second: 'h:mm:ss A',
				minute: 'h:mm A',
				hour: 'h A'
			}
		}
	}
	else if(format == "tooltip"){
		if(value == 0){
			timeformat = "YYYY-MM-DD HH:mm:ss";
		}
		else if(value == 1){
			timeformat = "YYYY-MM-DD h:mm:ss A";
		}
	}
	
	return timeformat;
}

function GetCookie(cookiename,returntype){
	var s;
	if((s = cookie.get("spd_"+cookiename)) != null){
		return cookie.get("spd_"+cookiename);
	}
	else{
		if(returntype == "string"){
			return "";
		}
		else if(returntype == "number"){
			return 0;
		}
	}
}

function SetCookie(cookiename,cookievalue){
	cookie.set("spd_"+cookiename, cookievalue, 31);
}

$j.fn.serializeObject = function(){
	var o = custom_settings;
	var a = this.serializeArray();
	$j.each(a, function(){
		if(o[this.name] !== undefined && this.name.indexOf("spdmerlin") != -1 && this.name.indexOf("version") == -1 && this.name.indexOf("spdmerlin_iface_enabled") == -1){
			if(!o[this.name].push){
				o[this.name] = [o[this.name]];
			}
			o[this.name].push(this.value || '');
		} else if(this.name.indexOf("spdmerlin") != -1 && this.name.indexOf("version") == -1 && this.name.indexOf("spdmerlin_iface_enabled") == -1){
			o[this.name] = this.value || '';
		}
	});
	return o;
};

$j.fn.serializeObjectInterfaces = function(){
	var o = custom_settings;
	var a = this.serializeArray();
	var ifacesenabled = [];
	$j.each($j("input[name='spdmerlin_iface_enabled']:checked"), function(){
		ifacesenabled.push($j(this).val());
	});
	var ifacesenabledstring = ifacesenabled.join(",");
	o["spdmerlin_ifaces_enabled"] = ifacesenabledstring;
	return o;
};

function SetCurrentPage(){
	document.form.next_page.value = window.location.pathname.substring(1);
	document.form.current_page.value = window.location.pathname.substring(1);
}

function initial(){
	SetCurrentPage();
	LoadCustomSettings();
	show_menu();
	$j("#Time_Format").val(GetCookie("Time_Format","number"));
	ScriptUpdateLayout();
	SetSPDStatsTitle();
	get_interfaces_file();
}

function SetGlobalDataset(txtchartname,dataobject){
	window[txtchartname] = dataobject;
	currentNoCharts++;
	if(currentNoCharts == maxNoCharts){
		if(interfacelist != ""){
			var interfacetextarray = interfacelist.split(',');
			for (i = 0; i < interfacetextarray.length; i++){
				Draw_Chart(interfacetextarray[i],"Combined");
				Draw_Chart(interfacetextarray[i],"Quality");
			}
		}
	}
}

function ScriptUpdateLayout(){
	var localver = GetVersionNumber("local");
	var serverver = GetVersionNumber("server");
	$j("#scripttitle").text($j("#scripttitle").text()+" - "+localver);
	$j("#spdmerlin_version_local").text(localver);
	
	if(localver != serverver && serverver != "N/A"){
		$j("#spdmerlin_version_server").text("Updated version available: "+serverver);
		showhide("btnChkUpdate", false);
		showhide("spdmerlin_version_server", true);
		showhide("btnDoUpdate", true);
	}
}

function reload(){
	location.reload(true);
}

function getChartPeriod(period){
	var chartperiod = "daily";
	if(period == 0) chartperiod = "daily";
	else if(period == 1) chartperiod = "weekly";
	else if(period == 2) chartperiod = "monthly";
	return chartperiod;
}

function ResetZoom(){
	if(interfacelist != ""){
		var interfacetextarray = interfacelist.split(',');
		for (i = 0; i < interfacetextarray.length; i++){
			for (i2 = 0; i2 < typelist.length; i2++){
				var chartobj = window["LineChart_"+interfacetextarray[i]+"_"+typelist[i2]];
				if(typeof chartobj === 'undefined' || chartobj === null){ continue; }
				chartobj.resetZoom();
			}
		}
	}
}

function ToggleDragZoom(button){
	var drag = true;
	var pan = false;
	var buttonvalue = "";
	if(button.value.indexOf("On") != -1){
		drag = false;
		pan = true;
		DragZoom = false;
		ChartPan = true;
		buttonvalue = "Drag Zoom Off";
	}
	else{
		drag = true;
		pan = false;
		DragZoom = true;
		ChartPan = false;
		buttonvalue = "Drag Zoom On";
	}
	
	if(interfacelist != ""){
		var interfacetextarray = interfacelist.split(',');
		for (i = 0; i < interfacetextarray.length; i++){
			for (i2 = 0; i2 < typelist.length; i2++){
				var chartobj = window["LineChart_"+interfacetextarray[i]+"_"+typelist[i2]];
				if(typeof chartobj === 'undefined' || chartobj === null){ continue; }
				chartobj.options.plugins.zoom.zoom.drag = drag;
				chartobj.options.plugins.zoom.pan.enabled = pan;
				chartobj.update();
			}
			button.value = buttonvalue;
		}
	}
}

function ExportCSV(){
	location.href = "/ext/spdmerlin/csv/spdmerlindata.zip";
	return 0;
}

function update_status(){
	$j.ajax({
		url: '/ext/spdmerlin/detect_update.js',
		dataType: 'script',
		timeout: 3000,
		error: function(xhr){
			setTimeout('update_status();', 1000);
		},
		success: function(){
			if(updatestatus == "InProgress"){
				setTimeout('update_status();', 1000);
			}
			else{
				document.getElementById("imgChkUpdate").style.display = "none";
				showhide("spdmerlin_version_server", true);
				if(updatestatus != "None"){
					$j("#spdmerlin_version_server").text("Updated version available: "+updatestatus);
					showhide("btnChkUpdate", false);
					showhide("btnDoUpdate", true);
				}
				else{
					$j("#spdmerlin_version_server").text("No update available");
					showhide("btnChkUpdate", true);
					showhide("btnDoUpdate", false);
				}
			}
		}
	});
}

function CheckUpdate(){
	showhide("btnChkUpdate", false);
	document.formScriptActions.action_script.value="start_spdmerlincheckupdate"
	document.formScriptActions.submit();
	document.getElementById("imgChkUpdate").style.display = "";
	setTimeout("update_status();", 2000);
}

function DoUpdate(){
	var action_script_tmp = "start_spdmerlindoupdate";
	document.form.action_script.value = action_script_tmp;
	var restart_time = 10;
	document.form.action_wait.value = restart_time;
	showLoading();
	document.form.submit();
}

function get_spdtest_file(){
	$j.ajax({
		url: '/ext/spdmerlin/spd-stats.htm',
		dataType: 'text',
		timeout: 1000,
		error: function(xhr){
			//do nothing
		},
		success: function(data){
			var lines = data.trim().split('\n');
			var arrlastLine = lines.slice(-1)[0].split('%').filter(Boolean);
			
			if(lines.length > 5){
				$j("#spdtest_output").html(lines[0] + '\n' + lines[1] + '\n' + lines[2] + '\n' + lines[3] + '\n' + lines[4] + '\n' + arrlastLine[arrlastLine.length-1] + "%");
			}
			else{
				$j("#spdtest_output").html("");
			}
		}
	});
}

function update_spdtest(){
	$j.ajax({
		url: '/ext/spdmerlin/detect_spdtest.js',
		dataType: 'script',
		timeout: 1000,
		error: function(xhr){
			//do nothing
		},
		success: function(){
			if(spdteststatus.indexOf("InProgress") != -1){
				if(spdteststatus.indexOf("_") != -1){
					showhide("imgSpdTest", true);
					showhide("spdtest_text", true);
					document.getElementById("spdtest_text").innerHTML = "Speedtest in progress for " + spdteststatus.substring(spdteststatus.indexOf("_")+1);
					document.getElementById("spdtest_output").parentElement.parentElement.style.display = "";
					get_spdtest_file();
				}
			}
			else if(spdteststatus == "Done"){
				document.getElementById("spdtest_text").innerHTML = "Refreshing tables and charts...";
				document.getElementById("spdtest_output").parentElement.parentElement.style.display = "none";
				setTimeout('PostSpeedTest();', 1000);
				clearInterval(myinterval);
			}
			else if(spdteststatus == "LOCKED"){
				showhide("imgSpdTest", false);
				document.getElementById("spdtest_text").innerHTML = "Scheduled speedtest already running!";
				showhide("spdtest_text", true);
				document.getElementById("spdtest_output").parentElement.parentElement.style.display = "none";
				showhide("btnRunSpeedtest", true);
				clearInterval(myinterval);
			}
			else if(spdteststatus == "NoLicense"){
				showhide("imgSpdTest", false);
				document.getElementById("spdtest_text").innerHTML = "Please accept Ookla license at command line via spdmerlin";
				showhide("spdtest_text", true);
				document.getElementById("spdtest_output").parentElement.parentElement.style.display = "none";
				showhide("btnRunSpeedtest", true);
				clearInterval(myinterval);
			}
			else if(spdteststatus == "Error"){
				showhide("imgSpdTest", false);
				document.getElementById("spdtest_text").innerHTML = "Error running speedtest";
				showhide("spdtest_text", true);
				document.getElementById("spdtest_output").parentElement.parentElement.style.display = "none";
				showhide("btnRunSpeedtest", true);
				clearInterval(myinterval);
			}
			else if(spdteststatus == "NoSwap"){
				showhide("imgSpdTest", false);
				document.getElementById("spdtest_text").innerHTML = "No Swap file configured/detected";
				showhide("spdtest_text", true);
				document.getElementById("spdtest_output").parentElement.parentElement.style.display = "none";
				showhide("btnRunSpeedtest", true);
				clearInterval(myinterval);
			}
		}
	});
}

function PostSpeedTest(){
	showhide("imgSpdTest", false);
	showhide("spdtest_text", false);
	showhide("btnRunSpeedtest", true);
	document.getElementById("table_allinterfaces").remove();
	currentNoCharts = 0;
	reload_js('/ext/spdmerlin/spdjs.js');
	$j("#Time_Format").val(GetCookie("Time_Format","number"));
	SetSPDStatsTitle();
	get_interfaces_file();
}

function RunSpeedtest(){
	showhide("btnRunSpeedtest", false);
	document.formScriptActions.action_script.value="start_spdmerlin";
	document.formScriptActions.submit();
	showhide("imgSpdTest", true);
	showhide("spdtest_text", false);
	setTimeout('StartSpeedTestInterval();', 1500);
}

var myinterval;
function StartSpeedTestInterval(){
	myinterval = setInterval("update_spdtest();", 400);
}

function reload_js(src){
	$j('script[src="' + src + '"]').remove();
	$j('<script>').attr('src', src+'?cachebuster='+ new Date().getTime()).appendTo('head');
}

function applyRule(){
	document.getElementById('amng_custom').value = JSON.stringify($j('form').serializeObject())
	var action_script_tmp = "start_spdmerlinconfig";
	document.form.action_script.value = action_script_tmp;
	var restart_time = 5;
	document.form.action_wait.value = restart_time;
	showLoading();
	document.form.submit();
}

function SaveInterfaces(){
	document.getElementById('amng_custom').value = JSON.stringify($j('form').serializeObjectInterfaces())
	var action_script_tmp = "start_spdmerlinconfiginterfaces";
	document.form.action_script.value = action_script_tmp;
	var restart_time = 5;
	document.form.action_wait.value = restart_time;
	showLoading();
	document.form.submit();
}

function GetVersionNumber(versiontype){
	var versionprop;
	if(versiontype == "local"){
		versionprop = custom_settings.spdmerlin_version_local;
	}
	else if(versiontype == "server"){
		versionprop = custom_settings.spdmerlin_version_server;
	}
	
	if(typeof versionprop == 'undefined' || versionprop == null){
		return "N/A";
	}
	else{
		return versionprop;
	}
}

function get_conf_file(){
	$j.ajax({
		url: '/ext/spdmerlin/config.htm',
		dataType: 'text',
		error: function(xhr){
			setTimeout("get_conf_file();", 1000);
		},
		success: function(data){
			var configdata=data.split("\n");
			configdata = configdata.filter(Boolean);
			
			for (var i = 0; i < configdata.length; i++){
				if(configdata[i].indexOf("OUTPUTDATAMODE") != -1){
					document.form.spdmerlin_outputdatamode.value=configdata[i].split("=")[1].replace(/(\r\n|\n|\r)/gm,"");
				}
				else if(configdata[i].indexOf("OUTPUTTIMEMODE") != -1){
					document.form.spdmerlin_outputtimemode.value=configdata[i].split("=")[1].replace(/(\r\n|\n|\r)/gm,"");
				}
				else if(configdata[i].indexOf("STORAGELOCATION") != -1){
					document.form.spdmerlin_storagelocation.value=configdata[i].split("=")[1].replace(/(\r\n|\n|\r)/gm,"");
				}
			}
		}
	});
}

function get_interfaces_file(){
	$j.ajax({
		url: '/ext/spdmerlin/interfaces_user.htm',
		dataType: 'text',
		error: function(xhr){
			setTimeout("get_interfaces_file();", 1000);
		},
		success: function(data){
			var interfaces=data.split("\n");
			
			interfaces=interfaces.filter(Boolean);
			interfacelist="";
			var interfacecharttablehtml='<div style="line-height:10px;">&nbsp;</div>';
			interfacecharttablehtml+='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="table_allinterfaces">';
			interfacecharttablehtml+='<thead class="collapsible-jquery" id="thead_allinterfaces">';
			interfacecharttablehtml+='<tr>';
			interfacecharttablehtml+='<td>Interfaces (click to expand/collapse)</td>';
			interfacecharttablehtml+='</tr>';
			interfacecharttablehtml+='</thead>';
			interfacecharttablehtml+='<tr><td align="center" style="padding: 0px;">';
			
			var interfaceconfigtablehtml='<div style="line-height:10px;">&nbsp;</div>';
			interfaceconfigtablehtml+='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable SettingsTable" id="table_configinterfaces">';
			interfaceconfigtablehtml+='<thead class="collapsible-jquery" id="thead_configinterfaces">';
			interfaceconfigtablehtml+='<tr>';
			interfaceconfigtablehtml+='<td colspan="2">Interface Configuration (click to expand/collapse)</td>';
			interfaceconfigtablehtml+='</tr>';
			interfaceconfigtablehtml+='</thead>';
			interfaceconfigtablehtml+='<tr>';
			interfaceconfigtablehtml+='<td class="settingname">Enabled for speedtest?</td><td class="settingvalue">';
			
			var interfacecount=interfaces.length;
			for (var i = 0; i < interfacecount; i++){
				var interfacename = "";
				if(interfaces[i].indexOf("#") != -1){
					interfacename = interfaces[i].substring(0,interfaces[i].indexOf("#")).trim();
					var interfacedisabled = "";
					var clickhint = "";
					if(interfaces[i].indexOf("interface not up") != -1){
						interfacedisabled = "disabled";
						clickhint="SettingHint(1);"
					}
					interfaceconfigtablehtml+='<input autocomplete="off" autocapitalize="off" type="checkbox" name="spdmerlin_iface_enabled" id="spdmerlin_iface_enabled_'+ interfacename.toLowerCase() +'" class="input ' + interfacedisabled + '" value="'+interfacename.toUpperCase()+'" ' + interfacedisabled + '>';
					interfaceconfigtablehtml+='<label for="spdmerlin_iface_enabled_'+ interfacename.toLowerCase() +'"><a class="hintstyle" href="javascript:void(0);" onclick="' + clickhint + '">'+interfacename.toUpperCase()+'</a></label>';
					continue
				}
				else{
					interfacename = interfaces[i].trim();
					interfaceconfigtablehtml+='<input autocomplete="off" autocapitalize="off" type="checkbox" name="spdmerlin_iface_enabled" id="spdmerlin_iface_enabled_'+ interfacename.toLowerCase() +'" class="input" value="'+interfacename.toUpperCase()+'" checked>';
					interfaceconfigtablehtml+='<label for="spdmerlin_iface_enabled_'+ interfacename.toLowerCase() +'">'+interfacename.toUpperCase()+'</label>';
				}
				
				interfacecharttablehtml += BuildInterfaceTable(interfacename);
				
				interfacelist+=interfacename+',';
			}
			
			interfacecharttablehtml+='</td>';
			interfacecharttablehtml+='</tr>';
			interfacecharttablehtml+='</table>';
			
			interfaceconfigtablehtml+='</td>';
			interfaceconfigtablehtml+='</tr>';
			interfaceconfigtablehtml+='<tr class="apply_gen" valign="top" height="35px">';
			interfaceconfigtablehtml+='<td colspan="2" style="background-color:rgb(77, 89, 93);">';
			interfaceconfigtablehtml+='<input type="button" onclick="SaveInterfaces();" value="Save" class="button_gen" name="button">';
			interfaceconfigtablehtml+='</td>';
			interfaceconfigtablehtml+='</tr>';
			interfaceconfigtablehtml+='</table>';
			
			$j("#table_buttons").after(interfaceconfigtablehtml);
			
			if(interfacelist.charAt(interfacelist.length-1) == ",") {
				interfacelist = interfacelist.slice(0, -1);
			}
			
			if(interfacelist != ""){
				$j("#table_buttons2").after(interfacecharttablehtml);
				maxNoCharts = interfacelist.split(',').length*3*2;
				AddEventHandlers();
				RedrawAllCharts();
				get_conf_file();
			}
		}
	});
}

function changeAllCharts(e){
	value = e.value * 1;
	name = e.id.substring(0, e.id.indexOf("_"));
	SetCookie(e.id,value);
	if(interfacelist != ""){
		var interfacetextarray = interfacelist.split(',');
		for (i = 0; i < interfacetextarray.length; i++){
			Draw_Chart(interfacetextarray[i],"Combined");
			Draw_Chart(interfacetextarray[i],"Quality");
		}
	}
}

function changeChart(e){
	value = e.value * 1;
	name = e.id.substring(0, e.id.indexOf("_"));
	SetCookie(e.id,value);
	if(e.id.indexOf("Combined") != -1){
		Draw_Chart(name,"Combined");
	}
	else if(e.id.indexOf("Quality") != -1){
		Draw_Chart(name,"Quality");
	}
}

function SettingHint(hintid) {
	var tag_name = document.getElementsByTagName('a');
	for (var i=0;i<tag_name.length;i++){
		tag_name[i].onmouseout=nd;
	}
	hinttext="My text goes here";
	if(hintid == 1) hinttext="Interface not enabled";
	return overlib(hinttext, CENTER);
}

function BuildInterfaceTable(name){
	var charthtml = '<div style="line-height:10px;">&nbsp;</div>';
	charthtml+='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="table_interfaces_'+name+'">';
	charthtml+='<thead class="collapsible-jquery" id="'+name+'">';
	charthtml+='<tr>';
	charthtml+='<td colspan="2">'+name+' (click to expand/collapse)</td>';
	charthtml+='</tr>';
	charthtml+='</thead>';
	charthtml+='<tr>';
	charthtml+='<td colspan="2" align="center" style="padding: 0px;">';
	charthtml+='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">';
	charthtml+='<thead class="collapsible-jquery" id="resulttable_'+name+'">';
	charthtml+='<tr><td colspan="2">Last 10 speedtest results (click to expand/collapse)</td></tr>';
	charthtml+='</thead>';
	charthtml+='<tr>';
	charthtml+='<td colspan="2" align="center" style="padding: 0px;">';
	charthtml+='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable StatsTable">';
	var nodata="";
	var objdataname = window["DataTimestamp_"+name];
	if(typeof objdataname === 'undefined' || objdataname === null){nodata="true"}
	else if(objdataname.length == 0){nodata="true"}
	else if(objdataname.length == 1 && objdataname[0] == ""){nodata="true"}
	
	if(nodata == "true"){
		charthtml+='<tr>';
		charthtml+='<td colspan="6" class="nodata">';
		charthtml+='No data to display';
		charthtml+='</td>';
		charthtml+='</tr>';
	} else{
		charthtml+='<col style="width:120px;">';
		charthtml+='<col style="width:120px;">';
		charthtml+='<col style="width:120px;">';
		charthtml+='<col style="width:120px;">';
		charthtml+='<col style="width:120px;">';
		charthtml+='<col style="width:120px;">';
		charthtml+='<thead>';
		charthtml+='<tr>';
		charthtml+='<th class="keystatsnumber">Time</th>';
		charthtml+='<th class="keystatsnumber">Download (Mbps)</th>';
		charthtml+='<th class="keystatsnumber">Upload (Mbps)</th>';
		charthtml+='<th class="keystatsnumber">Latency (ms)</th>';
		charthtml+='<th class="keystatsnumber">Jitter (ms)</th>';
		charthtml+='<th class="keystatsnumber">Packet Loss (%)</th>';
		charthtml+='</tr>';
		charthtml+='</thead>';
		
		for(i = 0; i < objdataname.length; i++){
			charthtml+='<tr>';
			charthtml+='<td>'+moment.unix(window["DataTimestamp_"+name][i]).format('YYYY-MM-DD HH:mm:ss')+'</td>';
			charthtml+='<td>'+window["DataDownload_"+name][i]+'</td>';
			charthtml+='<td>'+window["DataUpload_"+name][i]+'</td>';
			charthtml+='<td>'+window["DataLatency_"+name][i]+'</td>';
			charthtml+='<td>'+window["DataJitter_"+name][i]+'</td>';
			charthtml+='<td>'+window["DataPktLoss_"+name][i]+'</td>';
			charthtml+='</tr>';
		};
	}
	charthtml+='</table>';
	charthtml+='</td>';
	charthtml+='</tr>';
	charthtml+='</table>';
	charthtml+='<div style="line-height:10px;">&nbsp;</div>';
	charthtml+='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">';
	charthtml+='<thead class="collapsible-jquery" id="table_charts">';
	charthtml+='<tr>';
	charthtml+='<td>Tables and Charts (click to expand/collapse)</td>';
	charthtml+='</tr>';
	charthtml+='</thead>';
	charthtml+='<tr><td align="center" style="padding: 0px;">';
	charthtml+='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">';
	charthtml+='<thead class="collapsible-jquery" id="'+name+'_ChartCombined">';
	charthtml+='<tr>';
	charthtml+='<td colspan="2">Bandwidth (click to expand/collapse)</td>';
	charthtml+='</tr>';
	charthtml+='</thead>';
	charthtml+='<tr class="even">';
	charthtml+='<th width="40%">Period to display</th>';
	charthtml+='<td>';
	charthtml+='<select style="width:125px" class="input_option" onchange="changeChart(this)" id="' + name + '_Period_Combined">';
	charthtml+='<option value=0>Last 24 hours</option>';
	charthtml+='<option value=1>Last 7 days</option>';
	charthtml+='<option value=2>Last 30 days</option>';
	charthtml+='</select>';
	charthtml+='</td>';
	charthtml+='</tr>';
	charthtml+='<tr>';
	charthtml+='<td colspan="2" align="center" style="padding: 0px;">';
	charthtml+='<div style="background-color:#2f3e44;border-radius:10px;width:730px;height:500px;padding-left:5px;"><canvas id="divLineChart_'+name+'_Combined" height="500" /></div>';
	charthtml+='</td>';
	charthtml+='</tr>';
	charthtml+='</table>';
	charthtml+='<div style="line-height:10px;">&nbsp;</div>';
	charthtml+='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">';
	charthtml+='<thead class="collapsible-jquery" id="'+name+'_ChartQuality">';
	charthtml+='<tr>';
	charthtml+='<td colspan="2">Quality (click to expand/collapse)</td>';
	charthtml+='</tr>';
	charthtml+='</thead>';
	charthtml+='<tr class="even">';
	charthtml+='<th width="40%">Period to display</th>';
	charthtml+='<td>';
	charthtml+='<select style="width:125px" class="input_option" onchange="changeChart(this)" id="' + name + '_Period_Quality">';
	charthtml+='<option value=0>Last 24 hours</option>';
	charthtml+='<option value=1>Last 7 days</option>';
	charthtml+='<option value=2>Last 30 days</option>';
	charthtml+='</select>';
	charthtml+='</td>';
	charthtml+='</tr>';
	charthtml+='<tr>';
	charthtml+='<td colspan="2" align="center" style="padding: 0px;">';
	charthtml+='<div style="background-color:#2f3e44;border-radius:10px;width:730px;height:500px;padding-left:5px;"><canvas id="divLineChart_'+name+'_Quality" height="500" /></div>';
	charthtml+='</td>';
	charthtml+='</tr>';
	charthtml+='</table>';
	charthtml+='</td>';
	charthtml+='</tr>';
	charthtml+='</table>';
	charthtml+='</td>';
	charthtml+='</tr>';
	charthtml+='</table>';
	return charthtml;
}

function AddEventHandlers(){
	$j(".collapsible-jquery").click(function(){
		$j(this).siblings().toggle("fast",function(){
			if($j(this).css("display") == "none"){
				SetCookie($j(this).siblings()[0].id,"collapsed");
			}
			else{
				SetCookie($j(this).siblings()[0].id,"expanded");
			}
		})
	});
	
	$j(".collapsible-jquery").each(function(index,element){
		if(GetCookie($j(this)[0].id,"string") == "collapsed"){
			$j(this).siblings().toggle(false);
		}
		else{
			$j(this).siblings().toggle(true);
		}
	});
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
<tr><td colspan="2">General Configuration (click to expand/collapse)</td></tr>
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
