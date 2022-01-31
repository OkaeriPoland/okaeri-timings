<template>
  <apexchart type="line" height="300" :options="chartOptions" :series="chartSeries"></apexchart>
</template>

<script>
export default {
  components: {
  },
  props: {
    chartSeries: {
      type: Array
    },
    yFormatter: {
      type: Function,
      default: function (value) {
        return value.toFixed(3) + '%';
      }
    },
    chartOptions: {
      type: Object,
      default: function (props) {
        return {
          fill: {type: 'solid'},
          xaxis: {type: 'datetime'},
          yaxis: {
            labels: {
              formatter: props.yFormatter
            },
          },
          tooltip: {
            x: {
              format: "yyyy-MM-dd HH:mm:ss"
            }
          },
          dataLabels: {enabled: false},
          animations: {enabled: false},
          stroke: {curve: 'straight'}
        };
      }
    },
  }
}
</script>
