class Entries < Application
  # provides :xml, :yaml, :js

  def index
    @entries = Entry.all
    display @entries
  end

  def show(id)
    @entry = Entry[id]
    raise NotFound unless @entry
    display @entry
  end

  def new
    only_provides :html
    @entry = Entry.new
    render
  end

  def edit(id)
    only_provides :html
    @entry = Entry[id]
    raise NotFound unless @entry
    render
  end

  def create
    @entry = Entry.new(params[:entry])
    if @entry.save
      redirect url(:entry, @entry)
    else
      render :new
    end
  end

  def update
    @entry = Entry.get()
    raise NotFound unless @entry
    @entry.attributes = params[:entry]
    if  @entry.save
      redirect url(:entry, @entry)
    else
      raise BadRequest
    end
  end

  def destroy
    @entry = Entry.get()
    raise NotFound unless @entry
    if @entry.destroy
      redirect url(:entry)
    else
      raise BadRequest
    end
  end

end
