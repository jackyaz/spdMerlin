var $j = jQuery.noConflict(); //avoid conflicts on John's fork (state.js)
var daysofweek = ['Mon','Tues','Wed','Thurs','Fri','Sat','Sun'];
var maxNoCharts = 0;
var currentNoCharts = 0;

var interfacelist = '';
var interfacescomplete = [];
var interfacesdisabled = [];

var arraysortlistlinesWAN = [];
var sortfieldWAN = 'Time';
var sortnameWAN = 'Time';
var sortdirWAN = 'desc';
var arraysortlistlinesVPNC1 = [];
var sortfieldVPNC1 = 'Time';
var sortnameVPNC1 = 'Time';
var sortdirVPNC1 = 'desc';
var arraysortlistlinesVPNC2 = [];
var sortfieldVPNC2 = 'Time';
var sortnameVPNC2 = 'Time';
var sortdirVPNC2 = 'desc';
var arraysortlistlinesVPNC3 = [];
var sortfieldVPNC3 = 'Time';
var sortnameVPNC3 = 'Time';
var sortdirVPNC3 = 'desc';
var arraysortlistlinesVPNC4 = [];
var sortfieldVPNC4 = 'Time';
var sortnameVPNC4 = 'Time';
var sortdirVPNC4 = 'desc';
var arraysortlistlinesVPNC5 = [];
var sortfieldVPNC5 = 'Time';
var sortnameVPNC5 = 'Time';
var sortdirVPNC5 = 'desc';

var ShowLines = GetCookie('ShowLines','string');
var ShowFill = GetCookie('ShowFill','string');
if(ShowFill == ''){
	ShowFill = 'origin';
}

var DragZoom = true;
var ChartPan = false;

Chart.defaults.global.defaultFontColor = '#CCC';
Chart.Tooltip.positioners.cursor = function(chartElements,coordinates){
	return coordinates;
};

var dataintervallist = ['raw','hour','day'];
var chartlist = ['daily','weekly','monthly'];
var timeunitlist = ['hour','day','day'];
var intervallist = [24,7,30];
var bordercolourlist_Combined = ['#fc8500','#42ecf5'];
var backgroundcolourlist_Combined = ['rgba(252,133,0,0.5)','rgba(66,236,245,0.5)'];
var bordercolourlist_Quality = ['#53047a','#07f242','#ffffff'];
var backgroundcolourlist_Quality = ['rgba(83,4,122,0.5)','rgba(7,242,66,0.5)','rgba(255,255,255,0.5)'];

var typelist = ['Combined','Quality'];

function keyHandler(e){
	if(e.keyCode == 82){
		$j(document).off('keydown');
		ResetZoom();
	}
	else if(e.keyCode == 68){
		$j(document).off('keydown');
		ToggleDragZoom(document.form.btnDragZoom);
	}
	else if(e.keyCode == 70){
		$j(document).off('keydown');
		ToggleFill();
	}
	else if(e.keyCode == 76){
		$j(document).off('keydown');
		ToggleLines();
	}
}

$j(document).keydown(function(e){keyHandler(e);});
$j(document).keyup(function(e){
	$j(document).keydown(function(e){
		keyHandler(e);
	});
});

function Draw_Chart_NoData(txtchartname,txtcharttype,texttodisplay){
	document.getElementById('divLineChart_'+txtchartname+'_'+txtcharttype).width='730';
	document.getElementById('divLineChart_'+txtchartname+'_'+txtcharttype).height='500';
	document.getElementById('divLineChart_'+txtchartname+'_'+txtcharttype).style.width='730px';
	document.getElementById('divLineChart_'+txtchartname+'_'+txtcharttype).style.height='500px';
	var ctx = document.getElementById('divLineChart_'+txtchartname+'_'+txtcharttype).getContext('2d');
	ctx.save();
	ctx.textAlign = 'center';
	ctx.textBaseline = 'middle';
	ctx.font = 'normal normal bolder 48px Arial';
	ctx.fillStyle = 'white';
	ctx.fillText(texttodisplay,365,250);
	ctx.restore();
}

function Draw_Chart(txtchartname,txtcharttype){
	var txtunity = '';
	var txtunity2 = '';
	var txttitle = '';
	var metric0 = '';
	var metric1 = '';
	var metric2 = '';
	var showyaxis2 = false;
	
	if(txtcharttype == 'Combined'){
		txtunity = 'Mbps';
		txttitle = 'Bandwidth';
		metric0 = 'Download';
		metric1 = 'Upload';
	}
	else if(txtcharttype == 'Quality'){
		txtunity = 'ms';
		txtunity2 = '%';
		txttitle = 'Quality';
		metric0 = 'Latency';
		metric1 = 'Jitter';
		metric2 = 'PktLoss';
		showyaxis2 = true;
	}
	var chartperiod = getChartPeriod($j('#'+txtchartname+'_Period_'+txtcharttype+' option:selected').val());
	var chartinterval = getChartInterval($j('#'+txtchartname+'_Interval_'+txtcharttype+' option:selected').val());
	var txtunitx = timeunitlist[$j('#'+txtchartname+'_Period_'+txtcharttype+' option:selected').val()];
	var numunitx = intervallist[$j('#'+txtchartname+'_Period_'+txtcharttype+' option:selected').val()];
	var zoompanxaxismax = moment();
	var chartxaxismax = null;
	var chartxaxismin = moment().subtract(numunitx,txtunitx+'s');
	var charttype = 'line';
	var dataobject = window[txtcharttype+'_'+chartinterval+'_'+chartperiod+'_'+txtchartname];
	if(typeof dataobject === 'undefined' || dataobject === null){ Draw_Chart_NoData(txtchartname,txtcharttype,'No data to display'); return; }
	if(dataobject.length == 0){ Draw_Chart_NoData(txtchartname,txtcharttype,'No data to display'); return; }
	
	var chartData = dataobject.map(function(d){return {x: d.Time,y: d.Value}});
	
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
	}).map(function(d){return {x: d.Time,y: d.Value}});
	
	var chartData1 = dataobject.filter(function(item){
		return item.Metric == metric1;
	}).map(function(d){return {x: d.Time,y: d.Value}});
	
	var chartData2 = dataobject.filter(function(item){
		return item.Metric == metric2;
	}).map(function(d){return {x: d.Time,y: d.Value}});
	
	var objchartname=window['LineChart_'+txtchartname+'_'+txtcharttype];
	
	var timeaxisformat = getTimeFormat($j('#Time_Format option:selected').val(),'axis');
	var timetooltipformat = getTimeFormat($j('#Time_Format option:selected').val(),'tooltip');
	
	if(chartinterval == 'day'){
		charttype = 'bar';
		chartxaxismax = moment().endOf('day').subtract(9,'hours');
		chartxaxismin = moment().startOf('day').subtract(numunitx-1,txtunitx+'s').subtract(12,'hours');
		zoompanxaxismax = chartxaxismax;
	}

	if(chartperiod == 'daily' && chartinterval == 'day'){
		txtunitx = 'day';
		numunitx = 1;
		chartxaxismax = moment().endOf('day').subtract(9,'hours');
		chartxaxismin = moment().startOf('day').subtract(12,'hours');
		zoompanxaxismax = chartxaxismax;
	}
	
	factor=0;
	if(txtunitx=='hour'){
		factor=60*60*1000;
	}
	else if(txtunitx=='day'){
		factor=60*60*24*1000;
	}
	if(objchartname != undefined) objchartname.destroy();
	var ctx = document.getElementById('divLineChart_'+txtchartname+'_'+txtcharttype).getContext('2d');
	var lineOptions = {
		segmentShowStroke : false,
		segmentStrokeColor : '#000',
		animationEasing : 'easeOutQuart',
		animationSteps : 100,
		maintainAspectRatio: false,
		animateScale : true,
		hover: { mode: 'point' },
		legend: {
			display: true,
			position: 'top',
			reverse: true,
			onClick: function (e,legendItem){
				var index = legendItem.datasetIndex;
				var ci = this.chart;
				var meta = ci.getDatasetMeta(index);
				
				meta.hidden = meta.hidden === null ? !ci.data.datasets[index].hidden : null;
				
				if(ShowLines == 'line'){
					var annotationline = ''
					if(meta.hidden != true){
						annotationline = 'line';
					}
					
					if(ci.data.datasets[index].label == 'Latency' || ci.data.datasets[index].label == 'Download'){
						for(aindex = 0; aindex < 3; aindex++){
							ci.options.annotation.annotations[aindex].type=annotationline;
						}
					}
					else if(ci.data.datasets[index].label == 'Jitter' || ci.data.datasets[index].label == 'Upload'){
						for(aindex = 3; aindex < 6; aindex++){
							ci.options.annotation.annotations[aindex].type=annotationline;
						}
					}
					else if(ci.data.datasets[index].label == 'Packet Loss'){
						for(aindex = 6; aindex < 9; aindex++){
							ci.options.annotation.annotations[aindex].type=annotationline;
						}
					}
				}
				
				if(ci.data.datasets[index].label == 'Packet Loss'){
					var showaxis = false;
					if(meta.hidden != true){
						showaxis = true;
					}
					ci.scales['right-y-axis'].options.display = showaxis;
				}
				
				ci.update();
			}
		},
		title: { display: true,text: txttitle },
		tooltips: {
			callbacks: {
				title: function (tooltipItem,data){
					if(chartinterval == 'day'){
						return moment(tooltipItem[0].xLabel,'X').format('YYYY-MM-DD');
					}
					else{
						return moment(tooltipItem[0].xLabel,'X').format(timetooltipformat);
					}
				},
				label: function (tooltipItem,data){ var txtunitytip=txtunity; if(data.datasets[tooltipItem.datasetIndex].label == 'Packet Loss'){txtunitytip=txtunity2}; return round(data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index].y,2).toFixed(2)+' '+txtunitytip;}
			},
			itemSort: function(a,b){
				return b.datasetIndex - a.datasetIndex;
			},
			mode: 'point',
			position: 'cursor',
			intersect: true
		},
		scales: {
			xAxes: [{
				type: 'time',
				gridLines: { display: true,color: '#282828' },
				ticks: {
					min: chartxaxismin,
					max: chartxaxismax,
					display: true
				},
				time: {
					parser: 'X',
					unit: txtunitx,
					stepSize: 1,
					displayFormats: timeaxisformat
				}
			}],
			yAxes: [{
				type: getChartScale($j('#'+txtchartname+'_Scale_'+txtcharttype+' option:selected').val()),
				gridLines: { display: false,color: '#282828' },
				scaleLabel: { display: false,labelString: txtunity },
				id: 'left-y-axis',
				position: 'left',
				ticks: {
					display: true,
					beginAtZero: true,
					labels: {
						index:  ['min','max'],
						removeEmptyLines: true
					},
					userCallback: LogarithmicFormatter
				},
			},
			{
				type: getChartScale($j('#'+txtchartname+'_Scale_'+txtcharttype+' option:selected').val()),
				gridLines: { display: false,color: '#282828' },
				scaleLabel: { display: false,labelString: txtunity2 },
				id: 'right-y-axis',
				position: 'right',
				ticks: {
					display: showyaxis2,
					beginAtZero: true,
					labels: {
						index:  ['min','max'],
						removeEmptyLines: true
					},
					userCallback: LogarithmicFormatter
				},
			}]
		},
		plugins: {
			zoom: {
				pan: {
					enabled: ChartPan,
					mode: 'xy',
					rangeMin: {
						x: chartxaxismin,
						y: 0
					},
					rangeMax: {
						x: zoompanxaxismax//,
						//y: getLimit(chartData,'y','max',false)+getLimit(chartData,'y','max',false)*0.1
					},
				},
				zoom: {
					enabled: true,
					drag: DragZoom,
					mode: 'xy',
					rangeMin: {
						x: chartxaxismin,
						y: 0
					},
					rangeMax: {
						x: zoompanxaxismax//,
						//y: getLimit(chartData,'y','max',false)+getLimit(chartData,'y','max',false)*0.1
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
				borderColor: window['bordercolourlist_'+txtcharttype][0],
				borderWidth: 1,
				borderDash: [5,5],
				label: {
					backgroundColor: 'rgba(0,0,0,0.3)',
					fontFamily: 'sans-serif',
					fontSize: 10,
					fontStyle: 'bold',
					fontColor: '#fff',
					xPadding: 6,
					yPadding: 6,
					cornerRadius: 6,
					position: 'center',
					enabled: true,
					xAdjust: 0,
					yAdjust: 0,
					content: 'Avg. '+metric0+'='+round(getAverage(chartData0),2).toFixed(2)+txtunity
				}
			},
			{
				//id: 'maxline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'left-y-axis',
				value: getLimit(chartData0,'y','max',true),
				borderColor: window['bordercolourlist_'+txtcharttype][0],
				borderWidth: 1,
				borderDash: [5,5],
				label: {
					backgroundColor: 'rgba(0,0,0,0.3)',
					fontFamily: 'sans-serif',
					fontSize: 10,
					fontStyle: 'bold',
					fontColor: '#fff',
					xPadding: 6,
					yPadding: 6,
					cornerRadius: 6,
					position: 'right',
					enabled: true,
					xAdjust: 15,
					yAdjust: 0,
					content: 'Max. '+metric0+'='+round(getLimit(chartData0,'y','max',true),2).toFixed(2)+txtunity
				}
			},
			{
				//id: 'minline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'left-y-axis',
				value: getLimit(chartData0,'y','min',true),
				borderColor: window['bordercolourlist_'+txtcharttype][0],
				borderWidth: 1,
				borderDash: [5,5],
				label: {
					backgroundColor: 'rgba(0,0,0,0.3)',
					fontFamily: 'sans-serif',
					fontSize: 10,
					fontStyle: 'bold',
					fontColor: '#fff',
					xPadding: 6,
					yPadding: 6,
					cornerRadius: 6,
					position: 'left',
					enabled: true,
					xAdjust: 15,
					yAdjust: 0,
					content: 'Min. '+metric0+'='+round(getLimit(chartData0,'y','min',true),2).toFixed(2)+txtunity
				}
			},
			{
				//id: 'avgline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'left-y-axis',
				value: getAverage(chartData1),
				borderColor: window['bordercolourlist_'+txtcharttype][1],
				borderWidth: 1,
				borderDash: [5,5],
				label: {
					backgroundColor: 'rgba(0,0,0,0.3)',
					fontFamily: 'sans-serif',
					fontSize: 10,
					fontStyle: 'bold',
					fontColor: '#fff',
					xPadding: 6,
					yPadding: 6,
					cornerRadius: 6,
					position: 'center',
					enabled: true,
					xAdjust: 0,
					yAdjust: 0,
					content: 'Avg. '+metric1+'='+round(getAverage(chartData1),2).toFixed(2)+txtunity
				}
			},
			{
				//id: 'maxline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'left-y-axis',
				value: getLimit(chartData1,'y','max',true),
				borderColor: window['bordercolourlist_'+txtcharttype][1],
				borderWidth: 1,
				borderDash: [5,5],
				label: {
					backgroundColor: 'rgba(0,0,0,0.3)',
					fontFamily: 'sans-serif',
					fontSize: 10,
					fontStyle: 'bold',
					fontColor: '#fff',
					xPadding: 6,
					yPadding: 6,
					cornerRadius: 6,
					position: 'right',
					enabled: true,
					xAdjust: 15,
					yAdjust: 0,
					content: 'Max. '+metric1+'='+round(getLimit(chartData1,'y','max',true),2).toFixed(2)+txtunity
				}
			},
			{
				//id: 'minline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'left-y-axis',
				value: getLimit(chartData1,'y','min',true),
				borderColor: window['bordercolourlist_'+txtcharttype][1],
				borderWidth: 1,
				borderDash: [5,5],
				label: {
					backgroundColor: 'rgba(0,0,0,0.3)',
					fontFamily: 'sans-serif',
					fontSize: 10,
					fontStyle: 'bold',
					fontColor: '#fff',
					xPadding: 6,
					yPadding: 6,
					cornerRadius: 6,
					position: 'left',
					enabled: true,
					xAdjust: 15,
					yAdjust: 0,
					content: 'Min. '+metric1+'='+round(getLimit(chartData1,'y','min',true),2).toFixed(2)+txtunity
				}
			},
			{
				//id: 'avgline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'right-y-axis',
				value: getAverage(chartData2),
				borderColor: window['bordercolourlist_'+txtcharttype][2],
				borderWidth: 1,
				borderDash: [5,5],
				label: {
					backgroundColor: 'rgba(0,0,0,0.3)',
					fontFamily: 'sans-serif',
					fontSize: 10,
					fontStyle: 'bold',
					fontColor: '#fff',
					xPadding: 6,
					yPadding: 6,
					cornerRadius: 6,
					position: 'center',
					enabled: true,
					xAdjust: 0,
					yAdjust: 0,
					content: 'Avg. '+metric2+'='+round(getAverage(chartData2),2).toFixed(2)+txtunity2
				}
			},
			{
				//id: 'maxline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'right-y-axis',
				value: getLimit(chartData2,'y','max',true),
				borderColor: window['bordercolourlist_'+txtcharttype][2],
				borderWidth: 1,
				borderDash: [5,5],
				label: {
					backgroundColor: 'rgba(0,0,0,0.3)',
					fontFamily: 'sans-serif',
					fontSize: 10,
					fontStyle: 'bold',
					fontColor: '#fff',
					xPadding: 6,
					yPadding: 6,
					cornerRadius: 6,
					position: 'right',
					enabled: true,
					xAdjust: 15,
					yAdjust: 0,
					content: 'Max. '+metric2+'='+round(getLimit(chartData2,'y','max',true),2).toFixed(2)+txtunity2
				}
			},
			{
				//id: 'minline',
				type: ShowLines,
				mode: 'horizontal',
				scaleID: 'right-y-axis',
				value: getLimit(chartData2,'y','min',true),
				borderColor: window['bordercolourlist_'+txtcharttype][2],
				borderWidth: 1,
				borderDash: [5,5],
				label: {
					backgroundColor: 'rgba(0,0,0,0.3)',
					fontFamily: 'sans-serif',
					fontSize: 10,
					fontStyle: 'bold',
					fontColor: '#fff',
					xPadding: 6,
					yPadding: 6,
					cornerRadius: 6,
					position: 'left',
					enabled: true,
					xAdjust: 15,
					yAdjust: 0,
					content: 'Min. '+metric2+'='+round(getLimit(chartData2,'y','min',true),2).toFixed(2)+txtunity2
				}
			}
		]}
	};
	var lineDataset = {
		datasets: getDataSets(txtcharttype,dataobject,chartTrafficTypes)
	};
	objchartname = new Chart(ctx,{
		type: charttype,
		options: lineOptions,
		data: lineDataset
	});
	window['LineChart_'+txtchartname+'_'+txtcharttype]=objchartname;
}

function LogarithmicFormatter(tickValue,index,ticks){
	var unit = this.options.scaleLabel.labelString;
	if(this.type != 'logarithmic'){
		if(! isNaN(tickValue)){
			return round(tickValue,2).toFixed(2)+' '+unit;
		}
		else{
			return tickValue+' '+unit;
		}
	}
	else{
		var labelOpts =  this.options.ticks.labels || {};
		var labelIndex = labelOpts.index || ['min','max'];
		var labelSignificand = labelOpts.significand || [1,2,5];
		var significand = tickValue / (Math.pow(10,Math.floor(Chart.helpers.log10(tickValue))));
		var emptyTick = labelOpts.removeEmptyLines === true ? undefined : '';
		var namedIndex = '';
		if(index === 0){
			namedIndex = 'min';
		}
		else if(index === ticks.length - 1){
			namedIndex = 'max';
		}
		if(labelOpts === 'all' || labelSignificand.indexOf(significand) !== -1 || labelIndex.indexOf(index) !== -1 || labelIndex.indexOf(namedIndex) !== -1){
			if(tickValue === 0){
				return '0'+' '+unit;
			}
			else{
				if(! isNaN(tickValue)){
					return round(tickValue,2).toFixed(2)+' '+unit;
				}
				else{
					return tickValue+' '+unit;
				}
			}
		}
		return emptyTick;
	}
};

function getDataSets(charttype,objdata,objTrafficTypes){
	var datasets = [];
	colourname='#fc8500';
	
	for(var i = 0; i < objTrafficTypes.length; i++){
		var traffictypedata = objdata.filter(function(item){
			return item.Metric == objTrafficTypes[i];
		}).map(function(d){return {x: d.Time,y: d.Value}});
		var axisid = 'left-y-axis';
		if(objTrafficTypes[i] == 'PktLoss'){
			axisid = 'right-y-axis';
		}
		
		datasets.push({ label: objTrafficTypes[i].replace('PktLoss','Packet Loss'),data: traffictypedata,yAxisID: axisid,borderWidth: 1,pointRadius: 1,lineTension: 0,fill: ShowFill,backgroundColor: window['backgroundcolourlist_'+charttype][i],borderColor: window['bordercolourlist_'+charttype][i]});
	}
	datasets.reverse();
	return datasets;
}

function getLimit(datasetname,axis,maxmin,isannotation){
	var limit=0;
	var values;
	if(axis == 'x'){
		values = datasetname.map(function(o){ return o.x } );
	}
	else{
		values = datasetname.map(function(o){ return o.y } );
	}
	
	if(maxmin == 'max'){
		limit=Math.max.apply(Math,values);
	}
	else{
		limit=Math.min.apply(Math,values);
	}
	if(maxmin == 'max' && limit == 0 && isannotation == false){
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

function round(value,decimals){
	return Number(Math.round(value+'e'+decimals)+'e-'+decimals);
}

function ToggleLines(){
	var interfacetextarray = interfacelist.split(',');
	if(ShowLines == ''){
		ShowLines = 'line';
		SetCookie('ShowLines','line');
	}
	else{
		ShowLines = '';
		SetCookie('ShowLines','');
	}
	for(var i = 0; i < interfacetextarray.length; i++){
		for(var i2 = 0; i2 < typelist.length; i2++){
			var chartobj = window['LineChart_'+interfacetextarray[i]+'_'+typelist[i2]];
			if(typeof chartobj === 'undefined' || chartobj === null){ continue; }
			var maxlines = 6;
			if(typelist[i2] == 'Quality'){
				maxlines = 9;
			}
			for(var i3 = 0; i3 < maxlines; i3++){
				chartobj.options.annotation.annotations[i3].type=ShowLines;
			}
			chartobj.update();
		}
	}
}

function ToggleFill(){
	var interfacetextarray = interfacelist.split(',');
	if(ShowFill == 'origin'){
		ShowFill = 'false';
		SetCookie('ShowFill','false');
	}
	else{
		ShowFill = 'origin';
		SetCookie('ShowFill','origin');
	}
	
	for(var i = 0; i < interfacetextarray.length; i++){
		for(var i2 = 0; i2 < typelist.length; i2++){
			var chartobj = window['LineChart_'+interfacetextarray[i]+'_'+typelist[i2]];
			if(typeof chartobj === 'undefined' || chartobj === null){ continue; }
			chartobj.data.datasets[0].fill=ShowFill;
			chartobj.data.datasets[1].fill=ShowFill;
			if(typelist[i2] == 'Quality'){
				chartobj.data.datasets[2].fill=ShowFill;
			}
			chartobj.update();
		}
	}
}

function RedrawAllCharts(){
	var interfacetextarray = interfacelist.split(',');
	var i;
	for(var i2 = 0; i2 < chartlist.length; i2++){
		for(var i3 = 0; i3 < interfacetextarray.length; i3++){
			Draw_Chart_NoData(interfacetextarray[i3],'Combined','Data loading...');
			Draw_Chart_NoData(interfacetextarray[i3],'Quality','Data loading...');
			for(var i4 = 0; i4 < dataintervallist.length; i4++){
				d3.csv('/ext/spdmerlin/csv/Combined'+'_'+dataintervallist[i4]+'_'+chartlist[i2]+'_'+interfacetextarray[i3]+'.htm').then(SetGlobalDataset.bind(null,'Combined_'+dataintervallist[i4]+'_'+chartlist[i2]+'_'+interfacetextarray[i3]));
				d3.csv('/ext/spdmerlin/csv/Quality'+'_'+dataintervallist[i4]+'_'+chartlist[i2]+'_'+interfacetextarray[i3]+'.htm').then(SetGlobalDataset.bind(null,'Quality_'+dataintervallist[i4]+'_'+chartlist[i2]+'_'+interfacetextarray[i3]));
			}
		}
	}
}

function SetGlobalDataset(txtchartname,dataobject){
	window[txtchartname] = dataobject;
	currentNoCharts++;
	if(currentNoCharts == maxNoCharts){
		var interfacetextarray = interfacelist.split(',');
		for(var i = 0; i < interfacetextarray.length; i++){
			$j('#'+interfacetextarray[i]+'_Interval_Combined').val(GetCookie(interfacetextarray[i]+'_Interval_Combined','number'));
			$j('#'+interfacetextarray[i]+'_Interval_Quality').val(GetCookie(interfacetextarray[i]+'_Interval_Quality','number'));
			changePeriod(document.getElementById(interfacetextarray[i]+'_Interval_Combined'));
			changePeriod(document.getElementById(interfacetextarray[i]+'_Interval_Quality'));
			$j('#'+interfacetextarray[i]+'_Period_Combined').val(GetCookie(interfacetextarray[i]+'_Period_Combined','number'));
			$j('#'+interfacetextarray[i]+'_Period_Quality').val(GetCookie(interfacetextarray[i]+'_Period_Quality','number'));
			$j('#'+interfacetextarray[i]+'_Scale_Combined').val(GetCookie(interfacetextarray[i]+'_Scale_Combined','number'));
			$j('#'+interfacetextarray[i]+'_Scale_Quality').val(GetCookie(interfacetextarray[i]+'_Scale_Quality','number'));
			Draw_Chart(interfacetextarray[i],'Combined');
			Draw_Chart(interfacetextarray[i],'Quality');
		}
	}
}

function getTimeFormat(value,format){
	var timeformat;
	
	if(format == 'axis'){
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
	else if(format == 'tooltip'){
		if(value == 0){
			timeformat = 'YYYY-MM-DD HH:mm:ss';
		}
		else if(value == 1){
			timeformat = 'YYYY-MM-DD h:mm:ss A';
		}
	}
	
	return timeformat;
}

function GetCookie(cookiename,returntype){
	if(cookie.get('spd_'+cookiename) != null){
		return cookie.get('spd_'+cookiename);
	}
	else{
		if(returntype == 'string'){
			return '';
		}
		else if(returntype == 'number'){
			return 0;
		}
	}
}

function SetCookie(cookiename,cookievalue){
	cookie.set('spd_'+cookiename,cookievalue,10 * 365);
}

$j.fn.serializeObject = function(){
	var o = custom_settings;
	var a = this.serializeArray();
	$j.each(a,function(){
		if(o[this.name] !== undefined && this.name.indexOf('spdmerlin') != -1 && this.name.indexOf('version') == -1 && this.name.indexOf('spdmerlin_iface_enabled') == -1 && this.name.indexOf('spdmerlin_usepreferred') == -1 && this.name.indexOf('schdays') == -1 && this.name.indexOf('spdmerlin_preferredserver') == -1){
			if(!o[this.name].push){
				o[this.name] = [o[this.name]];
			}
			o[this.name].push(this.value || '');
		} else if(this.name.indexOf('spdmerlin') != -1 && this.name.indexOf('version') == -1 && this.name.indexOf('spdmerlin_iface_enabled') == -1 && this.name.indexOf('spdmerlin_usepreferred') == -1 && this.name.indexOf('schdays') == -1 && this.name.indexOf('spdmerlin_preferredserver') == -1){
			o[this.name] = this.value || '';
		}
	});
	
	$j.each(a,function(){
		if(o[this.name] !== undefined && this.name.indexOf('spdmerlin_preferredserver') != -1){
			if(!o[this.name].push){
				o[this.name] = [o[this.name]];
			}
			o[this.name].push(this.value || '');
		} else if(this.name.indexOf('spdmerlin_preferredserver') != -1){
			o[this.name] = this.value || '';
		}
	});
	
	
	var schdays = [];
	$j.each($j('input[name="spdmerlin_schdays"]:checked'),function(){
		schdays.push($j(this).val());
	});
	var schdaysstring = schdays.join(',');
	if(schdaysstring == 'Mon,Tues,Wed,Thurs,Fri,Sat,Sun'){
		schdaysstring = '*';
	}
	o['spdmerlin_schdays'] = schdaysstring;
	
	$j.each($j('input[name^="spdmerlin_usepreferred"]'),function(){
		o[this.id] = this.checked.toString();
	});
	
	var ifacesenabled = [];
	$j.each($j('input[name="spdmerlin_iface_enabled"]:checked'),function(){
		ifacesenabled.push(this.value);
	});
	var ifacesenabledstring = ifacesenabled.join(',');
	o['spdmerlin_ifaces_enabled'] = ifacesenabledstring;
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
	$j('#Time_Format').val(GetCookie('Time_Format','number'));
	ScriptUpdateLayout();
	get_statstitle_file();
	get_interfaces_file();
}

function ScriptUpdateLayout(){
	var localver = GetVersionNumber('local');
	var serverver = GetVersionNumber('server');
	$j('#spdmerlin_version_local').text(localver);
	
	if(localver != serverver && serverver != 'N/A'){
		$j('#spdmerlin_version_server').text('Updated version available: '+serverver);
		showhide('btnChkUpdate',false);
		showhide('spdmerlin_version_server',true);
		showhide('btnDoUpdate',true);
	}
}

function reload(){
	location.reload(true);
}

function getYAxisMax(chartname){
	if(chartname.indexOf('Quality') != -1){
		return 100;
	}
}

function getChartInterval(layout){
	var charttype = 'raw';
	if(layout == 0) charttype = 'raw';
	else if(layout == 1) charttype = 'hour';
	else if(layout == 2) charttype = 'day';
	return charttype;
}

function changePeriod(e){
	var value = e.value * 1;
	var name = e.id.substring(0,e.id.indexOf('_'));
	var type = e.id.substring(e.id.lastIndexOf('_')+1);
	
	if(value == 2){
		$j('select[id="'+name+'_Period_'+type+'"] option:contains(24)').text("Today");
	}
	else{
		$j('select[id="'+name+'_Period_'+type+'"] option:contains("Today")').text("Last 24 hours");
	}
}

function getChartPeriod(period){
	var chartperiod = 'daily';
	if(period == 0) chartperiod = 'daily';
	else if(period == 1) chartperiod = 'weekly';
	else if(period == 2) chartperiod = 'monthly';
	return chartperiod;
}

function getChartScale(scale){
	var chartscale = '';
	if(scale == 0){
		chartscale = 'linear';
	}
	else if(scale == 1){
		chartscale = 'logarithmic';
	}
	return chartscale;
}

function ResetZoom(){
	var interfacetextarray = interfacelist.split(',');
	for(var i = 0; i < interfacetextarray.length; i++){
		for(var i2 = 0; i2 < typelist.length; i2++){
			var chartobj = window['LineChart_'+interfacetextarray[i]+'_'+typelist[i2]];
			if(typeof chartobj === 'undefined' || chartobj === null){ continue; }
			chartobj.resetZoom();
		}
	}
}

function ToggleDragZoom(button){
	var drag = true;
	var pan = false;
	var buttonvalue = '';
	if(button.value.indexOf('On') != -1){
		drag = false;
		pan = true;
		DragZoom = false;
		ChartPan = true;
		buttonvalue = 'Drag Zoom Off';
	}
	else{
		drag = true;
		pan = false;
		DragZoom = true;
		ChartPan = false;
		buttonvalue = 'Drag Zoom On';
	}
	
	var interfacetextarray = interfacelist.split(',');
	for(var i = 0; i < interfacetextarray.length; i++){
		for(var i2 = 0; i2 < typelist.length; i2++){
			var chartobj = window['LineChart_'+interfacetextarray[i]+'_'+typelist[i2]];
			if(typeof chartobj === 'undefined' || chartobj === null){ continue; }
			chartobj.options.plugins.zoom.zoom.drag = drag;
			chartobj.options.plugins.zoom.pan.enabled = pan;
			chartobj.update();
		}
		button.value = buttonvalue;
	}
}

function ExportCSV(){
	location.href = '/ext/spdmerlin/csv/spdmerlindata.zip';
	return 0;
}

function update_status(){
	$j.ajax({
		url: '/ext/spdmerlin/detect_update.js',
		dataType: 'script',
		error: function(xhr){
			setTimeout(update_status,1000);
		},
		success: function(){
			if(updatestatus == 'InProgress'){
				setTimeout(update_status,1000);
			}
			else{
				document.getElementById('imgChkUpdate').style.display = 'none';
				showhide('spdmerlin_version_server',true);
				if(updatestatus != 'None'){
					$j('#spdmerlin_version_server').text('Updated version available: '+updatestatus);
					showhide('btnChkUpdate',false);
					showhide('btnDoUpdate',true);
				}
				else{
					$j('#spdmerlin_version_server').text('No update available');
					showhide('btnChkUpdate',true);
					showhide('btnDoUpdate',false);
				}
			}
		}
	});
}

function CheckUpdate(){
	showhide('btnChkUpdate',false);
	document.formScriptActions.action_script.value='start_spdmerlincheckupdate'
	document.formScriptActions.submit();
	document.getElementById('imgChkUpdate').style.display = '';
	setTimeout(update_status,2000);
}

function DoUpdate(){
	document.form.action_script.value = 'start_spdmerlindoupdate';
	document.form.action_wait.value = 10;
	showLoading();
	document.form.submit();
}

function getAllIndexes(arr,val){
	var indexes = [];
	for(var i = 0; i < arr.length; i++){
		if(arr[i].id == val){
			indexes.push(i);
		}
	}
	return indexes;
}

function get_spdtestservers_file(ifacename){
	$j.ajax({
		url: '/ext/spdmerlin/spdmerlin_serverlist_'+ifacename.toUpperCase()+'.htm?cachebuster='+new Date().getTime(),
		dataType: 'text',
		error: function(xhr){
			setTimeout(get_spdtestservers_file,1000,ifacename);
		},
		success: function(data){
			var servers = [];
			$j.each(data.split('\n').filter(Boolean),function (key,entry){
				var obj = {};
				obj['id'] = entry.split('|')[0];
				obj['name'] = entry.split('|')[1];
				servers.push(obj);
			});
			
			$j('#spdmerlin_preferredserver_'+ifacename).prop('disabled',false);
			$j('#spdmerlin_preferredserver_'+ifacename).removeClass('disabled');
			
			let dropdown = $j('#spdmerlin_preferredserver_'+ifacename);
			dropdown.empty();
			$j.each(servers,function (key,entry){
				dropdown.append($j('<option></option>').attr('value',entry.id+'|'+entry.name).text(entry.id+'|'+entry.name));
			});
			dropdown.prop('selectedIndex',0);
			
			$j('#spdmerlin_preferredserver_'+ifacename)[0].style.display = '';
			showhide('imgServerList_'+ifacename,false);
		}
	});
}

function get_manualspdtestservers_file(){
	$j.ajax({
		url: '/ext/spdmerlin/spdmerlin_manual_serverlist.htm?cachebuster='+new Date().getTime(),
		dataType: 'text',
		error: function(xhr){
			setTimeout(get_manualspdtestservers_file,2000);
		},
		success: function(data){
			var servers = [];
			$j.each(data.split('\n').filter(Boolean),function (key,entry){
				var obj = {};
				obj['id'] = entry.split('|')[0];
				obj['name'] = entry.split('|')[1];
				servers.push(obj);
			});
			
			if(document.form.spdtest_enabled.value == 'All'){
				var arrifaceindex = getAllIndexes(servers,'-----');
				for(var i = 0; i < arrifaceindex.length; i++){
					let dropdown = $j($j('select[name^=spdtest_serverprefselect]')[i]);
					dropdown.empty();
					var arrtmp = [];
					if(i == 0){
						arrtmp = servers.slice(0,arrifaceindex[i]);
					}
					else if(i == arrifaceindex.length-1){
						arrtmp = servers.slice(arrifaceindex[i-1]+1,servers.length-1);
					}
					else{
						arrtmp = servers.slice(arrifaceindex[i-1]+1,arrifaceindex[i]);
					}
					$j.each(arrtmp,function (key,entry){
						dropdown.append($j('<option></option>').attr('value',entry.id+'|'+entry.name).text(entry.id+'|'+entry.name));
					});
					dropdown.prop('selectedIndex',0);
				}
				
				$j.each($j('select[name^=spdtest_serverprefselect]'),function(){
					this.style.display = 'inline-block';
				});
				$j.each($j('span[id^=spdtest_serverprefselectspan]'),function(){
					this.style.display = 'inline-block';
				});
				showhide('imgManualServerList',false);
			}
			else{
				let dropdown = $j('select[name=spdtest_serverprefselect]');
				dropdown.empty();
				$j.each(servers,function (key,entry){
					dropdown.append($j('<option></option>').attr('value',entry.id+'|'+entry.name).text(entry.id+'|'+entry.name));
				});
				dropdown.prop('selectedIndex',0);
				showhide('spdtest_serverprefselect',true);
				showhide('imgManualServerList',false);
			}
			for(var i = 0; i < interfacescomplete.length; i++){
				if(interfacesdisabled.includes(interfacescomplete[i]) == false){
					$j('#spdtest_enabled_'+interfacescomplete[i].toLowerCase()).prop('disabled',false);
					$j('#spdtest_enabled_'+interfacescomplete[i].toLowerCase()).removeClass('disabled');
				}
			}
			$j.each($j('input[name=spdtest_serverpref]'),function(){
				$j(this).prop('disabled',false);
				$j(this).removeClass('disabled');
			});
		}
	});
}

function get_spdtestresult_file(){
	$j.ajax({
		url: '/ext/spdmerlin/spd-result.htm',
		dataType: 'text',
		error: function(xhr){
			setTimeout(get_spdtestresult_file,500);
		},
		success: function(data){
			var lines = data.trim().split('\n');
			data = lines.join('\n');
			$j('#spdtest_output').html(data);
			PostSpeedTest();
		}
	});
}

function get_spdtest_file(){
	$j.ajax({
		url: '/ext/spdmerlin/spd-stats.htm',
		dataType: 'text',
		error: function(xhr){
			//do nothing
		},
		success: function(data){
			var lines = data.trim().split('\n');
			var arrlastLine = lines.slice(-1)[0].split('%').filter(Boolean);
			
			if(lines.length > 5){
				$j('#spdtest_output').html(lines[0]+'\n'+lines[1]+'\n'+lines[2]+'\n'+lines[3]+'\n'+lines[4]+'\n'+arrlastLine[arrlastLine.length-1]+'%');
			}
			else{
				$j('#spdtest_output').html('');
			}
		}
	});
}

function update_spdtest(){
	$j.ajax({
		url: '/ext/spdmerlin/detect_spdtest.js',
		dataType: 'script',
		error: function(xhr){
			//do nothing
		},
		success: function(){
			if(spdteststatus.indexOf('InProgress') != -1){
				if(spdteststatus.indexOf('_') != -1){
					showhide('imgSpdTest',true);
					showhide('spdtest_text',true);
					document.getElementById('spdtest_text').innerHTML = 'Speedtest in progress for '+spdteststatus.substring(spdteststatus.indexOf('_')+1);
					document.getElementById('spdtest_output').parentElement.parentElement.style.display = '';
					get_spdtest_file();
				}
			}
			else if(spdteststatus == 'GenerateCSV'){
				document.getElementById('spdtest_text').innerHTML = 'Retrieving data for charts...';
			}
			else if(spdteststatus == 'Done'){
				clearInterval(myinterval);
				if(intervalclear == false){
					intervalclear = true;
					document.getElementById('spdtest_text').innerHTML = 'Refreshing tables and charts...';
					get_spdtestresult_file();
				}
			}
			else if(spdteststatus == 'LOCKED'){
				clearInterval(myinterval);
				showhide('imgSpdTest',false);
				document.getElementById('spdtest_text').innerHTML = 'Scheduled speedtest already running!';
				showhide('spdtest_text',true);
				document.getElementById('spdtest_output').parentElement.parentElement.style.display = 'none';
				showhide('btnRunSpeedtest',true);
			}
			else if(spdteststatus == 'NoLicense'){
				clearInterval(myinterval);
				showhide('imgSpdTest',false);
				document.getElementById('spdtest_text').innerHTML = 'Please accept Ookla license at command line via spdmerlin';
				showhide('spdtest_text',true);
				document.getElementById('spdtest_output').parentElement.parentElement.style.display = 'none';
				showhide('btnRunSpeedtest',true);
			}
			else if(spdteststatus == 'Error'){
				clearInterval(myinterval);
				showhide('imgSpdTest',false);
				document.getElementById('spdtest_text').innerHTML = 'Error running speedtest';
				showhide('spdtest_text',true);
				document.getElementById('spdtest_output').parentElement.parentElement.style.display = 'none';
				showhide('btnRunSpeedtest',true);
			}
			else if(spdteststatus == 'NoSwap'){
				clearInterval(myinterval);
				showhide('imgSpdTest',false);
				document.getElementById('spdtest_text').innerHTML = 'No Swap file configured/detected';
				showhide('spdtest_text',true);
				document.getElementById('spdtest_output').parentElement.parentElement.style.display = 'none';
				showhide('btnRunSpeedtest',true);
			}
		}
	});
}

function PostSpeedTest(){
	$j('#table_allinterfaces').empty();
	$j('#rowautomaticspdtest').empty();
	$j('#rowautospdprefserver').empty();
	$j('#rowautospdprefserverselect').empty();
	$j('#rowmanualspdtest').empty();
	$j('#table_allinterfaces').remove();
	$j('#rowautomaticspdtest').remove();
	$j('#rowautospdprefserver').remove();
	$j('#rowautospdprefserverselect').remove();
	$j('#rowmanualspdtest').remove();
	currentNoCharts = 0;
	$j('#Time_Format').val(GetCookie('Time_Format','number'));
	get_statstitle_file();
	setTimeout(get_interfaces_file,3000);
}

function RunSpeedtest(){
	showhide('btnRunSpeedtest',false);
	$j('#spdtest_output').html('');
	
	var spdtestservers = '';
	if(document.form.spdtest_serverpref.value == 'onetime'){
		if(document.form.spdtest_enabled.value == 'All'){
			$j.each($j('select[name^=spdtest_serverprefselect]'),function(){
				spdtestservers += this.value.substring(0,this.value.indexOf('|'))+'+';
			});
			spdtestservers = spdtestservers.slice(0,-1);
		}
		else{
			spdtestservers = document.form.spdtest_serverprefselect.value.substring(0,document.form.spdtest_serverprefselect.value.indexOf('|'));
		}
	}
	document.formScriptActions.action_script.value='start_spdmerlinspdtest_'+document.form.spdtest_serverpref.value+'_'+document.form.spdtest_enabled.value+'_'+spdtestservers.replace(/ /g,'%');
	document.formScriptActions.submit();
	showhide('imgSpdTest',true);
	showhide('spdtest_text',false);
	setTimeout(StartSpeedTestInterval,2000);
}

var myinterval;
var intervalclear = false;
function StartSpeedTestInterval(){
	intervalclear = false;
	myinterval = setInterval(update_spdtest,500);
}

function SaveConfig(){
	if(Validate_All()){
		$j('[name*=spdmerlin_]').prop('disabled',false);
		for(var i = 0; i < interfacescomplete.length; i++){
			$j('#spdmerlin_iface_enabled_'+interfacescomplete[i].toLowerCase()).prop('disabled',false);
			$j('#spdmerlin_iface_enabled_'+interfacescomplete[i].toLowerCase()).removeClass('disabled');
			$j('#spdmerlin_usepreferred_'+interfacescomplete[i].toLowerCase()).prop('disabled',false);
			$j('#spdmerlin_usepreferred_'+interfacescomplete[i].toLowerCase()).removeClass('disabled');
			$j('#changepref_'+interfacescomplete[i].toLowerCase()).prop('disabled',false);
			$j('#changepref_'+interfacescomplete[i].toLowerCase()).removeClass('disabled');
		}
		if(document.form.schedulemode.value == 'EveryX'){
			if(document.form.everyxselect.value == 'hours'){
				var everyxvalue = document.form.everyxvalue.value*1;
				document.form.spdmerlin_schmins.value = 0;
				if(everyxvalue == 24){
					document.form.spdmerlin_schhours.value = 0;
				}
				else{
					document.form.spdmerlin_schhours.value = '*/'+everyxvalue;
				}
			}
			else if(document.form.everyxselect.value == 'minutes'){
				document.form.spdmerlin_schhours.value = '*';
				var everyxvalue = document.form.everyxvalue.value*1;
				document.form.spdmerlin_schmins.value = '*/'+everyxvalue;
			}
		}
		document.getElementById('amng_custom').value = JSON.stringify($j('form').serializeObject());
		document.form.action_script.value = 'start_spdmerlinconfig';
		document.form.action_wait.value = 10;
		showLoading();
		document.form.submit();
	}
	else{
		return false;
	}
}

function GetVersionNumber(versiontype){
	var versionprop;
	if(versiontype == 'local'){
		versionprop = custom_settings.spdmerlin_version_local;
	}
	else if(versiontype == 'server'){
		versionprop = custom_settings.spdmerlin_version_server;
	}
	
	if(typeof versionprop == 'undefined' || versionprop == null){
		return 'N/A';
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
			setTimeout(get_conf_file,1000);
		},
		success: function(data){
			var configdata=data.split('\n');
			configdata = configdata.filter(Boolean);
			
			for(var i = 0; i < configdata.length; i++){
				let settingname = configdata[i].split('=')[0].toLowerCase();
				let settingvalue = configdata[i].split('=')[1].replace(/(\r\n|\n|\r)/gm,'');
				
				if(configdata[i].indexOf('SCHDAYS') != -1){
					if(settingvalue == '*'){
						for(var i2 = 0; i2 < daysofweek.length; i2++){
							$j('#spdmerlin_'+daysofweek[i2].toLowerCase()).prop('checked',true);
						}
					}
					else{
						var schdayarray = settingvalue.split(',');
						for(var i2 = 0; i2 < schdayarray.length; i2++){
							$j('#spdmerlin_'+schdayarray[i2].toLowerCase()).prop('checked',true);
						}
					}
				}
				else if(configdata[i].indexOf('USEPREFERRED') != -1){
					if(settingvalue == 'true'){
						eval('document.form.spdmerlin_'+settingname).checked = true;
					}
					else if(settingvalue == 'false'){
						eval('document.form.spdmerlin_'+settingname).checked = false;
					}
				}
				else if(configdata[i].indexOf('PREFERREDSERVER') != -1){
					$j('#span_spdmerlin_'+settingname).html(configdata[i].split('=')[0].split('_')[1]+' - '+settingvalue);
				}
				else if(configdata[i].indexOf('PREFERRED') == -1){
					eval('document.form.spdmerlin_'+settingname).value = settingvalue;
				}
				
				if(configdata[i].indexOf('AUTOMATED') != -1){
					AutomaticInterfaceEnableDisable($j('#spdmerlin_auto_'+document.form.spdmerlin_automated.value)[0]);
				}
				
				if(configdata[i].indexOf('AUTOBW') != -1){
					AutoBWEnableDisable($j('#spdmerlin_autobw_'+document.form.spdmerlin_autobw_enabled.value)[0]);
				}
			}
			if($j('[name=spdmerlin_schhours]').val().indexOf('/') != -1 && $j('[name=spdmerlin_schmins]').val() == 0){
				document.form.schedulemode.value = 'EveryX';
				document.form.everyxselect.value = 'hours';
				document.form.everyxvalue.value = $j('[name=spdmerlin_schhours]').val().split('/')[1];
			}
			else if($j('[name=spdmerlin_schmins]').val().indexOf('/') != -1 && $j('[name=spdmerlin_schhours]').val() == '*'){
				document.form.schedulemode.value = 'EveryX';
				document.form.everyxselect.value = 'minutes';
				document.form.everyxvalue.value = $j('[name=spdmerlin_schmins]').val().split('/')[1];
			}
			else{
				document.form.schedulemode.value = 'Custom';
			}
			ScheduleModeToggle($j('#schmode_'+$j('[name=schedulemode]:checked').val().toLowerCase())[0]);
		}
	});
}

function get_interfaces_file(){
	$j.ajax({
		url: '/ext/spdmerlin/interfaces_user.htm',
		dataType: 'text',
		error: function(xhr){
			setTimeout(get_interfaces_file,1000);
		},
		success: function(data){
			showhide('spdtest_text',false);
			showhide('imgSpdTest',false);
			showhide('btnRunSpeedtest',true);
			var interfaces = data.split('\n');
			interfaces = interfaces.filter(Boolean);
			interfacelist = '';
			interfacescomplete = [];
			interfacesdisabled = [];
			
			var interfacecharttablehtml='<div style="line-height:10px;">&nbsp;</div>';
			interfacecharttablehtml += '<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="table_allinterfaces">';
			interfacecharttablehtml += '<thead class="collapsible-jquery" id="thead_allinterfaces">';
			interfacecharttablehtml += '<tr><td>Interfaces (click to expand/collapse)</td></tr>';
			interfacecharttablehtml += '</thead>';
			interfacecharttablehtml += '<tr><td align="center" style="padding: 0px;">';
			
			var interfaceconfigtablehtml = '<tr id="rowautomaticspdtest"><td class="settingname">Interfaces to use for automatic speedtests</th><td class="settingvalue">';
			
			var prefserverconfigtablehtml = '<tr id="rowautospdprefserver"><td class="settingname">Interfaces that use a preferred server</th><td class="settingvalue">';
			
			var prefserverselecttablehtml = '<tr id="rowautospdprefserverselect"><td class="settingname">Preferred servers for interfaces</th><td class="settingvalue">';
			
			var speedtestifaceconfigtablehtml = '<tr id="rowmanualspdtest"><td class="settingname">Interfaces to use for manual speedtest</th><td class="settingvalue">';
			speedtestifaceconfigtablehtml += '<input type="radio" name="spdtest_enabled" id="spdtest_enabled_all" onchange="Change_SpdTestInterface(this)" class="input" settingvalueradio" value="All" checked>';
			speedtestifaceconfigtablehtml += '<label for="spdtest_enabled_all">All</label>';
			
			var interfacecount=interfaces.length;
			for(var i = 0; i < interfacecount; i++){
				var interfacename = '';
				if(interfaces[i].indexOf('#') != -1){
					interfacename = interfaces[i].substring(0,interfaces[i].indexOf('#')).trim();
					interfacescomplete.push(interfacename);
					var interfacedisabled = '';
					var ifacelabel = interfacename.toUpperCase();
					var changelabel = 'Change?';
					if(interfaces[i].indexOf('interface not up') != -1){
						interfacesdisabled.push(interfacename);
						interfacedisabled = 'disabled';
						ifacelabel = '<a class="hintstyle" href="javascript:void(0);" onclick="SettingHint(1);">'+interfacename.toUpperCase()+'</a>';
						changelabel = '<a class="hintstyle" href="javascript:void(0);" onclick="SettingHint(1);">Change?</a>';
					}
					interfaceconfigtablehtml += '<input type="checkbox" name="spdmerlin_iface_enabled" id="spdmerlin_iface_enabled_'+interfacename.toLowerCase()+'" class="input '+interfacedisabled+' settingvalue" value="'+interfacename.toUpperCase()+'" '+interfacedisabled+'>';
					interfaceconfigtablehtml += '<label for="spdmerlin_iface_enabled_'+interfacename.toLowerCase()+'">'+ifacelabel+'</label>';
					
					prefserverconfigtablehtml += '<input type="checkbox" name="spdmerlin_usepreferred_'+interfacename.toLowerCase()+'" id="spdmerlin_usepreferred_'+interfacename.toLowerCase()+'" class="input '+interfacedisabled+' settingvalue" value="'+interfacename.toUpperCase()+'" '+interfacedisabled+'>';
					prefserverconfigtablehtml += '<label for="spdmerlin_usepreferred_'+interfacename.toLowerCase()+'">'+ifacelabel+'</label>';
					
					prefserverselecttablehtml += '<span style="margin-left:4px;vertical-align:top;max-width:465px;display:inline-block;" id="span_spdmerlin_preferredserver_'+interfacename.toLowerCase()+'">'+interfacename.toUpperCase()+':</span><br />';
					prefserverselecttablehtml += '<input type="checkbox" name="changepref_'+interfacename.toLowerCase()+'" id="changepref_'+interfacename.toLowerCase()+'" class="input settingvalue '+interfacedisabled+'" '+interfacedisabled+' onchange="Toggle_ChangePrefServer(this)">';
					prefserverselecttablehtml += '<label for="changepref_'+interfacename.toLowerCase()+'">'+changelabel+'</label>';
					prefserverselecttablehtml += '<img id="imgServerList_'+interfacename.toLowerCase()+'" style="display:none;vertical-align:middle;" src="images/InternetScan.gif"/>';
					prefserverselecttablehtml += '<select class="disabled" name="spdmerlin_preferredserver_'+interfacename.toLowerCase()+'" id="spdmerlin_preferredserver_'+interfacename.toLowerCase()+'" style="min-width:100px;max-width:400px;display:none;vertical-align:top;" disabled></select><br />';
					
					speedtestifaceconfigtablehtml += '<input autocomplete="off" autocapitalize="off" type="radio" name="spdtest_enabled" id="spdtest_enabled_'+interfacename.toLowerCase()+'" onchange="Change_SpdTestInterface(this)" class="input '+interfacedisabled+' settingvalueradio" value="'+interfacename.toUpperCase()+'" '+interfacedisabled+'>';
					speedtestifaceconfigtablehtml += '<label for="spdtest_enabled_'+interfacename.toLowerCase()+'">'+ifacelabel+'</label>';
				}
				else{
					interfacename = interfaces[i].trim();
					interfacescomplete.push(interfacename);
					
					interfaceconfigtablehtml += '<input type="checkbox" name="spdmerlin_iface_enabled" id="spdmerlin_iface_enabled_'+interfacename.toLowerCase()+'" class="input settingvalue" value="'+interfacename.toUpperCase()+'" checked>';
					interfaceconfigtablehtml += '<label for="spdmerlin_iface_enabled_'+interfacename.toLowerCase()+'">'+interfacename.toUpperCase()+'</label>';
					
					prefserverconfigtablehtml += '<input type="checkbox" name="spdmerlin_usepreferred_'+interfacename.toLowerCase()+'" id="spdmerlin_usepreferred_'+interfacename.toLowerCase()+'" class="input settingvalue" value="'+interfacename.toUpperCase()+'" checked>';
					prefserverconfigtablehtml += '<label for="spdmerlin_usepreferred_'+interfacename.toLowerCase()+'">'+interfacename.toUpperCase()+'</label>';
					
					prefserverselecttablehtml += '<span style="margin-left:4px;vertical-align:top;max-width:465px;display:inline-block;" id="span_spdmerlin_preferredserver_'+interfacename.toLowerCase()+'">'+interfacename.toUpperCase()+':</span><br />';
					prefserverselecttablehtml += '<input type="checkbox" name="changepref_'+interfacename.toLowerCase()+'" id="changepref_'+interfacename.toLowerCase()+'" class="input settingvalue" onchange="Toggle_ChangePrefServer(this)">';
					prefserverselecttablehtml += '<label for="changepref_'+interfacename.toLowerCase()+'">Change?</label>';
					prefserverselecttablehtml += '<img id="imgServerList_'+interfacename.toLowerCase()+'" style="display:none;vertical-align:middle;" src="images/InternetScan.gif"/>';
					prefserverselecttablehtml += '<select class="disabled" name="spdmerlin_preferredserver_'+interfacename.toLowerCase()+'" id="spdmerlin_preferredserver_'+interfacename.toLowerCase()+'" style="min-width:100px;max-width:400px;display:none;vertical-align:top;" disabled></select><br />';
					
					speedtestifaceconfigtablehtml += '<input type="radio" name="spdtest_enabled" id="spdtest_enabled_'+interfacename.toLowerCase()+'" onchange="Change_SpdTestInterface(this)" class="input settingvalueradio" value="'+interfacename.toUpperCase()+'">';
					speedtestifaceconfigtablehtml += '<label for="spdtest_enabled_'+interfacename.toLowerCase()+'">'+interfacename.toUpperCase()+'</label>';
				}
				
				interfacecharttablehtml += BuildInterfaceTable(interfacename);
				
				interfacelist += interfacename+',';
			}
			
			interfacecharttablehtml += '</td></tr></table>';
			
			interfaceconfigtablehtml += '</td></tr>';
			
			prefserverconfigtablehtml += '</td></tr>';
			
			prefserverselecttablehtml += '</td></tr>';
			
			speedtestifaceconfigtablehtml += '</td></tr>';
			
			$j('#rowautomatedtests').after(prefserverselecttablehtml);
			$j('#rowautomatedtests').after(prefserverconfigtablehtml);
			$j('#rowautomatedtests').after(interfaceconfigtablehtml);
			$j('#thead_manualspeedtests').after(speedtestifaceconfigtablehtml);
			
			GenerateManualSpdTestServerPrefSelect();
			document.form.spdtest_serverpref.value = 'auto';
			
			if(interfacelist.charAt(interfacelist.length-1) == ','){
				interfacelist = interfacelist.slice(0,-1);
			}
			
			$j('#table_buttons2').after(interfacecharttablehtml);
			maxNoCharts = interfacelist.split(',').length*3*3*2;
			RedrawAllCharts();
			
			AddEventHandlers();
			
			var interfacetextarray = interfacelist.split(',');
			for(var i = 0; i < interfacetextarray.length; i++){
				$j('#sortTable'+interfacetextarray[i]).empty();
				$j('#sortTable'+interfacetextarray[i]).append(BuildLastXTableNoData(interfacetextarray[i]));
				get_lastx_file(interfacetextarray[i]);
			}
			get_conf_file();
		}
	});
}

function get_statstitle_file(){
	$j.ajax({
		url: '/ext/spdmerlin/spdtitletext.js',
		dataType: 'script',
		error: function(xhr){
			setTimeout(get_statstitle_file,1000);
		},
		success: function(){
			SetSPDStatsTitle();
		}
	});
}

function get_lastx_file(name){
	$j.ajax({
		url: '/ext/spdmerlin/lastx_'+name+'.htm',
		dataType: 'text',
		error: function(xhr){
			setTimeout(get_lastx_file,1000,name);
		},
		success: function(data){
			ParseLastXData(name,data);
		}
	});
}

function ParseLastXData(name,data){
	var arraysortlines = data.split('\n');
	arraysortlines = arraysortlines.filter(Boolean);
	window['arraysortlistlines'+name] = [];
	for(var i = 0; i < arraysortlines.length; i++){
		try{
			var resultfields = arraysortlines[i].split(',');
			var parsedsortline = new Object();
			parsedsortline.Time =  moment.unix(resultfields[0].trim()).format('YYYY-MM-DD HH:mm:ss');
			parsedsortline.Download = resultfields[1].trim();
			parsedsortline.Upload = resultfields[2].trim();
			parsedsortline.Latency = resultfields[3].trim();
			parsedsortline.Jitter = resultfields[4].trim();
			parsedsortline.PacketLoss = resultfields[5].trim();
			parsedsortline.DownloadData = resultfields[6].trim();
			parsedsortline.UploadData = resultfields[7].trim();
			parsedsortline.URL = resultfields[8].trim();
			window['arraysortlistlines'+name].push(parsedsortline);
		}
		catch{
			//do nothing, continue
		}
	}
	SortTable('sortTable'+name,'arraysortlistlines'+name,eval('sortname'+name)+' '+eval('sortdir'+name).replace('desc','↑').replace('asc','↓').trim(),'sortname'+name,'sortdir'+name);
}

function SortTable(tableid,arrayid,sorttext,sortname,sortdir){
	window[sortname] = sorttext.replace('↑','').replace('↓','').trim();
	var sorttype = 'number';
	var sortfield = window[sortname];
	switch(window[sortname]){
		case 'Time':
			sorttype = 'date';
		break
		case 'ResultURL':
			sorttype = 'string';
		break
	}
	
	if(sorttype == 'string'){
		if(sorttext.indexOf('↓') == -1 && sorttext.indexOf('↑') == -1){
			eval(arrayid+' = '+arrayid+'.sort((a,b) => (a.'+sortfield+'.toLowerCase() > b.'+sortfield+'.toLowerCase()) ? 1 : ((b.'+sortfield+'.toLowerCase() > a.'+sortfield+'.toLowerCase()) ? -1 : 0));');
			window[sortdir] = 'asc';
		}
		else if(sorttext.indexOf('↓') != -1){
			eval(arrayid+' = '+arrayid+'.sort((a,b) => (a.'+sortfield+'.toLowerCase() > b.'+sortfield+'.toLowerCase()) ? 1 : ((b.'+sortfield+'.toLowerCase() > a.'+sortfield+'.toLowerCase()) ? -1 : 0));');
			window[sortdir] = 'asc';
		}
		else{
			eval(arrayid+' = '+arrayid+'.sort((a,b) => (a.'+sortfield+'.toLowerCase() < b.'+sortfield+'.toLowerCase()) ? 1 : ((b.'+sortfield+'.toLowerCase() < a.'+sortfield+'.toLowerCase()) ? -1 : 0));');
			window[sortdir] = 'desc';
		}
	}
	else if(sorttype == 'number'){
		if(sorttext.indexOf('↓') == -1 && sorttext.indexOf('↑') == -1){
			eval(arrayid+' = '+arrayid+'.sort((a,b) => parseFloat(a.'+sortfield+'.replace("m","000")) - parseFloat(b.'+sortfield+'.replace("m","000")));');
			window[sortdir] = 'asc';
		}
		else if(sorttext.indexOf('↓') != -1){
			eval(arrayid+' = '+arrayid+'.sort((a,b) => parseFloat(a.'+sortfield+'.replace("m","000")) - parseFloat(b.'+sortfield+'.replace("m","000")));');
			window[sortdir] = 'asc';
		}
		else{
			eval(arrayid+' = '+arrayid+'.sort((a,b) => parseFloat(b.'+sortfield+'.replace("m","000")) - parseFloat(a.'+sortfield+'.replace("m","000")));');
			window[sortdir] = 'desc';
		}
	}
	else if(sorttype == 'date'){
		if(sorttext.indexOf('↓') == -1 && sorttext.indexOf('↑') == -1){
			eval(arrayid+' = '+arrayid+'.sort((a, b) => new Date(a.'+sortfield+') - new Date(b.'+sortfield+'));');
			window[sortdir] = 'asc';
		}
		else if(sorttext.indexOf('↓') != -1){
			eval(arrayid+' = '+arrayid+'.sort((a, b) => new Date(a.'+sortfield+') - new Date(b.'+sortfield+'));');
			window[sortdir] = 'asc';
		}
		else{
			eval(arrayid+' = '+arrayid+'.sort((a, b) => new Date(b.'+sortfield+') - new Date(a.'+sortfield+'));');
			window[sortdir] = 'desc';
		}
	}
	
	$j('#'+tableid).empty();
	$j('#'+tableid).append(BuildLastXTable(tableid.replace('sortTable','')));
	
	$j('#'+tableid).find('.sortable').each(function(index,element){
		if(element.innerHTML.replace(/ \(.*\)/,'').replace(' ','') == window[sortname]){
			if(window[sortdir] == 'asc'){
				element.innerHTML = element.innerHTML+' ↑';
			}
			else{
				element.innerHTML = element.innerHTML+' ↓';
			}
		}
	});
}

function BuildLastXTableNoData(){
	var tablehtml='<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="sortTable">';
	tablehtml += '<tr>';
	tablehtml += '<td class="nodata">';
	tablehtml += 'Data loading...';
	tablehtml += '</td>';
	tablehtml += '</tr>';
	tablehtml += '</table>';
	return tablehtml;
}

function BuildLastXTable(name){
	var tablehtml = '<table border="0" cellpadding="0" cellspacing="0" width="100%" class="sortTable">';
	tablehtml += '<col style="width:120px;">';
	tablehtml += '<col style="width:70px;">';
	tablehtml += '<col style="width:60px;">';
	tablehtml += '<col style="width:60px;">';
	tablehtml += '<col style="width:60px;">';
	tablehtml += '<col style="width:65px;">';
	tablehtml += '<col style="width:80px;">';
	tablehtml += '<col style="width:80px;">';
	tablehtml += '<col style="width:130px;">';
	
	tablehtml += '<thead class="sortTableHeader">';
	tablehtml += '<tr>';
	tablehtml += '<th class="sortable" onclick="SortTable(\'sortTable'+name+'\',\'arraysortlistlines'+name+'\',this.innerHTML.replace(/ \\(.*\\)/,\'\'),\'sortname'+name+'\',\'sortdir'+name+'\')">Time</th>';
	tablehtml += '<th class="sortable" onclick="SortTable(\'sortTable'+name+'\',\'arraysortlistlines'+name+'\',this.innerHTML.replace(/ \\(.*\\)/,\'\'),\'sortname'+name+'\',\'sortdir'+name+'\')">Download (Mbps)</th>';
	tablehtml += '<th class="sortable" onclick="SortTable(\'sortTable'+name+'\',\'arraysortlistlines'+name+'\',this.innerHTML.replace(/ \\(.*\\)/,\'\'),\'sortname'+name+'\',\'sortdir'+name+'\')">Upload (Mbps)</th>';
	tablehtml += '<th class="sortable" onclick="SortTable(\'sortTable'+name+'\',\'arraysortlistlines'+name+'\',this.innerHTML.replace(/ \\(.*\\)/,\'\'),\'sortname'+name+'\',\'sortdir'+name+'\')">Latency (ms)</th>';
	tablehtml += '<th class="sortable" onclick="SortTable(\'sortTable'+name+'\',\'arraysortlistlines'+name+'\',this.innerHTML.replace(/ \\(.*\\)/,\'\'),\'sortname'+name+'\',\'sortdir'+name+'\')">Jitter (ms)</th>';
	tablehtml += '<th class="sortable" onclick="SortTable(\'sortTable'+name+'\',\'arraysortlistlines'+name+'\',this.innerHTML.replace(/ \\(.*\\)/,\'\').replace(\' \',\'\'),\'sortname'+name+'\',\'sortdir'+name+'\')">Packet Loss (%)</th>';
	tablehtml += '<th class="sortable" onclick="SortTable(\'sortTable'+name+'\',\'arraysortlistlines'+name+'\',this.innerHTML.replace(/ \\(.*\\)/,\'\').replace(\' \',\'\'),\'sortname'+name+'\',\'sortdir'+name+'\')">Download Data (MB)</th>';
	tablehtml += '<th class="sortable" onclick="SortTable(\'sortTable'+name+'\',\'arraysortlistlines'+name+'\',this.innerHTML.replace(/ \\(.*\\)/,\'\').replace(\' \',\'\'),\'sortname'+name+'\',\'sortdir'+name+'\')">Upload Data (MB)</th>';
	tablehtml += '<th class="sortable" onclick="SortTable(\'sortTable'+name+'\',\'arraysortlistlines'+name+'\',this.innerHTML.replace(/ \\(.*\\)/,\'\'),\'sortname'+name+'\',\'sortdir'+name+'\')">URL</th>';
	tablehtml += '</tr>';
	tablehtml += '</thead>';
	tablehtml += '<tbody class="sortTableContent">';
	
	for(var i = 0; i < window['arraysortlistlines'+name].length; i++){
		tablehtml += '<tr class="sortRow">';
		tablehtml += '<td>'+window['arraysortlistlines'+name][i].Time+'</td>';
		tablehtml += '<td>'+window['arraysortlistlines'+name][i].Download+'</td>';
		tablehtml += '<td>'+window['arraysortlistlines'+name][i].Upload+'</td>';
		tablehtml += '<td>'+window['arraysortlistlines'+name][i].Latency+'</td>';
		tablehtml += '<td>'+window['arraysortlistlines'+name][i].Jitter+'</td>';
		tablehtml += '<td>'+window['arraysortlistlines'+name][i].PacketLoss.replace("null","N/A")+'</td>';
		tablehtml += '<td>'+window['arraysortlistlines'+name][i].DownloadData+'</td>';
		tablehtml += '<td>'+window['arraysortlistlines'+name][i].UploadData+'</td>';
		if(window['arraysortlistlines'+name][i].URL != ""){
			tablehtml += '<td><a href="'+window['arraysortlistlines'+name][i].URL+'" target="_blank">Speedtest result URL</a></td>';
		}
		else{
			tablehtml += '<td>No result URL</td>';
		}
		tablehtml += '</tr>';
	}
	
	tablehtml += '</tbody>';
	tablehtml += '</table>';
	return tablehtml;
}

function changeAllCharts(e){
	value = e.value * 1;
	name = e.id.substring(0,e.id.indexOf('_'));
	SetCookie(e.id,value);
	var interfacetextarray = interfacelist.split(',');
	for(var i = 0; i < interfacetextarray.length; i++){
		Draw_Chart(interfacetextarray[i],'Combined');
		Draw_Chart(interfacetextarray[i],'Quality');
	}
}

function changeChart(e){
	value = e.value * 1;
	name = e.id.substring(0,e.id.indexOf('_'));
	SetCookie(e.id,value);
	if(e.id.indexOf('Combined') != -1){
		Draw_Chart(name,'Combined');
	}
	else if(e.id.indexOf('Quality') != -1){
		Draw_Chart(name,'Quality');
	}
}

function SettingHint(hintid){
	var tag_name = document.getElementsByTagName('a');
	for(var i=0;i<tag_name.length;i++){
		tag_name[i].onmouseout=nd;
	}
	hinttext='My text goes here';
	if(hintid == 1) hinttext='Interface not enabled';
	if(hintid == 2) hinttext='Hour(s) of day to run speedtest<br />* for all<br />Valid numbers between 0 and 23<br />comma (,) separate for multiple<br />dash (-) separate for a range';
	if(hintid == 3) hinttext='Minute(s) of day to run speedtest<br />(* for all<br />Valid numbers between 0 and 59<br />comma (,) separate for multiple<br />dash (-) separate for a range';
	
	return overlib(hinttext,0,0);
}

function BuildInterfaceTable(name){
	var charthtml = '<div style="line-height:10px;">&nbsp;</div>';
	charthtml += '<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="table_interfaces_'+name+'">';
	charthtml += '<thead class="collapsible-jquery" id="'+name+'">';
	charthtml += '<tr>';
	charthtml += '<td colspan="2">'+name+' (click to expand/collapse)</td>';
	charthtml += '</tr>';
	charthtml += '</thead>';
	charthtml += '<tr>';
	charthtml += '<td colspan="2" align="center" style="padding: 0px;">';
	charthtml += '<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">';
	charthtml += '<thead class="collapsible-jquery" id="resulttable_'+name+'">';
	charthtml += '<tr><td>Latest speedtest results (click to expand/collapse)</td></tr>';
	charthtml += '</thead>';
	charthtml += '<tr>';
	charthtml += '<td style="padding: 0px;">';
	charthtml += '<div id="sortTable'+name+'" class="sortTableContainer" style="height:300px;"></div>'
	charthtml += '</td>';
	charthtml += '</tr>';
	charthtml += '</table>';
	charthtml += '<div style="line-height:10px;">&nbsp;</div>';
	charthtml += '<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">';
	charthtml += '<thead class="collapsible-jquery" id="table_charts">';
	charthtml += '<tr>';
	charthtml += '<td>Tables and Charts (click to expand/collapse)</td>';
	charthtml += '</tr>';
	charthtml += '</thead>';
	charthtml += '<tr><td align="center" style="padding: 0px;">';
	charthtml += '<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">';
	charthtml += '<thead class="collapsible-jquery" id="'+name+'_ChartCombined">';
	charthtml += '<tr>';
	charthtml += '<td colspan="2">Bandwidth (click to expand/collapse)</td>';
	charthtml += '</tr>';
	charthtml += '</thead>';
	charthtml += '<tr class="even">';
	charthtml += '<th width="40%">Data interval</th>';
	charthtml += '<td>';
	charthtml += '<select style="width:150px" class="input_option" onchange="changeChart(this);changePeriod(this);" id="'+name+'_Interval_Combined">';
	charthtml += '<option value="0">Raw</option>';
	charthtml += '<option value="1">Hours</option>';
	charthtml += '<option value="2">Days</option>';
	charthtml += '</select>';
	charthtml += '</td>';
	charthtml += '</tr>';
	charthtml += '<tr class="even">';
	charthtml += '<th width="40%">Period to display</th>';
	charthtml += '<td>';
	charthtml += '<select style="width:150px" class="input_option" onchange="changeChart(this)" id="'+name+'_Period_Combined">';
	charthtml += '<option value=0>Last 24 hours</option>';
	charthtml += '<option value=1>Last 7 days</option>';
	charthtml += '<option value=2>Last 30 days</option>';
	charthtml += '</select>';
	charthtml += '</td>';
	charthtml += '</tr>';
	charthtml += '<tr class="even">';
	charthtml += '<th width="40%">Scale type</th>';
	charthtml += '<td>';
	charthtml += '<select style="width:150px" class="input_option" onchange="changeChart(this)" id="'+name+'_Scale_Combined">';
	charthtml += '<option value="0">Linear</option>';
	charthtml += '<option value="1">Logarithmic</option>';
	charthtml += '</select>';
	charthtml += '</td>';
	charthtml += '</tr>';
	charthtml += '<tr>';
	charthtml += '<td colspan="2" align="center" style="padding: 0px;">';
	charthtml += '<div style="background-color:#2f3e44;border-radius:10px;width:730px;height:500px;padding-left:5px;"><canvas id="divLineChart_'+name+'_Combined" height="500" /></div>';
	charthtml += '</td>';
	charthtml += '</tr>';
	charthtml += '</table>';
	charthtml += '<div style="line-height:10px;">&nbsp;</div>';
	charthtml += '<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">';
	charthtml += '<thead class="collapsible-jquery" id="'+name+'_ChartQuality">';
	charthtml += '<tr>';
	charthtml += '<td colspan="2">Quality (click to expand/collapse)</td>';
	charthtml += '</tr>';
	charthtml += '</thead>';
	charthtml += '<tr class="even">';
	charthtml += '<th width="40%">Data interval</th>';
	charthtml += '<td>';
	charthtml += '<select style="width:150px" class="input_option" onchange="changeChart(this);changePeriod(this);" id="'+name+'_Interval_Quality">';
	charthtml += '<option value="0">Raw</option>';
	charthtml += '<option value="1">Hours</option>';
	charthtml += '<option value="2">Days</option>';
	charthtml += '</select>';
	charthtml += '</td>';
	charthtml += '</tr>';
	charthtml += '<tr class="even">';
	charthtml += '<th width="40%">Period to display</th>';
	charthtml += '<td>';
	charthtml += '<select style="width:150px" class="input_option" onchange="changeChart(this)" id="'+name+'_Period_Quality">';
	charthtml += '<option value=0>Last 24 hours</option>';
	charthtml += '<option value=1>Last 7 days</option>';
	charthtml += '<option value=2>Last 30 days</option>';
	charthtml += '</select>';
	charthtml += '</td>';
	charthtml += '</tr>';
	charthtml += '<tr class="even">';
	charthtml += '<th width="40%">Scale type</th>';
	charthtml += '<td>';
	charthtml += '<select style="width:150px" class="input_option" onchange="changeChart(this)" id="'+name+'_Scale_Quality">';
	charthtml += '<option value="0">Linear</option>';
	charthtml += '<option value="1">Logarithmic</option>';
	charthtml += '</select>';
	charthtml += '</td>';
	charthtml += '</tr>';
	charthtml += '<tr>';
	charthtml += '<td colspan="2" align="center" style="padding: 0px;">';
	charthtml += '<div style="background-color:#2f3e44;border-radius:10px;width:730px;height:500px;padding-left:5px;"><canvas id="divLineChart_'+name+'_Quality" height="500" /></div>';
	charthtml += '</td>';
	charthtml += '</tr>';
	charthtml += '</table>';
	charthtml += '</td>';
	charthtml += '</tr>';
	charthtml += '</table>';
	charthtml += '</td>';
	charthtml += '</tr>';
	charthtml += '</table>';
	return charthtml;
}

function AutomaticInterfaceEnableDisable(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.value;
	var prefix = inputname.substring(0,inputname.lastIndexOf('_'));
	
	var fieldnames = ['schhours','schmins'];
	var fieldnames2 = ['schedulemode','everyxselect','everyxvalue'];
	
	if(inputvalue == 'false'){
		for(var i = 0; i < interfacescomplete.length; i++){
			$j('#'+prefix+'_iface_enabled_'+interfacescomplete[i].toLowerCase()).prop('disabled',true);
			$j('#'+prefix+'_iface_enabled_'+interfacescomplete[i].toLowerCase()).addClass('disabled');
			$j('#'+prefix+'_usepreferred_'+interfacescomplete[i].toLowerCase()).prop('disabled',true);
			$j('#'+prefix+'_usepreferred_'+interfacescomplete[i].toLowerCase()).addClass('disabled');
			$j('#changepref_'+interfacescomplete[i].toLowerCase()).prop('disabled',true);
			$j('#changepref_'+interfacescomplete[i].toLowerCase()).addClass('disabled');
		}
		for (var i = 0; i < fieldnames.length; i++){
			$j('input[name='+prefix+'_'+fieldnames[i]+']').addClass('disabled');
			$j('input[name='+prefix+'_'+fieldnames[i]+']').prop('disabled',true);
		}
		for (var i = 0; i < daysofweek.length; i++){
			$j('#'+prefix+'_'+daysofweek[i].toLowerCase()).prop('disabled',true);
		}
		for (var i = 0; i < fieldnames2.length; i++){
			$j('[name='+fieldnames2[i]+']').addClass('disabled');
			$j('[name='+fieldnames2[i]+']').prop('disabled',true);
		}
	}
	else if(inputvalue == 'true'){
		for(var i = 0; i < interfacescomplete.length; i++){
			if(interfacesdisabled.includes(interfacescomplete[i]) == false){
				$j('#'+prefix+'_iface_enabled_'+interfacescomplete[i].toLowerCase()).prop('disabled',false);
				$j('#'+prefix+'_iface_enabled_'+interfacescomplete[i].toLowerCase()).removeClass('disabled');
				$j('#'+prefix+'_usepreferred_'+interfacescomplete[i].toLowerCase()).prop('disabled',false);
				$j('#'+prefix+'_usepreferred_'+interfacescomplete[i].toLowerCase()).removeClass('disabled');
				$j('#changepref_'+interfacescomplete[i].toLowerCase()).prop('disabled',false);
				$j('#changepref_'+interfacescomplete[i].toLowerCase()).removeClass('disabled');
			}
		}
		for (var i = 0; i < fieldnames.length; i++){
			$j('input[name='+prefix+'_'+fieldnames[i]+']').removeClass('disabled');
			$j('input[name='+prefix+'_'+fieldnames[i]+']').prop('disabled',false);
		}
		for (var i = 0; i < daysofweek.length; i++){
			$j('#'+prefix+'_'+daysofweek[i].toLowerCase()).prop('disabled',false);
		}
		for (var i = 0; i < fieldnames2.length; i++){
			$j('[name='+fieldnames2[i]+']').removeClass('disabled');
			$j('[name='+fieldnames2[i]+']').prop('disabled',false);
		}
	}
}

function ScheduleModeToggle(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.value;
	
	if(inputvalue == 'EveryX'){
		showhide('schfrequency',true);
		showhide('schcustom',false);
		if($j('#everyxselect').val() == 'hours'){
			showhide('spanxhours',true);
			showhide('spanxminutes',false);
		}
		else if($j('#everyxselect').val() == 'minutes'){
			showhide('spanxhours',false);
			showhide('spanxminutes',true);
		}
	}
	else if(inputvalue == 'Custom'){
		showhide('schfrequency',false);
		showhide('schcustom',true);
	}
}

function EveryXToggle(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.value;
	
	if(inputvalue == 'hours'){
		showhide('spanxhours',true);
		showhide('spanxminutes',false);
	}
	else if(inputvalue == 'minutes'){
		showhide('spanxhours',false);
		showhide('spanxminutes',true);
	}
	
	Validate_ScheduleValue($j('[name=everyxvalue]')[0]);
}

function AutoBWEnableDisable(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.value;
	var prefix = inputname.substring(0,inputname.indexOf('_'));
	
	var fieldnames = ['autobw_ulimit','autobw_llimit','autobw_sf','autobw_threshold','autobw_average'];
	
	if(inputvalue == 'false'){
		for (var i = 0; i < fieldnames.length; i++){
			$j('input[name^='+prefix+'_'+fieldnames[i]+']').addClass('disabled');
			$j('input[name^='+prefix+'_'+fieldnames[i]+']').prop('disabled',true);
		}
		
		$j('input[name^='+prefix+'_excludefromqos]').removeClass('disabled');
		$j('input[name^='+prefix+'_excludefromqos]').prop('disabled',false);
	}
	else if(inputvalue == 'true'){
		for (var i = 0; i < fieldnames.length; i++){
			$j('input[name^='+prefix+'_'+fieldnames[i]+']').removeClass('disabled');
			$j('input[name^='+prefix+'_'+fieldnames[i]+']').prop('disabled',false);
		}
		
		document.form.spdmerlin_excludefromqos.value = true;
		$j('input[name^='+prefix+'_excludefromqos]').addClass('disabled');
		$j('input[name^='+prefix+'_excludefromqos]').prop('disabled',true);
	}
}

function Toggle_ChangePrefServer(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.checked;
	
	var ifacename = inputname.split('_')[1];
	
	if(inputvalue == true){
		document.formScriptActions.action_script.value='start_spdmerlinserverlist_'+ifacename;
		document.formScriptActions.submit();
		showhide('imgServerList_'+ifacename,true);
		setTimeout(get_spdtestservers_file,2000,ifacename);
	}
	else{
		$j('#spdmerlin_preferredserver_'+ifacename)[0].style.display = 'none';
		$j('#spdmerlin_preferredserver_'+ifacename).prop('disabled',true);
		$j('#spdmerlin_preferredserver_'+ifacename).addClass('disabled');
	}
}

function Change_SpdTestInterface(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.value;
	
	GenerateManualSpdTestServerPrefSelect();
	Toggle_SpdTestServerPref(document.form.spdtest_serverpref);
}

function Toggle_SpdTestServerPref(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.value;
	
	if(inputvalue == 'onetime'){
		document.formScriptActions.action_script.value='start_spdmerlinserverlistmanual_'+document.form.spdtest_enabled.value;
		document.formScriptActions.submit();
		for(var i = 0; i < interfacescomplete.length; i++){
			$j('#spdtest_enabled_'+interfacescomplete[i].toLowerCase()).prop('disabled',true);
			$j('#spdtest_enabled_'+interfacescomplete[i].toLowerCase()).addClass('disabled');
		}
		$j.each($j('input[name=spdtest_serverpref]'),function(){
			$j(this).prop('disabled',true);
			$j(this).addClass('disabled');
		});
		showhide('rowmanualserverprefselect',true);
		showhide('imgManualServerList',true);
		
		if(document.form.spdtest_enabled.value == 'All'){
			$j.each($j('select[name^=spdtest_serverprefselect]'),function(){
				$j(this).empty();
			});
		}
		else{
			$j('select[name=spdtest_serverprefselect]').empty();
		}
		setTimeout(get_manualspdtestservers_file,2000);
	}
	else{
		showhide('rowmanualserverprefselect',false);
		if(document.form.spdtest_enabled.value == 'All'){
			$j.each($j('select[name^=spdtest_serverprefselect]'),function(){
				showhide(this.id,false);
			});
			$j.each($j('span[id^=spdtest_serverprefselectspan]'),function(){
				showhide(this.id,false);
			});
		}
		else{
			showhide('spdtest_serverprefselect',false);
		}
		showhide('imgManualServerList',false);
	}
}

function GenerateManualSpdTestServerPrefSelect(){
	$j('#rowmanualserverprefselect').remove();
	var serverprefhtml = '<tr class="even" id="rowmanualserverprefselect" style="display:none;">';
	serverprefhtml += '<td class="settingname">Choose a server</th><td class="settingvalue"><img id="imgManualServerList" style="display:none;vertical-align:middle;" src="images/InternetScan.gif"/>';
	
	if(document.form.spdtest_enabled.value == 'All'){
		for(var i = 0; i < interfacescomplete.length; i++){
			if(interfacesdisabled.includes(interfacescomplete[i]) == false){
				var interfacename = interfacescomplete[i].toLowerCase();
				serverprefhtml += '<span style="width:50px;display:none;" id="spdtest_serverprefselectspan_'+interfacename+'">'+interfacescomplete[i]+':</span><select name="spdtest_serverprefselect_'+interfacename+'" id="spdtest_serverprefselect_'+interfacename+'" style="display:none;max-width:415px;"></select><br />';
			}
		}
	}
	else{
		serverprefhtml += '<select name="spdtest_serverprefselect" id="spdtest_serverprefselect" style="display:none;"></select>';
	}
	
	serverprefhtml += '</td></tr>';
	$j('#rowmanualserverpref').after(serverprefhtml);
}

function Validate_All(){
	var validationfailed = false;
	
	if(! Validate_Number_Setting(document.form.spdmerlin_autobw_sf_down,100,0)) validationfailed=true;
	if(! Validate_Number_Setting(document.form.spdmerlin_autobw_sf_up,100,0)) validationfailed=true;
	if(! Validate_Number_Setting(document.form.spdmerlin_autobw_threshold_down,100,0)) validationfailed=true;
	if(! Validate_Number_Setting(document.form.spdmerlin_autobw_threshold_up,100,0)) validationfailed=true;
	if(! Validate_Number_Setting(document.form.spdmerlin_autobw_average_calc,30,1)) validationfailed=true;
	
	if(document.form.schedulemode.value == 'EveryX'){
		if(! Validate_ScheduleValue(document.form.everyxvalue)) validationfailed=true;
	}
	else if(document.form.schedulemode.value == 'Custom'){
		if(! Validate_Schedule(document.form.spdmerlin_schhours,'hours')) validationfailed=true;
		if(! Validate_Schedule(document.form.spdmerlin_schmins,'mins')) validationfailed=true;
	}
	
	if(validationfailed){
		alert('Validation for some fields failed. Please correct invalid values and try again.');
		return false;
	}
	else{
		return true;
	}
}

function Validate_Schedule(forminput,hoursmins){
	var inputname = forminput.name;
	var inputvalues = forminput.value.split(',');
	var upperlimit = 0;
	
	if(hoursmins == 'hours'){
		upperlimit = 23;
	}
	else if (hoursmins == 'mins'){
		upperlimit = 59;
	}
	
	showhide('btnfixhours',false);
	showhide('btnfixmins',false);
	
	var validationfailed = 'false';
	for(var i=0; i < inputvalues.length; i++){
		if(inputvalues[i] == '*' && i == 0){
			validationfailed = 'false';
		}
		else if(inputvalues[i] == '*' && i != 0){
			validationfailed = 'true';
		}
		else if(inputvalues[0] == '*' && i > 0){
			validationfailed = 'true';
		}
		else if(inputvalues[i] == ''){
			validationfailed = 'true';
		}
		else if(inputvalues[i].startsWith('*/')){
			if(! isNaN(inputvalues[i].replace('*/','')*1)){
				if((inputvalues[i].replace('*/','')*1) > upperlimit || (inputvalues[i].replace('*/','')*1) < 0){
					validationfailed = 'true';
				}
			}
			else{
				validationfailed = 'true';
			}
		}
		else if(inputvalues[i].indexOf('-') != -1){
			if(inputvalues[i].startsWith('-')){
				validationfailed = 'true';
			}
			else{
				var inputvalues2 = inputvalues[i].split('-');
				for(var i2=0; i2 < inputvalues2.length; i2++){
					if(inputvalues2[i2] == ''){
						validationfailed = 'true';
					}
					else if(! isNaN(inputvalues2[i2]*1)){
						if((inputvalues2[i2]*1) > upperlimit || (inputvalues2[i2]*1) < 0){
							validationfailed = 'true';
						}
						else if((inputvalues2[i2+1]*1) < (inputvalues2[i2]*1)){
							validationfailed = 'true';
							if(hoursmins == 'hours'){
								showhide('btnfixhours',true)
							}
							else if (hoursmins == 'mins'){
								showhide('btnfixmins',true)
							}
						}
					}
					else{
						validationfailed = 'true';
					}
				}
			}
		}
		else if(! isNaN(inputvalues[i]*1)){
			if((inputvalues[i]*1) > upperlimit || (inputvalues[i]*1) < 0){
				validationfailed = 'true';
			}
		}
		else{
			validationfailed = 'true';
		}
	}
	
	if(validationfailed == 'true'){
		$j(forminput).addClass('invalid');
		return false;
	}
	else{
		$j(forminput).removeClass('invalid');
		return true;
	}
}

function Validate_ScheduleValue(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.value*1;
	
	var upperlimit = 0;
	var lowerlimit = 1;
	
	var unittype = $j('#everyxselect').val();
	
	if(unittype == 'hours'){
		upperlimit = 24;
	}
	else if(unittype == 'minutes'){
		upperlimit = 30;
	}
	
	if(inputvalue > upperlimit || inputvalue < lowerlimit || forminput.value.length < 1){
		$j(forminput).addClass('invalid');
		return false;
	}
	else{
		$j(forminput).removeClass('invalid');
		return true;
	}
}

function Validate_Number_Setting(forminput,upperlimit,lowerlimit){
	var inputname = forminput.name;
	var inputvalue = forminput.value*1;

	if(inputvalue > upperlimit || inputvalue < lowerlimit){
		$j(forminput).addClass('invalid');
		return false;
	}
	else{
		$j(forminput).removeClass('invalid');
		return true;
	}
}

function Format_Number_Setting(forminput){
	var inputname = forminput.name;
	var inputvalue = forminput.value*1;

	if(forminput.value.length == 0 || inputvalue == NaN){
		return false;
	}
	else{
		forminput.value = parseInt(forminput.value);
		return true;
	}
}

function FixCron(hoursmins){
	if(hoursmins == 'hours'){
		var origvalue = document.form.spdmerlin_schhours.value;
		document.form.spdmerlin_schhours.value = origvalue.split('-')[0]+'-23,0-'+origvalue.split('-')[1];
		Validate_Schedule(document.form.spdmerlin_schhours,'hours');
	}
	else if(hoursmins == 'mins'){
		var origvalue = document.form.spdmerlin_schmins.value;
		document.form.spdmerlin_schmins.value = origvalue.split('-')[0]+'-59,0-'+origvalue.split('-')[1];
		Validate_Schedule(document.form.spdmerlin_schmins,'mins');
	}
}

function AddEventHandlers(){
	$j('.collapsible-jquery').off('click').on('click',function(){
		$j(this).siblings().toggle('fast',function(){
			if($j(this).css('display') == 'none'){
				SetCookie($j(this).siblings()[0].id,'collapsed');
			}
			else{
				SetCookie($j(this).siblings()[0].id,'expanded');
			}
		})
	});
	
	$j('.collapsible-jquery').each(function(index,element){
		if(GetCookie($j(this)[0].id,'string') == 'collapsed'){
			$j(this).siblings().toggle(false);
		}
		else{
			$j(this).siblings().toggle(true);
		}
	});
}
