# lib/flutter_component_generator.rb
class FlutterComponentGenerator
  def self.generate_component(name, &block)
    component_code = <<~FLUTTER_CODE
      import 'package:flutter/material.dart';

      class #{name} extends StatelessWidget {
        @override
        Widget build(BuildContext context) {
          return #{build_component(&block).indent(2)}
        }
      }
    FLUTTER_CODE

    component_code
  end

  def self.build_component(&block)
    component_builder = FlutterComponentBuilder.new
    component_builder.instance_eval(&block)

    component_builder.component_code
  end

  class FlutterComponentBuilder
    attr_accessor :component_code

    def initialize
      @component_code = ''
    end

    def component(name, &block)
      component_code << FlutterComponentGenerator.build_component(name, &block)
    end

    def container(&block)
      component_code << <<~FLUTTER_CODE
        Container(
          #{build_widget(&block).indent(2)}
        ),
      FLUTTER_CODE
    end

    def text(text)
      component_code << <<~FLUTTER_CODE
        Text(
          '#{text}',
        ),
      FLUTTER_CODE
    end

    def build_widget(&block)
      widget_builder = FlutterComponentBuilder.new
      widget_builder.instance_eval(&block)

      widget_builder.component_code
    end
  end
end
