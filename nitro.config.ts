import { generateDomainInstrumentation } from './server/system/sentry/generate-domain-instrumentation'

export default defineNitroConfig({
  compatibilityDate: '2026-02-06',
  experimental: { asyncContext: true },
  srcDir: 'server',
  ignore: ['test/**', '**/*.test.ts'],
  rollupConfig: {
    treeshake: {
      moduleSideEffects: (id) => id.includes('/graphql/') || id.includes('node_modules'),
    },
  },
  virtual: {
    '#domain-instrumentation': generateDomainInstrumentation,
  },
  runtimeConfig: {
    apiToken: '',
    anthropicApiKey: '',
    googleApiKey: '',
    hardcoverApiToken: '',
    sentryDsn: '',
    scanStrategy: '',
  },
  storage: {
    'migration-meta': { driver: 'fs', base: './.data/db/migration-meta' },
    books: { driver: 'fs', base: './.data/db/books' },
    images: { driver: 'fs', base: './.data/db/images' },
    series: { driver: 'fs', base: './.data/db/series' },
    'series-books': { driver: 'fs', base: './.data/db/series-books' },
    reviews: { driver: 'fs', base: './.data/db/reviews' },
    'scan-cache': { driver: 'fs', base: './.data/db/scan-cache' },
    'audible-credentials': { driver: 'fs', base: './.data/db/audible-credentials' },
    'audible-mappings': { driver: 'fs', base: './.data/db/audible-mappings' },
    'audible-auth-sessions': { driver: 'fs', base: './.data/db/audible-auth-sessions' },
  },
})
