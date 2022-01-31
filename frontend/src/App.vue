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

      <MDBCol md="12" v-if="!report">
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

      <MDBCol md="12" v-if="!report">
        <MDBCard>
          <MDBCardBody>
            <MDBCardTitle>2. Upload report</MDBCardTitle>
            <MDBFile size="lg" label="Please upload 'okaeri-timings-XXX.csv' file" accept=".csv" v-model="files"/>
          </MDBCardBody>
        </MDBCard>
      </MDBCol>

      <MDBCol md="12" v-if="report">
        <ReportDetails :meta="report.meta"/>
      </MDBCol>

      <MDBCol md="12" v-if="report">
        <ReportSummary :report="report"/>
      </MDBCol>

      <MDBCol md="12" v-if="report">
        <ReportHistoryProcStat :report="report"/>
      </MDBCol>

      <MDBCol md="12" v-if="report">
        <ReportHistoryProcMeminfo :report="report"/>
      </MDBCol>

    </MDBRow>
  </MDBContainer>

</template>

<script>
import {MDBCard, MDBCardBody, MDBCardText, MDBCardTitle, MDBCol, MDBContainer, MDBFile, MDBNavbar, MDBNavbarItem, MDBNavbarNav, MDBRow} from 'mdb-vue-ui-kit';
import ReportSummary from "@/components/report/summary/ReportSummary";
import ReportHistoryProcMeminfo from "@/components/report/history/ReportHistoryProcMeminfo";
import ReportHistoryProcStat from "@/components/report/history/ReportHistoryProcStat";
import ReportDetails from "@/components/report/ReportDetails";
import {ref} from "vue";

export default {
  components: {
    ReportDetails,
    ReportHistoryProcStat,
    ReportHistoryProcMeminfo,
    ReportSummary,
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
    MDBCardText
  },
  props: {
    msg: String
  },
  watch: {
    files: async function (value) {
      let formData = new FormData();
      formData.append('file', value[0]);
      this.report = await this.axios.post('/v1/parse', formData, {headers: {'Content-Type': 'multipart/form-data'}})
          .then((response) => response.data)
          .catch((error) => console.log(error));
    }
  },
  setup: function () {
    return {
      appUrl: process.env.VUE_APP_URL
    }
  },
  data: function () {
    return {
      files: ref([]),
      report: ref(),
    };
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
