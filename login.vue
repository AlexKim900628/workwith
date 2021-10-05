<template>
  <navbar
    position="fixed"
    menu-classes="ml-auto"
    disable-route-watcher="true"
  >
    <template slot-scope="{ toggle, isToggled }">
      <router-link v-popover:popover1 class="navbar-brand" to="/">
        <img src="/img/logo.png">
        Foot-Corner
      </router-link>
    </template>
    <template slot="navbar-menu">
      <li class="nav-item">
        <router-link
          class="nav-link"
          to="/"
        >
          <p>Upcoming Matches</p>
        </router-link>
      </li>
      <li class="nav-item">
        <router-link
          class="nav-link"
          to="/blog"
        >
          <p>Blog</p>
        </router-link>
      </li>
      <li class="nav-item">
        <router-link
          class="nav-link"
          to="/subscription"
        >
          <p>Subscription</p>
        </router-link>
      </li>
      she is okay. not bad. she works in covid-defense firm nowadays. so it's not hard work.
      just one thing, she misses husband. :)
      yinhe still didn't get star. :(
      all are okay.
      <li class="nav-item">
        <router-link
          class="nav-link"
