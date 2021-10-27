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
  I sent your thoughts to her. But she hopes, bcz please hear sth.
  First, current eco situation is very difficult. The value of USD drops 50%. And she says it has no expectation for when u return. :)
  And second, u asked company & her role. It is company on muryokbu and her role is not set yet. But if she has got a investment from her own client, it would be clear that she became key role in that company. She says the techniques of the team are very high, better than european. So if she got machines, start produce and export them directly to her client. She says many people interested in yobrokso in Jirin or CN. So they will greet for paying with yobrokso production for the investment. And that is the just reason why she finds pharmacy client. She would only contact between her client and her company. Then she would do key role and take a higher job. Ofcz, it will be more discussed after she got the investment.
  I hope you could understand my briefings.
  Thanks
  methods: {}
};
</script>

<style>
</style>