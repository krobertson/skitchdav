class Uploader
  def initialize(app)
    @app = app
  end

  def authenticate(request, &authenticated)
    auth = Rack::Auth::Basic::Request.new(request.env)

    if auth.provided? and auth.basic?
      if [ Settings.instance.username, Settings.instance.password ] == auth.credentials
        authenticated.call
      else
        [ Merb::ControllerExceptions::Forbidden.status,
          { },
          "Access denied.\n" ]
      end
    else
      [ Merb::ControllerExceptions::Unauthorized.status,
        { 'WWW-Authenticate' => 'Basic realm="SkitchDAV"' },
        "HTTP Basic: Access denied.\n" ]
    end
  end

  def call(env)
    request = Merb::Request.new(env)
    puts "UPLOADER: #{request.method} #{request.path}"
    if request.path =~ %r{/files}
      filename = request.path.split('/').last


      if request.put?
        authenticate(request) do
          entry = Entry.new
          file = Tempfile.open('wb')
          file.binmode
          file.write(request.raw_post)
          entry.image = Mash.new({'content_type' => 'image/jpeg', 'filename' => filename, 'size' => file.size, 'tempfile' => file})

          if entry.save
            ret = [201, {}, 'Created']
          else
            ret = [500, {}, entry.errors.to_json]
          end

          file.close
          file.unlink
          return ret
        end
      elsif request.get? or request.head?
        entry = Entry.first(:image_file_name => filename)
        headers = { 'Content-Type' => entry.image_content_type, 'Content-Length' => entry.image_file_size.to_s }
        content = request.head? ? '' : IO.read(entry.image.path)
        return [200, headers, content]
      elsif request.delete?
        authenticate(request) do
          entry = Entry.first(:image_file_name => filename)
          entry.destroy
          return [200, {}, 'Deleted']
        end
      end
    else
      @app.call(env)
    end
  end
end
