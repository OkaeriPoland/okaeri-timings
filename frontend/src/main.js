import 'mdb-vue-ui-kit/css/mdb.min.css'
import 'typeface-roboto/index.css'

import {createApp} from 'vue'
import App from './App.vue'

import axios from 'axios'
import VueAxios from 'vue-axios'
import fontAwesome from "@/plugins/font-awesome";
import VueApexCharts from "vue3-apexcharts";

const app = createApp(App);
app.use(VueAxios, axios);
app.use(fontAwesome);
app.use(VueApexCharts);
app.mount('#app')

app.axios.defaults.baseURL = process.env.VUE_APP_API_URL;
