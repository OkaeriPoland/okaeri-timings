<template>
  <MDBRow>
    <MDBCol md="7">
      <MDBTable>
        <thead>
        <tr>
          <th scope="col" style="width: 30%">#</th>
          <th scope="col" style="width: 40%">Value</th>
          <th scope="col" style="width: 30%">Share</th>
        </tr>
        </thead>
        <tbody>
        <tr v-for="stat in stats" :key="stat.name">
          <th scope="row">{{ stat.name }}</th>
          <td>{{ stat.value }}</td>
          <td>
            <template v-if="warningPoints[stat.name] && warningPoints[stat.name](stat.percent) !== null">
              <MDBBadge :color="warningPoints[stat.name](stat.percent)">
                {{ (stat.percent).toFixed(3) }}%
                <font-awesome-icon icon="exclamation-triangle"/>
              </MDBBadge>
            </template>
            <template v-else>
              {{ (stat.percent).toFixed(3) }}%
            </template>
          </td>
        </tr>
        </tbody>
      </MDBTable>
    </MDBCol>
    <MDBCol md="5" class="d-flex flex-column">
      <apexchart type="pie" height="300" class="mb-4" :options="chartOptions" :series="chartSeries"></apexchart>
      <MDBBtn outline="primary" class="mt-auto ms-auto" aria-controls="summaryHelp" @click="summaryHelpModal = true">
        <font-awesome-icon icon="question-circle"/>
        Help
      </MDBBtn>
    </MDBCol>

    <MDBModal id="summaryHelpModal" tabindex="-1" labelledby="summaryHelpModalLabel" class="modal-big" v-model="summaryHelpModal">
      <MDBModalHeader>
        <MDBModalTitle id="summaryHelpModalLabel"><font-awesome-icon icon="question-circle"/> Help</MDBModalTitle>
      </MDBModalHeader>
      <MDBModalBody>
        <h6>user</h6>
        <p>
          Time spent in user mode.<br>
          (e.g. <mark>applications</mark>)
        </p>

        <h6>nice</h6>
        <p>
          Time spent in user mode with low priority (nice).<br>
          (e.g. <mark>applications running with <a href="https://en.wikipedia.org/wiki/Nice_(Unix)" target="_blank" rel="noopener nofollow noreferrer">nice > 0</a></mark>)
        </p>

        <h6>system</h6>
        <p>
          Time spent in system mode.<br>
          (e.g. <mark>networking</mark>, <mark>firewall</mark>, <mark>drivers</mark>)
        </p>

        <h6>idle</h6>
        <p>Time spent in the idle task. This value should be USER_HZ times the second entry in the /proc/uptime pseudo-file.</p>

        <h6>iowait <small>(since Linux 2.5.41)</small></h6>
        <p>Time waiting for I/O to complete. This value is not reliable, for the following reasons:</p>
        <ol>
          <li>
            The CPU will not wait for I/O to complete; iowait is the time that a task is waiting for I/O to complete.
            When a CPU goes into idle state for outstanding task I/O, another task will be scheduled on this CPU.
          </li>
          <li>
            On a multi-core CPU, the task waiting for I/O to complete is not running on any CPU, so the iowait
            of each CPU is difficult to calculate.
          </li>
          <li>
            The value in this field may decrease in certain conditions.
          </li>
        </ol>

        <h6>irq <small>(since Linux 2.6.0)</small></h6>
        <p>Time servicing interrupts.</p>

        <h6>softirq <small>(since Linux 2.6.0)</small></h6>
        <p>Time servicing softirqs.</p>

        <h6>steal <small>(since Linux 2.6.11)</small></h6>
        <p>Stolen time, which is the time spent in other operating systems when running in a virtualized environment.</p>

        <h6>guest <small>(since Linux 2.6.24)</small></h6>
        <p>Time spent running a virtual CPU for guest operating systems under the control of the Linux kernel.</p>

        <h6>guest_nice <small>(since Linux 2.6.33)</small></h6>
        <p>Time spent running a niced guest (virtual CPU for guest operating systems under the control of the Linux kernel).</p>
      </MDBModalBody>
      <MDBModalFooter>

        <p class="mb-0 me-auto">
          This help page comes from the Linux manual for proc:
          <a href="#" @click="copyrightCollapse = !copyrightCollapse" aria-controls="copyrightCollapse" :aria-expanded="copyrightCollapse">Copyright</a>,
          <a href="#" @click="licenseCollapse = !licenseCollapse" aria-controls="licenseCollapse" :aria-expanded="licenseCollapse">License</a>
        </p>
        <MDBBtn color="primary" @click="summaryHelpModal = false">Close</MDBBtn>

        <MDBCollapse id="copyrightCollapse" v-model="copyrightCollapse" class="w-100">
<pre class="mt-2 mb-0">
Copyright (C) 1994, 1995 by Daniel Quinlan (quinlan@yggdrasil.com)
and Copyright (C) 2002-2008,2017 Michael Kerrisk &lt;mtk.manpages@gmail.com&gt;
with networking additions from Alan Cox (A.Cox@swansea.ac.uk)
and scsi additions from Michael Neuffer (neuffer@mail.uni-mainz.de)
and sysctl additions from Andries Brouwer (aeb@cwi.nl)
and System V IPC (as well as various other) additions from
Michael Kerrisk &lt;mtk.manpages@gmail.com&gt;
</pre>
        </MDBCollapse>

        <MDBCollapse id="licenseCollapse" v-model="licenseCollapse" class="w-100">
<pre class="mt-2 mb-0">
This is free documentation; you can redistribute it and/or
modify it under the terms of the GNU General Public License as
published by the Free Software Foundation; either version 2 of
the License, or (at your option) any later version.

The GNU General Public License's references to "object code"
and "executables" are to be interpreted as the output of any
document formatting or typesetting system, including
intermediate and printed output.

This manual is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public
License along with this manual; if not, see
&lt;http://www.gnu.org/licenses/&gt;.
</pre>
        </MDBCollapse>

      </MDBModalFooter>
    </MDBModal>

  </MDBRow>
</template>

<script>
import {MDBBadge, MDBBtn, MDBCol, MDBModal, MDBModalBody, MDBModalFooter, MDBModalHeader, MDBModalTitle, MDBRow, MDBTable, MDBCollapse} from "mdb-vue-ui-kit";
import {ref} from "vue";

export default {
  components: {
    MDBRow,
    MDBCol,
    MDBTable,
    MDBBadge,
    MDBBtn,
    MDBModal,
    MDBModalHeader,
    MDBModalTitle,
    MDBModalBody,
    MDBModalFooter,
    MDBCollapse
  },
  watch: {
    copyrightCollapse: function (value) {
      if (value) {
        setTimeout(() => document.getElementById("copyrightCollapse").scrollIntoView({behavior: 'smooth'}), 250);
      }
    },
    licenseCollapse: function (value) {
      if (value) {
        setTimeout(() => document.getElementById("licenseCollapse").scrollIntoView({behavior: 'smooth'}), 250);
      }
    },
  },
  props: {
    stats: {
      type: Array
    },
    warningPoints: {
      type: Object,
      default: function () {
        return {
          user: function (value) {
            return (value > 90) ? 'danger' : (value > 70) ? 'warning' : null
          },
          system: function (value) {
            return (value > 20) ? 'danger' : (value > 10) ? 'warning' : null
          },
          idle: function (value) {
            return (value < 10) ? 'danger' : (value < 30) ? 'warning' : null
          },
          iowait: function (value) {
            return (value > 10) ? 'danger' : (value > 3) ? 'warning' : null
          },
          steal: function (value) {
            return (value > 20) ? 'danger' : (value > 5) ? 'warning' : null
          },
          guest: function (value) {
            return (value > 90) ? 'danger' : (value > 70) ? 'warning' : null
          },
        };
      }
    },
    chartOptions: {
      type: Object,
      default: function () {
        return {
          labels: ['user', 'nice', 'system', 'idle', 'iowait', 'irq', 'softirq', 'steal', 'guest', 'guest_nice'],
          colors: ['#00aa00', '#0000aa', '#aa0000', '#aaaaaa', '#ff5555', '#ffaa00', '#ff00ff', '#44dddd', '#00aaaa', '#00aaaa'],
          animations: {enabled: false},
        };
      }
    },
    chartSeries: {
      type: Array
    }
  },
  data: function () {
    return {
      summaryHelpModal: ref(false),
      copyrightCollapse: ref(false),
      licenseCollapse: ref(false),
    }
  }
}
</script>

<style scoped>
.badge {
  font-size: unset;
}
</style>

<style>
.modal-big .modal-dialog {
  max-width: 1000px;
}
</style>
