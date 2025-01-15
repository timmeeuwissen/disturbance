<template lang="pug">
div.min-h-screen.bg-gray-100
  nav.bg-white.shadow-sm
    .max-w-7xl.mx-auto.px-4.sm:px-6.lg:px-8
      .flex.justify-between.h-16
        .flex
          .flex-shrink-0.flex.items-center
            h1.text-xl.font-bold Disturbance Monitor
          .hidden.sm:ml-6.sm:flex.sm:space-x-8
            NuxtLink.inline-flex.items-center.px-1.pt-1.text-sm.font-medium(
              to="/"
              :class="$route.path === '/' ? 'text-gray-900 border-b-2 border-indigo-500' : 'text-gray-500 hover:text-gray-700'"
            ) New Issue
            NuxtLink.inline-flex.items-center.px-1.pt-1.text-sm.font-medium(
              to="/issues"
              :class="$route.path === '/issues' ? 'text-gray-900 border-b-2 border-indigo-500' : 'text-gray-500 hover:text-gray-700'"
            ) Issues Overview
            NuxtLink.inline-flex.items-center.px-1.pt-1.text-sm.font-medium(
              to="/analytics"
              :class="$route.path === '/analytics' ? 'text-gray-900 border-b-2 border-indigo-500' : 'text-gray-500 hover:text-gray-700'"
            ) Analytics
  main
    .max-w-7xl.mx-auto.py-6.sm:px-6.lg:px-8
      slot
</template>

<script setup lang="ts">
// Layout script
</script>

<style lang="sass">
// Layout styles
</style>
