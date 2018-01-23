#==========================================================================
# *** Splash Screen
#--------------------------------------------------------------------------
#  This plugin provides the splash screen before the title. Can use a custom
# image in place of the default. This plugin ONLY works for RPG MAKER VX Ace.
#
# * Version: 1.0.1
#
# * Initial release: 2017-11-06
#
# * Updated: 2017-01-22
#
# * Coded by: boaromayo/Quesada's Swan
#
# Optional resources:
#   Custom splash screen
#
# NOTE: If you are using this plugin for your projects (commercial or non-commercial), 
# be sure to leave this comment visible or credit me (boaromayo or Quesada's Swan) 
# somewhere in your projects.
#
# * Changelog:
#    -- Delay added in-between scene transitions - 2018-01-22
#    -- Final touches  - 2018-01-22
#    -- Initial commit - 2017-11-07
#    -- Initialization - 2017-11-06
#==========================================================================
#==========================================================================
# ** SceneManager
#--------------------------------------------------------------------------
#  The module that the Scene classes will inherit from.
#==========================================================================
module SceneManager
  #--------------------------------------------------------------------------
  # * override method: Get First Scene Class
  #--------------------------------------------------------------------------
  def self.first_scene_class
    $BTEST ? Scene_Battle : Scene_Splash
  end
end

#==========================================================================
# ** new class: Scene_Splash
#--------------------------------------------------------------------------
#  This scene deals with the splash screen.
#==========================================================================
class Scene_Splash < Scene_Base
  #------------------------------------------------------------------------
  # * Object Initialization
  #------------------------------------------------------------------------
  def initialize
    @sprite = nil
    @fadeout = false
    @fadein = false
  end
  #------------------------------------------------------------------------
  # * Start Processing
  #------------------------------------------------------------------------
  def start
    super
    SceneManager.clear
    Graphics.freeze
    create_splashscreen
  end
  #------------------------------------------------------------------------
  # * Termination Processing
  #------------------------------------------------------------------------
  def terminate
    super
    dispose_splashscreen
  end
  #------------------------------------------------------------------------
  # * Get Transition Speed
  #------------------------------------------------------------------------
  def transition_speed
    return 60
  end
  #------------------------------------------------------------------------
  # * Create Splash Image
  #------------------------------------------------------------------------
  def create_splashscreen  
    @sprite = Sprite.new
    @sprite.bitmap = Cache.system(splashscreen_name)
    center_splashscreen(@sprite)
  end
  #------------------------------------------------------------------------
  # * Free Splash Image from Memory
  #------------------------------------------------------------------------
  def dispose_splashscreen
    @sprite.bitmap.dispose
    @sprite.dispose
  end
  #------------------------------------------------------------------------
  # * Move Splash Image to Center
  #------------------------------------------------------------------------
  def center_splashscreen(sprite)
    sprite.x = Graphics.width / 2
    sprite.y = Graphics.height / 2
    sprite.ox = sprite.bitmap.width / 2
    sprite.oy = sprite.bitmap.height / 2
  end
  
  #------------------------------------------------------------------------
  # * Splash Screen Filename
  #------------------------------------------------------------------------
  def splashscreen_name
    # Change name below to use different splash screen
    return "boaromayo-splash.png"
  end
  #------------------------------------------------------------------------
  # * Get Wait Time
  #------------------------------------------------------------------------
  def wait_time
    # Adjust how long splash stays on-screen
    return 90
  end
  #------------------------------------------------------------------------
  # * Frame Update
  #------------------------------------------------------------------------
  def update
    super
    goto_title if Input.trigger?(:C)
    Graphics.wait(wait_time)
    goto_title
  end
  #------------------------------------------------------------------------
  # * Transition To Title Screen
  #    delay: Delay time in between scene transitions
  #------------------------------------------------------------------------
  def goto_title(delay = 30)
    fadeout_all
    Graphics.wait(delay)
    SceneManager.goto(Scene_Title)
  end
end

#==============================================================================
# ** Scene_Gameover
#------------------------------------------------------------------------------
#  This class performs game over screen processing.
#==============================================================================
class Scene_Gameover < Scene_Base
  #----------------------------------------------------------------------------
  # * override method: Frame Update
  #----------------------------------------------------------------------------
  def update
    super
    goto_splash
  end
  #----------------------------------------------------------------------------
  # * new method: Transition to Splash Screen
  #----------------------------------------------------------------------------
  def goto_splash
    fadeout_all
    SceneManager.goto(Scene_Splash)
  end
end