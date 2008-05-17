class Uploader
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Merb::Request.new(env)
    if request.path =~ %r{/files}
      Merb.logger.debug "UPLOADER: #{request.method} #{request.path}"
      case request.method
      when :put    : put(request)
      when :get    : get_head(request)
      when :head   : get_head(request)
      when :delete : delete(request)
      else
        [ Merb::ControllerExceptions::MethodNotAllowed.status, {}, "Method not allowed.\n" ]
      end
    else
      @app.call(env)
    end
  end

  def authenticate(request, &authenticated)
    auth = Rack::Auth::Basic::Request.new(request.env)
    if auth.provided? and auth.basic?
      if [ Settings.instance.username, Settings.instance.password ] == auth.credentials
        authenticated.call
      else
        [ Merb::ControllerExceptions::Forbidden.status, {}, "Access denied.\n" ]
      end
    else
      [ Merb::ControllerExceptions::Unauthorized.status,
        { 'WWW-Authenticate' => 'Basic realm="SkitchDAV"' },
        "HTTP Basic: Access denied.\n" ]
    end
  end

  def get_head(request)
    filename = request.path.split('/').last
    entry = Entry.first(:image_file_name => filename)
    headers = { 'Content-Type' => entry.image_content_type, 'Content-Length' => entry.image_file_size.to_s }
    content = request.head? ? '' : IO.read(entry.image.path)
    [200, headers, content]
    #[301, { 'Location' => "/entries/#{entry.id}"}, 'Redirect']
  end

  def put(request)
    puts "blah blah blah blah"
    authenticate(request) do
      # write the request body to a temp file
      filename = request.path.split('/').last
      file = Tempfile.open('wb')
      file.binmode
      file.write(request.raw_post)

      # create the entry
      entry = Entry.new
      entry.image = Mash.new({'content_type' => 'image/jpeg', 'filename' => filename, 'size' => file.size, 'tempfile' => file})

      if entry.save
        ret = [201, {}, 'Created']
      else
        ret = [500, {}, entry.errors.to_json]
      end

      # close and remove the file
      file.close
      file.unlink
      ret
    end
  end

  def delete(request)
    authenticate(request) do
      filename = request.path.split('/').last
      entry = Entry.first(:image_file_name => filename)
      entry.destroy
      return [200, {}, 'Deleted']
    end
  end
end
