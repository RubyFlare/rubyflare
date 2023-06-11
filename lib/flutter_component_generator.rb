# lib/flutter_component_generator.rb
class FlutterComponentGenerator
  def self.generate_component(name, &block)
    component_builder = FlutterComponentBuilder.new
    component_builder.instance_eval(&block)

    component_code = <<~FLUTTER_CODE
      import 'package:flutter/material.dart';

      class #{name} extends StatelessWidget {
        @override
        Widget build(BuildContext context) {
          return #{component_builder.build_component}
        }
      }
    FLUTTER_CODE

    component_code
  end

  class FlutterComponentBuilder
    attr_accessor :component_code

    def initialize
      @component_code = ''
    end

    def build_component
      component_code
    end

    def method_missing(method_name, *args, &block)
      component_code << format_code_line(method_name, args, &block)
    end

    def format_code_line(method_name, args, &block)
      code_line = "#{method_name}("

      args.each_with_index do |arg, index|
        code_line << "#{arg.inspect}"
        code_line << ', ' if index < args.size - 1
      end

      code_line << ")"

      if block_given?
        nested_builder = FlutterComponentBuilder.new
        nested_builder.instance_eval(&block)
        code_line << " { #{nested_builder.build_component} }"
      end

      code_line << ','

      code_line
    end
  end
end
