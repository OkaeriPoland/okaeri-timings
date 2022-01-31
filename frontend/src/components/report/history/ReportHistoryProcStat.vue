<template>
  <MDBCard>
    <MDBCardBody>
      <MDBCardTitle class="d-flex">
        <span class="me-1">History</span>
        <MDBBadge color="primary">/proc/stat</MDBBadge>
      </MDBCardTitle>
      <MDBCardText>
        This section contains data (currently <code>{{ historyTab.replace('history-', '') }}</code>) changes over time represented as a relative (percent) share of the total CPU time.
      </MDBCardText>
      <!--suppress RequiredAttributes -->
      <MDBTabs v-model="historyTab">
        <MDBTabNav tabsClasses="mb-3">
          <MDBTabItem v-for="series in historySeries" :key="series.name" :tabId="`history-${series.name}`" :href="`history-${series.name}`">{{ series.name }}</MDBTabItem>
        </MDBTabNav>
        <MDBTabContent>
          <MDBTabPane v-for="series in historySeries" :key="series.name" :tabId="`history-${series.name}`">
            <ReportHistoryPage :key="historyTab" :name="series.name" :chart-series="[series]"/>
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
    MDBTabs,
    MDBTabNav,
    MDBTabItem,
    MDBTabContent,
    MDBTabPane,
    MDBBadge,
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

    const timeIndex = header.indexOf("timestamp");
    const cpuDataSums = data
        .map(row => this.rowSlice(row, header, metrics))
        .map(row => row.reduce((a, b) => a + b, 0))

    const series = metrics.map(metric => {
      const headerIndex = header.indexOf(metric);
      const name = metric.replace('cpu/', '');
      const mData = data.map((entry, rowIndex) => {
        let share = rowIndex > 0
            ? (entry[headerIndex] - data[rowIndex - 1][headerIndex]) / (cpuDataSums[rowIndex] - cpuDataSums[rowIndex - 1])
            : entry[headerIndex] / cpuDataSums[rowIndex];
        return [
          new Date(entry[timeIndex] * 1000),
          share * 100
        ];
      });
      return {name, data: mData}
    });

    return {
      historyTab: ref('history-steal'),
      historySeries: series
    }
  },
  methods: {
    rowSlice(row, header, metrics) {
      return row.filter((value, index) => {
        return metrics.includes(header[index]);
      });
    }
  }
}
</script>
