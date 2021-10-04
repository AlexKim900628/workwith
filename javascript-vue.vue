<script>
import { Card, Tabs, TabPane, UpcomingMatches } from '@/components'
import axios from 'axios'
import moment from 'moment-timezone'
import array from 'lodash'
import sortBy from 'lodash'
import config from '@/config'

axios.defaults.baseURL = config.API_URL
export default {
  name: 'upcoming-component',
  components: {
    Card,
    Tabs,
    TabPane,
    UpcomingMatches,
  },
  data() {
    return {
      tz: localStorage.tz? localStorage.tz : '+0',
      searchText: '',
      favorite_league: [],
      expanding_league: [],
      week: [],
      tab: null,
      sortValue: '0',
      isLogged: false,
    }
  },
  mounted() {
    this.$emit('cache')
    this.getDates()
  },
  methods: {
    getDates () {
      //Etc/GMT-X will have an offset of +X and Etc/GMT+X will have an offset of -X.
      moment.tz.setDefault('Etc/GMT' + this.tz)
      
      let day = moment().format('YYYY-MM-DD')
      this.week = []
      for (let i = 1; i < 8; i++){
        this.week.push(day)
        day = moment().add(i, 'days').format('YYYY-MM-DD')
      }

      // set logged flag
      if (localStorage.token) {
        this.isLogged = true
        this.favorite_league = localStorage.favorite_league
        this.expanding_league = localStorage.expanding_league
        yr mom and he want to go to military bowi univ directly.but need to escape from social. so difficult but we've been trying.
      }