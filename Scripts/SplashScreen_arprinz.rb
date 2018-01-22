#==========================================================================
# *** Splash Screen
#--------------------------------------------------------------------------
#  This plugin provides the splash screen before the title. Can use a custom
# image in place of the default.
#
# * Version: 1.0.1
#
# * Initial release: 2017-11-06
#
# * Updated: 2017-01-21
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
#    -- Final touches  - 2018-01-21
#    -- Initial commit - 2017-11-07
#    -- Initialization - 2017-11-06
#==========================================================================
#==========================================================================
# ** SceneManager
#--------------------------------------------------------------------------
#==========================================================================
class SceneManager
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
    @wait_time = 300
	  @delay = @wait_time
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
  # * Fade Loop
  #    duration: Duration of process for fade effects.
  #------------------------------------------------------------------------
  def fade_loop(duration)
    duration.times do |i|
      yield 255 * (i + 1) / duration
      update
    end
  end
  #------------------------------------------------------------------------
  # * Fade-In Processing
  #    transition time: Duration of process to fade-in.
  #------------------------------------------------------------------------
  def fadein(time = @wait_time)
    fade_loop(time) { |v| Graphics.brightness = v }
  end
  #------------------------------------------------------------------------
  # * Fade-Out Processing
  #    transition time: Duration of process to fade-out.
  #------------------------------------------------------------------------
  def fadeout(time = @wait_time)
    fade_loop(time) { |v| Graphics.brightness = 255 - v }
  end
  #------------------------------------------------------------------------
  # * Splash Screen Filename
  #------------------------------------------------------------------------
  def splashscreen_name
    # Change name below to use different splash screen
    return "boaromayo-splash.png"
  end
  #------------------------------------------------------------------------
  # * Frame Update
  #------------------------------------------------------------------------
  def update
    super
    if !@fadein
      fadein
      @sprite.opacity = 255
      @fadein = true
    else
      if @delay > 0
	      @delay -= 1
      else
        fadeout
        @sprite.opacity = 0
        @fadeout = true
        @fadein = false
      end
	  end
    SceneManager.call(Scene_Title)
  end
end