<template>
  <MDBCard>
    <MDBCardBody>
      <MDBCardTitle class="d-flex">
        <span class="me-1">Summary</span>
        <MDBBadge color="primary">/proc/stat</MDBBadge>
      </MDBCardTitle>
      <MDBCardText>
        This section contains raw data from <code>/proc/stat</code>, visualised and with calculated relative (percent) share of the total CPU time.
        <ul>
          <li><em>Current run</em> represents the data between the start and the end of the report generation.</li>
          <li><em>All time</em> represents absolute values from the last system restart until the end of the report generation.</li>
        </ul>
      </MDBCardText>
      <!--suppress RequiredAttributes -->
      <MDBTabs v-model="summaryTab">
        <MDBTabNav tabsClasses="mb-3">
          <MDBTabItem tabId="summary-current-run" href="summary-current-run">Current run</MDBTabItem>
          <MDBTabItem tabId="summary-all-time" href="summary-all-time">All time</MDBTabItem>
        </MDBTabNav>
        <MDBTabContent>
          <MDBTabPane tabId="summary-current-run">
            <ReportSummaryPage :key="summaryTab" :stats="summaryCurrent.stats" :chart-series="summaryCurrent.series"/>
          </MDBTabPane>
          <MDBTabPane tabId="summary-all-time">
            <ReportSummaryPage :key="summaryTab" :stats="summaryAll.stats" :chart-series="summaryAll.series"/>
          </MDBTabPane>
        </MDBTabContent>
      </MDBTabs>
    </MDBCardBody>
  </MDBCard>
</template>

<script>
import {MDBBadge, MDBCard, MDBCardBody, MDBCardText, MDBCardTitle, MDBTabContent, MDBTabItem, MDBTabNav, MDBTabPane, MDBTabs} from "mdb-vue-ui-kit";
import ReportSummaryPage from "@/components/report/summary/ReportSummaryPage";
import {ref} from "vue";

export default {
  components: {
    MDBCard,
    MDBCardBody,
    MDBCardTitle,
    MDBCardText,
    MDBTabs,
    MDBTabNav,
    MDBTabItem,
    MDBTabContent,
    MDBTabPane,
    MDBBadge,
    ReportSummaryPage,
  },
  props: {
    report: {
      type: Object
    }
  },
  data: function () {

    const metrics = ['cpu/user', 'cpu/nice', 'cpu/system', 'cpu/idle', 'cpu/iowait', 'cpu/irq', 'cpu/softirq', 'cpu/steal', 'cpu/guest', 'cpu/guest_nice'];
    const header = this.report.header;
    const data = this.report.data;

    return {
      summaryTab: ref('summary-current-run'),
      summaryCurrent: this.getSummaryCurrent(metrics, header, data),
      summaryAll: this.getSummaryAll(metrics, header, data),
    }
  },
  methods: {
    getSummaryCurrent(metrics, header, data) {
      const firstRow = data[0];
      const lastRow = data[data.length - 1];
      const dataRow = lastRow.map((value, index) => value - firstRow[index]);
      return this.getSummary(metrics, header, dataRow)
    },
    getSummaryAll(metrics, header, data) {
      const dataRow = data[data.length - 1];
      return this.getSummary(metrics, header, dataRow)
    },
    getSummary(metrics, header, dataRow) {
      const stats = metrics.map(metric => {
        const name = metric.replace('cpu/', '');
        const value = dataRow[header.indexOf(metric)];
        const percent = value / this.rowSlice(dataRow, header, metrics).reduce((a, b) => a + b, 0) * 100;
        return {name, value, percent: (Number.isNaN(percent) ? 0 : percent)};
      });
      return {
        series: stats.map(stat => stat.value),
        stats: stats.sort((a, b) => (a.value > b.value) ? -1 : 1)
      }
    },
    rowSlice(row, header, metrics) {
      return row.filter((value, index) => {
        return metrics.includes(header[index]);
      });
    }
  }
}
</script>
