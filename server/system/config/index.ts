import type { Brand } from 'ts-brand'

type ApiToken = Brand<string, 'ApiToken'>
type AnthropicApiKey = Brand<string, 'AnthropicApiKey'>
type GoogleApiKey = Brand<string, 'GoogleApiKey'>
type SentryDsn = Brand<string, 'SentryDsn'>
type ScanStrategy = 'claude' | 'native'

export const config = () => {
  const runtimeConfig = useRuntimeConfig()
  const rawStrategy = runtimeConfig.scanStrategy as string
  return {
    apiToken: runtimeConfig.apiToken as ApiToken,
    anthropicApiKey: runtimeConfig.anthropicApiKey as AnthropicApiKey,
    googleApiKey: runtimeConfig.googleApiKey as GoogleApiKey,
    sentryDsn: runtimeConfig.sentryDsn as SentryDsn,
    scanStrategy: (rawStrategy === 'native' ? 'native' : 'claude') as ScanStrategy,
  }
}
