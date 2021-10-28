<template>
    <v-card flat>
        <v-card-text v-if="!isLoaded" >
            <div class='ripple_loading' ><img src='/img/icons/Ripple-1s-200px.png'></div>
        </v-card-text>
        <v-card-text v-else>
            <v-list v-if="sortValue==1" flat expand>
              <v-list-group
                  v-for="group in byTime"
                  :key="group.time + group.league"
                  value=1
              >
                  <template v-slot:activator>
                    <v-list-item-icon>
                        <v-img class='flag' :src="'/img/flag/'+ group.games[0].league_country.code + '.png'"></v-img>
                    </v-list-item-icon>
                    <v-list-item-title v-text="group.league" class="group-label"></v-list-item-title>
                  </template>
                  <v-list-item
                    v-for="game in group.games"
                    :key="game.time"
                  >
                    <v-list-item-title>{{ game.start_dt | moment('HH:mm') }}
                        <router-link :to="{name: 'soccermatch', params: {ct: game.league_country.name, id: game.match_id}}">
                        {{ game.local_name }}&nbsp;&nbsp;&nbsp;
                        VS&nbsp;&nbsp;&nbsp;
                        {{ game.visitor_name }}
                        </router-link>
                    </v-list-item-title>
                  </v-list-item>
              </v-list-group>
            </v-list>
            <v-list v-else flat expand>
              <v-list-group
                  v-for="group in byCountryLeague"
                  :key="group.league"
                  :value="group.expanded? 1 : 0"
                  v-on:click.native.stop="$emit('upd_expand', group.expanded, group.league_id)"
                  no-action
              >
                  <template v-slot:activator>
                    <v-btn 
                        v-if="isLogged"
                        dark
                        icon 
                        v-on:click.native.stop="$emit('upd_favstar', group.fav_star, group.league_id)"
                    >
                        <v-icon v-if="group.fav_star" color="grey lighten-1">
                          mdi-star-outline
                        </v-icon>
                        <v-icon v-else color="yellow">
                          mdi-star
                        </v-icon>
                    </v-btn>
                    <v-list-item-icon>
                        <v-img class='flag' :src="'/img/flag/'+ group.games[0].league_country.code + '.png'"></v-img>
                    </v-list-item-icon>
                    <v-list-item-title v-text="group.league" class="group-label"><a href='/' /></v-list-item-title>
                  </template>

                  <v-list-item
                  v-for="game in group.games"
                  :key="game.match_id"
                  >
                    <v-list-item-title>{{ game.start_dt | moment('HH:mm') }}
                        <router-link :to="{name: 'soccermatch', params: {ct: game.league_country.name, id: game.match_id}}">
                        {{ game.local_name }}&nbsp;&nbsp;&nbsp;
                        VS&nbsp;&nbsp;&nbsp;
                        {{ game.visitor_name }}
                        </router-link>
                    </v-list-item-title>
                  </v-list-item>
              </v-list-group>
            </v-list>
        </v-card-text>
    </v-card>
</template>
<script>
import axios from 'axios'
import moment from 'moment-timezone'
import array from 'lodash'
import sortBy from 'lodash'
import config from '@/config'

axios.defaults.baseURL = config.API_URL
export default {
  name: 'upcoming-matches',
  props: [
      'dt',
      'favorite_league',
      'expanding_league',
      'searchText',
      'sortValue',
      'isLogged',
      'tz'],
  components: {},
  computed: {
    byTime() {
      let sch = this.searchText
      let allGames = []
      let regex = RegExp(sch, 'i')

      if (sch == '') allGames = this.matches
      else {
        this.matches.forEach((evt) => {
          if (regex.test(evt.local_name) || regex.test(evt.visitor_name)
              || regex.test(evt.league_name) || regex.test(evt.league_country.name)) {

                allGames.push(evt)

          }
        })
      }

      /* grouping Label : startHour + league */
      let label = function(game){
          return moment(game['start_dt']).format("HH:mm") + game['league_country']['name'] + ', ' + game['league_name']
      }

      let grouping = function(group, label){
          return {
              time: label.substring(0, 5),
              league: label.substring(5),
              games: _.orderBy(group, ['start_dt', 'league_country.code'])
          }
      }
      
      let result = _.chain(allGames)
          .groupBy(label)
          .map(grouping)
          .sortBy('time', 'league')
          .value()

      return result
    },
    byCountryLeague() {
        let sch = this.searchText
        let allGames = []
        let regex = RegExp(sch, 'i')

        if (sch == '') allGames = this.matches
        else {
          this.matches.forEach((evt) => {
            if (regex.test(evt.local_name) || regex.test(evt.visitor_name)
                || regex.test(evt.league_name) || regex.test(evt.league_country.name)) {
                  
                  allGames.push(evt)

            }
          })
        }

        let league = function(game){
            return game['league_country']['name'] + ', ' + game['league_name']
        }

        let lg = this.favorite_league
        let exp = this.expanding_league
        let groupToLeague = function(group, league){
            return {
                league: league,
                league_id: group[0]['league_id'],
                fav_star: (lg && lg.includes(group[0]['league_id']))? 0 : 1,
                expanded: (exp && exp.includes(group[0]['league_id']))? 1 : 0,
                games: _.orderBy(group, 'start_dt')
            }
        }

        let result = _.chain(allGames)
            .groupBy(league)
            .map(groupToLeague)
            .sortBy('fav_star', 'league')
            .value()
            
        return result    
    }
  },
  data() {
    return {
      matches: [{
          match_id: '',
          local_id: '',
          local_name: '',
          visitor_id: '',
          visitor_name: '',
          winner_id: '',
          league_id: '',
          league_name: '',
          league_country: {
            code: '',
            name: ''
            },
          season_id: '',
          season_name: '',
          referee_id: '',
          referee_name: '',
          start_dt: ''
        }],
      isLoaded: false,
    }
  },
  created: function() {
    this.isLoaded = false
    
    let from, to
    // check current time due to timezone
    if (this.dt == moment().format('YYYY-MM-DD')) {
      from = moment().utc().format('YYYY-MM-DD HH:mm')
      to = moment(this.dt).add('days', 1).utc().format('YYYY-MM-DD HH:mm')
    } else {
      from = moment(this.dt).utc().format('YYYY-MM-DD HH:mm')
      to = moment(from).add('days', 1).format('YYYY-MM-DD HH:mm')
    }
    axios
    .get('/upcoming/'+from+'/'+to)
    .then(response => {
      this.matches = response.data
      this.isLoaded = true
    })
    .catch(error => {})
  },
  She met him(manager for that project in company) and received some docs about their past works with a client in Jirin pharmacy co. He produced sample products and sent to his client. At that time, the client quoted 93% about his sample products.
ywf says it(main 90% products) costs 12k in cn, 15k in eu. And the rest sth which are remained during production, costs 1.5k in our country. She hopes for importing machines and exporting the products to yr client. And yr client sold them.
She is majored in Medical and has a pharmacy client, so he(manager) promised to hire ywf as bookeeper.
Then ywf will be on duty related to finance on this project. They say they can produce and export now if yr client needs sample products.
Thanks
  methods: {}
};
</script>

<style>
</style>