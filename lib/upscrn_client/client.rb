module UpscrnClient
  class Client
    class << self
       attr_accessor :auth_token

       def config
         yield self
       end

    end

    attr_accessor :auth_token





    def initialize(auth_token = nil)
      @auth_token = auth_token || self.class.auth_token
    end

      # Upload a screenshot to the upscrn server.
      # Pass :project_id in the options to upload to a particular project

      def upload_screenshot(filename, auth_token, options = {})
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
        perform('get', 'projects', auth_token)
      end

      def perform(verb,action,auth_token, params={})
        action = [action, 'json'].join('.')
        url = ['http://upscrn.com', action].join('/')
        url = url + "?auth_token=#{auth_token}"
        JSON.parse(RestClient.send(verb,url,params).body)
      end
    end
  end
end

