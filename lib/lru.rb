class Lru
  Link = Struct.new(:value,:key,:prev,:next)
  attr_reader :size

  def initialize(max=10)
    @size = 0
    @cache = {}
    @max = max
    @list = nil
  end

  def create_link(item)
    ln = Link.new(fetch(item),item,nil,nil)
    ln.prev = ln
    ln.next = ln
  end

  def move_link(item)
    ln = Link.new(fetch(item),item,@list,nil)
    ln.prev = @list.prev
    ln.next = nil
    @list.prev = ln
  end

  def move_head(item)
    ln = @cache[item]
    ln.next = @list
    ln.prev.next = nil
    ln
  end

  def delete_key(item)
    @old = @list.prev
    old_key = @old.key
    @old.key = item
    @old.value = fetch(item)
    @cache[item] = @old

    @cache.delete(old_key)
  end

  def retrieve(item)
    if @cache[item]
      @list = move_head(item)
      return Optional.new(@cache[item],true)
    end

    if @size < @max
      @size += 1
      if @list.nil?
        @list = create_link(item)
      else
        @list = move_link(item)
      end
      @cache[item] = @list

      return Optional.new(@cache[item],false)
    else
      delete_key(item)

      return Optional.new(@cache[item],false)
    end
  end

  private

  def fetch(item)
    "THIS PAGE: #{item}"
  end
end

class Optional
  def initialize(item = nil, exists = false)
    @exists = exists
    @item = item if item
  end

  def missed?
    not @exists
  end

  def produce
    return item if @exists
    raise 'Trying to produce non existent cache item'
  end
end