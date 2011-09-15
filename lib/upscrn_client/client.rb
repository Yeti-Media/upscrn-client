module UpscrnClient
  class Client
    class << self

      
      # Upload a screenshot to the upscrn server. 
      # Pass :project_id in the options to upload to a particular project
      
      def upload_screenshot(filename, auth_token, options = {})
        puts "filepath: #{filepath}"
        @result = Hash.new
        @result['success'] = true
        file = File.open filename, 'r'
        begin
          if options[:project_id]
            post_response = perform("post", "projects/#{options[:project_id]}/screenshots", auth_token,  {:screenshot => {:image => @image}})
          else
            post_response = perform('post', 'screenshots', auth_token, {:screenshot => {:image => file}})
          end
  
          puts "response: #{post_response}"
          @url = post_response["url"]
          @result['success'] = true
          @result['url'] = @url
          #clickable_link = NSAttributedString.hyperlinkFromString("See on upscrn", withURL:nsurl)
          puts "url = #{@url}"
          #@url_label.stringValue = nsurl
          #show_screenshot_url(@url, nsurl)
          @url
        rescue Exception => e
          puts "Exception!  #{e.message}"
          @result['success'] = false
          puts "1"
          @result['error'] = e.message.to_s
          puts "set result"
          #@url_label.stringValue = e.message
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
        #url = ['http://127.0.0.1:3000', action].join('/')
        url = url + "?auth_token=#{auth_token}"
        #p url
        JSON.parse(RestClient.send(verb,url,params).body)
      end
    end
  end
end