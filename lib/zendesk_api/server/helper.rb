module ZendeskAPI::Server
  module Helper
    def get_documentation(file)
      File.join(settings.documentation_dir, "#{file}.md")
    end

    def help
      File.open(get_documentation("introduction")) {|f| f.read}
    end

    def map_headers(headers)
      headers.map do |k,v|
        name = k.split("-").map(&:capitalize).join("-")
        "#{name}: #{v}"
      end.join("\n")
    end

    def set_request(request)
      @html_request = <<-END
HTTP/1.1 #{@method.to_s.upcase} #{request[:url]}
#{map_headers(request[:request_headers])}
      END

      if @method != :get && @json && !@json.empty?
        parsed_json = CodeRay.scan(@json, :json).span
        @html_request << "\n\n#{parsed_json}"
      end
    end

    def set_response(response)
      @html_response =<<-END
HTTP/1.1 #{response[:status]}
#{map_headers(response[:headers])}


#{CodeRay.scan(JSON.pretty_generate(response[:body]), :json).span}
      END
    end

    def client(params = params)
      ZendeskAPI::Client.new do |c|
        params.each do |key, value|
          value = "https://#{value}.zendesk.com/api/v2/" if key == 'url'
          c.send("#{key}=", value)
        end
      end
    end
  end
end