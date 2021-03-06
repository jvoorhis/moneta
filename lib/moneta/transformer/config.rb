module Moneta
  class Transformer
    # Available key/value transformers
    TRANSFORMER = {
      # Name    => [ Type,       Load,                             Dump,                             Library         ],
      :bencode  => [ :serialize, '::BEncode.load(%s)',             '::BEncode.dump(%s)',             'bencode'       ],
      :bert     => [ :serialize, '::BERT.decode(%s)',              '::BERT.encode(%s)',              'bert'          ],
      :bson     => [ :serialize, "::BSON.deserialize(%s)['v']",    "::BSON.serialize('v'=>%s).to_s", 'bson'          ],
      :json     => [ :serialize, '::MultiJson.load(%s).first',     '::MultiJson.dump([%s])',         'multi_json'    ],
      :marshal  => [ :serialize, '::Marshal.load(%s)',             '::Marshal.dump(%s)'                              ],
      :msgpack  => [ :serialize, '::MessagePack.unpack(%s)',       '::MessagePack.pack(%s)',         'msgpack'       ],
      :ox       => [ :serialize, '::Ox.parse_obj(%s)',             '::Ox.dump(%s)',                  'ox'            ],
      :tnet     => [ :serialize, '::TNetstring.parse(%s).first',   '::TNetstring.dump(%s)',          'tnetstring'    ],
      :yaml     => [ :serialize, '::YAML.load(%s)',                '::YAML.dump(%s)',                'yaml'          ],
      :bzip2    => [ :compress,  '::Bzip2.uncompress(%s)',         '::Bzip2.compress(%s)',           'bzip2'         ],
      :lzma     => [ :compress,  '::LZMA.decompress(%s)',          '::LZMA.compress(%s)',            'lzma'          ],
      :lzo      => [ :compress,  '::LZO.decompress(%s)',           '::LZO.compress(%s)',             'lzoruby'       ],
      :snappy   => [ :compress,  '::Snappy.inflate(%s)',           '::Snappy.deflate(%s)',           'snappy'        ],
      :quicklz  => [ :compress,  '::QuickLZ.decompress(%s)',       '::QuickLZ.compress(%s)',         'qlzruby'       ],
      :zlib     => [ :compress,  '::Zlib::Inflate.inflate(%s)',    '::Zlib::Deflate.deflate(%s)',    'zlib'          ],
      :uuencode => [ :encode,    "%s.unpack('u').first",           "[%s].pack('u').strip"                            ],
      :base64   => RUBY_VERSION > '1.9' ?
                   [ :encode,    "%s.unpack('m0').first",          "[%s].pack('m0')"                                 ] :
                   [ :encode,    "%s.unpack('m').first",           "[%s].pack('m').gsub(\"\n\", '')"                 ],
      :escape   => [ :encode,    'Helper.unescape(%s)',            'Helper.escape(%s)'                               ],
      :hmac     => [ :hmac,      'Helper.hmacverify(%s, @secret)', 'Helper.hmacsign(%s, @secret)',   'openssl'       ],
      :truncate => [ :truncate,  nil,                              'Helper.truncate(%s, @maxlen)',   'digest/md5'    ],
      :md5      => [ :digest,    nil,                              '::Digest::MD5.hexdigest(%s)',    'digest/md5'    ],
      :rmd160   => [ :digest,    nil,                              '::Digest::RMD160.hexdigest(%s)', 'digest/rmd160' ],
      :sha1     => [ :digest,    nil,                              '::Digest::SHA1.hexdigest(%s)',   'digest/sha1'   ],
      :sha256   => [ :digest,    nil,                              '::Digest::SHA256.hexdigest(%s)', 'digest/sha2'   ],
      :sha384   => [ :digest,    nil,                              '::Digest::SHA384.hexdigest(%s)', 'digest/sha2'   ],
      :sha512   => [ :digest,    nil,                              '::Digest::SHA512.hexdigest(%s)', 'digest/sha2'   ],
      :prefix   => [ :prefix,    nil,                              '(options[:prefix]||@prefix)+%s'                  ],
      :spread   => [ :spread,    nil,                              'Helper.spread(%s)'                               ],
      :to_s     => [ :to_s,      nil,                              '%s.to_s'                                         ],
    }

    # Allowed value transformers (Read it like a regular expression!)
    VALUE_TRANSFORMER = 'serialize? compress? hmac? encode?'

    # Allowed key transformers (Read it like a regular expression!)
    KEY_TRANSFORMER = '(serialize | to_s)? prefix? ((encode? truncate?) | (digest spread?))?'
  end
end
