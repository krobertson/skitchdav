class Uploader
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Merb::Request.new(env)
    if request.path =~ %r{/files}
      filename = request.path.split('/').last

      puts "UPLOADER: #{request.method} #{request.path}"

      if request.put?
        entry = Entry.new
        file = Tempfile.open('wb')
        file.binmode
        file.write(request.raw_post)
        entry.image = Mash.new({'content_type' => 'image/jpeg', 'filename' => filename, 'size' => file.size, 'tempfile' => file})

        if entry.valid?
          entry.save
          ret = [201, {}, 'Created']
        else
          ret = [500, {}, entry.errors.to_json]
        end

        file.close
        file.unlink
        return ret
      elsif request.get? or request.head?
        entry = Entry.first(:image_file_name => filename)
        headers = { 'Content-Type' => entry.image_content_type, 'Content-Length' => entry.image_file_size.to_s }
        content = request.head? ? '' : IO.read(entry.image.path)
        return [200, headers, content]
      elsif request.delete?
        entry = Entry.first(:image_file_name => filename)
        entry.destroy
        return [200, {}, 'Deleted']        
      end
    else
      @app.call(env)
    end
  end
end
