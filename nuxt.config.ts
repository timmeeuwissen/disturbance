// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: true },
  
  modules: ['vuetify/nuxt'],

  css: [
    'vuetify/lib/styles/main.sass',
    '@mdi/font/css/materialdesignicons.css',
    '~/assets/styles/main.sass'
  ],

  build: {
    transpile: ['vuetify']
  },

  vuetify: {
    moduleOptions: {
      /* module specific options */
    },
    vuetifyOptions: {
      /* vuetify options */
      ssr: false
    }
  },

  vite: {
    define: {
      'process.env.DEBUG': false,
    },
    clearScreen: false,
    logLevel: 'warning',
    server: {
      hmr: {
        overlay: true
      }
    }
  },

  ssr: false,

  app: {
    head: {
      title: 'Disturbance Monitor',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' }
      ]
    }
  },

  runtimeConfig: {
    public: {
      apiBase: '/api'
    }
  },

  compatibilityDate: '2025-01-15'
})
