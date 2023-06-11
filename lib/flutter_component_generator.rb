# lib/flutter_component_generator.rb
class FlutterComponentGenerator
  def self.generate_component(name, &block)
    component_builder = FlutterComponentBuilder.new(name)
    component_builder.instance_eval(&block)

    component_code = <<~FLUTTER_CODE
      import 'package:flutter/material.dart';

      class #{name} extends StatefulWidget {
        #{component_builder.build_initializer}
        @override
        _#{name}State createState() => _#{name}State();
      }

      class _#{name}State extends State<#{name}> {
        @override
        Widget build(BuildContext context) {
          return #{component_builder.build_component.indent(2)}
        }
      }
    FLUTTER_CODE

    component_code
  end

  class FlutterComponentBuilder
    attr_reader :component_code

    def initialize(name)
      @component_code = ''
      @name = name
      @initializer = ''
    end

    def build_initializer
      @initializer
    end

    def component(name, &block)
      component_builder = FlutterComponentBuilder.new(name)
      component_builder.instance_eval(&block)

      component_code << component_builder.component_code
    end

    def stateful_component(name, &block)
      component_builder = FlutterComponentBuilder.new(name)
      component_builder.instance_eval(&block)

      component_code << component_builder.build_stateful_component_code
    end

    def initializer(&block)
      @initializer = <<~FLUTTER_CODE
        #{block.to_ruby}
      FLUTTER_CODE
    end

    def build_component
      component_code
    end

    def build_stateful_component_code
      <<~FLUTTER_CODE
        class #{@name} extends StatefulWidget {
          @override
          _#{@name}State createState() => _#{@name}State();
        }

        class _#{@name}State extends State<#{@name}> {
          @override
          Widget build(BuildContext context) {
            return #{component_code.indent(2)}
          }
        }
      FLUTTER_CODE
    end

    def method_missing(method_name, *args, &block)
      code_line = "#{method_name}("

      args.each_with_index do |arg, index|
        code_line << "#{arg.inspect}"
        code_line << ', ' if index < args.size - 1
      end

      code_line << ")"

      if block_given?
        nested_builder = FlutterComponentBuilder.new(@name)
        nested_builder.instance_eval(&block)
        code_line << " { #{nested_builder.build_component.indent(2)} }"
      end

      component_code << code_line << ','

      component_code
    end

    def respond_to_missing?(method_name, _include_private = false)
      true
    end
  end
end
