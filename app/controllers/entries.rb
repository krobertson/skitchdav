class Entries < Application
  # provides :xml, :yaml, :js

  def index
    @entries = Entry.all
    @entry = Entry.new
    display @entries
  end

  def show(id)
    @entry = Entry[id]
    raise NotFound unless @entry
    display @entry
  end

  def create
    @entry = Entry.new(params[:entry])
    @entry.image = params[:image]
    if @entry.save
  		flash[:notice] = "File has been uploaded and is ready for use!"
      redirect url(:entries)
    else
      render :index
    end
  end

  def destroy(id)
    @entry = Entry[id]
    raise NotFound unless @entry
    if @entry.destroy
      redirect url(:entries)
    else
      raise BadRequest
    end
  end
  
  def resize(id)
    @entry = Entry[id]
    raise NotFound unless @entry
    @entry.image_dimensions = "#{params[:width]}x#{params[:height]}>"
    @entry.image.reprocess!
    if @entry.save
      flash[:notice] = "Resized the image."
  		redirect url(:entry, @entry)
		else
		  raise BadRequest
	  end
  end

end
