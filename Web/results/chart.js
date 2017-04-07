
    var colors = d3.scale.category20();
    var chart;
    nv.addGraph(function() {
        chart = nv.models.stackedAreaChart()
            .useInteractiveGuideline(true)
            .x(function(d) { return d[0] })
            .y(function(d) { return d[1] })
            .duration(300);

        chart.showControls(false)
        chart.style("expand");

        chart.xAxis.tickFormat(function(d) { return d3.time.format('%H:%M')(new Date(d)) });
        chart.yAxis.tickFormat(d3.format(',.4f'));
        chart.legend.vers('furious');
        d3.select('#chart1')
            .datum(histcatexplong)
            .transition().duration(1000)
            .call(chart)
            .each('start', function() {
                setTimeout(function() {
                    d3.selectAll('#chart1 *').each(function() {
                        if(this.__transition__)
                            this.__transition__.duration = 1;
                    })
                }, 0)
            });
        nv.utils.windowResize(chart.update);
        return chart;
    });


    function volatileChart(startPrice, volatility, numPoints) {
        var rval =  [];
        var now =+new Date();
        numPoints = numPoints || 100;
        for(var i = 1; i < numPoints; i++) {
            rval.push({x: now + i * 1000 * 60 * 60 * 24, y: startPrice});
            var rnd = Math.random();
            var changePct = 2 * volatility * rnd;
            if ( changePct > volatility) {
                changePct -= (2*volatility);
            }
            startPrice = startPrice + startPrice * changePct;
        }
        return rval;
    }

    wrk = volatileChart(25.0, 0.09,30);

    nv.addGraph(function() {
            var chart = nv.models.sparklinePlus();
            chart.margin({left:70})
                .x(function(d,i) { return i })
                .showLastValue(true)
                .xTickFormat(function(d) {
                    return d3.time.format('%M:%S')(new Date(wrk[d].x))
                });
            d3.select('#spark1')
                    .datum(wrk)
                    .call(chart);

            chart.alignValue(false);
            chart.showLastValue(false);
            chart.animate(false);
            return chart;
        });
