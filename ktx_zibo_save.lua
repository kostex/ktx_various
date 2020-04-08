-- Script by Roel Koster (kostex/koelooptiemanna)
-- https://github.com/kostex/ktx_various/

require("graphics")

local dos = false
if package.config:sub(1,1) == "\\" then
  dos = true
end

dataref("H", "sim/graphics/view/window_height", "readonly", 1)
DO_SOMETIMES_TIME_SEC = 600

local pad = ""
if dos then
  pad =  SYSTEM_DIRECTORY .. "\\Output\\situations\\"
else
  pad = SYSTEM_DIRECTORY .. "Output/situations/"
end

local filelist = {}
local save_file_exists = {}
local save_files = false
local filecount = 0
local line = ""
local offset = 70
local istate = false
local delete_slot_mode = false
local enter_name = false
local file_item_clicked = 0
local save_file_route = {}
local save_file_equals = {}
local filename_regel = "Enter_Save_FileName_Here"


function ktx_draw_rect(x,y,w,h)
  graphics.draw_rectangle(x, SCREEN_HIGHT - y, x + w, SCREEN_HIGHT - y + h)
end

function ktx_draw_string(x,y,s,color)
  graphics.draw_string(x, SCREEN_HIGHT - y, s,color)
end

function ktx_draw_button(x,y,s,size,r1,g1,b1,a1,color)
  graphics.set_color(r1,g1,b1,a1)
  if size == 0 then
    ktx_draw_rect(x,y,measure_string(s)+4,16)
  else
    ktx_draw_rect(x,y,size,16)
  end
  ktx_draw_string(x+2,y-4,s,color)
end

function ktx_draw_arrow(x,y,angle,length,color)
  ktx_c(color)
  graphics.draw_angle_arrow(x, SCREEN_HIGHT - y, angle, length, 20, 3)
end

function ktx_draw_field(x,y,s,size,r1,g1,b1,color)
  graphics.set_color(r1,g1,b1)
  if size == 0 then
    ktx_draw_rect(x,y,measure_string(s)+4,16)
  else
    ktx_draw_rect(x,y,size,16)
  end
  if enter_name then
    ktx_c("red")
    ktx_draw_rect(x+measure_string(s),y,2,16)
  end
  ktx_draw_string(x+2,y-4,s,color)
end


function ktx_c(color)
  if color == "red" then
    graphics.set_color(1,0,0)
  elseif color == "white" then
    graphics.set_color(1,1,1)
  elseif color == "grey" then
    graphics.set_color(0.6,0.6,0.6)
  elseif color == "green" then
    graphics.set_color(0,1,0)
  elseif color == "black" then
    graphics.set_color(0,0,0)
  else
    graphics.set_color(0,0,1)
  end
end

function ktx_mouse_y()
  return SCREEN_HIGHT - MOUSE_Y
end

function draw_ktx_save()
  if istate then
    -- interface shows
    ktx_draw_button(10,20+offset,"(X) KTX ZIBO LOAD/SAVE FLIGHT EXTENSION",820,0.2,0.2,0.2,1,"white")

    -- Black Background
    graphics.set_color(0,0,0,0.3)
    if filecount > 7 then
      ktx_draw_rect(10, 20+offset ,820, -(55 + filecount*20))
    else
      ktx_draw_rect(10, 20+offset ,820, -200)
    end

    if not enter_name then
      ktx_draw_button(20,50+offset,"Manual Refresh Situations",350,0.6,0.9,0.6,1,"black")
    end

    y = 80+offset
    x = 20
    for i=0,filecount-1 do
      if file_item_clicked == i+1 then
        ktx_draw_button(x, y, filelist[i+1][1].." ("..filelist[i+1][2]..")",350,0.5,0.5,0.5,1,"white")
        ktx_c("red")
        ktx_draw_rect(x+350,y,5,16)
      else
        ktx_draw_button(x, y, filelist[i+1][1],350,0.4,0.4,0.4,1,"white")
      end
      y = y + 20
    end

    x = 400
    y = 80+offset
    for i=1,4 do
      status="Slot"..i..": "..save_file_equals[i]
      ktx_draw_button(x, y, status, 350,0,0.5,0.8,1,"white")
      y = y + 20
    end
    if file_item_clicked == 0 and save_files and not enter_name then
      ktx_draw_button(x,y,"Delete Slot Mode",100,1,0,0,1,"white")
    end

    if delete_slot_mode then
      y = 80+offset
      for i=1,4 do
        if save_file_exists[i] then
          ktx_draw_button(x + 360, y, "Delete", 60,1,0,0,1,"white")
        end
        y = y + 20
      end
    end

    y = 80+offset
    if file_item_clicked > 0 then
      -- Load/Delete Mode
      for i=1,4 do
        ktx_draw_button(x + 360, y, "Load Sel", 60,0,0.5,0,1,"white")
        y = y + 20
      end
      ktx_draw_arrow(x - 2, y + 12,270,20,"red")
      ktx_draw_button(x, y + 20, "Delete Situation", 120,1,0,0,1,"white")
    else
      -- Save As Mode
      ktx_draw_field(x,50+offset,filename_regel,420,1,1,1,"black")
      for i=1,4 do
        if save_file_exists[i] then
          if filename_regel ~= "Enter_Save_FileName_Here" and filename_regel ~= "" then
            ktx_draw_button(x + 360, y, "Save As",60,0,0.5,0,1,"white")
          end
        end
        y = y + 20
      end
    end
  else
    -- Show HotSpot
    ktx_draw_button(0,offset+20,"KTX_Zibo_Save",90,0.5,0.5,0.5,0.5,"white")
  end
end

function read_file(filename)
  f = pad..filename
  lines = {}
  for l in io.lines(f) do
    lines[#lines + 1] = l
    if #lines > 6 then
      break
    end
  end
  dep = string.sub(lines[4],1,4)
  des = string.sub(lines[5],1,4)
  return dep.."_"..des
end

function save_sit(n,s)
  if dos then
    os.execute('copy "'..pad..'B738X_0'..n..'.dat" "'..pad..s..'.dat"')
    os.execute('copy "'..pad..'B738X_0'..n..'.sit" "'..pad..s..'.sit"')
  else
    os.execute("cp '"..pad.."B738X_0"..n..".dat' '"..pad..s..".dat'")
    os.execute("cp '"..pad.."B738X_0"..n..".sit' '"..pad..s..".sit'")
  end
  refresh()
end

function load_sit(n,s)
  if dos then
    os.execute('copy "'..pad..s..'.dat" "'..pad..'B738X_0'..n..'.dat"')
    os.execute('copy "'..pad..s..'.sit" "'..pad..'B738X_0'..n..'.sit"')
  else
    os.execute("cp '"..pad..s..".dat' '"..pad.."B738X_0"..n..".dat'")
    os.execute("cp '"..pad..s..".sit' '"..pad.."B738X_0"..n..".sit'")
  end
  file_item_clicked = 0
  refresh()
end

function delete_file(s)
  file_item_clicked = 0
  if dos then
    os.execute('del "'..pad..s..'.*"')
  else
    os.execute("rm '"..pad..s..".'*")
  end
  refresh()
end

function checksum_sit(s)
  result = false
  local f
  if dos then
    f = io.popen('certutil -hashfile "'..pad..s..'.sit" | findstr -v ash')
    cs = f:read("*a")
  else
    f = io.popen("sum '"..pad..s.."'.sit")
    cs = string.sub(f:read("*a"),1,6)
  end
  f:close()
  return cs
end

function refresh()
  if not enter_name then
    delete_slot_mode = false
    save_files = false
    file_item_clicked = 0
    local dir = directory_to_table(pad)
    filelist = {}
    save_file_exists = {false,false,false,false}
    save_file_route = {"Empty","Empty","Empty","Empty"}
    save_file_equals = save_file_route
    filecount = 0
    for filenumber, filename in pairs(dir) do
      if string.sub(filename,-3) == "dat" then
        if string.sub(filename,1,6) ~= "B738X_" then
          filecount = filecount + 1
          filelist[filecount]={}
          filelist[filecount][1] = string.sub(filename, 1, string.len(filename)-4)
          filelist[filecount][2] = read_file(filename)
          filelist[filecount][3] = checksum_sit(filelist[filecount][1])
        else
          sindex = tonumber(string.sub(filename,8,8))
          save_file_exists[sindex] = true
          save_files = true
          save_file_route[sindex] = read_file(filename)
          save_file_equals[sindex] = save_file_route[sindex].." (no backup yet)"
        end
      end
    end
    for i=1,4 do
      if save_file_exists[i] then
        cs = checksum_sit("B738X_0"..i)
        if filecount > 0 then
          for j=1,filecount do
            if filelist[j][3] == cs then
              save_file_equals[i]=filelist[j][1]
              break
            end
          end
        end
      end
    end
  end
end

function mouse_check()
  if istate and MOUSE_STATUS == "down" then
    -- Interface shows

    if MOUSE_X > 10 and MOUSE_X < 810 and ktx_mouse_y() > offset and ktx_mouse_y() < offset+20 then
      -- Clicked on Title bar
      istate = false
    end

    if MOUSE_X > 20 and MOUSE_X < 370 and ktx_mouse_y() > 30+offset and ktx_mouse_y() < 50+offset then
      -- Clicked on Refresh
      enter_name = false
      refresh()
    end

    if MOUSE_X > 20 and MOUSE_X < 370 and ktx_mouse_y() > 60+offset and ktx_mouse_y() < (60 + filecount*20)+offset then
      -- Clicked on a DAT file
      enter_name = false
      clicked_item = math.ceil((ktx_mouse_y()-60-offset)/20)
      if file_item_clicked == clicked_item then
        file_item_clicked = 0
      else
        file_item_clicked = math.ceil((ktx_mouse_y()-60-offset)/20)
      end
    end

    if MOUSE_X > 760 and MOUSE_X < 820 and ktx_mouse_y() > 60+offset and ktx_mouse_y() < (60 + 4*20)+offset and file_item_clicked == 0 and filename_regel ~= "Enter_Save_FileName_Here" and filename_regel ~= "" then
      -- Clicked on a SaveAs button
      enter_name = false
      clicked_item = math.ceil((ktx_mouse_y()-60-offset)/20)
      if save_file_exists[clicked_item] then
        save_sit(clicked_item,filename_regel)
      end
    end

    if MOUSE_X > 760 and MOUSE_X < 820 and ktx_mouse_y() > 60+offset and ktx_mouse_y() < (60 + 4*20)+offset and file_item_clicked > 0 then
      -- Clicked on a Load button
      enter_name = false
      clicked_item = math.ceil((ktx_mouse_y()-60-offset)/20)
      load_sit(clicked_item,filelist[file_item_clicked][1])
    end

    if MOUSE_X > 400 and MOUSE_X < 500 and ktx_mouse_y() > 140+offset and ktx_mouse_y() < 160+offset and file_item_clicked == 0 and save_files and not enter_name then
      -- Clicked on Delete Slot MODE toggle
      delete_slot_mode = not delete_slot_mode
    end

    if MOUSE_X > 760 and MOUSE_X < 820 and ktx_mouse_y() > 60+offset and ktx_mouse_y() < (60 + 4*20)+offset and file_item_clicked == 0 and delete_slot_mode then
      -- Clicked on a Delete Slot button
      enter_name = false
      clicked_item = math.ceil((ktx_mouse_y()-60-offset)/20)
      if save_file_exists[clicked_item] then
        delete_file("B738X_0"..clicked_item)
      end
    end

    if MOUSE_X > 400 and MOUSE_X < 520 and ktx_mouse_y() > 160+offset and ktx_mouse_y() < 180+offset and file_item_clicked > 0 then
      -- Clicked on Delete Situation
      enter_name = false
      delete_file(filelist[file_item_clicked][1])
    end

    if MOUSE_X > 400 and MOUSE_X < 820 and ktx_mouse_y() > 30+offset and ktx_mouse_y() < 50+offset and file_item_clicked == 0 then
      -- Enter Filename
      enter_name = true
    else
      enter_name = false
    end
  else
    -- Click Spot to show interface
    if MOUSE_X > 0 and MOUSE_X < 90 and ktx_mouse_y() > offset and ktx_mouse_y() < offset+20 then
      istate = true
    end
  end
end

function FromKeyboard()
	if enter_name and KEY_ACTION=="pressed" then
    RESUME_KEY = true
		-- escape
		if VKEY == 27 then
			filename_regel = ""
			return
		end
		-- delete
		if VKEY == 8 and filename_regel ~= "" then
			filename_regel = string.sub(filename_regel, 1, string.len(filename_regel)-1)
			return
		end
		-- enter
		if VKEY == 13 then
			enter_name = false
			return
		end
		-- anything else
		filename_regel = filename_regel .. CKEY
	end
end


do_on_keystroke("FromKeyboard()")

do_on_mouse_click("mouse_check()")
do_every_draw("if ktx_save then draw_ktx_save() end")

add_macro("KTX_Zibo_Save", "ktx_save = true refresh()", "ktx_save = false", "activate")
