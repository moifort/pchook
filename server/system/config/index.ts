import type { Brand } from 'ts-brand'

type ApiToken = Brand<string, 'ApiToken'>
type AnthropicApiKey = Brand<string, 'AnthropicApiKey'>
type GoogleApiKey = Brand<string, 'GoogleApiKey'>
type SentryDsn = Brand<string, 'SentryDsn'>

export const config = () => {
  const runtimeConfig = useRuntimeConfig()
  return {
    apiToken: runtimeConfig.apiToken as ApiToken,
    anthropicApiKey: runtimeConfig.anthropicApiKey as AnthropicApiKey,
    googleApiKey: runtimeConfig.googleApiKey as GoogleApiKey,
    sentryDsn: runtimeConfig.sentryDsn as SentryDsn,
  }
}
