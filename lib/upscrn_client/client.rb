module Upscrn
  class Client
    class << self

       attr_accessor :auth_token

       def config
         yield self
       end


      #### WARNING: THE CLASS METHODS ARE DEPRECATED

       # Upload a screenshot to the upscrn server.
      # Pass :project_id in the options to upload to a particular project

      def upload_screenshot(filename, auth_token, options = {})
        puts "DEPRECATED: will be removed on version 0.3"
        #puts "filepath: #{filepath}"
        @result = Hash.new
        @result['success'] = true
        file = File.open filename, 'r'
        begin
          if options[:project_id]
            post_response = perform("post", "projects/#{options[:project_id]}/screenshots", auth_token,  {:screenshot => {:image => @image}})
          else
            post_response = perform('post', 'screenshots', auth_token, {:screenshot => {:image => file}})
          end

          #puts "response: #{post_response}"
          @url = post_response["url"]
          @result['success'] = true
          @result['url'] = @url
          #puts "url = #{@url}"
          @url
        rescue Exception => e
          #puts "Exception!  #{e.message}"
          @result['success'] = false
          @result['error'] = e.message.to_s
        end
        @result
      end


      # return a list of projects for a given user
      # list is returned in json format
      def projects(auth_token)
        puts "DEPRECATED: will be removed on version 0.3"
        perform('get', 'projects', auth_token)
      end

      private

      def perform(verb,action,auth_token, params={})
        action = [action, 'json'].join('.')
        url = ['http://upscrn.com', action].join('/')
        url = url + "?auth_token=#{auth_token}"
        JSON.parse(RestClient.send(verb,url,params).body)
      end

    end

    attr_accessor :auth_token , :resources , :params



    def initialize(auth_token = nil)
      @auth_token = auth_token || self.class.auth_token
      @resources = []
      @params = {}
    end


    def projects(params = {})
       tap do
         @resources = ['projects']
         @params.merge!(params)
       end
    end

    def screenshots(params = {})
       tap do
         @resources += ['screenshots']
         @params.merge!(params)
       end
    end

    def comments(params = {})
       tap do
         @resources += ['comments']
         @params.merge!(params)
       end
    end

    def videos(params = {})
       tap do
         @resources += ['videos']
         @params.merge!(params)
       end
    end

    def project(id , params = {})
      tap do
        @resources = ['projects',id]
        @params.merge!(params)
      end
    end

    def screenshot(id , params = {})
      tap do
        @resources += ['screenshots',id]
        @params.merge!(params)
      end
    end

    def video(id , params = {})
      tap do
        @resources += ['videos',id]
        @params.merge!(params)
      end
    end

    def comment(params = {})
      tap do
        @resources += ['comments']
        @params.merge!(params)
      end
    end



    def get(clean = true)
      result = client[build_path(@auth_token,@resources,@params)].get
      self.clean if clean
      JSON.parse result
    end

    def post(clean = true)
      result = client[build_path(@auth_token,@resources)].post(@params)
      self.clean if clean
      JSON.parse result
    end

    def put(clean = true)
      result = client[build_path(@auth_token,@resources)].put(@params)
      self.clean if clean
      JSON.parse result
    end

    def clean
      tap do
        @resources = []
        @params = {}
      end
    end

    private

    def client
      @client ||= RestClient::Resource.new('http://upscrn.com')
    end

    def build_path(auth_token,resources , params = {})
      url = resources.join('/')
      url += '.json'
      url += "?" + params.merge(:auth_token => auth_token).to_a.map{|p| p.join('=')}.join('&')
      puts "Path built: #{url}"
      URI.encode(url)
    end

  end
end

