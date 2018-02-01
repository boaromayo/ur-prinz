#=======================================================================================
# *** Credits Window
#---------------------------------------------------------------------------------------
#  This plugin calls up a window containing the credits (contributors, artists, 
# designers, etc.) of the current project.
#
# * Version 0.8.0
#
# * Initial release: 2017-10-29
#
# * Initial commit: 2017-11-27
#
# * Updated: 2018-01-31
#
# * Coded by: boaromayo/Quesada's Swan
#
# NOTE: If you are using this plugin for your projects (commercial or non-commercial), 
# be sure to leave this comment visible or credit me (boaromayo or Quesada's Swan) 
# in your projects.
#
# * Changelog:
#    -- Updated terms of use information - 2018-01-31
#    -- Finished sprite background - 2017-11-28
#    -- Started script; Initial commit - 2017-11-27
#=======================================================================================
#===================================================================
# ** New class: Game_Credits
#-------------------------------------------------------------------
#  This class keeps the lists of resources and contributors.
#===================================================================
class Game_Credits < Game_System
  #-----------------------------------------------------------------
  # * Public Instance Variables
  #-----------------------------------------------------------------
  attr_reader :credit_tilesets				# List of tilesets
  attr_reader :credit_art				# List of artists
  attr_reader :credit_programs			# List of programmers and plugins
  attr_reader :credit_music				# List of composers
  attr_reader :credit_dedication		# Dedications
  #-----------------------------------------------------------------
  # * Object Initialization
  #-----------------------------------------------------------------
  def initialize
  	@credit_tilesets = []
  	@credit_art = []
  	@credit_programs = []
  	@credit_music = []
  	@credit_dedication = []
  end
  #-----------------------------------------------------------------
  # * Add To Credits (Tilesets)
  #-----------------------------------------------------------------
  def credit_tilesets=(credit,index)
  	@credit_tilesets[index] = credit
  	refresh
  end
  #-----------------------------------------------------------------
  # * Add To Credits (Artists)
  #-----------------------------------------------------------------
  def credit_art=(credit,index)
  	@credit_art[index] = credit
  	refresh
  end
  #-----------------------------------------------------------------
  # * Add To Credits (Programmers)
  #-----------------------------------------------------------------
  def credit_programs=(credit,index)
  	@credit_programs[index] = credit
  	refresh
  end
  #-----------------------------------------------------------------
  # * Add To Credits (Music)
  #-----------------------------------------------------------------
  def credit_music=(credit,index)
  	@credit_music[index] = credit
  	refresh
  end
  #-----------------------------------------------------------------
  # * Add To Credits (Programmers)
  #-----------------------------------------------------------------
  def credit_dedication=(credit,index)
  	@credit_dedication[index] = credit
  	refresh
  end
end
#===================================================================
# ** New class: Window_Credits
#-------------------------------------------------------------------
#  This window lists the credits of the contributors of the game.
#===================================================================
class Window_Credits < Window_Selectable
  #-----------------------------------------------------------------
  # * Object Initialization
  #-----------------------------------------------------------------
  def initialize
    super
    @data = []
    refresh
    select(0)
    activate
  end
  #-----------------------------------------------------------------
  # * Max Number of Items
  #-----------------------------------------------------------------
  def item_max
  	@data ? @data.size : 1
  end
  #-----------------------------------------------------------------
  # * Get Credits List
  #-----------------------------------------------------------------
  def credits
  	@data
  end
  #-----------------------------------------------------------------
  # * Add To Data List
  #-----------------------------------------------------------------
  def make_credits_list
  	$game_credits.credit_tilesets.each_with_index |credit,i| { @data.push($game_credits.credit_tilesets(credit,i)) }
  	$game_credits.credit_art.each_with_index |credit,i| { @data.push($game_credits.credit_art(credit,i)) }
  	$game_credits.credit_programs.each_with_index |credit,i| { @data.push($game_credits.credit_programs(credit,i)) }
  	$game_credits.credit_music.each_with_index |credit,i| { @data.push($game_credits.credit_music(credit,i)) }
    $game_credits.credit_dedication.each_with_index |credit,i| { @data.push($game_credits.credit_dedication(credit,i)) }
  end
  #-----------------------------------------------------------------
  # * Draw Item
  #-----------------------------------------------------------------
  def draw_item(index)
  	credit = @data[index]
  	if credit
  	  rect = rect_item_for_text(index)
  	  draw_text(rect, credit, 0)
  	end
  end
  #-----------------------------------------------------------------
  # * Refresh
  #-----------------------------------------------------------------
  def refresh
  	super
  	make_credits_list
  	draw_all_items
  end
end

#===================================================================
# ** New class: Scene_Credits
#===================================================================
class Scene_Credits < Scene_Base
  #-----------------------------------------------------------------
  # * Start Processing
  #-----------------------------------------------------------------
  def start
  	super
  	create_background
  	create_credits_window
  end
  #-----------------------------------------------------------------
  # * Create Background
  #-----------------------------------------------------------------
  def create_background
  	@sprite_bg = Sprite.new
  	@sprite_bg.bitmap = Cache.picture("catalogue_bg.png")
  	@sprite_bg.z = 100
  	center_sprite(@sprite_bg)
  end
  #-----------------------------------------------------------------
  # * Create Credits Window
  #-----------------------------------------------------------------
  def create_credits_window
  	@credits_window = Window_Credits.new
  	@credits_window.viewport = @viewport
  	@credits_window.opacity = 0
  end
  #-----------------------------------------------------------------
  # * Move Sprite to Screen Center
  #-----------------------------------------------------------------
  def center_sprite(sprite)
  	sprite.ox = sprite.bitmap.width / 2
  	sprite.oy = sprite.bitmap.height / 2
  	sprite.x = Graphics.width / 2
  	sprite.y = Graphics.height / 2
  end
end