#==========================================================================
# *** Bestiary/Monster Book
#--------------------------------------------------------------------------
#  This plugin provides a list of enemies defeated in-game. The bestiary
# shows the quantity of enemies slain, along with other stats, from health
# to treasures to weaknesses and strengths.
#
# * Version: 1.0.1
#
# * Updated: 2017-10-29
#
# * Coded by: boaromayo/Quesada's Swan
#
# Optional prerequisites:
#  * Expanded iconset for elements
#
# NOTE: If you are using this plugin for your projects (commercial or non-commercial), 
# be sure to leave this comment visible or credit me (boaromayo or Quesada's Swan) 
# somewhere in your projects.
#==========================================================================
#==========================================================================
# ** RPG::Enemy Modifications
#==========================================================================
class RPG::Enemy < RPG::BaseItem
  attr_accessor	:slain						# Number of certain enemy defeated
  #------------------------------------------------------------------------
  # * alias method: Object Initialization
  #------------------------------------------------------------------------
  alias enemy_initialize initialize
  def initialize
	enemy_initialize
	@slain = 0
  end
end
#==========================================================================
# ** Game_System
#--------------------------------------------------------------------------
#  This class handles system data. It saves the disable state of saving and 
# menus. Instances of this class are referenced by $game_system.
#==========================================================================
class Game_System
  #------------------------------------------------------------------------
  # * Add new public instance variables
  #------------------------------------------------------------------------
  attr_accessor :enemy_encounter			# Checks if enemy encountered?
  attr_accessor :enemy_slain?				# Number of enemies slain
  #------------------------------------------------------------------------
  # * Add initialize method
  #------------------------------------------------------------------------
  alias bestiary_initialize initialize
  def initialize
	bestiary_initialize
	@enemy_encounter = []
	@enemy_slain? = 0
	$data_enemies.size.each do |enemy|
	  @enemy_encounter[enemy] = false
	end
  end
end

#==========================================================================
# ** Game_Troop
#--------------------------------------------------------------------------
#  This class handles enemy groups and battle-related data. Also performs
# battle events. The instance of this class is referenced by $game_troop.
#==========================================================================
class Game_Troop < Game_Unit
  #------------------------------------------------------------------------
  # * override method: 
  #------------------------------------------------------------------------
  alias 
  def
    
  end
  #------------------------------------------------------------------------
  # * new method: Include Dead Enemies
  #------------------------------------------------------------------------
  def check_enemies
    enemies.each do |enemy|
	  unless enemy.slain > 0
	    $game_system.enemy_slain? += 1
		$game_system.enemy_encounter[enemy.id] = true
	  end
	end
  end
end

#==========================================================================
# ** Window_BestiaryStatus
#--------------------------------------------------------------------------
#  This window displays the completeness of the bestiary.
#==========================================================================
class Window_BestiaryStatus < Window_Help
  #------------------------------------------------------------------------
  # * Object Initialization
  #------------------------------------------------------------------------
  def initialize
    super
    draw_progress
  end
  #------------------------------------------------------------------------
  # * Draw Progress
  #------------------------------------------------------------------------
  def draw_progress
    completed = $game_system.enemy_slain?
    max_enemies = $data_enemies.size
	#complete_pct = (completed / max_i) * 100
    prog_text = "Progress: " + completed.to_s + "/" + max_enemies.to_s
    set_text(prog_text)
  end
end

#==========================================================================
# ** Window_BestiaryList
#--------------------------------------------------------------------------
#  This window displays the list of monsters.
#==========================================================================
class Window_BestiaryList < Window_Selectable
  #------------------------------------------------------------------------
  # * Object Initialization
  #------------------------------------------------------------------------
  def initialize
    super(0, 0, Graphics.width, Graphics.height - fitting_height(2))
    @data = []
  end
  #------------------------------------------------------------------------
  # * Get Column Count
  #------------------------------------------------------------------------
  def col_max
    return 2
  end
  #------------------------------------------------------------------------
  # * Get Number of Enemies Slain
  #------------------------------------------------------------------------
  def enemy_now
	$game_system.enemy_slain?
  end
  #------------------------------------------------------------------------
  # * Get Maximum Number of Enemies In Bestiary
  #------------------------------------------------------------------------
  def enemy_max
    $data_enemies.size
  end
  #------------------------------------------------------------------------
  # * Get Data of Selected Enemy
  #		id : Enemy ID
  #------------------------------------------------------------------------
  def enemy(id)
    @data[id]
  end
  #------------------------------------------------------------------------
  # * Determine Entry Recorded
  #------------------------------------------------------------------------
  def recorded?(id)
    enemy(id) != nil
  end
  #------------------------------------------------------------------------
  # * Get Enemies Data
  #------------------------------------------------------------------------
  #def enemies
	#@data
  #end
  #------------------------------------------------------------------------
  # * Add Enemy Data
  #		id 	   : Enemy ID
  #		enemy  : Enemy
  #------------------------------------------------------------------------
  def add_enemy(id, enemy)
    @data[id] = enemy
  end
  #------------------------------------------------------------------------
  # * Draw Item - Enemy Data
  #		id  : Enemy ID
  #------------------------------------------------------------------------
  def draw_item(id)
    change_color(normal_color, recorded?(id))
	recorded?(id) ? draw_text(item_rect_for_text(id), enemy(id).name, 0) : 
		draw_text(item_rect_for_text(id), "????????")
	recorded?(id) ? draw_text(item_rect_for_text(id), enemy(id).slain, 1) : 0
  end
end

#==========================================================================
# ** Window_BestiaryLeft
#--------------------------------------------------------------------------
#  This window (the left window) displays the enemy's sprite & background.
#==========================================================================
class Window_BestiaryLeft < Window_Selectable
  #------------------------------------------------------------------------
  # * Object Initialization
  #------------------------------------------------------------------------
  def initialize(enemy)
    super(0, 0, window_width, Graphics.height)
    @enemy = enemy
    refresh
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    return Graphics.width / 2
  end
  #--------------------------------------------------------------------------
  # * Get Window Height
  #--------------------------------------------------------------------------
  def window_height
    return Graphics.height / 2
  end
  #------------------------------------------------------------------------
  # * Set Enemy
  #------------------------------------------------------------------------
  def enemy=(enemy)
    return if @enemy == enemy
    @enemy = enemy
    refresh
  end
  #------------------------------------------------------------------------
  # * Get Enemy Bitmap
  #------------------------------------------------------------------------
  def enemy_bitmap(enemy)
    sprite = enemy.battler_sprite
	sprite
  end
  #------------------------------------------------------------------------
  # * Get Battle Background
  #------------------------------------------------------------------------
  def enemy_background(enemy)
    enemy.battle_background
  end
end

#==========================================================================
# ** Window_BestiaryRight
#--------------------------------------------------------------------------
#  This window (the right window) displays enemy stats (HP, MP, etc).
#==========================================================================
class Window_BestiaryRight < Window_Selectable
  #------------------------------------------------------------------------
  # * Object Initialization
  #------------------------------------------------------------------------
  def initialize(enemy)
    super(window_width, 0, window_width, Graphics.height)
    @enemy = enemy
	create_ratings
    refresh
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    return Graphics.width / 2
  end
  #--------------------------------------------------------------------------
  # * Draw Enemy Name
  #--------------------------------------------------------------------------
  def draw_enemy_name(enemy, x, y, width = 144)
    name = enemy.battler_name
    draw_text(x, y, width, line_height, name)
  end
  #--------------------------------------------------------------------------
  # * Draw Horizontal Line
  #--------------------------------------------------------------------------
  def draw_horz_line(y)
    line_y = y + line_height / 2 - 1
    contents.fill_rect(0, line_y, contents_width, 2, line_color)
  end
  #--------------------------------------------------------------------------
  # * Get Color of Horizontal Line
  #--------------------------------------------------------------------------
  def line_color
    color = system_color
    color.alpha = 48
    color
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh(mode = 0)
    contents.clear
    draw_enemy_name(@enemy, window_width - 10, 0)
    draw_horz_line(line_height + line_height / 4 + 3)
    if mode == 0
      draw_basic_stats(@enemy, 10, 0)
      draw_other_stats(@enemy, 10, line_height * 3)
    elsif mode == 1
      draw_elem_stats(@enemy)
    elsif mode == 2
	  draw_enemy_items(@enemy, 10, 0)
	end
  end
  #--------------------------------------------------------------------------
  # * Draw Basic Stats
  #--------------------------------------------------------------------------
  def draw_basic_stats(enemy, x, y)
    draw_enemy_hp(enemy, x, y + line_height * 2)
    draw_enemy_mp(enemy, x, y + line_height * 3)
	#draw_enemy_tp(enemy, x, y + line_height * 4)
  end
  #--------------------------------------------------------------------------
  # * Draw Other Stats
  #--------------------------------------------------------------------------
  def draw_other_stats(enemy, x, y)
    param_count.each { |i| draw_enemy_param(enemy, x, y + line_height * i, i) }
  end
  #--------------------------------------------------------------------------
  # * Draw Enemy Element Status Rates
  #--------------------------------------------------------------------------
  def draw_elem_stats(enemy)
    # Add the defense ratings starting from weakest => absorbing
    add_ratings
    elements_count.each do |elem|
	  draw_enemy_element(enemy, 10, line_height * (elem + 2), elem)
	end
	change_color(normal_color)
  end
  #--------------------------------------------------------------------------
  # * Enemy Parameter Count
  #--------------------------------------------------------------------------
  def param_count
    2..7 # 2 => ATK, 7 => LCK
  end
  #--------------------------------------------------------------------------
  # * Enemy S-Parameter Count
  #--------------------------------------------------------------------------
  def sparam_count
    1..5 # 1 => , 5 =>
  end
  #--------------------------------------------------------------------------
  # * Enemy Element Rate Count
  #	    NOTE: Adjust number of elements counted based on elements used.
  #--------------------------------------------------------------------------
  def elements_count
    3..14 # 3 => Fire, 14 => Void/Null
  end
  #--------------------------------------------------------------------------
  # * Enemy States Rate Count
  #		NOTE: Adjust number of states counted based on states used.
  #--------------------------------------------------------------------------
  def states_count
    1..10 # 1 => Death, 10 => Burn?
  end
  #--------------------------------------------------------------------------
  # * Draw Enemy HP
  #--------------------------------------------------------------------------
  def draw_enemy_hp(enemy, x, y, width = 288)
    change_color(system_color)
    draw_text(x, y, width, line_height, Vocab::hp)
    change_color(normal_color)
    draw_text(x + width - 32, y, width, line_height, enemy.mhp, 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Enemy MP
  #--------------------------------------------------------------------------
  def draw_enemy_mp(enemy, x, y, width = 288)
    change_color(system_color)
    draw_text(x, y, width, line_height, Vocab::mp)
    change_color(normal_color)
    draw_text(x + width - 32, y, width, line_height, enemy.mmp, 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Enemy TP
  #--------------------------------------------------------------------------
  def draw_enemy_tp(enemy, x, y, width = 288)
    change_color(system_color)
    draw_text(x, y, width, line_height, Vocab::tp)
    change_color(normal_color)
    draw_text(x + width - 32, y, width, line_height, enemy.tp, 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Enemy Parameters
  #--------------------------------------------------------------------------
  def draw_enemy_param(enemy, x, y, param_id, width = 172)
    change_color(system_color)
    draw_text(x, y, width, line_height, Vocab::param(param_id))
    change_color(normal_color)
    draw_text(x + width - 32, y, width, line_height, enemy.param(param_id), 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Enemy Ex-Parameters
  #--------------------------------------------------------------------------
  def draw_enemy_eva(enemy, x, y, width = 172)
    change_color(system_color)
	draw_text(x, y, width, line_height, "EVA")
	change_color(normal_color)
	draw_text(x + width - 32, y, width, line_height, enemy.eva, 1)
	draw_text(x + width - 32 + 4, y, 16, line_height, "%", 1)
  end
  #--------------------------------------------------------------------------
  # * Create Enemy Defense Ratings List
  #--------------------------------------------------------------------------
  def create_ratings
	@rate_list = []
  end
  #--------------------------------------------------------------------------
  # * Add Enemy Defense Rating
  #     name   : rating name
  #     symbol : corresponding symbol
  #--------------------------------------------------------------------------
  def add_rating(name, symbol)
    @rate_list.push({:name=>name, :symbol=>symbol})
  end
  #--------------------------------------------------------------------------
  # * Get Enemy Defense Rating
  #--------------------------------------------------------------------------
  def rating(index)
    @rate_list[index][:name]
  end
  #--------------------------------------------------------------------------
  # * Add Enemy Rating Names
  #--------------------------------------------------------------------------
  def add_ratings
    add_rating("Very Weak", :very_weak)
    add_rating("Weak",      :weak)
    add_rating("---------", :neutral)
    add_rating("Strong",    :strong)
    add_rating("Immune",    :immune)
    add_rating("Absorb",    :absorb)
  end
  #--------------------------------------------------------------------------
  # * Draw Enemy Element Defense Stats
  #--------------------------------------------------------------------------
  def draw_enemy_element(enemy, x, y, param_id, width = 172)
    # Element tag to track enemy's element defense
    element_def = ""
    erate = enemy.element_rate(param_id)
	# Branch rating based on enemy's element defense
    if erate >= 200
	  change_color(text_color(10))
      element_def = rating(0)
    elsif erate > 100
	  change_color(text_color(2))
      element_def = rating(1)
    elsif erate == 100
	  change_color(normal_color, false)
      element_def = rating(2)
    elsif erate > 0
      element_def = rating(3)
    elsif erate == 0
      element_def = rating(4)
    else
	  change_color(text_color(3))
      element_def = rating(5)
    end
	draw_icon(element_icon(param_id), x, y)
    draw_text(x + width - 32, y, width, line_height, element_def, 2)
  end
  #------------------------------------------------------------------------
  # * Draw Enemy State Defense Stats
  #------------------------------------------------------------------------
  def draw_enemy_state(enemy, x, y, param_id, width = 172)
    # State defense tag to track enemy's status defense
    state_def = ""
    srate = enemy.state_rate(param_id)
	# Branch rating based on enemy's state defense
	if srate >= 200
	  change_color(text_color(10))
	  state_def = rating(0)
	elsif srate > 100
	  change_color(text_color(2))
	  state_def = rating(1)
	elsif srate == 100
	  change_color(normal_color, false)
	  state_def = rating(2)
	elsif srate > 0
	  state_def = rating(3)
	elsif srate == 0
	  state_def = rating(4)
	else
	  change_color(text_color(3))
	  state_def = rating(5)
	end
	draw_text(x + width - 32, y, width, line_height, state_def, 2)
  end
  #------------------------------------------------------------------------
  # * Draw Enemy Debuff Defense Stats
  #------------------------------------------------------------------------
  def draw_enemy_debuff(enemy, x, y, param_id, width = 172)
    # Debuff defense tag to track enemy's status defense
    debuff_def = ""
    debuff_rate = enemy.debuff_rate(param_id)
	# Branch rating based on enemy's debuff defense
	if debuff_rate >= 200
	  change_color(text_color(10))
	  debuff_def = rating(0)
	elsif debuff_rate > 100
	  change_color(text_color(2))
	  debuff_def = rating(1)
	elsif debuff_rate == 100
	  change_color(normal_color, false)
	  debuff_def = rating(2)
	elsif debuff_rate > 0
	  debuff_def = rating(3)
	elsif debuff_rate == 0
	  debuff_def = rating(4)
	else
	  change_color(text_color(3))
	  debuff_def = rating(5)
	end
	draw_text(x + width - 32, y, width, line_height, debuff_def, 2)
  end
  #------------------------------------------------------------------------
  # * Draw Enemy Dropped Items
  #------------------------------------------------------------------------
  def draw_enemy_items(enemy, x, y, width = 172)
    items = enemy.drop_items
    change_color(system_color)
    draw_text(x, y, width, line_height, "Drops")
	draw_horz_line(y + line_height)
    change_color(normal_color)
    items.each do |item|
	  draw_item_name(item, x, y + line_height * 2)
    end
  end
  #------------------------------------------------------------------------
  # * Draw Element Icons
  # 	Note: These numbers are only applicable to the big iconset.
  #------------------------------------------------------------------------
  def element_icon(index)
    # Set icon values based on icon index (adjust if icon index for each element is different)
    elem_icon = 101
	physical_icon = 2
	wood_icon = 192
	steel_icon = 146
	heart_icon = 135
	byss_icon = 136
	
	# Return icon value based on index passed
	return index + elem_icon if index > 2 && index < 11
	return 0 if index == 2
	return wood_icon if index == 11
	return steel_icon if index == 12
	return heart_icon if index == 13
	return byss_icon if index == 14
	return physical_icon
  end
  #------------------------------------------------------------------------
  # * Draw Element Icons
  #  Note: This method is for the default iconset.
  #------------------------------------------------------------------------
  #def element_icon(index)
    # Set icon values based on loaded bigicon
    #elem_icon = 93
	#physical_icon = 107
	
	# Return icon value based on index passed
	#return index + elem_icon if index > 2 && index < 11
	#return 0 if index == 2
	#return physical_icon
  #end
end

#==========================================================================
# ** Scene_Bestiary
#--------------------------------------------------------------------------
#  This class performs the bestiary scene processing.
#==========================================================================

class Scene_Bestiary < Scene_Base
  #------------------------------------------------------------------------
  # * Start Processing
  #------------------------------------------------------------------------
  def start
    super
	@id = 0
	load_bestiary_data
    create_bestiary_list_windows
    create_bestiary_windows(enemy(@id))
  end
  #------------------------------------------------------------------------
  # * Create Bestiary List
  #------------------------------------------------------------------------
  def create_bestiary_list_windows
    create_status_window
    create_list_window
  end
  #------------------------------------------------------------------------
  # * Create Stat Window
  #------------------------------------------------------------------------
  def create_status_window
    @status_window = Window_BestiaryStatus.new
    @status_window.viewport = @viewport
  end
  #------------------------------------------------------------------------
  # * Create Bestiary List Window
  #------------------------------------------------------------------------
  def create_list_window
    @list_window = Window_BestiaryList.new
	@list_window.activate
	@list_window.show
  end
  #------------------------------------------------------------------------
  # * Create Bestiary Windows
  #		enemy : Enemy Data
  #------------------------------------------------------------------------
  def create_bestiary_windows(enemy)
    create_left_window(enemy)
    create_right_window(enemy)
  end
  #------------------------------------------------------------------------
  # * Create Left Window
  #		enemy : Enemy Data
  #------------------------------------------------------------------------
  def create_left_window(enemy)
    @left_window = Window_BestiaryLeft.new(enemy)
	@left_window.deactivate
	@left_window.hide
  end
  #------------------------------------------------------------------------
  # * Create Right Window
  #		enemy : Enemy Data
  #------------------------------------------------------------------------
  def create_right_window(enemy)
    @right_window = Window_BestiaryRight.new(enemy)
	@right_window.deactivate
	@right_window.hide
  end
  #------------------------------------------------------------------------
  # * Load Bestiary Data
  #------------------------------------------------------------------------
  def load_bestiary_data
	enemies_encounter = $game_system.enemy_encounter
	enemies_slain	  = $game_system.enemy_slain?
	enemies_slain_no  = $data_enemies.slain
	# Place list into data based on the number of enemies slain
	if enemies_slain > 0
	  enemies_encounter.each do |enemy|
		@list_window.add_enemy(enemy.id, enemy) if enemies_encounter[enemy] == true
	  end
	end
  end
  #------------------------------------------------------------------------
  # * Frame Update
  #------------------------------------------------------------------------
  def update
    super
    update_all_windows
  end
  #------------------------------------------------------------------------
  # * Update All Windows
  #------------------------------------------------------------------------
  def update_all_windows
    @left_window.update
    @right_window.update
  end
  #------------------------------------------------------------------------
  # * Get Enemy
  #		id : Enemy ID Number
  #------------------------------------------------------------------------
  def enemy(id)
	@list_window.enemy(id)
  end
  #------------------------------------------------------------------------
  # * Switch to Next Enemy
  #------------------------------------------------------------------------
  def next_enemy
  end
  #------------------------------------------------------------------------
  # * Switch to Previous Enemy
  #------------------------------------------------------------------------
  def prev_enemy
  end
end
