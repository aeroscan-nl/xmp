class XMP
  class Namespace
    # available attributes
    attr_reader :attributes

    def initialize(xmp, namespace) # :nodoc
      @xmp = xmp
      @namespace = namespace.to_s

      @attribute_map = {}
      @attributes = []
      embedded_attributes =
        xml.xpath("//rdf:Description").map { |d|
          d.attributes.values.
            select { |attr| (attr.namespace ? attr.namespace.prefix.to_s : nil) == @namespace }.
            map(&:name)
        }.flatten
      @attributes.concat embedded_attributes
      standalone_attributes = xml.xpath("//rdf:Description/#{@namespace}:*").
                                  map(&:name)
      @attributes.concat standalone_attributes
      map_attributes @attributes
    end

    def inspect
      "#<XMP::Namespace:#{@namespace} (#{attributes.inspect})>"
    end

    def method_missing(method, *args)
      if has_attribute?(method)
        self[method]
      else
        super
      end
    end

    def [](name)
      name = name.to_s.downcase
      raise "Unknown attribute" unless has_attribute?(name)
      embedded_attribute(@attribute_map[name]) || standalone_attribute(@attribute_map[name])
    end

    def has_attribute?(name)
      @attribute_map.key?(name.to_s.downcase)
    end

    def respond_to?(method)
      has_attribute?(method) or super
    end

    private

    def map_attributes(attrs)
      attrs.each do |attr_name|
        @attribute_map[attr_name.downcase] = attr_name
      end
    end

    def embedded_attribute(name)
      element = xml.at("//rdf:Description[@#{@namespace}:#{name}]")
      return unless element
      element.attribute(name.to_s).text
    end

    def standalone_attribute(name)
      attribute_xpath = "//#{@namespace}:#{name}"
      attribute = xml.xpath(attribute_xpath).first
      return unless attribute

      array_value = attribute.xpath("./rdf:Bag | ./rdf:Seq | ./rdf:Alt").first
      if array_value
        items = array_value.xpath("./rdf:li")
        items.map { |i| i.text }
      else
        attribute.text
      end
    end

    def xml
      @xmp.xml
    end
  end
end
