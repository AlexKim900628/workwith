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
      hi, today your wife called me and asked your cn phone num.
      it seems she will call you. plz let me know
      <li class="nav-item">
        <router-link
          class="nav-link"
          to="/contacts"
        >
          <p>Contacts</p>
        </router-link>