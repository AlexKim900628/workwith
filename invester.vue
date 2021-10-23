this.fLocal = true
        this.fVisitor = true

        this.calledLast = false
        this.calledLeague = false
        this.calledSquad = false
        this.leagueLoaded = false
        this.leagues = []
        this.seasons = []
        this.totalSeasons = []

        this.basicLoaded = false
        this.lastAvgLoaded = false
        this.statsLoaded = false
        this.squadLoaded = false
        this.lastLoaded = false
                
        this.currentCoach = false
        this.prevCoach = false
        this.chosenLeagues = []
        this.chosenSeasons = []
        this.querySeasons = ''
        
        this.getBasics()
      },

      perPage: function (val) {
        if (this.lastLoaded) {
          this.page = 0
          this.lastPage = -1
          this.last = []
          this.statsLoaded = false
        
          this.getLast()
        }
      },

      chosenLeagues: function (val) {
        if (this.lastLoaded)
          this.changeQSeasons()
      },

      chosenSeasons: function (val) {
        if (this.lastLoaded)
          this.changeQSeasons()
      },

      currentCoach (val) {
        if (this.lastLoaded) {
          this.page = 0
          this.lastPage = -1
          this.last = []
          this.statsLoaded = false
          
          this.getLast()
        }
      },

      prevCoach (val) {
        if (this.lastLoaded) {
          this.page = 0
          this.lastPage = -1
          this.last = []
          this.statsLoaded = false
          
          this.getLast()
        }
      },

      fLocal (val) {
        if (this.lastLoaded) {
          if (!val && !this.fVisitor) {
            this.fLocal = !val
          }else {
            this.page = 0
            this.lastPage = -1
            this.last = []
            this.statsLoaded = false

            this.getLast()
          }
        }
      },
      
      fVisitor (val) {
        if (this.lastLoaded) {
          if (!val && !this.fLocal) {
            this.fVisitor = !val
          }else {
            this.page = 0
            this.lastPage = -1
            this.last = []
            this.statsLoaded = false

            this.getLast()
          }
        }
      },

      fullHalf (val) {
        this.page = 0
        this.lastPage = -1
        this.last = []
        this.statsLoaded = false

        this.getLast()
      }
  },
  methods: {
      async getBasics() {
        //Etc/GMT-X will have an offset of +X and Etc/GMT+X will have an offset of -X.
        moment.tz.setDefault('Etc/GMT' + this.tz)

        axios
        .get('/team_info/' + this.$route.params.id)
        .then(response => {
            let data = response.data

            this.team.id = data.id
            this.team.name = data.name
            this.team.logo = data.logo_path? data.logo_path : ''
            this.team.isNational = data.national_team? data.national_team : ''
            this.team.founded = data.founded? data.founded : ''
            
            this.league.id = data.league? data.league.data.id : ''
            this.league.name = data.league? data.league.data.name : ''
            this.league.logo = data.league? data.league.data.logo_path : ''
            this.league.season_id = data.league? data.league.data.current_season_id : ''

            this.country.id = data.country? data.country.data.id : ''
            this.country.name = data.country? data.country.data.name : ''
            this.country.flag = data.country? '/img/flag/' + data.country_id + '.png' : ''

            this.venue = data.venue? data.venue.data : ''
            this.coach = data.coach? data.coach.data : ''

            this.trophies = data.trophies.data.map((item, key) => ({...item, key}))

            this.ranking[0] = data.fifaranking? data.fifaranking.data : null
            this.ranking[1] = data.uefaranking? data.uefaranking.data : null

            this.basicLoaded = true
            this.getSquad()
            this.getLast()
            this.callLeague()
        })
        //.catch(error => {})
      },

      getSquad() {
        if (!localStorage.token) {
          this.message = "Sorry, please login to view these data. Thanks."
          this.squadLoaded = true
        } else {
          axios
          .get('/team_squad/' + this.league.season_id + '/' + this.team.id,
            { 'headers': { 'Authorization': 'Token ' + localStorage.token } })
          .then(response => {
            if (response.data.type == 0) {
              this.message = "Sorry, you have not permission to view these data. Please subscribe for it. Thanks."
            }else if (response.data.type == 1) {
              this.message = "Sorry, your subscription has expired. Kindly pay to view these data. Thanks."
            }else {
              let pls = response.data.data

              pls.forEach((item) => {
                if (item.position_id == 1) this.squad.goalkeeper.push(item)
                else if (item.position_id == 2) this.squad.defender.push(item)
                else if (item.position_id == 3) this.squad.midfielder.push(item)
                else this.squad.attacker.push(item)
              })

              this.authorization = true

              this.player = this.squad.goalkeeper[0]
              
              /* get most appearances */
              
              let appears = pls.sort((a, b) => (b.appearences) - (a.appearences))
              this.mostAppears = appears.splice(0, 10)

            }
            this.squadLoaded = true
          })
          .catch(error => {
            if (error.response.status == 401) {
              localStorage.removeItem('token')
              localStorage.removeItem('uid')
              location.reload()
            }              
          })
        }
      },

      // return x % n
      get_remaining(x, n) {
        return (x - 1 + n) % n + 1;
      },

      // get suitable per page
      get_perPage(total, per) {
        for (let i = per; i <= total; i++) {
          if (this.get_remaining(total, i) >= per) return i
        }
        return total
      },

      callLeague() {
        if (!localStorage.token) {
          this.message = "Sorry, please login to view these data. Thanks."
          this.squadLoaded = true
        } else {
          axios
            .get('/get_seasonByTeam/' + this.team.id,
              { 'headers': { 'Authorization': 'Token ' + localStorage.token } })
            .then(response => {
              this.leagues = response.data.leagues
              this.seasons = response.data.seasons.sort().reverse()
              this.totalSeasons = response.data.totalSeason
              this.leagueLoaded = true
              this.showLeague = true
            })
            .catch(error => {
              if (error.response.status == 401) {
                localStorage.removeItem('token')
                localStorage.removeItem('uid')
                location.reload()
              }              
            })
        }
      },
      
      changeQSeasons() {
        let querys = ''
        this.totalSeasons.forEach((item) => {
          let leagues = this.chosenLeagues.filter(function (league) { return league == item.league_id })
          let seasons = this.chosenSeasons.filter(function (season) { return season == item.season_name })
          if((this.chosenLeagues.length == 0 || leagues.length > 0) && (this.chosenSeasons.length == 0 || seasons.length > 0))
            querys += (item.season_id + ',')
        })
        
        if(!querys) {
          if (this.lastLoaded)
            querys = '-1'
          else
            querys = 0
        }

        this.querySeasons = querys

        this.page = 0
        this.lastPage = -1
        this.last = []
        this.statsLoaded = false

        this.getLast()
      },

      getLast() {
        if (!localStorage.token) {
          this.msg_last = "Sorry, please login to view the Last Matches. Thanks."
          this.lastLoaded = true
        } else {
          let seasons, coach, prevcoach, home, away
          home = this.fLocal? 1 : 0
          away = this.fVisitor? 1: 0
          coach = this.currentCoach? this.coach.coach_id : 0
          prevcoach = this.prevCoach? this.coach.coach_id : 0
          seasons = !this.querySeasons? 0 : this.querySeasons

          axios
          .get(
            '/getLast/',{
              params: {
                id: this.team.id,
                seasons: seasons,
                pgNo: this.page,
                perPage: this.perPage,
                home: home,
                away: away,
                coach: coach,
                prevcoach: prevcoach,
                fullHalf: this.fullHalf,
                similar: 0
                },
              headers: { 'Authorization': 'Token ' + localStorage.token } })
          .then(response => {
            if (response.data.type == 0) {
              this.msg_last = "Sorry, you have not permission to view the Last Matches. Please subscribe for it. Thanks."
            }else if (response.data.type == 1) {
              this.msg_last = "Sorry, your subscription had expired. Kindly pay to view the Last Matches. Thanks."
            }else {
              response = response.data

              let lastAvg = {}
              let otherLastAvg = {}
              if (!this.page) {
                lastAvg.cornerMatch = response.stats.corner[0] + response.stats.corner[1] + response.stats.corner[2]
                lastAvg.cornerWDL = response.stats.corner
                lastAvg.cornerPoint = 3 * response.stats.corner[0] + response.stats.corner[1]
                lastAvg.cornerDiff = response.stats.tCorner + ' - ' + response.stats.oCorner
                lastAvg.cornerDiff_avg = !lastAvg.cornerMatch? 0 : ((response.stats.tCorner - response.stats.oCorner) / lastAvg.cornerMatch).toFixed(2)
                lastAvg.cornerTotal = !lastAvg.cornerMatch? 0 : ((response.stats.tCorner + response.stats.oCorner) / lastAvg.cornerMatch).toFixed(2)
                lastAvg.cornerT1 = !lastAvg.cornerMatch? 0 : (response.stats.tCorner / lastAvg.cornerMatch).toFixed(2)
                lastAvg.cornerT2 = !lastAvg.cornerMatch? 0 : (response.stats.oCorner / lastAvg.cornerMatch).toFixed(2)

                lastAvg.goalMatch = response.stats.goal[0] + response.stats.goal[1] + response.stats.goal[2]
                lastAvg.goalWDL = response.stats.goal
                lastAvg.goalPoint = 3 * response.stats.goal[0] + response.stats.goal[1]
                lastAvg.goalDiff = response.stats.tGoal + ' - ' + response.stats.oGoal
                lastAvg.goalDiff_avg = !lastAvg.goalMatch? 0 : ((response.stats.tGoal - response.stats.oGoal) / lastAvg.goalMatch).toFixed(2)
                lastAvg.goalTotal = !lastAvg.goalMatch? 0 : ((response.stats.tGoal + response.stats.oGoal) / lastAvg.goalMatch).toFixed(2)
                lastAvg.goalT1 = !lastAvg.goalMatch? 0 : (response.stats.tGoal / lastAvg.goalMatch).toFixed(2)
                lastAvg.goalT2 = !lastAvg.goalMatch? 0 : (response.stats.oGoal / lastAvg.goalMatch).toFixed(2)

                lastAvg.cardMatch = response.stats.card
                lastAvg.cardDiff_yc = response.stats.tYC + ' - ' + response.stats.oYC
                lastAvg.cardTotal_yc = !lastAvg.cardMatch? 0 : ((response.stats.tYC + response.stats.oYC) / lastAvg.cardMatch).toFixed(2)
                lastAvg.cardT1_yc = !lastAvg.cardMatch? 0 : (response.stats.tYC / lastAvg.cardMatch).toFixed(2)
                lastAvg.cardT2_yc = !lastAvg.cardMatch? 0 : (response.stats.oYC / lastAvg.cardMatch).toFixed(2)
                lastAvg.cardDiff_rc = response.stats.tRC + ' - ' + response.stats.oRC
                lastAvg.cardTotal_rc = !lastAvg.cardMatch? 0 : ((response.stats.tRC + response.stats.oRC) / lastAvg.cardMatch).toFixed(2)
                lastAvg.cardT1_rc = !lastAvg.cardMatch? 0 : (response.stats.tRC / lastAvg.cardMatch).toFixed(2)
                lastAvg.cardT2_rc = !lastAvg.cardMatch? 0 : (response.stats.oRC / lastAvg.cardMatch).toFixed(2)
              
                // get avg stats for other tab
                otherLastAvg.win = response.stats.avg_w
                otherLastAvg.draw = response.stats.avg_d
                otherLastAvg.lost = response.stats.avg_l
                otherLastAvg.point = []
                otherLastAvg.match = []
                otherLastAvg.diff = []
                otherLastAvg.diff_av = []
                otherLastAvg.total = []
                otherLastAvg.t1 = []
                otherLastAvg.t2 = []
                for(let i = 0; i < 21; i++) {
                  otherLastAvg.point.push((3 * response.stats.avg_w[i]) + response.stats.avg_d[i])
                  otherLastAvg.match.push(response.stats.avg_w[i] + response.stats.avg_d[i] + response.stats.avg_l[i])
                  otherLastAvg.diff.push(response.stats.avg_t1[i] + ' - ' + response.stats.avg_t2[i])
                  otherLastAvg.diff_av.push(!otherLastAvg.match[i]? 0 : ((response.stats.avg_t1[i] - response.stats.avg_t2[i]) / otherLastAvg.match[i]).toFixed(2))
                  otherLastAvg.total.push(!otherLastAvg.match[i]? 0 : ((response.stats.avg_t1[i] + response.stats.avg_t2[i]) / otherLastAvg.match[i]).toFixed(2))
                  otherLastAvg.t1.push(!otherLastAvg.match[i]? 0 : (response.stats.avg_t1[i] / otherLastAvg.match[i]).toFixed(2))
                  otherLastAvg.t2.push(!otherLastAvg.match[i]? 0 : (response.stats.avg_t2[i] / otherLastAvg.match[i]).toFixed(2))
                }
                
                this.lastAvg = lastAvg
                this.otherLastAvg = otherLastAvg
                this.lastAvgLoaded = true
              }

              if (response.stats.foundCount == 0) {
                if (this.page == 0) {
                  this.lastPage = 0
                }else {
                  this.page -= 1
                  this.lastPage = this.page                  
                }
              }else {
                if (this.perPage == 'All' || response.stats.foundCount < this.perPage) {
                  this.lastPage = this.page
                }
                this.last[this.page] = response.stats.data
              }
              this.authorization = true
            }
            
            this.lastLoaded = true
            this.statsLoaded = true

          })
          .catch(error => {
            if (error.response.status == 401) {
              localStorage.removeItem('token')
              localStorage.removeItem('uid')
              location.reload()
            }              
          })
        }
      },

      cornerModal(id, home_id, home, away) {
        if (this.last[this.page][id].corners.data.length != 0) {
          this.subCorner.dt = this.last[this.page][id].date
          this.subCorner.home = home
          this.subCorner.away = away
          this.subCorner.data = []
          this.last[this.page][id].corners.data.forEach((evt) => {
            let item = {
                comment: evt.comment,
                h_m: '',
                a_m: ''
              }
            if (evt.team_id == home_id) item.h_m = (evt.extra_minute)? evt.minute + '+' + evt.extra_minute + "'" : evt.minute + "'"
            else item.a_m = (evt.extra_minute)? evt.minute + '+' + evt.extra_minute + "'" : evt.minute + "'"
            this.subCorner.data.push(item)
          })
          this.$modal.show('subCornerModal')
        }
      },

      coachModal() {
          this.$modal.show('coachModal')
      },

      cardModal(id, home_id, home, away) {
        if (this.last[this.page][id].cards.length != 0) {
          this.subCard.dt = this.last[this.page][id].date
          this.subCard.home = home
          this.subCard.away = away
          this.subCard.data = []
          this.last[this.page][id].cards.forEach((evt) => {
            let item = {
                player: evt.player_name,
                minute: (evt.extra_minute)? evt.minute + '+' + evt.extra_minute + "'" : evt.minute + "'",
                h_c: '',
                a_c: ''
              }
            if (evt.team == home_id) item.h_c = evt.type
            else item.a_c = evt.type

            this.subCard.data.push(item)
          })
          this.$modal.show('subCardModal')
        }
      },

      goalModal(id, home_id, home, away) {
        if (this.last[this.page][id].goals.length != 0) {
          this.subGoal.dt = this.last[this.page][id].date
          this.subGoal.home = home
          this.subGoal.away = away
          this.subGoal.data = []
          this.last[this.page][id].goals.forEach((evt) => {
            let item = {
                player: evt.player_name,
                minute: (evt.extra_minute)? evt.minute + '+' + evt.extra_minute + "'" : evt.minute + "'",
                h_g: '',
                a_g: ''
              }
            if (evt.team_id == home_id) item.h_g = evt.type
            else item.a_g = evt.type

            this.subGoal.data.push(item)
          })
          this.$modal.show('subGoalModal')
        }
      },

      playerModal(member) {
        this.player = member
        this.playerDialog = true
      },

      venueModal() {
          this.$modal.show('venueModal')
      },

      prev() {
        this.page++
        if (!this.last[this.page]) {
          this.statsLoaded = false
          this.getLast()        
        }
      },

      next() {
        this.page--
      },

      perPageChange(evt) {
        this.perPage = this.pPageByUser
      },

      tabChange() {
        /* tab = 6 for Scorers */
        if (this.tab == 6) {
          if (this.scorers) {
            this.tabLoaded = true
          } else {
            if (!localStorage.token) {
              this.message = "Sorry, please login to view these data. Thanks."
              this.tabLoaded = true
            } else {
              this.tabLoaded = false

              axios
                .get('/team_scorers/' + this.$route.params.id + '/' + this.league.season_id,
                  { 'headers': { 'Authorization': 'Token ' + localStorage.token } })
                .then(response => {
                  /* 
                    Set scorers from null to []
                    To prevent duplication api calls for unsubscribed user
                  */
                  this.scorers = []

                  if (response.data.type == 0) {
                    this.message = "Sorry, you have not permission to view these data. Please subscribe for it. Thanks."
                  }else if (response.data.type == 1) {
                    this.message = "Sorry, your subscription has expired. Kindly pay to view these data. Thanks."
                  }else {
                    this.scorers = response.data
                    this.arrangeScorers()
                    this.authorization = true
                  }
                  this.tabLoaded = true
                })
                .catch(error => {
                  if (error.response.status == 401) {
                    localStorage.removeItem('token')
                    localStorage.removeItem('uid')
                    location.reload()
                  }              
                })
            }
          }
        }

        /* tab = 7 for Statistics */
        if (this.tab == 7) {
          if (this.teamStats) {
            this.tabLoaded = true
          } else {
            if (!localStorage.token) {
              this.message = "Sorry, please login to view these data. Thanks."
              this.tabLoaded = true
            } else {
              this.tabLoaded = false

              axios
                .get('/team_stats/' + this.$route.params.id + '/' + this.league.season_id,
                  { 'headers': { 'Authorization': 'Token ' + localStorage.token } })
                .then(response => {
                  /* 
                    Set Statistics from null to []
                    To prevent duplication api calls for unsubscribed user
                  */
                  this.teamStats = []

                  if (response.data.type == 0) {
                    this.message = "Sorry, you have not permission to view these data. Please subscribe for it. Thanks."
                  }else if (response.data.type == 1) {
                    this.message = "Sorry, your subscription has expired. Kindly pay to view these data. Thanks."
                  }else {
                    this.teamStats = response.data.data.slice().reverse()

                    this.authorization = true
                  }
                  this.tabLoaded = true
                })
                .catch(error => {
                  if (error.response.status == 401) {
                    localStorage.removeItem('token')
                    localStorage.removeItem('uid')
                    location.reload()
                  }              
                })
            }
          }
        }

        /* tab = 8 for Transfers */
        if (this.tab == 8) {
          if (this.transfers) {
            this.tabLoaded = true
          } else {
            if (!localStorage.token) {
              this.message = "Sorry, please login to view these data. Thanks."
              this.tabLoaded = true
            } else {
              this.tabLoaded = false

              axios
                .get('/team_transfers/' + this.$route.params.id,
                  { 'headers': { 'Authorization': 'Token ' + localStorage.token } })
                .then(response => {
                  /* 
                    Set transfers from null to []
                    To prevent duplication api calls for unsubscribed user
                  */
                  this.transfers = []

                  if (response.data.type == 0) {
                    this.message = "Sorry, you have not permission to view these data. Please subscribe for it. Thanks."
                  }else if (response.data.type == 1) {
                    this.message = "Sorry, your subscription has expired. Kindly pay to view these data. Thanks."
                  }else {
                    this.transfers = response.data.data
                    this.authorization = true
                  }
                  this.tabLoaded = true
                })
                .catch(error => {
                  if (error.response.status == 401) {
                    localStorage.removeItem('token')
                    localStorage.removeItem('uid')
                    location.reload()
                  }              
                })
            }
          }
        }

        /* tab = 9 for Rivals */
        if (this.tab == 9) {
          if (this.rivals) {
            this.tabLoaded = true
          } else {
            if (!localStorage.token) {
              this.message = "Sorry, please login to view these data. Thanks."
              this.tabLoaded = true
            } else {
              this.tabLoaded = false

              axios
                .get('/team_rivals/' + this.$route.params.id,
                  { 'headers': { 'Authorization': 'Token ' + localStorage.token } })
                .then(response => {
                  /* 
                    Set rivals from null to []
                    To prevent duplication api calls for unsubscribed user
                  */
                  this.rivals = []

                  if (response.data.type == 0) {
                    this.message = "Sorry, you have not permission to view these data. Please subscribe for it. Thanks."
                  }else if (response.data.type == 1) {
                    this.message = "Sorry, your subscription has expired. Kindly pay to view these data. Thanks."
                  }else {
                    this.rivals = response.data.data
                    this.authorization = true
                  }
                  this.tabLoaded = true
                })
                .catch(error => {
                  if (error.response.status == 401) {
                    localStorage.removeItem('token')
                    localStorage.removeItem('uid')
                    location.reload()
                  }              
                })
            }
          }
        }
      },
      
      /*
        mothod for arrange goalscorers, assists, cardscorers
      */
      arrangeScorers() {
        let goal = this.scorers.goalscorers.data.sort((a, b) => (b.goals + b.penalty_goals) - (a.goals + a.penalty_goals))
        let card = this.scorers.cardscorers.data.sort((a, b) => (b.yellowcards + b.redcards) - (a.yellowcards + a.redcards))
        let assist = this.scorers.assistscorers.data.sort((a, b) => b.assists - a.assists)

        this.scorers = {'goal': goal, 'card': card, 'assist': assist}
      },

      /*
        event for show stats Dialog
      */
      showStats(ind) {
        this.curStage = ind
        this.statsDialog = true
      },
  }
};
</script>
ywife called me and asked sth.
she knows somebody who needs investment for his company. The company began a new plan for 'Yob-lok-so'(kr name, en: chlorophyll) in the past. But it was failed due to some reasons. And now he(maybe CEO) plans to do it again and finds the invester for it. He says that many people knows chlorophyll in Jirin Prov.
It may be around 100k usd. She(yr wf) seems to get a job in that company. And she thought you had a client who works in pharmacy company so contacted me to ask if you are possible to do it. Now it's impossible to invest by cash but production facilities are possible to be imported.

Please let me know yr thoughts. Thanks

<style>
  @import '../assets/footcorner/soccermatch.css';
</style>
