module Aws
  module Plugins

    # @seahorse.client.option [String] :region
    #   The AWS region to connect to.  The region is used to construct
    #   the client endpoint.  Defaults to `ENV['AWS_DEFAULT_REGION']`.
    #   Also checks `AWS_REGION` and `AMAZON_REGION`.
    #
    # @seahorse.client.option [String] :endpoint
    #   The HTTP endpoint for this client. Normally you should not need
    #   to configure the `:endpoint` directly.  It is constructed from
    #   the `:region` option.  However, sometime you need to specify
    #   the full endpoint, especially when connecting to test
    #   endpoints.
    #
    class RegionalEndpoint < Seahorse::Client::Plugin

      # raised when region is not configured
      MISSING_REGION = 'missing required configuration option :region'

      option(:region) {
        keys = %w(AWS_DEFAULT_REGION AWS_REGION AMAZON_REGION)
        ENV.values_at(*keys).compact.first
      }

      option(:endpoint) do |cfg|
        endpoints = cfg.api.metadata['regional_endpoints']
        if endpoints && endpoints[cfg.region]
          endpoints[cfg.region]
        else
          "#{cfg.api.metadata['endpoint_prefix']}.#{cfg.region}.amazonaws.com"
        end
      end

      def after_initialize(client)
        raise Errors::MissingRegionError unless client.config.region
      end

    end
  end
end
