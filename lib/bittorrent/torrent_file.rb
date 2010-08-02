
module Bittorrent

  module TorrentFile
    include Bcode

    INFO          = 'info'
    ANNOUNCE      = 'announce'
    COMMENT       = 'comment'
    CREATED_BY    = 'created by'
    CREATION_DATE = 'creation date'
    ENCODING      = 'encoding'
    FILES         = 'files'
    LENGTH        = 'length'
    PATH          = 'path'
    NAME          = 'name'
    PIECE_LENGTH  = 'piece length'
    PIECES        = 'pieces'
    PRIVATE       = 'private'

    PRIVATE_FLAG  = '1'

    class InvalidTorrentError < StandardError
    end

    def parse_torrent_file(torrent_data, logger = nil)
      begin
        meta_info = parse_bencoded(torrent_data)
      rescue => e
        logger.debug ":-o bittorrent::torrent_file.parse error: #{e.message} [#{e.backtrace[0]}]" if logger
        raise InvalidTorrentError.new('error while parsing')
      end
      check_meta_info meta_info, logger
      meta_info
    end

    private
    
      def check_meta_info(meta_info, logger = nil)
        info = meta_info[INFO]
        begin
          Time.at(meta_info[CREATION_DATE]) if meta_info[CREATION_DATE] # optional, just check format

          raise 'empty info[NAME]' if info[NAME].blank?
          raise 'empty info[PIECE_LENGTH]' unless info[PIECE_LENGTH]
          raise 'empty info[PIECES]' if info[PIECES].blank?

          if info[FILES].blank? # single file mode
            raise 'empty info[LENGTH] in single file mode' unless info[LENGTH]
          else
            info[FILES].each do |file|
              raise 'empty file[LENGTH]' unless file[LENGTH]
              file[PATH].each {|path| raise 'empty file[PATH]' if path.blank? }
            end
          end
        rescue => e
          logger.debug ":-o bittorrent::torrent_file.check error: #{e.message} [#{e.backtrace[0]}]" if logger
          raise InvalidTorrentError.new(e.message)
        end
      end

      # bencode the INFO entry, used to calculate the torrent's info hash
      def bencode_info_entry(info)
        root = BDictionary.new

        if info[FILES].blank? # single file mode
          root[LENGTH] = BNumber.new(info[LENGTH])
        else
          files_list = BList.new
          info[FILES].each do |info_file|
            file = BDictionary.new
            file[LENGTH] = BNumber.new(info_file[LENGTH])
            file_path_list = BList.new
            info_file[PATH].each {|info_file_path| file_path_list << BString.new(info_file_path) }
            file[PATH] = file_path_list
            files_list << file
          end
          root[FILES] = files_list
        end
        root[NAME] = BString.new(info[NAME])
        root[PIECE_LENGTH] = BNumber.new(info[PIECE_LENGTH])
        root[PIECES] = BString.new(info[PIECES])
        root[PRIVATE] = BNumber.new(info[PRIVATE]) if info[PRIVATE]
        root.out
      end
  end
end





