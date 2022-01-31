<template>
  <MDBCard>
    <MDBCardBody>
      <MDBCardTitle class="d-flex">
        <span class="me-1">Report from {{ new Date().toLocaleString() }}</span>
        <MDBBadge color="primary">OT-v1.0</MDBBadge>
      </MDBCardTitle>
      <MDBRow>
        <MDBCol md="12">
          <MDBTable class="mb-0">
            <thead>
            <tr>
              <th scope="col">#</th>
              <th scope="col">Value</th>
            </tr>
            </thead>
            <tbody>
            <tr v-for="key in Object.keys(meta)" :key="key">
              <th scope="row">{{ key }}</th>
              <td>{{ meta[key] }}</td>
            </tr>
            </tbody>
          </MDBTable>
        </MDBCol>
      </MDBRow>
    </MDBCardBody>
  </MDBCard>
</template>

<script>
import {MDBBadge, MDBCard, MDBCardBody, MDBCardTitle, MDBTable, MDBRow, MDBCol} from "mdb-vue-ui-kit";

export default {
  components: {
    MDBCard,
    MDBCardBody,
    MDBCardTitle,
    MDBTable,
    MDBBadge,
    MDBRow,
    MDBCol
  },
  props: {
    meta: Object
  }
}
</script>

<style scoped>
table th, table td {
  padding: .2em;
}
</style>
