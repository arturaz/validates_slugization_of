module Arturaz
  module ValidatesSlugizationOf
    # Create and validate slug for attribute.
    #
    # Sets up validation filter to create slug for _attr_. Also checks if that
    # slug is unique and adds error to _attr_ if it isn't. Stores slug in _slug_
    # attribute by default.
    #
    # Options:
    # - :to => attribute name to slugize to.
    # 
    # It also takes all regular validation and #validates_each options.
    # 
    # It can be given a block to slugize value of _attr_ instead of just calling
    # #slugize on _value_. Block receives two arguments: _record_ and _value_.
    # Look into #validates_each to learn more about those.
    # 
    # Example:
    # <code>
    # # Creates a slug from _title_ to _title_slug_ by taking _record_ id and 
    # # appending it with even or odd.
    # validates_slugization_of(:title, 
    #   :to => :title_slug, 
    #   :on => :create,
    #   :message => "should be unique."
    # ) do |record, value|
    #   "#{record.id}-" + (value % 2 == 0 ? "even" : "odd")
    # end
    # </code>
    #
    def validates_slugization_of(attr, options={}, &block)
      options[:to] ||= :slug
      options[:message] ||= "is already taken."

      validates_each(attr, options) do |record, attr, value|
        if block.nil?
          slug = value.to_s.slugize
        else
          slug = block.call(record, value)
        end

        record.send "#{options[:to]}=", slug
        if record.class.find(:first, :conditions => [
          "#{options[:to]}=? AND #{primary_key}!=?", slug, record.id
        ])
          record.errors.add attr, options[:message]
        end
      end
    end
  end
end
