-- Relast turns on "loop one" if the playlist starts playing
-- the last media item. The idea is that you have something playing
-- in the background and when you want to switch, whatever you add
-- gets to be played continuously until you add something else.
--
-- Implementation details:
--
-- You don't get the current playlist index from vlc.playlist.current()
-- instead you get the id of the item currently playing.
-- ids seem to be assigned according to the order they were added
-- to the playlist, which seems to follow some internal sorting or
-- is just the order the OS returns the list of files to VLC
--
-- The actual order of items within the playlist is the keys
-- within the `children` table in the returned playlist object.
--
-- To map item ids to their position in the playlist, you need
-- to check the `id` key for each element in `children`.
--
-- In this case, all I care about is the id of the last item
-- in the playlist, so I can check if the one currently being played
-- is the last one.
--
-- ---
--
-- input and playing listeners don't work anymore it seems
-- so we're stuck with the spammy meta-listener
--
-- It can be quite crashy if you don't take care to filter
-- when you run your stuff on, hence the check to make sure
-- the playlist stuff runs only once after the media has
-- actually changed. I tried to reduce the number of calls
-- to vlc.playlist.get and be as specific as possible to avoid
-- crashyness.

function descriptor()
	return { 
		title = "Repeat last item in playlist",
		version = "0.1.0",
		author = "MechaLynx",
		url = '',
		shortdesc = "relast";
		capabilities = { "meta-listener" }
	}
end

function activate()
    -- vlc.msg.dbg("[RELAST]: Activated")

    -- initialize this just in case
    previous_item = -1
end

function deactivate()
    -- vlc.msg.dbg("[RELAST]: Deactivated")
    collectgarbage()
end

function meta_changed()
    -- prevent this from running a million times on each media item change
    current_item = vlc.playlist.current()
    if (previous_item ~= current_item and current_item > 0 ) then
        previous_item = current_item
        -- now it gets the correct length
        playlist = vlc.playlist.get("normal", false)['children']
        playlist_length = tablelength(playlist)
        last_id = playlist[playlist_length]['id']

        -- vlc.msg.dbg("[RELAST]: Last item id: " .. tostring(last_id))
        -- vlc.msg.dbg("[RELAST]: Current playlist index: " .. tostring(current_item))
        -- vlc.msg.dbg("[RELAST]: Playlist status: " .. vlc.playlist.status())
        -- vlc.msg.dbg("[RELAST]: Size of playlist: " .. tostring(playlist_length))

        if ( current_item == last_id ) then
            vlc.playlist['repeat']()
        end
    end
end

-- http://stackoverflow.com/questions/2705793/how-to-get-number-of-entries-in-a-lua-table
-- Yes I'm a complete Lua noob
function tablelength(T)
  local count = 0
  for _ in pairs(T) do 
      count = count + 1 
  end
  return count
end
