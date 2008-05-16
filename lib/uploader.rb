class Uploader
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Merb::Request.new(env)
    if request.path =~ %r{/files} and request.put?
      #return [405, {}, 'Method not allowed, must use a POST request'] unless request.method.downcase == 'post'

      entry = Entry.new
      file = Tempfile.open('wb')
      file.binmode
      file.write(request.raw_post)
      entry.image = file

      if entry.valid?
        entry.save
        file.close
        file.unlink
        [201, {}, 'Created']
      else
        [500, {}, entry.errors.to_json]
      end
    else
      @app.call(env)
    end
  end
end
