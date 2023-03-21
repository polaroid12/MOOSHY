pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
--mooshy by daria

--inits

function _init()
		init_menu()
	--	init_pickups()
	end

function init_menu()

_update = update_menu
_draw = draw_menu
end

--variables

function init_game()
  player={
    friend=0,
    sp=1,
    x=59,
    y=59,
    w=8,
    h=8,
    flp=false,
    dx=0,
    dy=0,
    max_dx=2,
    max_dy=3,
    acc=0.5,
    boost=4,
    anim=0,
    running=false,
    jumping=false,
    falling=false,
    sliding=false,
    landed=false
  }
  
  friend={91}

  gravity=0.3
  friction=0.85

  --simple camera
  cam_x=0

  --map limits
  map_start=0
  map_end=1024
  
 --set state
  _update = update_game
		_draw = draw_game
end


-->8

function update_menu()
		if btnp(❎) then
		
		init_game()
		end
	end

function update_game()
  player_update()
  player_animate()
  
--  update_pickups()

  --simple camera
  cam_x=player.x-64+(player.w/2)
  if cam_x<map_start then
     cam_x=map_start
  end
  if cam_x>map_end-128 then
     cam_x=map_end-128
  end
  camera(cam_x,0)
end

--draws

function draw_menu()
cls()
print("help mooshy find", 30,60)
print("its friends", 40,70)
print("press ❎ to start",30,80)
end

function draw_game()
  cls()
  map(0,0)
  spr(player.sp,player.x,player.y,1,1,player.flp)
		
	--	if (btn(⬇️))
	
	 show_inventory()

--		draw_pickups()

end
-->8
--swap tiles

function interact(x,y)
if (is_tile(friend,x,y)) then
  get_friend(x,y)
  end
end

function is_tile(tile_type,x,y)
 tile=mget(flr(x/64),(flr(y/64)))
 for i=1,#tile_type do
  if (tile==tile_type[i]) return true
 end
 return false
end
		
function swap_tile(x,y)
 tile=mget(flr(x/64),(flr(y/64)))
 mset(flr(x/64),(flr(y/64)),tile+1)
end

function get_friend(x,y)
 player.friend+=1
-- friendscore+=1
 swap_tile(x,y)
-- sfx(1)
end


--collisions

function collide_map(obj,aim,flag)
 --obj = table needs x,y,w,h
 --aim = left,right,up,down

 local x=obj.x  local y=obj.y
 local w=obj.w  local h=obj.h

 local x1=0	 local y1=0
 local x2=0  local y2=0

 if aim=="left" then
   x1=x-1  y1=y
   x2=x    y2=y+h-1

 elseif aim=="right" then
   x1=x+w-1    y1=y
   x2=x+w  y2=y+h-1

 elseif aim=="up" then
   x1=x+2    y1=y-1
   x2=x+w-3  y2=y

 elseif aim=="down" then
   x1=x+2      y1=y+h
   x2=x+w-3    y2=y+h
 end

 --pixels to tiles
 x1/=8    y1/=8
 x2/=8    y2/=8

 if fget(mget(x1,y1), flag)
 or fget(mget(x1,y2), flag)
 or fget(mget(x2,y1), flag)
 or fget(mget(x2,y2), flag) then
   return true
 else
   return false
 end

end

-->8
--player

function player_update()
  --physics
  player.dy+=gravity
  player.dx*=friction

  --controls
  if btn(⬅️) then
    player.dx-=player.acc
    player.running=true
    player.flp=true
  end
  if btn(➡️) then
    player.dx+=player.acc
    player.running=true
    player.flp=false
  end

  --slide
  if player.running
  and not btn(⬅️)
  and not btn(➡️)
  and not player.falling
  and not player.jumping then
    player.running=false
    player.sliding=true
  end

  --jump
  if btnp(❎)
  and player.landed then
    player.dy-=player.boost
    player.landed=false
    
  end

	interact(player.x*8,player.y*8)

  --check collision up and down
  if player.dy>0 then
    player.falling=true
    player.landed=false
    player.jumping=false

    player.dy=limit_speed(player.dy,player.max_dy)

    if collide_map(player,"down",0) then
      player.landed=true
      player.falling=false
      player.dy=0
      player.y-=((player.y+player.h+1)%8)-1
    end
  elseif player.dy<0 then
    player.jumping=true
    if collide_map(player,"up",1) then
      player.dy=0
    end
  end

  --check collision left and right
  if player.dx<0 then

    player.dx=limit_speed(player.dx,player.max_dx)

    if collide_map(player,"left",1) then
      player.dx=0
    end
  elseif player.dx>0 then

    player.dx=limit_speed(player.dx,player.max_dx)

    if collide_map(player,"right",1) then
      player.dx=0
    end
  end

  --stop sliding
  if player.sliding then
    if abs(player.dx)<.2
    or player.running then
      player.dx=0
      player.sliding=false
    end
  end

  player.x+=player.dx
  player.y+=player.dy
 --limit player to map
  if player.x<map_start then
    player.x=map_start
  end
  if player.x>map_end-player.w then
    player.x=map_end-player.w
  end
end

function player_animate()
  if player.jumping then
    player.sp=7
  elseif player.falling then
    player.sp=8
  elseif player.sliding then
    player.sp=9
  elseif player.running then
    if time()-player.anim>.1 then
      player.anim=time()
      player.sp+=1
      if player.sp>6 then
        player.sp=3
      end
    end
  else --player idle
    if time()-player.anim>.3 then
      player.anim=time()
      player.sp+=1
      if player.sp>2 then
        player.sp=1
      end
    end
  end
end

function limit_speed(num,maximum)
  return mid(-maximum,num,maximum)
end

-->8
--inventory

function show_inventory()
invx=player.x
invy=8


--rectfill(invx,invy,invx+48,invy+24,8)
print("friends:"..player.friend,invx+7,invy+4,0)

end
-->8
--pickups
--function init_pickups()
	--	pu = {}
	--	add(pu, {s=91, x=25, y=1})
	--	add(pu, {s=91, x=51, y=3})
--end


--function update_pickups()

--end


--function draw_pickups()
			--for p in all(pu) do
					--spr(p.s, p.x*8, p.y*8)
			
		--	end
--end
-->8
--collision for pickups

--function aabb_collide(
--		x1, y1, w1, h1
--		x2, y2, w2, h2)
		
	--	if x1 < x2 + w2 and
				--	x1 + w1 > x2 and
					--y1 < y2 + h2 and
				--	y1 + h1 > y2
				--	return true
				--	end
				
		
	--	return false
--end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008888000000000000888800008888000088880000888800000000000088880000000000000000000000000000000000000000000000000000000000
00700700088878800088880008887880088887800888788008888780008888000888788000888800000000000000000000000000000000000000000000000000
00077000087888800888788008788880088788800878888008878880088878800878888008887880000000000000000000000000000000000000000000000000
00077000088888800878888008888880088888800888888008888880087888800888888008788880000000000000000000000000000000000000000000000000
00700700007171000888888000717100007771000071710000777100088888800071710008888880000000000000000000000000000000000000000000000000
00000000007777000077770000777700007777000077770000777700007777000077770000717100000000000000000000000000000000000000000000000000
00000000007005000070050000700500000750000050070000057000000750000007500000777700000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbcb33ebbbbbbbbbbb3300000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbb3bbbbbbbbbbbbbbb3bbbbbbbbcac3eaeb3bbbb3bbbb300000000000000000000000000000000000000000000000000000000000000000000000000000000
bb3333b3bbbb3bb33bb3333b3bb33bcbbbeb333bb343bbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000
3b3444b43bb333b433b3443b3bb3443bbbb3344334433bbb00000000000000000000000000000000000000000000000000000000000000000000000000000000
4b4484344b344334443444434b344443bb3b4444444433bb00000000000000000000000000000000000000000000000000000000000000000000000000000000
4348a84443444434444444444b444444bb43444444443b3b00000000000000000000000000000000000000000000000000000000000000000000000000000000
44448454544444455444444544444445b3444445544444bb00000000000000000000000000000000000000000000000000000000000000000000000000000000
54444555554454445544445555444455334444554544444300000000000000000000000000000000000000000000000000000000000000000000000000000000
54444444444455544444554444444545000000004544444444444544000000000000000000000000000000003333333333333333000000000000000000000000
554444444444455444455444444444550000000044544554444454440000000000000000000777770000000033eeee3333333333000000000000000000000000
54444444444444444454444444c44544000000004444544444444444000000000000000000077557000000003eee7ee333333333000000000000000000000000
4444444444444444444444454cac4444000000004444444445444445000000000000000000755770000000003e7eeee333333333000000000000000000000000
44444444444444444444455444c44444000000005444444444544455000000000000000007577700000000003eeeeee333333333000000000000000000000000
4444444444444444445544444444444400000000354544444444445300000000000000007777700000000000337d7d3333333333000000000000000000000000
44444445544444444544444454444444000000003355544554445533000000000000000000000000000000003377773333333333000000000000000000000000
44444455554444445444444455444444000000003333333333333333000000000000000000000000000000003373353333333333000000000000000000000000
44444444444444444444444444444444000000000000000000000000000000000000000033333333333333333333333300000000000000000000000000000000
55555555555555554444444444444444000000000000000000000000000000000000000033333333333333333333339300000000000000000000000000000000
4554444544544444444424424445244400000000000000000000000000000000000000003333333333333333333339a900000000000000000000000000000000
4444444444454444244522452425524200000000000000000000000000000000000000003e3333333333383333333b9300000000000000000000000000000000
555555555555555554258525525855420000000000000000000000000000000000000000eaeb333333338a833b33b33300000000000000000000000000000000
4544544445444544525555255555552500000000000000000000000000000000000000003e33bb3333b3b83333bb3b3300000000000000000000000000000000
444544444444544455855555555555550000000000000000000000000000000000000000333bb333333b333333b3333300000000000000000000000000000000
3344443333333333005555000000000000000000000000000000000000000000000000003333b333333b333333b3333300000000000000000000000000000000
3344443333544434005555000055550000000000000000000000000033c33333c33c33c33333333333333333cc33333ccccccccccccccccccccccccc00000000
33444433334544430055520000225500000000000000000000000000333c33c33c33c33c333333bb3333333333333333cccccccccccccccccccccccc00000000
434445333344443b00552500005255000000000000000000000000003333333333333333333333b33333333333333333cccccccccccc777c77cccccc00000000
34445433334445330052550000552500000000000000000000000000333333333333333333333b333333333333333333ccccccccccc77767777ccccc00000000
b344443b3444543300525500005555000000000000000000000000003333333333333333b33333333333333333333333ccccccccc777767777777ccc00000000
3354443443444433005555000055550000000000000000000000000033333333333333333b3333333333333333333333ccccccccc777777777777ccc00000000
334544433b44443300255500005225000000000000000000000000003333333333333333333333333333333333333333ccccccccccccc777777ccccc00000000
3344443b3345443300525500005552000000000000000000000000003333333333333333333333333333333333333333cccccccccccccccccccccccc00000000
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888eeeeee888eeeeee888777777888eeeeee888eeeeee888eeeeee888eeeeee888888888888888888ff8ff8888228822888222822888888822888888228888
8888ee888ee88ee88eee88778887788ee888ee88ee8e8ee88ee888ee88ee8eeee88888888888888888ff888ff888222222888222822888882282888888222888
888eee8e8ee8eeee8eee8777778778eeeee8ee8eee8e8ee8eee8eeee8eee8eeee88888e88888888888ff888ff888282282888222888888228882888888288888
888eee8e8ee8eeee8eee8777888778eeee88ee8eee888ee8eee888ee8eee888ee8888eee8888888888ff888ff888222222888888222888228882888822288888
888eee8e8ee8eeee8eee8777877778eeeee8ee8eeeee8ee8eeeee8ee8eee8e8ee88888e88888888888ff888ff888822228888228222888882282888222288888
888eee888ee8eee888ee8777888778eee888ee8eeeee8ee8eee888ee8eee888ee888888888888888888ff8ff8888828828888228222888888822888222888888
888eeeeeeee8eeeeeeee8777777778eeeeeeee8eeeeeeee8eeeeeeee8eeeeeeee888888888888888888888888888888888888888888888888888888888888888
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111dd1d1d1ddd1ddd11111ddd1ddd1d111ddd11dd11111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111d111d1d1d1d1d1d111111d111d11d111d111d1111111111111111111111111111111111111111111111111111111111111111111111111111111111
1ddd1ddd1ddd1d1d1ddd1ddd111111d111d11d111dd11ddd11111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111d1ddd1d1d1d11111111d111d11d111d11111d11111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111dd11ddd1d1d1d11111111d11ddd1ddd1ddd1dd111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1ee111ee1eee1eee11ee1ee1111111661616166616661111166616661611166611711616111116161171111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111116111616161616161111116111611611161117111616111116161117111111111111111111111111111111111111
1ee11e1e1e1e1e1111e111e11e1e1e1e111116661616166616661111116111611611166117111161111116661117111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111111161666161616111111116111611611161117111616117111161117111111111111111111111111111111111111
1e1111ee1e1e11ee11e11eee1ee11e1e111116611666161616111666116116661666166611711616171116661171111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111166616661611166611111bbb11bb1bbb1bbb1171161611111616117111111111111111111111111111111111111111111111111111111111111111111111
1111116111611611161117771bbb1b111b1111b11711161611111616111711111111111111111111111111111111111111111111111111111111111111111111
1111116111611611166111111b1b1b111bb111b11711116111111666111711111111111111111111111111111111111111111111111111111111111111111111
1111116111611611161117771b1b1b1b1b1111b11711161611711116111711111111111111111111111111111111111111111111111111111111111111111111
1111116116661666166611111b1b1bbb1bbb11b11171161617111666117111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111bbb11bb1bbb1bbb11711616111116161111166616661611166611111cc11171111111111111111111111111111111111111111111111111111111111111
11111bbb1b111b1111b1171116161111161611111161116116111611117111c11117111111111111111111111111111111111111111111111111111111111111
11111b1b1bbb1bb111b1171111611111166611111161116116111661177711c11117111111111111111111111111111111111111111111111111111111111111
11111b1b111b1b1111b1171116161171111611711161116116111611117111c11117111111111111111111111111111111111111111111111111111111111111
11111b1b1bb11bbb11b111711616171116661711116116661666166611111ccc1171111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1ee11ee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1ee11e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1eee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1ee111ee1eee1eee11ee1ee1111111661666166611111616166616161171161611111616117111111111111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111116111611116111111616161116161711161611111616111711111111111111111111111111111111111111111111
1ee11e1e1e1e1e1111e111e11e1e1e1e111116111661116111111661166116661711116111111666111711111111111111111111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111116161611116111111616161111161711161611711116111711111111111111111111111111111111111111111111
1e1111ee1e1e11ee11e11eee1ee11e1e111116661666116116661616166616661171161617111666117111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111166611111616166616161166111111111cc11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111616111116161611161616111171177711c11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111666111116611661166616661777111111c11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111611111116161611111611161171177711c11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111161111711616166616661661111111111ccc1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111161611661166116616661666111111111cc11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111616161116111616161616111171177711c11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111661166616111616166116611777111111c11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111616111616111616161616111171177711c11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111161616611166166116161666111111111ccc1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111166161616661666111116661666161116661171161611111616117111111111111111111111111111111111111111111111111111111111111111111111
11111611161616161616111111611161161116111711161611111616111711111111111111111111111111111111111111111111111111111111111111111111
11111666161616661666111111611161161116611711116111111666111711111111111111111111111111111111111111111111111111111111111111111111
11111116166616161611111111611161161116111711161611711116111711111111111111111111111111111111111111111111111111111111111111111111
11111661166616161611166611611666166616661171161617111666117111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111bb1bbb1b1b11711cc111711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111b111b111b1b171111c111171111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111bbb1bb111b1171111c111171111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111b1b111b1b171111c111171111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111bb11b111b1b11711ccc11711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1ee11ee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1ee11e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1eee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111dd11dd1d111d111ddd11dd1ddd11dd1dd111dd11111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111d111d1d1d111d1111d11d1111d11d1d1d1d1d1111111111111111111111111111111111111111111111111111111111111111111111111111111111
1ddd1ddd1d111d1d1d111d1111d11ddd11d11d1d1d1d1ddd11111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111d111d1d1d111d1111d1111d11d11d1d1d1d111d11111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111dd1dd11ddd1ddd1ddd1dd11ddd1dd11d1d1dd111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1ee111ee1eee1eee11ee1ee1111111661166161116111666166116661111166616661666117111661666166611111666166616661111166616111666
1e111e1e1e1e1e1111e111e11e1e1e1e111116111616161116111161161616111111166616161616171116161616116111111616116116661111161116111616
1ee11e1e1e1e1e1111e111e11e1e1e1e111116111616161116111161161616611111161616661666171116161661116111111666116116161111166116111666
1e111e1e1e1e1e1111e111e11e1e1e1e111116111616161116111161161616111111161616161611171116161616116111711616116116161171161116111616
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
82888222822882228888822882828882828882228888888888888888888888888888888888888888888888888222822282228882822282288222822288866688
82888828828282888888882882828828828882828888888888888888888888888888888888888888888888888282888288828828828288288282888288888888
82888828828282288888882882228828822282828888888888888888888888888888888888888888888888888222882288828828822288288222822288822288
82888828828282888888882888828828828282828888888888888888888888888888888888888888888888888282888288828828828288288882828888888888
82228222828282228888822288828288822282228888888888888888888888888888888888888888888888888222822288828288822282228882822288822288
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003030303030300000000000000000000030303030000000000030000000000000101010100000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7c7c7c7c7c7c7c7c7c7c7d7e7c7c7c7c7c7c7c7c7c7c7c7c7c7d7e7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7d7e7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7d7e7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7d7e7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7c7c7c7c7d7e7c7c7c7c7c7c7c7c7c7c7c7d7e7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7d7e7c7c7c7c7c7c7c7c7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7c78777877787778777877787778777877787778777877787778777877787778777877787778777877787778777877777877444345787778777877787778777877770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7b7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a4443457a7a7a7a7a7a7a7a7a797a7a7a7a7a7a7a5553567a7a7a7a7a7a7a7a7a7a7a7a7a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a5552567a7a7a7a7a7a5b7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7a7a7a7a7a7a797a7a7a7a7a7a797a7a7a7a7a7a7a7a7a7a7a7a7a5b7a7a7a7a7a7a797a7a7a6160617a7a444340457a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7a797a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a44457a7a7a7a7a7a7a7a7a7a7a717a7a7a555251567a7a7a7a7a7a7a7a7a6160617a7a7a7a7a7a7a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a55567a7a7a7a7a7a7a7a7a7a7a717a797a7a7a7a7a7a7a7a7a7a7a7a7a7a7a707a7a7a7a7a7a7a7a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7a7a7a7a797a7a7a7a7a7a7a7a6061607a7a7a7a7a7a7a7a7a7a7a7a7a7a6061607a7a7a7a7a7a707a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a717a7a7a7a7a7a7a7a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7a7a7a7a7a7a7a7a697a7a797a707a717a7a7a7a7a7a7a7a6b7a7a7a7a7a717a707a7a7a44404342457a7a6a7a7a7a7a7a7a7a7a7a7a7a44434140417a7a7a7a7a7a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7a7a7a7a7a7a4442457a7a7a7a717a707a7a7a7a7a7a7a444240457a7a7a707a717a7a4453515250524240424241457a7a7a7a7a7a7a7a55535152517a7a7a7a7a7a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7a7a7a6a7a44525050457a5b7a707a707a7a44457a7a4452515350457a69717a707a445152515153515150505053567a7a7a7a7a7a7a7a7a555352507a7a7a7a7a7a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4041424242505150505343414241414043415153424153505251505142424142434053515152505252515352525600000000000000000000005551520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5052505350535052525150525150515352515251535150525051535251535051515251525051515153515151560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
001100001b5501d55021550265502855026550215502155024550295502b550295501d550195501c55020550265502955027550255502455024550275502a5502b5502a55024550225502355026550285502a550
00060000000002f050330503505035050000500404005040320403104000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500003105036050370403701038040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0008000034050370503a0503a05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
