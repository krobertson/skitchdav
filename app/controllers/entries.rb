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
    # create the entry
    @entry = Entry.new
    @entry.image = params[:image]

    # save
    if @entry.save
  		flash[:notice] = "File has been uploaded and is ready for use!"
      redirect url(:entries)
    else
      render :index
    end
  end

  def destroy(id)
    # get the entry
    @entry = Entry[id]
    raise NotFound unless @entry

    # delete
    if @entry.destroy
      redirect url(:entries)
    else
      raise BadRequest
    end
  end

  def settings
    # protect from get requests
    raise BadRequest unless request.post?

    # Update the default dimensions
    if Settings.update_dimensions("#{params[:width]}x#{params[:height]}>")
  		flash[:notice] = "Settings have been updated.  They will only affect new images."
  		redirect url(:entries)
		else
		  raise BadRequest
	  end
  end

  def resize(id)
    # protect from get requests
    raise BadRequest unless request.post?

    # get the entry
    @entry = Entry[id]
    raise NotFound unless @entry

    # change the dimensions and process
    @entry.image_dimensions = "#{params[:width]}x#{params[:height]}>"
    @entry.image.reprocess!
    if @entry.save
      # set flash and redirect
      flash[:notice] = "Resized the image."
  		redirect url(:entry, @entry)
		else
		  raise BadRequest
	  end
  end

end
