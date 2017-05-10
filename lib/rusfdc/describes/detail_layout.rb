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
          section[:layout_rows].flat_map do |r|
            extract_item(r)
          end
        end

        def extract_item(row)
          # when section has some rows, row is expressed as hash has layout_items array
          # when section has only one row, row is expressed as [tag_anem, [item, item]]
          items = row.instance_of?(Hash) ? row[:layout_items] : row[1]
          items.select { |i| i[:label] }.map { |i| layout_item_info(i) }
        end

        def layout_item_info(item)
          comp = item[:layout_components]
          l = LayoutItem.new(item[:label], item[:required])
          if comp
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