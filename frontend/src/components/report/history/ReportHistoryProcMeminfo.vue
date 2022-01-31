<template>
  <MDBCard>
    <MDBCardBody>
      <MDBCardTitle class="d-flex">
        <span class="me-1">History</span>
        <MDBBadge color="primary">/proc/meminfo</MDBBadge>
      </MDBCardTitle>
      <MDBCardText>
        This section contains memory usage changes over time.
      </MDBCardText>
      <!--suppress RequiredAttributes -->
      <MDBTabs v-model="historyTab">
        <MDBTabNav tabsClasses="mb-3">
          <MDBTabItem tab-id="history-mem" href="history-mem">Memory</MDBTabItem>
          <MDBTabItem tab-id="history-swap" href="history-swap">Swap</MDBTabItem>
        </MDBTabNav>
        <MDBTabContent>
          <MDBTabPane tab-id="history-mem">
            <ReportHistoryPage :key="historyTab" :chart-series="memSeries" :y-formatter="yFormatter"/>
          </MDBTabPane>
          <MDBTabPane tab-id="history-swap">
            <ReportHistoryPage :key="historyTab" :chart-series="swapSeries" :y-formatter="yFormatter"/>
          </MDBTabPane>
        </MDBTabContent>
      </MDBTabs>
    </MDBCardBody>
  </MDBCard>
</template>

<script>
import {MDBBadge, MDBCard, MDBCardBody, MDBCardText, MDBCardTitle, MDBTabContent, MDBTabItem, MDBTabNav, MDBTabPane, MDBTabs} from "mdb-vue-ui-kit";
import ReportHistoryPage from "@/components/report/history/ReportHistoryPage";
import {ref} from "vue";

export default {
  components: {
    ReportHistoryPage,
    MDBCard,
    MDBCardBody,
    MDBCardTitle,
    MDBCardText,
    MDBBadge,
    MDBTabs,
    MDBTabNav,
    MDBTabItem,
    MDBTabContent,
    MDBTabPane,
  },
  props: {
    report: {
      type: Object
    }
  },
  data: function () {

    const memMetrics = ['mem/total', 'mem/free', 'mem/available', 'mem/buffers', 'mem/cached'];
    const swapMetrics = ['swap/cached', 'swap/total', 'swap/free'];

    const header = this.report.header;
    const data = this.report.data;
    const timeIndex = header.indexOf("timestamp");

    const memSeries = memMetrics.map(metric => {
      const index = header.indexOf(metric);
      return {name: metric, data: data.map(entry => [new Date(entry[timeIndex] * 1000), entry[index]])}
    })

    const swapSeries = swapMetrics.map(metric => {
      const index = header.indexOf(metric);
      return {name: metric, data: data.map(entry => [new Date(entry[timeIndex] * 1000), entry[index]])}
    })

    return {
      historyTab: ref('history-mem'),
      memSeries,
      swapSeries
    }
  },
  methods: {
    yFormatter(value) {
      return this.formatBytes(value * 1024);
    },
    formatBytes(value) {
      let b = 0, c = parseInt(value, 10) || 0;
      for (; 1024 <= c && ++b;) c /= 1024;
      return c.toFixed(10 > c && 0 < b ? 1 : 0) + " " + ["bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"][b]
    }
  }
}
</script>
