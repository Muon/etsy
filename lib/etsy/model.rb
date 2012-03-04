module Etsy
  module Model # :nodoc:all

    module ClassMethods

      def attribute(name, options = {})
        from = options.fetch(:from, name).to_s

        if name == :id
          define_method :id_field do
            from
          end
        end

        define_method name do
          result[from]
        end
      end

      def attributes(*names)
        names.each {|name| attribute(name) }
      end

      def association(name, options = {})
        from = (options.delete(:from) || name).to_s
        class_name = (options.delete(:class) || from).to_s
        define_method name do
          unless result[from]
            opts = { :includes => from, :fields => id_field }.merge(oauth_info).merge(options)
            result[from] = self.class.find(id, opts).send(:result)[from]
          end

          if result[from].is_a? Array
            result[from].map { |x| Etsy.const_get(class_name).new(x, token, secret) }
          else
            Etsy.const_get(class_name).new(result[from], token, secret)
          end
        end
      end

      def get(endpoint, options = {})
        objects = get_all(endpoint, options)
        if objects.length == 0
          nil
        elsif objects.length == 1
          objects[0]
        else
          objects
        end
      end

      def get_all(endpoint, options={})
        limit = options[:limit]

        if limit
          initial_offset = options.fetch(:offset, 0)
          batch_size = options.fetch(:batch_size, 100)

          result = []

          if limit == :all
            response = Request.get(endpoint, options.merge(:limit => batch_size, :offset => initial_offset))
            result << response.result
            limit = [response.count - batch_size - initial_offset, 0].max
            initial_offset += batch_size
          end

          num_batches = limit / batch_size

          num_batches.times do |batch|
            total_offset = initial_offset + batch * batch_size
            response = Request.get(endpoint, options.merge(:limit => batch_size, :offset => total_offset))
            result << response.result
          end

          remainder = limit % batch_size

          if remainder > 0
            total_offset = initial_offset + num_batches * batch_size
            response = Request.get(endpoint, options.merge(:limit => remainder, :offset => total_offset))
            result << response.result
          end
        else
          response = Request.get(endpoint, options)
          result = response.result
        end

        [result].flatten.map do |data|
          if options[:access_token] && options[:access_secret]
            new(data, options[:access_token], options[:access_secret])
          else
            new(data)
          end
        end
      end

      def post(endpoint, options={})
        Request.post(endpoint, options)
      end

      def find_one_or_more(endpoint, identifiers_and_options)
        options = options_from(identifiers_and_options)
        append = options.delete(:append_to_endpoint)
        append = append.nil? ? "" : "/#{append}"
        identifiers = identifiers_and_options
        get("/#{endpoint}/#{identifiers.join(',')}#{append}", options)
      end

      def options_from(argument)
        (argument.last.class == Hash) ? argument.pop : {}
      end

    end

    def initialize(result = nil, token = nil, secret = nil)
      @result = result
      @token = token
      @secret = secret
    end

    def token
      @token
    end

    def secret
      @secret
    end

    def result
      @result
    end

    def oauth_info
      (token && secret) ? { :access_token => token, :access_secret => secret } : {}
    end

    def self.included(other)
      other.extend ClassMethods
    end
  end
end
