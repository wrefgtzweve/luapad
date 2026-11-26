local MAX_DECOMPRESSED_SIZE = 5 * 1024 * 1024 -- 5 MB

function luapad.ReadCompressed()
    local len = net.ReadUInt( 16 )
    local data = net.ReadData( len )

    return util.Decompress( data, MAX_DECOMPRESSED_SIZE )
end

function luapad.WriteCompressed( data )
    local compressed = util.Compress( data )
    local len = #compressed

    net.WriteUInt( len, 16 )
    net.WriteData( compressed, len )
end
