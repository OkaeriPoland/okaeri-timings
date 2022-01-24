import 'mdb-vue-ui-kit/css/mdb.min.css'
import 'typeface-roboto/index.css'

import {createApp} from 'vue'
import App from './App.vue'

import fontAwesome from "@/plugins/font-awesome";
import VueApexCharts from "vue3-apexcharts";

const app = createApp(App);
app.use(fontAwesome);
app.use(VueApexCharts);
app.mount('#app')
