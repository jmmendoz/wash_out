xml.instruct!
xml.tag! "wsdl:definitions", 'xmlns' => 'http://schemas.xmlsoap.org/wsdl/',
                'xmlns:tns' => @namespace,
                'xmlns:soap' => 'http://schemas.xmlsoap.org/wsdl/soap/',
                'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema',
                'xmlns:soap-enc' => 'http://schemas.xmlsoap.org/soap/encoding/',
                'xmlns:wsdl' => 'http://schemas.xmlsoap.org/wsdl/',
                'name' => @name,
                'targetNamespace' => @namespace do

  xml.tag! "wsdl:types" do
    xml.tag! "xsd:schema", :targetNamespace => @namespace, :xmlns => 'http://www.w3.org/2001/XMLSchema' do
      defined = []
      @map.each do |operation, formats|
        (formats[:in] + formats[:out]).each do |p|
          wsdl_type xml, p, defined
        end
      end
    end
  end

  @map.each do |operation, formats|
    xml.tag! "wsdl:message", :name => "#{operation}" do
      formats[:in].each do |p|
        xml.tag! "wsdl:part", wsdl_occurence(p, false, :name => p.name, :type => p.namespaced_type)
      end
    end
    xml.tag! "wsdl:message", :name => formats[:response_tag] do
      formats[:out].each do |p|
        xml.tag! "wsdl:part", wsdl_occurence(p, false, :name => p.name, :type => p.namespaced_type)
      end
    end
  end

  xml.tag! "wsdl:portType", :name => "#{@name}_port" do
    @map.each do |operation, formats|
      xml.tag! "wsdl:operation", :name => operation do
        xml.tag! "wsdl:input", :message => "tns:#{operation}"
        xml.tag! "wsdl:output", :message => "tns:#{formats[:response_tag]}"
      end
    end
  end

  xml.tag! "wsdl:binding", :name => "#{@name}_binding", :type => "tns:#{@name}_port" do
    xml.tag! "soap:binding", :style => 'document', :transport => 'http://schemas.xmlsoap.org/soap/http'
    @map.keys.each do |operation|
      xml.tag! "wsdl:operation", :name => operation do
        xml.tag! "soap:operation", :soapAction => operation
        xml.tag! "wsdl:input" do
          xml.tag! "soap:body",
            :use => "literal",
            :namespace => @namespace
        end
        xml.tag! "wsdl:output" do
          xml.tag! "soap:body",
            :use => "literal",
            :namespace => @namespace
        end
      end
    end
  end

  xml.tag! "wsdl:service", :name => @service_name do
    xml.tag! "wsdl:port", :name => "#{@name}_port", :binding => "tns:#{@name}_binding" do
      xml.tag! "soap:address", :location => WashOut::Router.url(request, @controller_path)
    end
  end
end
