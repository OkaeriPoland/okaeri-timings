<template>
  <apexchart type="line" height="300" :options="chartOptions" :series="[{name: name, data: chartSeries}]"></apexchart>
</template>

<script>
export default {
  components: {
  },
  props: {
    name: {
      type: String
    },
    chartOptions: {
      type: Object,
      default: function () {
        return {
          fill: {type: 'solid'},
          xaxis: {type: 'datetime'},
          yaxis: {
            labels: {
              formatter: function (value) {
                return value.toFixed(3) + '%';
              }
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
    chartSeries: {
      type: Array
    }
  }
}
</script>
