
module Bittorrent

  module Bcode
  
    DICTIONARY  = 'd'
    LIST        = 'l'
    NUMBER      = 'i'
    END_MARK    = 'e'    

    # The classes below are used to generate bencoded strings.
    #   Example:
    #     root = BDictionary.new
    #     root['my_string'] = BString.new('string') 
    #     root['my_number'] = BNumber.new(1)
    #     my_list = BList.new
    #     my_list << BDictionary.new
    #     root['my_list'] = my_list
    #     root.out
    
    class BString
      def initialize(s = nil)
        @s = s || ''
      end

      def out
        @s.size.to_s + ':' + @s
      end
    end

    class BNumber
      def initialize(n)
        @n = n
      end

      def out
        NUMBER + @n.to_s + END_MARK
      end
    end

    class BRaw
      def initialize(s)
        @s = s
      end

      def out
        @s
      end
    end

    class BList
      def initialize
        @a = []
      end

      def <<(e)
        @a << e
      end

      def out
        s = ''
        s << LIST
        @a.each {|e| s << e.out }
        s << END_MARK
      end
    end

    class BDictionary
      def initialize
        @a = []
      end

      def []=(name, e)
        @a << {:name => name, :e => e}
      end
      
      def out
        s = ''
        s << DICTIONARY
        @a.each do |e|
          s << e[:name].size.to_s + ':' + e[:name]
          s << e[:e].out
        end
        s << END_MARK
      end
    end
    
    
    # Parse a bencoded string and return a hash containing the bcode entries.
    def parse_bencoded(data)
      raise 'bencoded data must be a String' unless data.is_a? String
      do_parse StringIO.new(data)
    end

    private

      def do_parse(data)
        return nil if data.eof?
        byte = data.read(1)
        case byte
          when END_MARK
            return nil
          when DICTIONARY
            h = {}
            loop do
              key = do_parse data
              return h unless key
              h[key] = do_parse data
            end
          when LIST
            a = []
            loop do
              e = do_parse data
              return a unless e
              a << e
            end
          when NUMBER
            n = ''
            loop do
              byte = data.read(1)
              return Integer(n) if byte == END_MARK
              n << byte
            end
          else
            s = ''
            size = parse_size data, byte            
            size.times { s << data.read(1) }
            return s
        end
      end

      def parse_size(data, byte)
        size = ''
        while byte != ':'
          size << byte
          byte = data.read(1)
        end
        Integer(size)
      end
  end
end