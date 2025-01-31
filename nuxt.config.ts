// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: true },
  
  modules: [
    ['@pinia/nuxt', {
      imports: ['defineStore', 'storeToRefs']
    }],
    '@pinia-plugin-persistedstate/nuxt',
    async (options, nuxt) => {
      nuxt.hooks.hook('vite:extendConfig', async config => {
        const vuetify = await import('vite-plugin-vuetify')
        config.plugins = config.plugins || []
        config.plugins.push(vuetify.default())
      })
    }
  ],

  css: [
    'vuetify/lib/styles/main.sass',
    '@mdi/font/css/materialdesignicons.css',
    '~/assets/styles/main.sass'
  ],

  build: {
    transpile: ['vuetify']
  },

  vite: {
    define: {
      'process.env.DEBUG': false,
    },
    ssr: {
      noExternal: ['vuetify']
    },
    clearScreen: false,
    logLevel: 'info',
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

  imports: {
    dirs: ['stores']
  },

  typescript: {
    strict: true
  },

  compatibilityDate: '2025-01-15'
})
