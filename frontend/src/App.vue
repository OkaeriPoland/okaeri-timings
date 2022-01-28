<template>

  <MDBNavbar expand="lg" dark bg="dark" container>
    <MDBNavbarNav class="mb-lg-0">
      <MDBNavbarItem href="#" class="font-weight-bold" active>Okaeri Timings</MDBNavbarItem>
    </MDBNavbarNav>
    <MDBNavbarNav right class="mb-lg-0">
      <MDBNavbarItem href="https://github.com/OkaeriPoland/okaeri-timings" active>
        <font-awesome-icon :icon="['fab', 'github']"/>
        GitHub
      </MDBNavbarItem>
    </MDBNavbarNav>
  </MDBNavbar>

  <MDBContainer class="my-5">
    <MDBRow class="gy-4">

      <MDBCol md="12" v-if="!summaryLoaded">
        <MDBCard>
          <MDBCardBody>
            <MDBCardTitle>1. Generate report</MDBCardTitle>
            <MDBCardText>
              Execute this command on your Linux based system:
              <pre class="mt-2 mb-4">curl -s {{ appUrl }}/otimings.sh | bash -s 60</pre>
              <strong>Note:</strong> report generation takes a long time. Make sure it runs till the end (e.g. using <code>screen</code>)
              for the best results. The default run-time is <code>60</code> minutes and cannot be shorter than 5 minutes. After the script
              finalizes its run, the file named 'okaeri-timings-XXX.csv' (e.g. 'okaeri-timings-1642975054.csv') will be available.
            </MDBCardText>
          </MDBCardBody>
        </MDBCard>
      </MDBCol>

      <MDBCol md="12" v-if="!summaryLoaded">
        <MDBCard>
          <MDBCardBody>
            <MDBCardTitle>2. Upload report</MDBCardTitle>
            <MDBFile size="lg" label="Please upload 'okaeri-timings-XXX.csv' file" accept=".csv" v-model="files"/>
          </MDBCardBody>
        </MDBCard>
      </MDBCol>

      <MDBCol md="12" v-if="summaryLoaded">
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
            <MDBTabs v-model="summaryTab">
              <MDBTabNav tabsClasses="mb-3">
                <MDBTabItem tabId="summary-current-run" href="summary-current-run">Current run</MDBTabItem>
                <MDBTabItem tabId="summary-all-time" href="summary-all-time">All time</MDBTabItem>
              </MDBTabNav>
              <MDBTabContent>
                <MDBTabPane tabId="summary-current-run">
                  <Summary :key="summaryTab" :stats="summaryStats" :chart-series="summarySeries"/>
                </MDBTabPane>
                <MDBTabPane tabId="summary-all-time">
                  <Summary :key="summaryTab" :stats="summaryStatsAll" :chart-series="summarySeriesAll"/>
                </MDBTabPane>
              </MDBTabContent>
            </MDBTabs>
          </MDBCardBody>
        </MDBCard>
      </MDBCol>

      <MDBCol md="12" v-if="summaryLoaded">
        <MDBCard>
          <MDBCardBody>
            <MDBCardTitle class="d-flex">
              <span class="me-1">History</span>
              <MDBBadge color="primary">/proc/stat</MDBBadge>
            </MDBCardTitle>
            <MDBCardText>
              This section contains data (currently <code>{{ historyTab.replace('history-', '') }}</code>) changes over time represented as a relative (percent) share of the total CPU time.
            </MDBCardText>
            <MDBTabs v-model="historyTab">
              <MDBTabNav tabsClasses="mb-3">
                <MDBTabItem v-for="label in dataLabels" :key="label" :tabId="`history-${label}`" :href="`history-${label}`">{{ label }}</MDBTabItem>
              </MDBTabNav>
              <MDBTabContent>
                <MDBTabPane v-for="label in dataLabels" :key="label" :tabId="`history-${label}`">
                  <History :key="historyTab" :name="label" :chart-series="historySeries[label]"/>
                </MDBTabPane>
              </MDBTabContent>
            </MDBTabs>
          </MDBCardBody>
        </MDBCard>
      </MDBCol>

      <MDBCol md="12" v-if="summaryLoaded">
        <MDBCard>
          <MDBCardBody>
            <MDBCardTitle class="d-flex">
              <span class="me-1">History</span>
              <MDBBadge color="primary">/proc/meminfo</MDBBadge>
            </MDBCardTitle>
            <MDBCardText>
              This section contains memory usage changes over time.
            </MDBCardText>
            <code>TODO</code>
          </MDBCardBody>
        </MDBCard>
      </MDBCol>

    </MDBRow>
  </MDBContainer>

</template>

<script>
import {
  MDBBadge,
  MDBCard,
  MDBCardBody,
  MDBCardText,
  MDBCardTitle,
  MDBCol,
  MDBContainer,
  MDBFile,
  MDBNavbar,
  MDBNavbarItem,
  MDBNavbarNav,
  MDBRow,
  MDBTabContent,
  MDBTabItem,
  MDBTabNav,
  MDBTabPane,
  MDBTabs
} from 'mdb-vue-ui-kit';
import Summary from "@/components/Summary";
import History from "@/components/History";
import {ref} from "vue";

export default {
  components: {
    History,
    Summary,
    MDBNavbar,
    MDBNavbarNav,
    MDBNavbarItem,
    MDBContainer,
    MDBCard,
    MDBCardBody,
    MDBCardTitle,
    MDBFile,
    MDBRow,
    MDBCol,
    MDBTabs,
    MDBTabNav,
    MDBTabItem,
    MDBTabContent,
    MDBTabPane,
    MDBCardText,
    MDBBadge
  },
  props: {
    msg: String
  },
  watch: {
    files: async function (value) {
      this.rawData = (await this.fileToString(value[0])).split(/\r?\n/).map(l => l.split(" "));
      const firstLineData = this.rawData[0].slice(1).map(i => parseInt(i));
      const lastLineData = this.rawData[this.rawData.length - 1].slice(1).map(i => parseInt(i));
      // update summary
      this.summarySeriesAll = lastLineData;
      this.summarySeries = lastLineData.map((i, index) => i - firstLineData[index]);
      this.summaryLoaded = true;
      // update history
      this.dataLabels.forEach((label, index) => {
        this.historySeries[label] = this.calculateHistory(this.rawData, index);
      });
    },
    summarySeries: function (value) {
      this.summaryStats = this.calculateSummaryStats(value);
    },
    summarySeriesAll: function (value) {
      this.summaryStatsAll = this.calculateSummaryStats(value);
    }
  },
  setup: function () {
    return {
      dataLabels: ['user', 'nice', 'system', 'idle', 'iowait', 'irq', 'softirq', 'steal', 'guest', 'guest_nice'],
      appUrl: process.env.VUE_APP_URL
    }
  },
  data: function () {
    return {
      files: ref([]),
      rawData: undefined,
      // summary
      summaryTab: ref('summary-current-run'),
      summaryLoaded: false,
      summaryStats: [],
      summaryStatsAll: [],
      summarySeries: [],
      summarySeriesAll: [],
      // steal
      historyTab: ref('history-steal'),
      historySeries: {},
    };
  },
  methods: {
    fileToString(file) {
      return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.readAsText(file, "UTF-8");
        reader.onload = event => resolve(event.target.result)
        reader.onerror = event => reject(event);
      });
    },
    calculateSummaryStats(data) {
      const dataTotal = data.reduce((a, b) => a + b, 0);
      let stats = [];
      this.dataLabels.forEach((label, index) => {
        stats[index] = {
          name: label,
          value: data[index],
          percent: (data[index] / dataTotal) * 100
        }
      });
      stats.sort((a, b) => {
        return (a.value > b.value) ? -1 : 1;
      });
      return stats;
    },
    calculateHistory(rawData, index) {
      let history = [];
      let lastTotal = 0;
      let lastValue = 0;
      rawData.forEach(line => {
        const date = new Date(line[0]);
        const rawValue = parseInt(line[index + 1]);
        const value = rawValue - lastValue;
        const rawTotal = line.slice(1).map(i => parseInt(i)).reduce((a, b) => a + b, 0);
        const total = rawTotal - lastTotal;
        history.push([date, ((value / total) * 100)])
        lastTotal = rawTotal;
        lastValue = rawValue;
      })
      return history;
    }
  }
}
</script>

<style>
body {
  min-height: 100vh;
  background-color: #eaeaea;
}

#app {
  font-family: 'Roboto', Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

pre {
  border: 1px solid;
  border-radius: 2px;
  background-color: rgba(0, 0, 0, 0.05);
  padding: 5px;
}
</style>
