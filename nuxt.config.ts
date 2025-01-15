// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: true },
  modules: [
    '@nuxtjs/tailwindcss'
  ],
  css: [
    '~/assets/styles/main.sass'
  ],
  app: {
    head: {
      title: 'Disturbance Monitor',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' }
      ]
    }
  },
  build: {
    transpile: ['@heroicons/vue']
  },
  vite: {
    css: {
      preprocessorOptions: {
        sass: {
          additionalData: '@use "sass:math"\n'
        }
      }
    }
  },
  runtimeConfig: {
    public: {
      apiBase: '/api'
    }
  }
})
