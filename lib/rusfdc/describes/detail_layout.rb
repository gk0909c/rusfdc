module Rusfdc
  module Describes
    LayoutItem = Struct.new(:label, :required, :type, :field, :field_type)

    # interface of detail layouts with field info
    class DetailLayout
      def initialize(describe)
        @sections = describe[:layouts][:detail_layout_sections]
      end

      def merge_fields(fields)
        # extract layout info
        sections = extract_detail_layout_info
        merge_fields_to_detail_layout(sections, fields)
        sections
      end

      private

        def extract_detail_layout_info
          @sections.map do |s|
            { name: s[:heading], items: extract_items(s) }
          end
        end

        def extract_items(section)
          rows = section[:layout_rows]
          rows = [rows] if section[:rows].to_i == 1

          rows.flat_map do |r|
            r[:layout_items].select { |i| i[:label] }.map { |i| layout_item_info(i) }
          end
        end

        def layout_item_info(item)
          comp = item[:layout_components]
          l = LayoutItem.new(item[:label], item[:required])
          if comp
            comp = comp[0] if comp.instance_of?(Array)
            l.type = comp[:type]
            l.field = comp[:value]
          end
          l
        end

        def merge_fields_to_detail_layout(sections, fields)
          field_hash = generate_field_hash(fields)

          sections.map do |s|
            s[:items].select { |i| field_item?(i) }.map do |i|
              field = field_hash[i.field]
              i.field_type = field[:type]
            end
          end
        end

        def generate_field_hash(fields)
          fields.each_with_object({}) { |f, h| h[f[:name]] = f }
        end

        def field_item?(item)
          item[:type] == 'Field'
        end
    end
  end
end
