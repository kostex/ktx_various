-- Script by Roel Koster (kostex/koelooptiemanna)
-- https://github.com/kostex/ktx_various/

require("graphics")


dataref("H", "sim/graphics/view/window_height", "readonly", 1)
DO_SOMETIMES_TIME_SEC = 60
local pad = SYSTEM_DIRECTORY .. "Output/situations/"
local filelist = {}
local save_file_exists = {}
local filecount = 0
local line = ""
local enter_name = false
local file_item_clicked = 0
local filename_regel = "Enter_Save_FileName_Here"


function ktx_draw_rect(x,y,w,h)
  graphics.draw_rectangle(x, SCREEN_HIGHT - y, x + w, SCREEN_HIGHT - y - h)
end

function ktx_draw_string(x,y,s,color)
  graphics.draw_string(x, SCREEN_HIGHT - y, s,color)
end

function ktx_draw_button(x,y,s,size,r1,g1,b1,color)
  graphics.set_color(r1,g1,b1)
  if size == 0 then
    ktx_draw_rect(x,y,measure_string(s)+4,-16)
  else
    ktx_draw_rect(x,y,size,-16)
  end
  ktx_draw_string(x+2,y-4,s,color)
end

function ktx_draw_field(x,y,s,size,r1,g1,b1,color)
  graphics.set_color(r1,g1,b1)
  if size == 0 then
    ktx_draw_rect(x,y,measure_string(s)+4,-16)
  else
    ktx_draw_rect(x,y,size,-16)
  end
  if enter_name then
    ktx_c("red")
    ktx_draw_rect(x+measure_string(s),y,2,-16)
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
  ktx_draw_button(10,20,"ZIBO LOAD/SAVE FLIGHT EXTENSION",800,0.2,0.2,0.2,"white")

  -- Black Background
  ktx_c("black")
  if filecount > 4 then
    ktx_draw_rect(10, 20 ,800, 55 + filecount*20)
  else
    ktx_draw_rect(10, 20 ,800, 150)
  end

  ktx_draw_button(20,50,"Refresh Situations",350,0.6,0.9,0.6,"black")

  y = 80
  x = 20
  for i=0,filecount-1 do
    if file_item_clicked == i+1 then
      ktx_draw_button(x, y, filelist[i+1][1].." ("..filelist[i+1][2]..")",350,0.5,0.5,0.5,"white")
      ktx_c("red")
      ktx_draw_rect(x+350,y,5,-16)
    else
      ktx_draw_button(x, y, filelist[i+1][1],350,0.4,0.4,0.4,"white")
    end
    y = y + 20
  end

  y = 80
  x = 400
  if file_item_clicked > 0 then
    for i=1,4 do
      status=string.format("Load in %d", i)
      ktx_draw_button(x, y, status, 100,1,0,0,"white")
      y = y + 20
    end
  else
    ktx_draw_field(x,50,filename_regel,390,1,1,1,"black")
    for i=1,4 do
      if save_file_exists[i] then
        status="Filled"
        if filename_regel ~= "Enter_Save_FileName_Here" and filename_regel ~= "" then
          ktx_draw_button(x + 110, y, "SaveAs",50,0,0.5,0,"white")
        end
      else
        status="Empty"
      end
      ktx_draw_button(x, y, string.format("Slot %d %s", i, status), 100,0.3,0.3,0.3,"white")
      y = y + 20
    end
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
  return string.sub(lines[4],1,4).."_"..string.sub(lines[5],1,4)
end

function save_sit(n,s)
  os.execute("cp '"..pad.."B738X_0"..n..".dat' '"..pad..s..".dat'")
  os.execute("cp '"..pad.."B738X_0"..n..".sit' '"..pad..s..".sit'")
  refresh()
end

function load_sit(n,s)
  os.execute("cp '"..pad..s..".dat' '"..pad.."B738X_0"..n..".dat'")
  os.execute("cp '"..pad..s..".sit' '"..pad.."B738X_0"..n..".sit'")
  file_item_clicked = 0
  refresh()
end

function refresh()
  file_item_clicked = 0
  local dir = directory_to_table(pad)
  filelist = {}
  save_file_exists = {false,false,false,false}
  filecount = 0
  for filenumber, filename in pairs(dir) do
      if string.sub(filename,-3) == "dat" then
        if string.sub(filename,1,6) ~= "B738X_" then
          filecount = filecount + 1
          filelist[filecount]={}
          filelist[filecount][1] = string.sub(filename, 1, string.len(filename)-4)
          filelist[filecount][2] = read_file(filename)
        end
      elseif string.sub(filename,1,6) == "B738X_" then
        save_file_exists[tonumber(string.sub(filename,8,8))] = true
      end
  end
end

function mouse_check()
  if MOUSE_STATUS ~= "down" then
    return
  end

  if MOUSE_X > 20 and MOUSE_X < 370 and ktx_mouse_y() > 30 and ktx_mouse_y() < 50 then
    -- Clicked on Refresh
    enter_name = false
    refresh()
  end

  if MOUSE_X > 20 and MOUSE_X < 370 and ktx_mouse_y() > 60 and ktx_mouse_y() < (60 + filecount*20) then
    -- Clicked on a DAT file
    enter_name = false
    clicked_item = math.ceil((ktx_mouse_y()-60)/20)
    if file_item_clicked == clicked_item then
      file_item_clicked = 0
    else
      file_item_clicked = math.ceil((ktx_mouse_y()-60)/20)
    end
  end

  if MOUSE_X > 510 and MOUSE_X < 560 and ktx_mouse_y() > 60 and ktx_mouse_y() < (60 + 4*20) then
    -- Clicked on a SaveAs button
    enter_name = false
    clicked_item = math.ceil((ktx_mouse_y()-60)/20)
    if save_file_exists[clicked_item] then
      save_sit(clicked_item,filename_regel)
    end
  end

  if MOUSE_X > 400 and MOUSE_X < 500 and ktx_mouse_y() > 60 and ktx_mouse_y() < (60 + 4*20) and file_item_clicked > 0 then
    -- Clicked on a Load button
    enter_name = false
    clicked_item = math.ceil((ktx_mouse_y()-60)/20)
    load_sit(clicked_item,filelist[file_item_clicked][1])
  end

  if MOUSE_X > 400 and MOUSE_X < 790 and ktx_mouse_y() > 30 and ktx_mouse_y() < 50 and file_item_clicked == 0 then
    -- Enter Filename
    enter_name = true
  else
    enter_name = false
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

add_macro("KTX_Zibo_Save", "ktx_save = true refresh()", "ktx_save = false", "activate")

do_on_mouse_click("mouse_check()")
do_every_draw("if ktx_save then draw_ktx_save() end")
