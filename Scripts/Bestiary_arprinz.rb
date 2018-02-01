#==========================================================================
# *** Bestiary/Monster Book
#--------------------------------------------------------------------------
#  This plugin provides a list of enemies defeated in-game. The bestiary
# shows the quantity of enemies slain, along with other stats, from health
# to treasures to weaknesses and strengths.
#
# * Version: 0.8.1
#
# * Initial release: 2017-10-16
#
# * Initial commit: 2017-10-16
#
# * Updated: 2018-01-31
#
# * Coded by: boaromayo/Quesada's Swan
#
# Optional prerequisites:
#  * Expanded iconset for elements
#
# NOTE: If you are using this plugin for your projects (commercial or non-commercial), 
# be sure to leave this comment visible or credit me (boaromayo or Quesada's Swan) 
# somewhere in your projects.
#
# * Changelog:
#    -- Updated other information - 2018-01-31
#    -- Changed die method to an alias - 2018-01-10
#    -- Added third mode and mode number - 2018-01-04
#    -- Fixed second mode bugs - 2018-01-03
#    -- Fixed enemy sprite bug and other bugs - 2017-12-21
#    -- Initial v0.8.1 alpha release - 2017-12-20
#    -- Added enemy name and number slain - 2017-11-20
#    -- Fixed bug that prevents leaving bestiary menu - 2017-11-17
#    -- Fixed additional crashing bugs - 2017-11-16
#    -- Modified game objects and fixed bugs - 2017-11-15
#    -- Fixed additional bugs - 2017-11-14
#    -- Fixed error bug in Game_System - 2017-11-14
#    -- Added Scene_Menu override methods - 2017-11-14
#    -- Added Game_Enemy new and override methods - 2017-11-14
#    -- Added $imported global variable - 2017-11-06
#    -- Unknown text method re-added - 2017-11-06
#    -- Unknown text method removed - 2017-11-05
#    -- Edited draw_item method - 2017-11-04
#    -- Added sparam_count method - 2017-11-04
#    -- Removed explicit condition in loading data - 2017-11-02
#    -- Displayed enemy slain in list window - 2017-10-26
#    -- Added more features and fixed bugs - 2017-10-25
#    -- Added more features - 2017-10-18
#    -- Initial commit - 2017-10-16
#    -- Started script - 2017-10-09
#==========================================================================

$imported ||= {}
$imported["Bestiary_arprinz"] = true

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
  attr_accessor :enemy_slain			    # Quantity of enemy types slain
  attr_accessor :enemy_list           # List of enemies slain
  attr_accessor :total_enemy_slain		# Number of enemies slain
  #------------------------------------------------------------------------
  # * alias method: Object Initialization
  #------------------------------------------------------------------------
  alias bestiary_initialize initialize
  def initialize
    bestiary_initialize
    @enemy_encounter = []
    @enemy_slain = []
    @enemy_list = []
	  @total_enemy_slain = 0
    $data_enemies.each_index do |enemy|
      @enemy_encounter[enemy] = false
	    @enemy_slain[enemy] = 0
      @enemy_list[enemy] = nil
    end
  end
  #------------------------------------------------------------------------
  # * new method: Get Quantity of Certain Enemy Slain
  #------------------------------------------------------------------------
  def enemies_slain(enemy_id)
    @enemy_slain[enemy_id].to_i
  end
  #------------------------------------------------------------------------
  # * new method: Add Enemies Slain
  #------------------------------------------------------------------------
  def add_enemies_slain(enemy_id)
    unless @enemy_slain[enemy_id] > 0
      @total_enemy_slain = @total_enemy_slain + 1
    end
    @enemy_slain[enemy_id] = @enemy_slain[enemy_id] + 1
  end
end

#==========================================================================
# ** Game_Enemy
#--------------------------------------------------------------------------
#  This class handles enemies. It used within the Game_Troop class 
# ($game_troop).
#==========================================================================
class Game_Enemy < Game_Battler
  #------------------------------------------------------------------------
  # * new method: Check Enemies Encountered
  #------------------------------------------------------------------------
  def add_encountered_enemy(enemy_id)
    @enemy_id = enemy_id
    unless $game_system.enemy_encounter.include?(@enemy_id)
      $game_system.enemy_encounter[@enemy_id] = true
      # Add enemy to list if encountered
      $game_system.enemy_list[@enemy_id] = self
    end
  end
  #------------------------------------------------------------------------
  # * alias method: Die
  #------------------------------------------------------------------------
  alias bestiary_die die
  def die
	  bestiary_die
    # Enable access to enemy in list if slain
    $game_system.add_enemies_slain(@enemy_id)
  end
end

#==============================================================================
# ** Game_Troop
#------------------------------------------------------------------------------
#  This class handles enemy groups and battle-related data. Also performs
# battle events. The instance of this class is referenced by $game_troop.
#==============================================================================
class Game_Troop < Game_Unit
  #--------------------------------------------------------------------------
  # * alias method: Setup
  #  troop_id : troop_id
  #--------------------------------------------------------------------------
  alias bestiary_setup setup
  def setup(troop_id)
    bestiary_setup(troop_id)
    troop.members.each do |member|
      next unless $data_enemies[member.enemy_id]
      enemy = Game_Enemy.new(@enemies.size, member.enemy_id)
	  enemy.add_encountered_enemy(member.enemy_id)
    end
  end
end

#==========================================================================
# ** Window_BestiaryStatus
#--------------------------------------------------------------------------
#  This window displays bestiary progress.
#==========================================================================
class Window_BestiaryStatus < Window_Help
  #------------------------------------------------------------------------
  # * Object Initialization
  #------------------------------------------------------------------------
  def initialize
    super(1)
    refresh
  end
  #------------------------------------------------------------------------
  # * Draw Progress
  #------------------------------------------------------------------------
  def draw_progress
    prog_text = "Progress: " + enemy_now.to_s + "/" + enemy_max.to_s
    pct_text = enemy_pct.to_s + "%"
    draw_text_ex(4, 0, prog_text)
    draw_text(4, 0, contents.width - 8, calc_line_height(pct_text), pct_text, 2)
  end
  #------------------------------------------------------------------------
  # * Get Number of Enemies Slain
  #------------------------------------------------------------------------
  def enemy_now
    $game_system.total_enemy_slain
  end
  #------------------------------------------------------------------------
  # * Get Maximum Number of Enemies In Bestiary
  #------------------------------------------------------------------------
  def enemy_max
    $data_enemies.size
  end
  #------------------------------------------------------------------------
  # * Get Percentage of Enemies in Bestiary
  #------------------------------------------------------------------------
  def enemy_pct
    ((enemy_now.to_f / enemy_max) * 100).to_i
  end
  #------------------------------------------------------------------------
  # * override method: Refresh
  #------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_progress
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
    super(0, fitting_height(1), Graphics.width, Graphics.height - fitting_height(1))
    @unknown = "????????"
    refresh
    select(0)
    activate
  end
  #------------------------------------------------------------------------
  # * Get Column Count
  #------------------------------------------------------------------------
  def col_max
    return 2
  end
  #------------------------------------------------------------------------
  # * Get Enemies Possible
  #------------------------------------------------------------------------
  def item_max
    $game_system.enemy_list.size
  end
  #--------------------------------------------------------------------------
  # * override method: Get Activation State of Selection Item
  #--------------------------------------------------------------------------
  def current_item_enabled?
    recorded?(index)
  end
  #------------------------------------------------------------------------
  # * Determine Enemy Recorded
  #    id : Enemy ID
  #------------------------------------------------------------------------
  def recorded?(id)
    $game_system.enemies_slain(id) > 0
  end
  #------------------------------------------------------------------------
  # * Get Unknown Text
  #------------------------------------------------------------------------
  def unknown
    @unknown
  end
  #------------------------------------------------------------------------
  # * Draw Enemy Data
  #   index  : Enemy ID
  #------------------------------------------------------------------------
  def draw_item(index)
    enemy = $game_system.enemy_list[index]
    name = $game_system.enemy_encounter[index] != nil ? enemy.name : unknown
    slain = $game_system.enemies_slain(index)
    change_color(normal_color, recorded?(index))
    draw_text(item_rect_for_text(index), name, 0)
    draw_text(item_rect_for_text(index), slain, 2)
  end
end

#==========================================================================
# ** Window_BestiaryLeft
#--------------------------------------------------------------------------
#  This window (the left window) displays the enemy's sprite & background.
#==========================================================================
class Window_BestiaryLeft < Window_Base
  #------------------------------------------------------------------------
  # * Object Initialization
  #------------------------------------------------------------------------
  def initialize(enemy = nil)
    super(0, 0, window_width, Graphics.height)
    @enemy = enemy
    self.visible = false
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
    refresh(enemy)
  end
  #------------------------------------------------------------------------
  # * Get Enemy Bitmap
  #------------------------------------------------------------------------
  def enemy_bitmap(enemy)
    sprite = Cache.battler(enemy.battler_name, enemy.battler_hue)
	  sprite
  end
  #------------------------------------------------------------------------
  # * Get Battle Background
  #------------------------------------------------------------------------
  def enemy_battleback(enemy)
    #sprite1 = Cache.battleback1()
    #sprite2 = Cache.battleback2()
  end
  #------------------------------------------------------------------------
  # * Draw Enemy Bitmap
  #------------------------------------------------------------------------
  def draw_enemy_graphic(enemy, x, y)
    bitmap = enemy_bitmap(enemy)
    bw = bitmap.width
    bh = bitmap.height
    src_rect = Rect.new(0, 0, bw, bh)
    contents.blt(x - bw / 2, y - bh / 2, bitmap, src_rect)
  end
  #------------------------------------------------------------------------
  # * Refresh
  #------------------------------------------------------------------------
  def refresh(enemy)
    contents.clear
    if enemy != nil
      draw_enemy_graphic(enemy, window_width / 2, window_height)
    end
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
  def initialize(enemy = nil)
    super(window_width, 0, window_width, Graphics.height)
    @enemy = enemy
    @mode = 0
    @max_mode = 2
    self.visible = false
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    return Graphics.width / 2
  end
  #------------------------------------------------------------------------
  # * Set Enemy
  #------------------------------------------------------------------------
  def enemy=(enemy)
    return if @enemy == enemy
    @enemy = enemy
    refresh
  end
  #--------------------------------------------------------------------------
  # * Draw Current Mode
  #--------------------------------------------------------------------------
  def draw_mode(width = 128)
    current_mode = (@mode+1).to_s
    max_mode = (@max_mode+1).to_s
    mode_rate = current_mode + "/" + max_mode
    draw_text(4 + width - 16, Graphics.height - 52, width, line_height, mode_rate, 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Enemy Name
  #--------------------------------------------------------------------------
  def draw_enemy_name(enemy, x, y, width = 144)
    name = enemy.name
    draw_text(x, y, width, line_height, name)
  end
  #--------------------------------------------------------------------------
  # * Draw Horizontal Line
  #--------------------------------------------------------------------------
  def draw_horz_line(y)
    line_y = y + line_height / 4 - 1
    contents.fill_rect(0, line_y, contents_width, 2, line_color)
  end
  #--------------------------------------------------------------------------
  # * Get Color of Horizontal Line
  #--------------------------------------------------------------------------
  def line_color
    color = system_color
    color.alpha = 160
    color
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh(mode = 0)
    contents.clear
    create_ratings
    add_ratings # Add defense ratings starting from weakest => absorbing
    draw_horz_line(line_height)
    draw_mode
    if @enemy != nil
      draw_enemy_name(@enemy, 4, 0)
      if mode == 0
        draw_basic_stats(@enemy, 4, 0)
        draw_other_stats(@enemy, 4, line_height * 3)
      elsif mode == 1
        draw_elem_stats(@enemy)
      elsif mode == 2
        draw_enemy_items(@enemy, 4, line_height * 2)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Previous Mode
  #--------------------------------------------------------------------------
  def previous_mode
    @mode = @mode > 0 ? @mode - 1 : @max_mode
    refresh(@mode)
    activate
  end
  #--------------------------------------------------------------------------
  # * Next Mode
  #--------------------------------------------------------------------------
  def next_mode
    @mode = @mode < @max_mode ? @mode + 1 : 0
    refresh(@mode)
    activate
  end
  #--------------------------------------------------------------------------
  # * override method: Hide Window
  #--------------------------------------------------------------------------
  def hide
    super
    @mode = 0 # Set to first panel of window during hiding process
    refresh(@mode)
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
    draw_enemy_eva(enemy, x, y + line_height * 8)
  end
  #--------------------------------------------------------------------------
  # * Draw Enemy Element Status Rates
  #--------------------------------------------------------------------------
  def draw_elem_stats(enemy)
    # Get each element's status for enemy
    elements_count.each do |elem|
      draw_enemy_defense(enemy, 4, line_height * (elem - 1), elem)
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
  #     NOTE: Adjust number of elements counted based on elements used.
  #--------------------------------------------------------------------------
  def elements_count
    3..14 # 3 => Fire, 14 => Void/Null
  end
  #--------------------------------------------------------------------------
  # * Enemy States Rate Count
  #   NOTE: Adjust number of states counted based on states used.
  #--------------------------------------------------------------------------
  def states_count
    1..10 # 1 => Death, 10 => Burn?
  end
  #--------------------------------------------------------------------------
  # * Draw Enemy HP
  #--------------------------------------------------------------------------
  def draw_enemy_hp(enemy, x, y, width = 124)
    change_color(system_color)
    draw_text(x, y, width, line_height, Vocab::hp)
    change_color(normal_color)
    draw_text(x + width - 16, y, width, line_height, enemy.mhp, 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Enemy MP
  #--------------------------------------------------------------------------
  def draw_enemy_mp(enemy, x, y, width = 124)
    change_color(system_color)
    draw_text(x, y, width, line_height, Vocab::mp)
    change_color(normal_color)
    draw_text(x + width - 16, y, width, line_height, enemy.mmp, 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Enemy TP
  #--------------------------------------------------------------------------
  def draw_enemy_tp(enemy, x, y, width = 124)
    change_color(system_color)
    draw_text(x, y, width, line_height, Vocab::tp)
    change_color(normal_color)
    draw_text(x + width - 16, y, width, line_height, "0", 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Enemy Parameters
  #--------------------------------------------------------------------------
  def draw_enemy_param(enemy, x, y, param_id, width = 124)
    change_color(system_color)
    draw_text(x, y, width, line_height, Vocab::param(param_id))
    change_color(normal_color)
    draw_text(x + width - 16, y, width, line_height, enemy.param(param_id), 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Enemy Ex-Parameters
  #--------------------------------------------------------------------------
  def draw_enemy_eva(enemy, x, y, width = 124)
    eva = (enemy.eva * 100).to_i.to_s
    change_color(system_color)
    draw_text(x, y, width, line_height, "EVA")
    change_color(normal_color)
    draw_text(x + width - 16, y, width, line_height, eva + "%", 2)
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
  # * Draw Enemy Element Defense
  #--------------------------------------------------------------------------
  def draw_enemy_element(enemy, x, y, param_id, width = 124)
    # Initialize tag to label enemy's element defense rating
    element_tag = ""
    rate = enemy.element_rate(param_id) * 100 # Multiply to return percentages
    # Branch rating based on enemy's element defense rate
    if rate >= 200
      change_color(text_color(10))
      element_tag = rating(0)
    elsif rate > 100
      change_color(text_color(2))
      element_tag = rating(1)
    elsif rate == 100
      change_color(normal_color)
      element_tag = rating(2)
    elsif rate > 0
      change_color(normal_color, false)
      element_tag = rating(3)
    elsif rate == 0
      change color(normal_color, false)
      element_tag = rating(4)
    else
      change_color(text_color(3))
      element_tag = rating(5)
    end
    draw_icon(element_icon(param_id), x, y)
    draw_text(x + width - 16, y, width, line_height, element_tag, 2)
  end
  #------------------------------------------------------------------------
  # * Draw Enemy State Defense
  #------------------------------------------------------------------------
  def draw_enemy_state(enemy, x, y, param_id, width = 124)
    # State defense tag to track enemy's status defense
    state_tag = ""
    rate = enemy.state_rate(param_id) * 100
	# Branch rating based on enemy's state defense rate
	if rate >= 200
	  change_color(text_color(10))
	  state_tag = rating(0)
	elsif rate > 100
	  change_color(text_color(2))
	  state_tag = rating(1)
	elsif rate == 100
	  change_color(normal_color)
	  state_tag = rating(2)
	elsif rate > 0
    change_color(normal_color, false)
	  state_tag = rating(3)
	elsif rate == 0
    change_color(normal_color, false)
	  state_tag = rating(4)
	else
	  change_color(text_color(3))
	  state_tag = rating(5)
	end
	  draw_text(x + width - 16, y, width, line_height, state_tag, 2)
  end
  #------------------------------------------------------------------------
  # * Draw Enemy Debuff Defense
  #------------------------------------------------------------------------
  def draw_enemy_debuff(enemy, x, y, param_id, width = 124)
    # Debuff defense tag to track enemy's status defense
    debuff_tag = ""
    rate = enemy.debuff_rate(param_id) * 100
	# Branch rating based on enemy's debuff defense rate
	if rate >= 200
	  change_color(text_color(10))
	  debuff_tag = rating(0)
	elsif rate > 100
	  change_color(text_color(2))
	  debuff_tag = rating(1)
	elsif rate == 100
	  change_color(normal_color)
	  debuff_tag = rating(2)
	elsif rate > 0
    change_color(normal_color, false)
	  debuff_tag = rating(3)
	elsif rate == 0
    change_color(normal_color, false)
	  debuff_tag = rating(4)
	else
	  change_color(text_color(3))
	  debuff_tag = rating(5)
	end
	  draw_text(x + width - 16, y, width, line_height, debuff_tag, 2)
  end
  #------------------------------------------------------------------------
  # * Draw Enemy Dropped Item
  #------------------------------------------------------------------------
  def draw_enemy_drop_item(drop_item, rect)
    case drop_item.kind
    when 1; item = $data_items[drop_item.data_id]
    when 2; item = $data_weapons[drop_item.data_id] 
    when 3; item = $data_armors[drop_item.data_id]
    end
    draw_item_name(item, rect.x, rect.y)
  end
  #------------------------------------------------------------------------
  # * Draw Enemy Dropped Items
  #------------------------------------------------------------------------
  def draw_enemy_items(enemy, x, y, width = 124)
    items = enemy.drop_items
    change_color(system_color)
    draw_text(x, y, width, line_height, "Drops")
    change_color(normal_color)
    items.each_with_index do |item,i|
      if item.kind > 0
        rect = item_rect(i)
        rect.x += 16
        rect.y = line_height * (i + 3)
	      draw_enemy_drop_item(item, rect)
      else
        # Draw neutral text if no items dropped
        rect = item_rect_for_text(i)
        rect.x += 16
        rect.y = line_height * (i + 3)
        draw_text(rect, rating(2))
      end
    end
  end
  #------------------------------------------------------------------------
  # * Draw Element Icons
  # 	Note: These numbers are only applicable to the big iconset.
  #------------------------------------------------------------------------
  def element_icon(index)
    # Set icon values based on icon index 
    # (adjust if icon index for each element is different)
    fire_icon = 104
    ice_icon = 105
    thun_icon = 106
    water_icon = 107
    earth_icon = 108
    wind_icon = 109
    light_icon = 110
    dark_icon = 111
    wood_icon = 192
    steel_icon = 146
    heart_icon = 135
    byss_icon = 136

    element_set = { 
      3 => fire_icon, # Fire
      4 => ice_icon, # Ice
      5 => thun_icon, # Thunder
      6 => water_icon, # Water
      7 => earth_icon, # Earth
      8 => wind_icon, # Wind
      9 => light_icon, # Light
      10 => dark_icon, # Darkness
      11 => wood_icon, # Wood
      12 => steel_icon, # Steel
      13 => heart_icon, # Heart
      14 => byss_icon, # Null/Void
    }
	
	  # Return icon value based on index passed
	  return element_set[index]
  end
  #------------------------------------------------------------------------
  # * Draw Element Icons
  #  Note: This method is for the default iconset.
  #------------------------------------------------------------------------
  #def element_icon(index)
    # Set icon values based on icon index 
    # (adjust if icon index for each element is different)
    #fire_icon = 96
    #ice_icon = 97
    #thun_icon = 98
    #water_icon = 99
    #earth_icon = 100
    #wind_icon = 101
    #light_icon = 102
    #dark_icon = 103
    #wood_icon = 331
    #steel_icon = 350
    #heart_icon = 119
    #byss_icon = 120
	  
    #element_set = {
      #3 => fire_icon, # Fire
      #4 => ice_icon, # Ice
      #5 => thun_icon, # Thunder
      #6 => water_icon, # Water
      #7 => earth_icon, # Earth
      #8 => wind_icon, # Wind
      #9 => light_icon, # Light
      #10 => dark_icon, # Darkness
      #11 => wood_icon, # Wood
      #12 => steel_icon, # Steel
      #13 => heart_icon, # Heart
      #14 => byss_icon, # Null/Void
    #}
    
	  # Return icon value based on index passed
    #return element_set[index]
  #end
end

#==============================================================================
# ** Window_MenuCommand
#------------------------------------------------------------------------------
#  This command window appears on the menu screen.
#==============================================================================

class Window_MenuCommand < Window_Command
  #--------------------------------------------------------------------------
  # * alias method: For Adding Original Commands
  #--------------------------------------------------------------------------
  alias bestiary_cmd add_original_commands
  def add_original_commands
    bestiary_cmd
	add_bestiary_command
  end
  #--------------------------------------------------------------------------
  # * new method: Add Bestiary to Command List
  #--------------------------------------------------------------------------
  def add_bestiary_command
    add_command("Bestiary", :bestiary, bestiary_enabled)
  end
  #--------------------------------------------------------------------------
  # * new method: Get Activation State of Bestiary
  #--------------------------------------------------------------------------
  def bestiary_enabled
    return true
  end
end

#==========================================================================
# ** Scene_Menu
#--------------------------------------------------------------------------
#  This class performs the menu scene processing.
#==========================================================================
class Scene_Menu < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * override method: Create Command Window
  #--------------------------------------------------------------------------
  def create_command_window
    @command_window = Window_MenuCommand.new
    @command_window.set_handler(:item,      method(:command_item))
    @command_window.set_handler(:skill,     method(:command_personal))
    @command_window.set_handler(:equip,     method(:command_personal))
    @command_window.set_handler(:status,    method(:command_personal))
    @command_window.set_handler(:formation, method(:command_formation))
	  @command_window.set_handler(:bestiary,	method(:command_bestiary))
    @command_window.set_handler(:save,      method(:command_save))
    @command_window.set_handler(:game_end,  method(:command_game_end))
    @command_window.set_handler(:cancel,    method(:return_scene))
  end
  #--------------------------------------------------------------------------
  # * new method: [Bestiary] Window
  #--------------------------------------------------------------------------
  def command_bestiary
    SceneManager.call(Scene_Bestiary)
  end
end

#==========================================================================
# ** Scene_Bestiary
#--------------------------------------------------------------------------
#  This class performs the bestiary scene processing.
#==========================================================================
class Scene_Bestiary < Scene_MenuBase
  #------------------------------------------------------------------------
  # * Object Initialization
  #------------------------------------------------------------------------
  def initialize
    update_enemy(-1)
  end
  #------------------------------------------------------------------------
  # * Start Processing
  #------------------------------------------------------------------------
  def start
    super
    create_bestiary_list_windows
    create_bestiary_windows
  end
  #------------------------------------------------------------------------
  # * Create Bestiary List Windows
  #------------------------------------------------------------------------
  def create_bestiary_list_windows
    create_status_window
    create_list_window
  end
  #------------------------------------------------------------------------
  # * Create Bestiary Windows
  #------------------------------------------------------------------------
  def create_bestiary_windows
    create_left_window
    create_right_window
  end
  #------------------------------------------------------------------------
  # * Create Stat Window
  #------------------------------------------------------------------------
  def create_status_window
    @status_window = Window_BestiaryStatus.new
    @status_window.viewport = @viewport
  end
  #------------------------------------------------------------------------
  # * Create List Window
  #------------------------------------------------------------------------
  def create_list_window
    @list_window = Window_BestiaryList.new
    @list_window.viewport = @viewport
    @list_window.set_handler(:ok,     method(:on_enemy_ok))
    @list_window.set_handler(:cancel, method(:return_scene))
  end
  #------------------------------------------------------------------------
  # * Create Left Window
  #------------------------------------------------------------------------
  def create_left_window
    @left_window = Window_BestiaryLeft.new
  end
  #------------------------------------------------------------------------
  # * Create Right Window
  #------------------------------------------------------------------------
  def create_right_window
    @right_window = Window_BestiaryRight.new
    @right_window.set_handler(:cancel,   method(:on_enemy_cancel))
    #@right_window.set_handler(:pagedown, method(:next_enemy))
    #@right_window.set_handler(:pageup,   method(:prev_enemy))
    @right_window.set_handler(:pageup,       method(:cursor_up))
    @right_window.set_handler(:pagedown,     method(:cursor_down))
  end
  #------------------------------------------------------------------------
  # * Enemy [OK] Processing
  #------------------------------------------------------------------------
  def on_enemy_ok
    determine_enemy
  end
  #------------------------------------------------------------------------
  # * Enemy [Cancel]
  #------------------------------------------------------------------------
  def on_enemy_cancel
    hide_bestiary_windows
    show_bestiary_list_windows
  end
  #------------------------------------------------------------------------
  # * Confirm Enemy
  #------------------------------------------------------------------------
  def determine_enemy
    update_enemy(@list_window.index)
    if @enemy != nil
      @left_window.enemy = @enemy
      @right_window.enemy = @enemy
      hide_bestiary_list_windows
      show_bestiary_windows
    end
  end
  #------------------------------------------------------------------------
  # * Show Bestiary List Windows
  #------------------------------------------------------------------------
  def show_bestiary_list_windows
    show_window(@status_window)
    show_window(@list_window)
  end
  #------------------------------------------------------------------------
  # * Hide Bestiary List Windows
  #------------------------------------------------------------------------
  def hide_bestiary_list_windows
    hide_window(@status_window)
    hide_window(@list_window)
  end
  #------------------------------------------------------------------------
  # * Show Bestiary Windows
  #------------------------------------------------------------------------
  def show_bestiary_windows
    show_window(@left_window)
    show_window(@right_window)
  end
  #------------------------------------------------------------------------
  # * Hide Bestiary Windows
  #------------------------------------------------------------------------
  def hide_bestiary_windows
    hide_window(@left_window)
    hide_window(@right_window)
  end
  #------------------------------------------------------------------------
  # * Show Window
  #------------------------------------------------------------------------
  def show_window(window)
    window.activate
    window.show
  end
  #------------------------------------------------------------------------
  # * Hide Window
  #------------------------------------------------------------------------
  def hide_window(window)
    window.deactivate
    window.hide
  end  
  #------------------------------------------------------------------------
  # * Get Selected Enemy
  #------------------------------------------------------------------------
  def enemy(index)
    $game_system.enemy_list[index]
  end
  #------------------------------------------------------------------------
  # * Switch to Previous Enemy
  #------------------------------------------------------------------------
  def prev_enemy
    i = 0 # Counter
    # Increase counter if enemy has not been slain
    if $game_system.enemy_slain[@index-1] <= 0 && @index > 0
      i -= 1
    end
    update_enemy(@index+i)
  end
  #------------------------------------------------------------------------
  # * Switch to Next Enemy
  #------------------------------------------------------------------------
  def next_enemy
    i = 0 # Counter
    # Decrease counter if enemy has not been slain
    if $game_system.enemy_slain[@index+1] <= 0 && @index < $game_system.enemy_slain.size - 1
      i += 1
    end
    update_enemy(@index+i)
  end
  #------------------------------------------------------------------------
  # * Cursor Up
  #------------------------------------------------------------------------
  def cursor_up
    @right_window.previous_mode
  end
  #------------------------------------------------------------------------
  # * Cursor Down
  #------------------------------------------------------------------------
  def cursor_down
    @right_window.next_mode
  end
  #------------------------------------------------------------------------
  # * Update Selected Enemy
  #------------------------------------------------------------------------
  def update_enemy(index)
    @index = index
    @enemy = enemy(@index)
  end
end