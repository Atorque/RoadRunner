require "fiddle"
require "fiddle/import"
require "thread"

$LOAD_PATH.unshift(
  File.expand_path("vendor/chunky_png", __dir__)
)

require "chunky_png"

# ============================================================
# SETTINGS
# ============================================================

WIDTH  = 1280
HEIGHT = 720

# Use an explicit 60 FPS cap. Movement and animation use delta time,
# so their speeds remain correct even if a frame occasionally overruns.
VSYNC_ENABLED = false
TARGET_FPS = 60.0
TARGET_FRAME_TIME = 1.0 / TARGET_FPS

# Procedural audio is synthesized in a small background buffer, so there are
# no music or effect files to ship with the Windows build.
AUDIO_ENABLED = true

# Temporary player placeholder. Its footprint is drawn as a wireframe
# box until a car model replaces it.
PLAYER_HALF_WIDTH = 3.0
PLAYER_LENGTH = 6.0
PLAYER_HEIGHT = 2.0
PLAYER_SPEED = 28.0
PLAYER_START_Z = 30.0
CAR_BOUNCE_HEIGHT = 0.055
CAR_VIBRATION_AMOUNT = 0.025
CAR_OUTLINE_WIDTH = 2.0
CAR_SHADOW_ALPHA = 0.42
CAR_SMOKE_INTERVAL = 0.11
CAR_SMOKE_LIFETIME = 0.725
CAR_SMOKE_MAX_PUFFS = 14
CAR_MAX_HEALTH = 100
CAR_HIT_DAMAGE = 10
PEDESTRIAN_SCORE = 100
SHOT_COOLDOWN = 0.10
SHOT_BURST_INTERVAL = 0.10
SHOT_HIT_RADIUS = 2.8
# Each full step above normal speed adds another projectile to the volley.
MULTISHOT_SPEED_STEP = 0.50

# Kept deliberately small: each impact draws only a handful of sparks,
# two low-segment rings, and a few point sprites.
EXPLOSION_PARTICLE_COUNT = 24
EXPLOSION_DURATION = 1.05
EXPLOSION_SHOCKWAVE_SEGMENTS = 18
# Normal gameplay rarely has more than a few. The higher cap permits a
# one-off multi-stage game-over blast without affecting ordinary frames.
MAX_ACTIVE_EXPLOSIONS = 18
GAME_OVER_MAX_EXPLOSIONS = 72


# ============================================================
# TEXTURE
# ============================================================

TEXTURE_FILE = "texture/ground.png"
WALL_LEFT_TEXTURE_FILE = "texture/wall_left.png"
WALL_RIGHT_TEXTURE_FILE = "texture/wall_right.png"


# How fast the ground texture moves.

SCROLL_SPEED = 0.2

# The road starts at normal speed, then gains 1% every five seconds.
ROAD_SPEED_INCREASE_INTERVAL = 5.0
ROAD_SPEED_INCREASE = 0.01
PEDESTRIAN_KILL_SPEED_INCREASE = 0.01
KILLS_PER_SPEED_TIER = 10

PEDESTRIAN_SPAWN_INTERVAL = 0.75
PEDESTRIAN_MAX_COUNT = 18
# Add one concurrent pedestrian for each full 10% of extra road speed.
PEDESTRIAN_COUNT_SPEED_STEP = 0.10
PEDESTRIAN_SPAWN_Z = 360.0
PEDESTRIAN_DESPAWN_Z = -12.0
PEDESTRIAN_HALF_WIDTH = 2.025
PEDESTRIAN_HEIGHT = 8.1
PEDESTRIAN_EDGE_MARGIN = 7.0
PEDESTRIAN_SHADOW_LENGTH = 8.1
PEDESTRIAN_SHADOW_ALPHA = 0.58
PEDESTRIAN_SIDE_SPEED = 3.0
PEDESTRIAN_FRAME_DURATION = 0.09
PEDESTRIAN_FRAME_WIDTH = 64
PEDESTRIAN_FRAME_HEIGHT = 128
PEDESTRIAN_FRAMES_PER_ROW = 34
PEDESTRIAN_ROWS = 16
PEDESTRIAN_TEXTURE_FILE = "texture/char_sheet.png"

OBSTACLE_SPAWN_INTERVAL = 2.0
OBSTACLE_MAX_COUNT = 8
OBSTACLE_SPAWN_Z = 380.0
OBSTACLE_DESPAWN_Z = -12.0
OBSTACLE_HALF_WIDTH = 2.25
OBSTACLE_HEIGHT = 4.5
OBSTACLE_HIT_DAMAGE = 20
OBSTACLE_EXPLOSION_SCALE = 1.6
OBSTACLE_SHEET_COLUMNS = 4
OBSTACLE_SHEET_ROWS = 4
OBSTACLE_FRAMES = [0, 1, 2, 3, 4, 5].freeze
OBSTACLE_TEXTURE_FILE = "texture/obstacle_sheet.png"

STREET_LAMP_MAX_PAIRS = 6
STREET_LAMP_INITIAL_PAIR_COUNT = 6
STREET_LAMP_SPAWN_Z = 360.0
STREET_LAMP_DESPAWN_Z = -18.0
# Distance between lamp pairs along the road, in world units.
STREET_LAMP_SPACING = 55.0
STREET_LAMP_HALF_WIDTH = 4.05
STREET_LAMP_HEIGHT = 16.2
STREET_LAMP_LEFT_TEXTURE_FILE = "texture/StreetLamp_Left.png"
STREET_LAMP_RIGHT_TEXTURE_FILE = "texture/StreetLamp_Right.png"


# Texture repetition across the ground.

TEXTURE_REPEAT_X = 1.0


# Texture repetition into the distance.

TEXTURE_REPEAT_Z = 5.0

# The wall sheets are 2048 wide by 1024 high: their width runs along the road
# and their height runs vertically. They use the same scroll phase as the road.
WALL_HEIGHT = 24.0
WALL_TEXTURE_REPEAT_Z = 5.0


# ============================================================
# CAMERA SETTINGS
# ============================================================

# Camera position.

CAMERA_X = 0.0
CAMERA_Y = 20.0
CAMERA_Z = -8.0


# ------------------------------------------------------------
# Camera pitch
# ------------------------------------------------------------
#
# 0    = horizontal
# -10  = slightly downward
# -20  = downward
# -30  = more downward
# -45  = steeply downward
#
# Keep the negative values.
#

CAMERA_PITCH = -30.0


# ------------------------------------------------------------
# Camera yaw
# ------------------------------------------------------------

CAMERA_YAW = 0.0


# ------------------------------------------------------------
# Camera roll
# ------------------------------------------------------------

CAMERA_ROLL = 0.0


# ------------------------------------------------------------
# Field of view
# ------------------------------------------------------------

CAMERA_FOV = 60.0


# ============================================================
# GROUND SETTINGS
# ============================================================

GROUND_LEFT  = -50.0
GROUND_RIGHT = 50.0

GROUND_NEAR_Z = 0.0
GROUND_FAR_Z  = 1024.0

# Drivable track inside the wider textured ground. Adjust these values
# to move the red boundary lines and the car's allowed steering area.
TRACK_LEFT = -22.0
TRACK_RIGHT = 22.0
TRACK_NEAR_Z = 0.0
TRACK_FAR_Z = GROUND_FAR_Z

STREET_LAMP_LEFT_X = TRACK_LEFT - STREET_LAMP_HALF_WIDTH
STREET_LAMP_RIGHT_X = TRACK_RIGHT + STREET_LAMP_HALF_WIDTH
PEDESTRIAN_LEFT_BOUND = GROUND_LEFT + PEDESTRIAN_EDGE_MARGIN
PEDESTRIAN_RIGHT_BOUND = GROUND_RIGHT - PEDESTRIAN_EDGE_MARGIN

# The ground's scrolling UVs correspond to this much forward world movement.
PEDESTRIAN_FORWARD_SPEED =
  SCROLL_SPEED * GROUND_FAR_Z / TEXTURE_REPEAT_Z


# ============================================================
# FOG SETTINGS
# ============================================================

# Turn fog on/off.

FOG_ENABLED = true


# ------------------------------------------------------------
# Fog colour
# ------------------------------------------------------------
#
# Dark blue-black.
#
# Increase these values for lighter fog.
#

FOG_R = 0.015
FOG_G = 0.020
FOG_B = 0.030


# ------------------------------------------------------------
# Fog start
# ------------------------------------------------------------
#
# Objects are completely unaffected before this distance.
#

FOG_START = 100.0


# ------------------------------------------------------------
# Fog end
# ------------------------------------------------------------
#
# At this distance the object is completely fogged.
#

FOG_END = 500.0


# ============================================================
# OPENGL CLIPPING
# ============================================================

OPENGL_NEAR = 0.1

OPENGL_FAR = 2000.0


# ============================================================
# GLFW
# ============================================================

module GLFW

  extend Fiddle::Importer

  dlload File.expand_path(
    "glfw3.dll",
    __dir__
  )


  extern "int glfwInit()"

  extern "void glfwTerminate()"


  extern "void* glfwCreateWindow(" \
         "int, int, const char*, void*, void*)"


  extern "void glfwDestroyWindow(void*)"


  extern "void glfwMakeContextCurrent(void*)"


  extern "void glfwSwapBuffers(void*)"


  extern "void glfwPollEvents()"

  extern "int glfwGetKey(void*, int)"

  extern "int glfwGetMouseButton(void*, int)"

  extern "void glfwGetCursorPos(void*, void*, void*)"

  extern "void glfwSetWindowTitle(void*, const char*)"


  extern "int glfwWindowShouldClose(void*)"


  extern "void glfwSwapInterval(int)"


  extern "double glfwGetTime()"

end


# ============================================================
# OPENGL
# ============================================================

module GL

  extend Fiddle::Importer

  dlload "opengl32.dll"


  # ==========================================================
  # BASIC
  # ==========================================================

  extern "void glClearColor(float, float, float, float)"

  extern "void glClear(unsigned int)"

  extern "void glViewport(int, int, int, int)"

  extern "void glEnable(unsigned int)"

  extern "void glDisable(unsigned int)"

  extern "void glBlendFunc(unsigned int, unsigned int)"

  extern "void glAlphaFunc(unsigned int, float)"

  extern "void glDepthMask(unsigned char)"

  extern "void glColor4f(float, float, float, float)"

  extern "void glLineWidth(float)"

  extern "void glPointSize(float)"


  # ==========================================================
  # MATRIX
  # ==========================================================

  extern "void glMatrixMode(unsigned int)"

  extern "void glLoadIdentity()"

  extern "void glOrtho(double, double, double, double, double, double)"

  extern "void glPushMatrix()"

  extern "void glPopMatrix()"


  extern "void glFrustum(" \
         "double, double, double, double, double, double)"


  extern "void glTranslatef(float, float, float)"

  extern "void glRotatef(float, float, float, float)"


  # ==========================================================
  # TEXTURES
  # ==========================================================

  extern "void glGenTextures(int, void*)"

  extern "void glDeleteTextures(int, void*)"


  extern "void glBindTexture(" \
         "unsigned int, unsigned int)"


  extern "void glTexParameteri(" \
         "unsigned int, unsigned int, int)"


  extern "void glTexImage2D(" \
         "unsigned int, int, int, int, int, int, " \
         "unsigned int, unsigned int, void*)"


  # ==========================================================
  # GEOMETRY
  # ==========================================================

  extern "void glBegin(unsigned int)"

  extern "void glEnd()"

  extern "void glTexCoord2f(float, float)"

  extern "void glVertex3f(float, float, float)"


  # ==========================================================
  # FOG
  # ==========================================================

  extern "void glFogi(unsigned int, int)"

  extern "void glFogf(unsigned int, float)"

  extern "void glFogfv(unsigned int, void*)"

end


# ============================================================
# OPENGL CONSTANTS
# ============================================================

GL_COLOR_BUFFER_BIT = 0x00004000

GL_DEPTH_BUFFER_BIT = 0x00000100


# ============================================================
# DEPTH
# ============================================================

GL_DEPTH_TEST = 0x0B71
GL_BLEND = 0x0BE2
GL_ALPHA_TEST = 0x0BC0
GL_SRC_ALPHA = 0x0302
GL_ONE_MINUS_SRC_ALPHA = 0x0303
GL_GREATER = 0x0204


# ============================================================
# MATRICES
# ============================================================

GL_PROJECTION = 0x1701

GL_MODELVIEW = 0x1700


# ============================================================
# TEXTURES
# ============================================================

GL_TEXTURE_2D = 0x0DE1

GL_TEXTURE_WRAP_S = 0x2802

GL_TEXTURE_WRAP_T = 0x2803

GL_TEXTURE_MIN_FILTER = 0x2801

GL_TEXTURE_MAG_FILTER = 0x2800

GL_REPEAT = 0x2901

GL_LINEAR = 0x2601


# ============================================================
# TEXTURE FORMAT
# ============================================================

GL_RGBA = 0x1908

GL_UNSIGNED_BYTE = 0x1401


# ============================================================
# GEOMETRY
# ============================================================

GL_QUADS = 0x0007
GL_POLYGON = 0x0009
GL_LINES = 0x0001
GL_POINTS = 0x0000
GL_LINE_LOOP = 0x0002
GL_ONE = 0x0001


# ============================================================
# GLFW KEYS
# ============================================================

GLFW_PRESS = 1
GLFW_KEY_W = 87
GLFW_KEY_A = 65
GLFW_KEY_S = 83
GLFW_KEY_D = 68
GLFW_KEY_G = 71
GLFW_KEY_SPACE = 32
GLFW_KEY_ESCAPE = 256
GLFW_KEY_LEFT_CONTROL = 341
GLFW_KEY_RIGHT_CONTROL = 345
GLFW_MOUSE_BUTTON_LEFT = 0


# ============================================================
# FOG
# ============================================================

GL_FOG = 0x0B60

GL_FOG_MODE = 0x0B65

GL_FOG_COLOR = 0x0B66

GL_FOG_START = 0x0B63

GL_FOG_END = 0x0B64


# ============================================================
# INITIALIZE GLFW
# ============================================================

puts "Initializing GLFW..."


unless GLFW.glfwInit != 0

  abort(
    "ERROR: Could not initialize GLFW."
  )

end


puts "GLFW initialized."


# ============================================================
# CREATE WINDOW
# ============================================================

window =
  GLFW.glfwCreateWindow(
    WIDTH,
    HEIGHT,
    "Ruby OpenGL Perspective Ground",
    nil,
    nil
  )


if window.nil? || window.to_i == 0

  GLFW.glfwTerminate

  abort(
    "ERROR: Could not create GLFW window."
  )

end


# ============================================================
# OPENGL CONTEXT
# ============================================================

GLFW.glfwMakeContextCurrent(
  window
)


# VSync limits rendering to the display refresh rate. Keeping it
# configurable lets the scene favour higher frame rates by default.
GLFW.glfwSwapInterval(
  VSYNC_ENABLED ? 1 : 0
)


puts "OpenGL context created."


# ============================================================
# VIEWPORT
# ============================================================

GL.glViewport(
  0,
  0,
  WIDTH,
  HEIGHT
)


# ============================================================
# BACKGROUND COLOUR
# ============================================================

#
# Make the clear colour identical to the fog colour.
#
# This gives us a smooth-looking transition into the
# distance instead of a bright horizon behind the fog.
#

GL.glClearColor(
  FOG_R,
  FOG_G,
  FOG_B,
  1.0
)


# ============================================================
# DEPTH BUFFER
# ============================================================

GL.glEnable(
  GL_DEPTH_TEST
)


# ============================================================
# 2D TEXTURES
# ============================================================

GL.glEnable(
  GL_TEXTURE_2D
)


# ============================================================
# SETUP PERSPECTIVE
# ============================================================

GL.glMatrixMode(
  GL_PROJECTION
)


GL.glLoadIdentity


aspect =
  WIDTH.to_f / HEIGHT.to_f


fov_radians =
  CAMERA_FOV *
  Math::PI /
  180.0


near =
  OPENGL_NEAR


far =
  OPENGL_FAR


top =
  Math.tan(
    fov_radians / 2.0
  ) * near


bottom =
  -top


right =
  top * aspect


left =
  -right


GL.glFrustum(
  left,
  right,
  bottom,
  top,
  near,
  far
)


# ============================================================
# SETUP FOG
# ============================================================

if FOG_ENABLED

  puts "Enabling distance fog..."

  # ----------------------------------------------------------
  # Enable fog
  # ----------------------------------------------------------

  GL.glEnable(
    GL_FOG
  )


  # ----------------------------------------------------------
  # Linear fog
  # ----------------------------------------------------------
  #
  # Fog amount is determined from the distance between
  # the camera and the rendered geometry.
  #

  GL.glFogi(
    GL_FOG_MODE,
    GL_LINEAR
  )


  # ----------------------------------------------------------
  # Fog starts
  # ----------------------------------------------------------

  GL.glFogf(
    GL_FOG_START,
    FOG_START
  )


  # ----------------------------------------------------------
  # Fog becomes completely opaque here
  # ----------------------------------------------------------

  GL.glFogf(
    GL_FOG_END,
    FOG_END
  )


  # ----------------------------------------------------------
  # Fog colour
  # ----------------------------------------------------------

  fog_colour =
    [
      FOG_R,
      FOG_G,
      FOG_B,
      1.0
    ].pack("f4")


  fog_pointer =
    Fiddle::Pointer[
      fog_colour
    ]


  GL.glFogfv(
    GL_FOG_COLOR,
    fog_pointer
  )

else

  puts "Fog disabled."

end


# ============================================================
# LOAD TEXTURE
# ============================================================

unless File.exist?(TEXTURE_FILE)

  abort(
    "ERROR: Cannot find texture: #{TEXTURE_FILE}"
  )

end


puts(
  "Loading #{TEXTURE_FILE}..."
)


image =
  ChunkyPNG::Image.from_file(
    TEXTURE_FILE
  )


texture_width =
  image.width


texture_height =
  image.height


puts(
  "Texture: #{texture_width} x #{texture_height}"
)


# ============================================================
# CONVERT PNG TO RGBA
# ============================================================

pixels =
  String.new(
    capacity:
      texture_width *
      texture_height *
      4
  )


#
# Flip vertically because OpenGL's texture origin is
# conventionally at the bottom-left.
#

(texture_height - 1).downto(0) do |y|

  texture_width.times do |x|

    color =
      image[x, y]


    pixels <<
      ChunkyPNG::Color.r(color).chr


    pixels <<
      ChunkyPNG::Color.g(color).chr


    pixels <<
      ChunkyPNG::Color.b(color).chr


    pixels <<
      ChunkyPNG::Color.a(color).chr

  end

end


# ============================================================
# CREATE OPENGL TEXTURE
# ============================================================

texture_buffer =
  Fiddle::Pointer.malloc(
    Fiddle::SIZEOF_INT
  )


GL.glGenTextures(
  1,
  texture_buffer
)


texture_id =
  texture_buffer[
    0,
    Fiddle::SIZEOF_INT
  ].unpack1("i")


puts(
  "OpenGL texture ID: #{texture_id}"
)


# ============================================================
# CONFIGURE TEXTURE
# ============================================================

GL.glBindTexture(
  GL_TEXTURE_2D,
  texture_id
)


# ------------------------------------------------------------
# Horizontal repeat
# ------------------------------------------------------------

GL.glTexParameteri(
  GL_TEXTURE_2D,
  GL_TEXTURE_WRAP_S,
  GL_REPEAT
)


# ------------------------------------------------------------
# Vertical repeat
# ------------------------------------------------------------

GL.glTexParameteri(
  GL_TEXTURE_2D,
  GL_TEXTURE_WRAP_T,
  GL_REPEAT
)


# ------------------------------------------------------------
# Minification filter
# ------------------------------------------------------------

GL.glTexParameteri(
  GL_TEXTURE_2D,
  GL_TEXTURE_MIN_FILTER,
  GL_LINEAR
)


# ------------------------------------------------------------
# Magnification filter
# ------------------------------------------------------------

GL.glTexParameteri(
  GL_TEXTURE_2D,
  GL_TEXTURE_MAG_FILTER,
  GL_LINEAR
)


# ============================================================
# UPLOAD TEXTURE
# ============================================================

pixel_pointer =
  Fiddle::Pointer[
    pixels
  ]


GL.glTexImage2D(
  GL_TEXTURE_2D,
  0,
  GL_RGBA,
  texture_width,
  texture_height,
  0,
  GL_RGBA,
  GL_UNSIGNED_BYTE,
  pixel_pointer
)


GL.glBindTexture(
  GL_TEXTURE_2D,
  0
)


puts "Texture uploaded."


# ============================================================
# LOAD ANOTHER PNG AS AN OPENGL TEXTURE
# ============================================================

def load_texture(file)

  abort("ERROR: Cannot find texture: #{file}") unless File.exist?(file)

  image = ChunkyPNG::Image.from_file(file)
  pixels = String.new(capacity: image.width * image.height * 4)

  (image.height - 1).downto(0) do |y|
    image.width.times do |x|
      color = image[x, y]
      pixels << ChunkyPNG::Color.r(color).chr
      pixels << ChunkyPNG::Color.g(color).chr
      pixels << ChunkyPNG::Color.b(color).chr
      pixels << ChunkyPNG::Color.a(color).chr
    end
  end

  buffer = Fiddle::Pointer.malloc(Fiddle::SIZEOF_INT)
  GL.glGenTextures(1, buffer)
  id = buffer[0, Fiddle::SIZEOF_INT].unpack1("i")

  GL.glBindTexture(GL_TEXTURE_2D, id)
  GL.glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
  GL.glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
  GL.glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
  GL.glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
  GL.glTexImage2D(
    GL_TEXTURE_2D, 0, GL_RGBA, image.width, image.height, 0,
    GL_RGBA, GL_UNSIGNED_BYTE, Fiddle::Pointer[pixels]
  )
  GL.glBindTexture(GL_TEXTURE_2D, 0)

  id
end


$pedestrian_texture_id = load_texture(PEDESTRIAN_TEXTURE_FILE)
$street_lamp_left_texture_id = load_texture(STREET_LAMP_LEFT_TEXTURE_FILE)
$street_lamp_right_texture_id = load_texture(STREET_LAMP_RIGHT_TEXTURE_FILE)
$obstacle_texture_id = load_texture(OBSTACLE_TEXTURE_FILE)


def load_optional_texture(file)
  unless File.exist?(file)
    warn "Wall texture not found yet: #{file}"
    return nil
  end

  load_texture(file)
end


$wall_left_texture_id = load_optional_texture(WALL_LEFT_TEXTURE_FILE)
$wall_right_texture_id = load_optional_texture(WALL_RIGHT_TEXTURE_FILE)


# ============================================================
# DRAW GROUND
# ============================================================

def draw_ground(scroll)

  GL.glBindTexture(
    GL_TEXTURE_2D,
    $texture_id
  )


  GL.glBegin(
    GL_QUADS
  )


  # ==========================================================
  # NEAR LEFT
  # ==========================================================

  GL.glTexCoord2f(
    0.0,
    scroll
  )


  GL.glVertex3f(
    GROUND_LEFT,
    0.0,
    GROUND_NEAR_Z
  )


  # ==========================================================
  # NEAR RIGHT
  # ==========================================================

  GL.glTexCoord2f(
    TEXTURE_REPEAT_X,
    scroll
  )


  GL.glVertex3f(
    GROUND_RIGHT,
    0.0,
    GROUND_NEAR_Z
  )


  # ==========================================================
  # FAR RIGHT
  # ==========================================================

  GL.glTexCoord2f(
    TEXTURE_REPEAT_X,
    scroll + TEXTURE_REPEAT_Z
  )


  GL.glVertex3f(
    GROUND_RIGHT,
    0.0,
    GROUND_FAR_Z
  )


  # ==========================================================
  # FAR LEFT
  # ==========================================================

  GL.glTexCoord2f(
    0.0,
    scroll + TEXTURE_REPEAT_Z
  )


  GL.glVertex3f(
    GROUND_LEFT,
    0.0,
    GROUND_FAR_Z
  )


  GL.glEnd


  GL.glBindTexture(
    GL_TEXTURE_2D,
    0
  )

end


# ============================================================
# PEDESTRIANS
# ============================================================

class Pedestrian

  attr_reader :x, :z, :row, :frame

  def initialize
    # Spawn at varying depths so arrivals do not form a line.
    @z = PEDESTRIAN_SPAWN_Z + rand * 140.0
    @x = rand * (PEDESTRIAN_RIGHT_BOUND - PEDESTRIAN_LEFT_BOUND - PEDESTRIAN_HALF_WIDTH * 2) +
         PEDESTRIAN_LEFT_BOUND + PEDESTRIAN_HALF_WIDTH
    @row = rand(PEDESTRIAN_ROWS)
    @direction = [:left, :right].sample
    @action_time = 0.0
    @frame_time = 0.0
    @frame = @direction == :right ? 17 : 16
    choose_action
  end

  def update(delta, road_speed_multiplier)
    # Match the apparent forward motion of the scrolling ground.
    @z -= PEDESTRIAN_FORWARD_SPEED * road_speed_multiplier * delta
    @action_time -= delta

    choose_action if @action_time <= 0.0

    @x += @side_speed * delta
    if @x <= PEDESTRIAN_LEFT_BOUND + PEDESTRIAN_HALF_WIDTH ||
       @x >= PEDESTRIAN_RIGHT_BOUND - PEDESTRIAN_HALF_WIDTH
      @x = @x.clamp(
        PEDESTRIAN_LEFT_BOUND + PEDESTRIAN_HALF_WIDTH,
        PEDESTRIAN_RIGHT_BOUND - PEDESTRIAN_HALF_WIDTH
      )
      @direction = @direction == :left ? :right : :left
      @side_speed = @direction == :left ? -PEDESTRIAN_SIDE_SPEED : PEDESTRIAN_SIDE_SPEED
    end

    if @side_speed.zero?
      # World +X appears on the left after the scene's 180-degree
      # camera turn, so use the opposite sheet direction.
      @frame = @direction == :right ? 17 : 16
    else
      @frame_time += delta
      walk_frame = (@frame_time / PEDESTRIAN_FRAME_DURATION).to_i % 16
      @frame = @direction == :right ? 33 - walk_frame : walk_frame
    end
  end

  def off_camera?
    @z < PEDESTRIAN_DESPAWN_Z
  end

  private

  def choose_action
    @action_time = rand * 1.8 + 0.35

    if rand < 0.32
      @side_speed = 0.0
    else
      @direction = [:left, :right].sample if rand < 0.45
      @side_speed = @direction == :left ? -PEDESTRIAN_SIDE_SPEED : PEDESTRIAN_SIDE_SPEED
    end
  end
end


def draw_pedestrians(pedestrians)
  GL.glBindTexture(GL_TEXTURE_2D, $pedestrian_texture_id)
  GL.glEnable(GL_BLEND)
  GL.glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  GL.glEnable(GL_ALPHA_TEST)
  GL.glAlphaFunc(GL_GREATER, 0.02)

  pedestrians.each do |pedestrian|
    u_left = pedestrian.frame.to_f / PEDESTRIAN_FRAMES_PER_ROW
    u_right = (pedestrian.frame + 1).to_f / PEDESTRIAN_FRAMES_PER_ROW
    v_top = 1.0 - pedestrian.row.to_f / PEDESTRIAN_ROWS
    v_bottom = 1.0 - (pedestrian.row + 1).to_f / PEDESTRIAN_ROWS

    left = pedestrian.x - PEDESTRIAN_HALF_WIDTH
    right = pedestrian.x + PEDESTRIAN_HALF_WIDTH

    # Keep the old world-space perspective warp as a black silhouette
    # on the ground, extending away from the pedestrian's feet.
    GL.glColor4f(0.0, 0.0, 0.0, PEDESTRIAN_SHADOW_ALPHA)
    GL.glBegin(GL_QUADS)
    GL.glTexCoord2f(u_left, v_bottom)
    GL.glVertex3f(left, 0.02, pedestrian.z)
    GL.glTexCoord2f(u_right, v_bottom)
    GL.glVertex3f(right, 0.02, pedestrian.z)
    GL.glTexCoord2f(u_right, v_top)
    GL.glVertex3f(right, 0.02, pedestrian.z + PEDESTRIAN_SHADOW_LENGTH)
    GL.glTexCoord2f(u_left, v_top)
    GL.glVertex3f(left, 0.02, pedestrian.z + PEDESTRIAN_SHADOW_LENGTH)
    GL.glEnd

    # Cancel the camera rotation after moving to the pedestrian's
    # world position. This second copy faces the camera, stays upright,
    # and only changes size with distance.
    GL.glColor4f(1.0, 1.0, 1.0, 1.0)
    GL.glPushMatrix
    GL.glTranslatef(pedestrian.x, 0.0, pedestrian.z)
    GL.glRotatef(-180.0, 0.0, 1.0, 0.0)
    GL.glRotatef(-CAMERA_YAW, 0.0, 1.0, 0.0)
    GL.glRotatef(CAMERA_PITCH, 1.0, 0.0, 0.0)
    GL.glRotatef(-CAMERA_ROLL, 0.0, 0.0, 1.0)

    GL.glBegin(GL_QUADS)
    GL.glTexCoord2f(u_left, v_bottom)
    GL.glVertex3f(-PEDESTRIAN_HALF_WIDTH, 0.0, 0.0)
    GL.glTexCoord2f(u_right, v_bottom)
    GL.glVertex3f(PEDESTRIAN_HALF_WIDTH, 0.0, 0.0)
    GL.glTexCoord2f(u_right, v_top)
    GL.glVertex3f(PEDESTRIAN_HALF_WIDTH, PEDESTRIAN_HEIGHT, 0.0)
    GL.glTexCoord2f(u_left, v_top)
    GL.glVertex3f(-PEDESTRIAN_HALF_WIDTH, PEDESTRIAN_HEIGHT, 0.0)
    GL.glEnd
    GL.glPopMatrix
  end

  GL.glDisable(GL_ALPHA_TEST)
  GL.glDisable(GL_BLEND)
  GL.glColor4f(1.0, 1.0, 1.0, 1.0)
  GL.glBindTexture(GL_TEXTURE_2D, 0)
end


# ============================================================
# STREET LAMPS
# ============================================================

class StreetLamp
  attr_reader :x, :z, :texture_id

  def initialize(side = [:left, :right].sample, z = STREET_LAMP_SPAWN_Z)
    @z = z
    @x = side == :left ? STREET_LAMP_LEFT_X : STREET_LAMP_RIGHT_X
    # The asset names describe the direction of the cast light, not the roadside.
    @texture_id = side == :left ? $street_lamp_right_texture_id : $street_lamp_left_texture_id
  end

  def update(delta, road_speed_multiplier)
    # Lamps are fixed to the roadside: only the world's forward scroll moves them.
    @z -= PEDESTRIAN_FORWARD_SPEED * road_speed_multiplier * delta
  end

  def off_camera?
    @z < STREET_LAMP_DESPAWN_Z
  end
end


def initial_street_lamps
  Array.new(STREET_LAMP_INITIAL_PAIR_COUNT) do |index|
    z = STREET_LAMP_SPAWN_Z - index * STREET_LAMP_SPACING
    [StreetLamp.new(:left, z), StreetLamp.new(:right, z)]
  end
  .flatten
end


def draw_street_lamps(street_lamps)
  GL.glEnable(GL_BLEND)
  GL.glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  GL.glEnable(GL_ALPHA_TEST)
  GL.glAlphaFunc(GL_GREATER, 0.02)
  GL.glColor4f(1.0, 1.0, 1.0, 1.0)

  street_lamps.each do |lamp|
    GL.glBindTexture(GL_TEXTURE_2D, lamp.texture_id)
    GL.glPushMatrix
    GL.glTranslatef(lamp.x, 0.0, lamp.z)
    GL.glRotatef(-180.0, 0.0, 1.0, 0.0)
    GL.glRotatef(-CAMERA_YAW, 0.0, 1.0, 0.0)
    GL.glRotatef(CAMERA_PITCH, 1.0, 0.0, 0.0)
    GL.glRotatef(-CAMERA_ROLL, 0.0, 0.0, 1.0)

    GL.glBegin(GL_QUADS)
    GL.glTexCoord2f(0.0, 0.0)
    GL.glVertex3f(-STREET_LAMP_HALF_WIDTH, 0.0, 0.0)
    GL.glTexCoord2f(1.0, 0.0)
    GL.glVertex3f(STREET_LAMP_HALF_WIDTH, 0.0, 0.0)
    GL.glTexCoord2f(1.0, 1.0)
    GL.glVertex3f(STREET_LAMP_HALF_WIDTH, STREET_LAMP_HEIGHT, 0.0)
    GL.glTexCoord2f(0.0, 1.0)
    GL.glVertex3f(-STREET_LAMP_HALF_WIDTH, STREET_LAMP_HEIGHT, 0.0)
    GL.glEnd
    GL.glPopMatrix
  end

  GL.glDisable(GL_ALPHA_TEST)
  GL.glDisable(GL_BLEND)
  GL.glBindTexture(GL_TEXTURE_2D, 0)
end


# ============================================================
# ROAD OBSTACLES
# ============================================================

class RoadObstacle
  attr_reader :x, :z, :frame

  def initialize
    @z = OBSTACLE_SPAWN_Z + rand * 120.0
    @x = rand * (TRACK_RIGHT - TRACK_LEFT - OBSTACLE_HALF_WIDTH * 2) +
         TRACK_LEFT + OBSTACLE_HALF_WIDTH
    @frame = OBSTACLE_FRAMES.sample
  end

  def update(delta, road_speed_multiplier)
    @z -= PEDESTRIAN_FORWARD_SPEED * road_speed_multiplier * delta
  end

  def off_camera?
    @z < OBSTACLE_DESPAWN_Z
  end
end


def draw_obstacles(obstacles)
  GL.glBindTexture(GL_TEXTURE_2D, $obstacle_texture_id)
  GL.glEnable(GL_BLEND)
  GL.glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  GL.glEnable(GL_ALPHA_TEST)
  GL.glAlphaFunc(GL_GREATER, 0.02)
  GL.glColor4f(1.0, 1.0, 1.0, 1.0)

  obstacles.each do |obstacle|
    column = obstacle.frame % OBSTACLE_SHEET_COLUMNS
    row = obstacle.frame / OBSTACLE_SHEET_COLUMNS
    u_left = column.to_f / OBSTACLE_SHEET_COLUMNS
    u_right = (column + 1).to_f / OBSTACLE_SHEET_COLUMNS
    v_top = 1.0 - row.to_f / OBSTACLE_SHEET_ROWS
    v_bottom = 1.0 - (row + 1).to_f / OBSTACLE_SHEET_ROWS

    GL.glPushMatrix
    GL.glTranslatef(obstacle.x, 0.0, obstacle.z)
    GL.glRotatef(-180.0, 0.0, 1.0, 0.0)
    GL.glRotatef(-CAMERA_YAW, 0.0, 1.0, 0.0)
    GL.glRotatef(CAMERA_PITCH, 1.0, 0.0, 0.0)
    GL.glRotatef(-CAMERA_ROLL, 0.0, 0.0, 1.0)

    GL.glBegin(GL_QUADS)
    GL.glTexCoord2f(u_left, v_bottom)
    GL.glVertex3f(-OBSTACLE_HALF_WIDTH, 0.0, 0.0)
    GL.glTexCoord2f(u_right, v_bottom)
    GL.glVertex3f(OBSTACLE_HALF_WIDTH, 0.0, 0.0)
    GL.glTexCoord2f(u_right, v_top)
    GL.glVertex3f(OBSTACLE_HALF_WIDTH, OBSTACLE_HEIGHT, 0.0)
    GL.glTexCoord2f(u_left, v_top)
    GL.glVertex3f(-OBSTACLE_HALF_WIDTH, OBSTACLE_HEIGHT, 0.0)
    GL.glEnd
    GL.glPopMatrix
  end

  GL.glDisable(GL_ALPHA_TEST)
  GL.glDisable(GL_BLEND)
  GL.glBindTexture(GL_TEXTURE_2D, 0)
end


# ============================================================
# SCROLLING TRACK WALLS
# ============================================================

def draw_walls(scroll)
  walls = [
    [$wall_left_texture_id, GROUND_LEFT],
    [$wall_right_texture_id, GROUND_RIGHT]
  ]

  walls.each do |texture_id, x|
    next unless texture_id

    GL.glBindTexture(GL_TEXTURE_2D, texture_id)
    GL.glColor4f(1.0, 1.0, 1.0, 1.0)
    GL.glEnable(GL_BLEND)
    GL.glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
    GL.glEnable(GL_ALPHA_TEST)
    GL.glAlphaFunc(GL_GREATER, 0.01)
    GL.glDepthMask(0)
    GL.glBegin(GL_QUADS)
    # The sheet is 2048 wide x 1024 high: U travels along the road and scrolls;
    # V travels up the wall.
    GL.glTexCoord2f(scroll, 0.0)
    GL.glVertex3f(x, 0.0, GROUND_NEAR_Z)
    GL.glTexCoord2f(scroll, 1.0)
    GL.glVertex3f(x, WALL_HEIGHT, GROUND_NEAR_Z)
    GL.glTexCoord2f(scroll + WALL_TEXTURE_REPEAT_Z, 1.0)
    GL.glVertex3f(x, WALL_HEIGHT, GROUND_FAR_Z)
    GL.glTexCoord2f(scroll + WALL_TEXTURE_REPEAT_Z, 0.0)
    GL.glVertex3f(x, 0.0, GROUND_FAR_Z)
    GL.glEnd
  end

  GL.glDepthMask(1)
  GL.glDisable(GL_ALPHA_TEST)
  GL.glDisable(GL_BLEND)
  GL.glColor4f(1.0, 1.0, 1.0, 1.0)
  GL.glBindTexture(GL_TEXTURE_2D, 0)
end


# ============================================================
# PROCEDURAL AUDIO (Windows waveOut)
# ============================================================

# A compact real-time mixer.  It makes a coherent, randomized dubstep loop
# from six synth voices, then mixes one-shot gunfire and blast voices into the
# same output.  The sequencer reads the current road-speed multiplier, so its
# BPM rises naturally with the game.
if Gem.win_platform?
  module WinMM
    extend Fiddle::Importer

    dlload "winmm.dll"

    extern "int waveOutOpen(void*, unsigned int, void*, void*, void*, unsigned int)"
    extern "int waveOutPrepareHeader(void*, void*, unsigned int)"
    extern "int waveOutWrite(void*, void*, unsigned int)"
    extern "int waveOutUnprepareHeader(void*, void*, unsigned int)"
    extern "int waveOutReset(void*)"
    extern "int waveOutClose(void*)"
    extern "int mciSendStringW(void*, void*, unsigned int, void*)"
  end
end


# SDL2_mixer streams the OGG independently of the render loop. Windows uses
# the bundled runtime; Linux uses the normal distribution-provided libraries.
SDL_AUDIO_AVAILABLE = begin
  module SDLAudio
    extend Fiddle::Importer

    dlload(
      Gem.win_platform? ?
        File.expand_path("audio/runtime/SDL2.dll", __dir__) :
        "libSDL2-2.0.so.0"
    )

    extern "int SDL_Init(unsigned int)"
    extern "void SDL_QuitSubSystem(unsigned int)"
    extern "void* SDL_RWFromFile(char*, char*)"
  end

  module SDLMixer
    extend Fiddle::Importer

    dlload(
      Gem.win_platform? ?
        File.expand_path("audio/runtime/SDL2_mixer.dll", __dir__) :
        "libSDL2_mixer-2.0.so.0"
    )

    extern "int Mix_Init(int)"
    extern "void Mix_Quit()"
    extern "int Mix_OpenAudio(int, unsigned short, int, int)"
    extern "void Mix_CloseAudio()"
    extern "void* Mix_LoadMUS(char*)"
    extern "int Mix_PlayMusic(void*, int)"
    extern "void Mix_HaltMusic()"
    extern "void Mix_PauseMusic()"
    extern "void Mix_ResumeMusic()"
    extern "void Mix_FreeMusic(void*)"
    extern "void* Mix_LoadWAV_RW(void*, int)"
    extern "int Mix_PlayChannelTimed(int, void*, int, int)"
    extern "void Mix_FreeChunk(void*)"
    extern "int Mix_AllocateChannels(int)"
  end

  true
rescue Fiddle::DLError
  false
end


class BackgroundMusic
  SDL_INIT_AUDIO = 0x0000_0010
  MIX_INIT_OGG = 0x0000_0010
  AUDIO_S16SYS = 0x8010

  def initialize(path)
    return unless SDL_AUDIO_AVAILABLE && File.exist?(path)
    return unless SDLAudio.SDL_Init(SDL_INIT_AUDIO).zero?
    return if SDLMixer.Mix_Init(MIX_INIT_OGG) & MIX_INIT_OGG == 0
    return unless SDLMixer.Mix_OpenAudio(44_100, AUDIO_S16SYS, 2, 1_024).zero?

    self.class.instance_variable_set(:@ready, true)
    SDLMixer.Mix_AllocateChannels(16)
    @music = SDLMixer.Mix_LoadMUS(File.expand_path(path))
    @active = @music && SDLMixer.Mix_PlayMusic(@music, -1).zero?
  end

  def self.ready?
    @ready == true
  end

  def enabled=(enabled)
    return unless @active

    enabled ? SDLMixer.Mix_ResumeMusic() : SDLMixer.Mix_PauseMusic()
  rescue StandardError
    nil
  end

  def stop
    return unless @active

    SDLMixer.Mix_HaltMusic()
    SDLMixer.Mix_FreeMusic(@music) if @music
    SDLMixer.Mix_CloseAudio()
    SDLMixer.Mix_Quit()
    SDLAudio.SDL_QuitSubSystem(SDL_INIT_AUDIO)
    @active = false
  rescue StandardError
    nil
  end
end


# WAV effects are decoded once when the game starts, then played on free SDL
# channels immediately.  They can overlap without interrupting the OGG music.
class SoundEffects
  def initialize
    @chunks = {}
    return unless BackgroundMusic.ready?

    @chunks[:shot] = load_wav("audio/pew.wav")
    @chunks[:explosion] = load_wav("audio/bang.wav")
    @chunks[:large_explosion] = load_wav("audio/kaboom.wav")
  end

  def shot
    play(:shot)
  end

  def explosion(large: false)
    play(large ? :large_explosion : :explosion)
  end

  def stop
    @chunks.each_value { |chunk| SDLMixer.Mix_FreeChunk(chunk) if chunk }
    @chunks.clear
  rescue StandardError
    nil
  end

  private

  def load_wav(path)
    return nil unless File.exist?(path)

    rwops = SDLAudio.SDL_RWFromFile(File.expand_path(path), "rb")
    rwops && SDLMixer.Mix_LoadWAV_RW(rwops, 1)
  rescue StandardError
    nil
  end

  def play(name)
    chunk = @chunks[name]
    SDLMixer.Mix_PlayChannelTimed(-1, chunk, 0, -1) if chunk
  rescue StandardError
    nil
  end
end


class ProceduralAudio
  # Short, low-cost mono buffers keep firing response close to immediate. The
  # original longer queue created a noticeable input-to-sound delay.
  SAMPLE_RATE = 8_000
  BUFFER_SECONDS = 0.075
  BUFFER_SAMPLES = (SAMPLE_RATE * BUFFER_SECONDS).to_i
  WAVE_HEADER_SIZE = 48
  WAVE_MAPPER = -1
  TWO_PI = Math::PI * 2.0

  def initialize
    @mutex = Mutex.new
    @events = []
    @voices = []
    @speed_multiplier = 1.0
    @running = true
    @music_time = 0.0
    @next_step = 0.0
    @step = 0
    @bar = -1
    @pattern = {}
    @pad_phase = 0.0
    # Background music is now a streamed OGG; this mixer only needs to make
    # low-latency effects, which leaves considerably more CPU for rendering.
    @music_enabled = false
    @handle = open_device
    @thread = Thread.new { run } if @handle
  rescue StandardError
    # Sound is optional: a missing or locked Windows audio device must never
    # stop the game from launching.
    @handle = nil
  end

  def speed_multiplier=(value)
    @mutex.synchronize { @speed_multiplier = value }
  end

  def shot
    queue(:shot)
  end

  def explosion(large: false)
    queue(large ? :large_explosion : :explosion)
  end

  def stop
    return unless @handle

    @running = false
    @thread&.join(0.8)
    WinMM.waveOutReset(@handle)
    WinMM.waveOutClose(@handle)
    @handle = nil
  rescue StandardError
    nil
  end

  private

  def open_device
    format = [1, 1, SAMPLE_RATE, SAMPLE_RATE * 2, 2, 16].pack("v v V V v v")
    format_pointer = Fiddle::Pointer[format]
    handle_pointer = Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP)
    return nil unless WinMM.waveOutOpen(handle_pointer, WAVE_MAPPER, format_pointer, nil, nil, 0).zero?

    address = handle_pointer[0, Fiddle::SIZEOF_VOIDP].unpack1("Q<")
    Fiddle::Pointer.new(address)
  end

  def queue(type)
    @mutex.synchronize { @events << type }
  end

  def run
    queued = []
    while @running
      queued.reject! do |item|
        next false if item[:release_at] > Process.clock_gettime(Process::CLOCK_MONOTONIC)

        WinMM.waveOutUnprepareHeader(@handle, item[:header], WAVE_HEADER_SIZE)
        true
      end

      pcm = render_buffer
      data = Fiddle::Pointer[pcm]
      header = Fiddle::Pointer.malloc(WAVE_HEADER_SIZE)
      header[0, WAVE_HEADER_SIZE] = [data.to_i, pcm.bytesize, 0, 0, 0, 0, 0, 0].pack("Q< L< L< Q< L< L< Q< Q<")
      WinMM.waveOutPrepareHeader(@handle, header, WAVE_HEADER_SIZE)
      WinMM.waveOutWrite(@handle, header, WAVE_HEADER_SIZE)
      queued << {
        pcm: pcm,
        header: header,
        # Retain each native buffer until it has definitely left the hardware
        # queue. This keeps only about two buffers queued (~150 ms) instead of
        # letting latency grow while the game is busy drawing a frame.
        release_at: Process.clock_gettime(Process::CLOCK_MONOTONIC) + BUFFER_SECONDS * 2.1
      }
      sleep(BUFFER_SECONDS * 0.80)
    end
  rescue StandardError
    # The rendering thread quietly stops if the device disappears.
    @running = false
  end

  def render_buffer
    speed, events = @mutex.synchronize do
      captured = @events
      @events = []
      [@speed_multiplier, captured]
    end
    events.each { |event| @voices << { type: event, age: 0.0, phase: rand * TWO_PI } }

    samples = Array.new(BUFFER_SAMPLES, 0)
    BUFFER_SAMPLES.times do |index|
      advance_sequencer(speed) if @music_enabled
      time = @music_time
      sample = (@music_enabled ? pad_sample(time) : 0.0) + voice_sample(time)
      samples[index] = [[(sample * 10_500.0).to_i, -32_000].max, 32_000].min
      @music_time += 1.0 / SAMPLE_RATE
    end
    samples.pack("s<*")
  end

  def advance_sequencer(speed)
    bpm = 138.0 * speed
    step_length = 60.0 / bpm / 4.0
    return unless @music_time >= @next_step

    current_bar = @step / 16
    make_pattern if current_bar != @bar
    position = @step % 16
    @voices << { type: :kick, age: 0.0, phase: 0.0 } if @pattern[:kick][position]
    @voices << { type: :snare, age: 0.0, phase: rand * TWO_PI } if @pattern[:snare][position]
    @voices << { type: :hat, age: 0.0, phase: rand * TWO_PI } if @pattern[:hat][position]
    if @pattern[:bass][position]
      @voices << { type: :bass, age: 0.0, phase: @pattern[:notes][position] }
    end
    if @pattern[:lead][position]
      @voices << { type: :lead, age: 0.0, phase: @pattern[:notes][position] + 12 }
    end
    @step += 1
    @next_step += step_length
  end

  def make_pattern
    @bar = @step / 16
    root = [38, 41, 43, 36].sample
    notes = Array.new(16) { root + [0, 0, 3, 5, 7, 10].sample }
    @pattern = {
      kick:  Array.new(16) { |i| [0, 6, 8, 11, 14].include?(i) || (i == 15 && rand < 0.45) },
      snare: Array.new(16) { |i| [4, 12].include?(i) || (i == 10 && rand < 0.35) },
      hat:   Array.new(16) { |i| i.even? || rand < 0.28 },
      bass:  Array.new(16) { |i| [0, 2, 6, 8, 10, 14].include?(i) },
      lead:  Array.new(16) { |i| [3, 7, 11, 15].include?(i) && rand < 0.72 },
      notes: notes,
      root: root
    }
  end

  def pad_sample(time)
    return 0.0 unless @pattern[:root]

    frequency = midi_frequency(@pattern[:root] - 12)
    # Slow detuned pad is the sixth layer, filling space under the rhythm.
    Math.sin(TWO_PI * frequency * time) * 0.025 +
      Math.sin(TWO_PI * frequency * 1.503 * time) * 0.014
  end

  def voice_sample(time)
    total = 0.0
    @voices.reject! do |voice|
      voice[:age] += 1.0 / SAMPLE_RATE
      age = voice[:age]
      type = voice[:type]
      duration = type == :large_explosion ? 1.25 : (type == :explosion ? 0.65 : 0.30)
      next true if age > duration

      total += synth_voice(type, age, voice[:phase], time)
      false
    end
    total
  end

  def synth_voice(type, age, note, time)
    case type
    when :kick
      envelope = Math.exp(-age * 15.0)
      Math.sin(TWO_PI * (145.0 * Math.exp(-age * 12.0) + 42.0) * age) * envelope * 0.72
    when :snare
      noise(age * 19_871.0 + note) * Math.exp(-age * 18.0) * 0.23
    when :hat
      noise(age * 71_243.0 + note) * Math.exp(-age * 42.0) * 0.09
    when :bass
      frequency = midi_frequency(note)
      wobble = 0.35 + 0.65 * (Math.sin(TWO_PI * 5.5 * age) * 0.5 + 0.5)
      ((Math.sin(TWO_PI * frequency * age) * 0.75) +
       (Math.sin(TWO_PI * frequency * 2.01 * age) * 0.25)) *
        Math.exp(-age * 3.4) * wobble * 0.31
    when :lead
      frequency = midi_frequency(note)
      (Math.sin(TWO_PI * frequency * age) + Math.sin(TWO_PI * frequency * 2.0 * age) * 0.34) *
        Math.exp(-age * 6.0) * 0.13
    when :shot
      (noise(age * 91_333.0 + note) * 0.52 +
       Math.sin(TWO_PI * (940.0 - age * 2_100.0) * age) * 0.45) * Math.exp(-age * 23.0) * 0.55
    when :explosion, :large_explosion
      large = type == :large_explosion
      power = large ? 1.08 : 0.72
      decay = large ? 1.65 : 3.9
      # A sweeping sub oscillator gives the blast real weight; its long decay
      # is deliberately separated from the noisy crack so it remains audible
      # on speakers as well as headphones.
      sub = Math.sin(TWO_PI * (54.0 - age * 19.0) * age) * (large ? 0.88 : 0.62)
      rumble = Math.sin(TWO_PI * (92.0 - age * 37.0) * age) * 0.42
      (noise(age * 13_211.0 + note) * 0.46 + rumble + sub) * Math.exp(-age * decay) * power
    else
      0.0
    end
  end

  def midi_frequency(note)
    440.0 * (2.0 ** ((note - 69.0) / 12.0))
  end

  def noise(value)
    hashed = Math.sin(value * 12.9898) * 43_758.5453
    (hashed - hashed.floor) * 2.0 - 1.0
  end
end


# ============================================================
# PEDESTRIAN IMPACT EFFECT
# ============================================================

class Explosion

  def initialize(x, z, scale: 1.0)
    @x = x
    @z = z
    @scale = scale
    @duration = EXPLOSION_DURATION * (0.62 + @scale * 0.38)
    @age = 0.0
    @seed = rand * Math::PI * 2.0
    particle_count =
      (EXPLOSION_PARTICLE_COUNT * @scale).round.clamp(4, 72)

    @particles = Array.new(particle_count) do
      angle = rand * Math::PI * 2.0
      speed = (rand * 10.0 + 5.0) * @scale
      {
        x: 0.0,
        y: (rand * 1.3 + 0.3) * @scale,
        z: 0.0,
        vx: Math.cos(angle) * speed,
        vy: (rand * 10.0 + 5.0) * @scale,
        vz: Math.sin(angle) * speed * 0.7,
        hot: rand < 0.68,
        size: rand * 5.0 + 4.0
      }
    end
  end

  def update(delta, road_speed_multiplier)
    @age += delta
    @z -= PEDESTRIAN_FORWARD_SPEED * road_speed_multiplier * delta

    @particles.each do |particle|
      particle[:x] += particle[:vx] * delta
      particle[:y] += particle[:vy] * delta
      particle[:z] += particle[:vz] * delta
      particle[:vy] -= 18.0 * delta
      particle[:vx] *= 0.985
      particle[:vz] *= 0.985
    end
  end

  def finished?
    @age >= @duration
  end

  def draw_glow
    alpha = (1.0 - @age / @duration).clamp(0.0, 1.0)
    flash = (1.0 - @age / (0.18 * @scale)).clamp(0.0, 1.0)

    GL.glPointSize((44.0 * flash + 12.0) * @scale)
    GL.glColor4f(1.0, 0.16, 0.01, alpha * 0.24)
    GL.glBegin(GL_POINTS)
    GL.glVertex3f(@x, 1.4 * @scale, @z)
    GL.glEnd

    GL.glPointSize((25.0 * flash + 7.0) * @scale)
    GL.glColor4f(1.0, 0.72, 0.04, alpha * 0.45)
    GL.glBegin(GL_POINTS)
    GL.glVertex3f(@x, 1.4 * @scale, @z)
    GL.glEnd

    GL.glPointSize((10.0 * flash + 3.0) * @scale)
    GL.glColor4f(1.0, 0.98, 0.65, alpha)
    GL.glBegin(GL_POINTS)
    GL.glVertex3f(@x, 1.4 * @scale, @z)
    GL.glEnd
  end


  def draw_shockwaves
    draw_shockwave(@age, 1.0)
    draw_shockwave(@age - 0.13, 0.62) if @age > 0.13
  end


  def draw_fireburst
    flash = (1.0 - @age / (0.32 * @scale)).clamp(0.0, 1.0)
    return if flash <= 0.0

    # Nine deterministic rays are much cheaper than adding another
    # particle system, while making the initial impact feel larger.
    GL.glLineWidth((2.0 + flash * 2.0) * @scale)
    GL.glBegin(GL_LINES)
    9.times do |index|
      angle = @seed + index.to_f / 9.0 * Math::PI * 2.0
      reach = (4.0 + (index % 3) * 1.5) * @scale * (1.0 - flash * 0.25)
      rise = (1.5 + (index % 4) * 0.65) * @scale

      GL.glColor4f(1.0, 0.25 + flash * 0.7, 0.03, flash * 0.72)
      GL.glVertex3f(@x, 1.0 * @scale, @z)
      GL.glColor4f(1.0, 0.05, 0.0, 0.0)
      GL.glVertex3f(
        @x + Math.cos(angle) * reach,
        @scale + rise,
        @z + Math.sin(angle) * reach * 0.6
      )
    end
    GL.glEnd

    GL.glLineWidth((3.0 + flash * 3.0) * @scale)
    GL.glColor4f(1.0, 0.95, 0.55, flash * 0.85)
    GL.glBegin(GL_LINES)
    GL.glVertex3f(@x, 0.15 * @scale, @z)
    GL.glVertex3f(@x, (3.5 + flash * 4.0) * @scale, @z)
    GL.glEnd
  end


  def draw_sparks
    alpha = (1.0 - @age / @duration).clamp(0.0, 1.0)

    GL.glBegin(GL_LINES)
    @particles.each do |particle|
      next unless particle[:hot]

      GL.glColor4f(1.0, 0.2 + alpha * 0.65, 0.02, alpha)
      GL.glVertex3f(@x + particle[:x], [particle[:y], 0.08].max, @z + particle[:z])
      GL.glVertex3f(
        @x + particle[:x] - particle[:vx] * 0.045,
        [particle[:y] - particle[:vy] * 0.045, 0.08].max,
        @z + particle[:z] - particle[:vz] * 0.045
      )
    end
    GL.glEnd

    GL.glPointSize(7.0 * @scale)
    GL.glBegin(GL_POINTS)
    @particles.each do |particle|
      if particle[:hot]
        GL.glColor4f(1.0, 0.78, 0.08, alpha)
      else
        # Dark embers become the cheap smoke-like tail of the effect.
        GL.glColor4f(0.28, 0.12, 0.04, alpha * 0.45)
      end

      GL.glVertex3f(
        @x + particle[:x],
        [particle[:y], 0.08].max,
        @z + particle[:z]
      )
    end
    GL.glEnd
  end

  private

  def draw_shockwave(age, strength)
    return if age < 0.0

    progress = (age / @duration).clamp(0.0, 1.0)
    radius = (1.0 + progress * 18.0) * @scale
    alpha = (1.0 - progress) * strength * 0.8

    GL.glLineWidth((3.0 - progress * 1.5) * @scale)
    GL.glColor4f(1.0, 0.28 + progress * 0.35, 0.03, alpha)
    GL.glBegin(GL_LINE_LOOP)
    EXPLOSION_SHOCKWAVE_SEGMENTS.times do |index|
      angle = @seed + index.to_f / EXPLOSION_SHOCKWAVE_SEGMENTS * Math::PI * 2.0
      GL.glVertex3f(
        @x + Math.cos(angle) * radius,
        0.10,
        @z + Math.sin(angle) * radius * 0.58
      )
    end
    GL.glEnd
  end
end


class CarSmokePuff
  def initialize(player)
    @x = player[:x] + (rand - 0.5) * 1.8
    @y = 0.52 + rand * 0.18
    @z = player[:z] - PLAYER_LENGTH / 2.0 - 0.25
    @age = 0.0
    @drift_x = (rand - 0.5) * 0.65
    @rise_speed = 0.75 + rand * 0.45
    @shade = 0.42 + rand * 0.16
  end

  def update(delta, road_speed_multiplier)
    @age += delta
    @x += @drift_x * delta
    @y += @rise_speed * delta
    @z -= PEDESTRIAN_FORWARD_SPEED * road_speed_multiplier * 0.1 * delta
  end

  def finished?
    @age >= CAR_SMOKE_LIFETIME
  end

  def draw
    progress = (@age / CAR_SMOKE_LIFETIME).clamp(0.0, 1.0)
    radius = 0.24 + progress * 1.08
    alpha = (1.0 - progress) * 0.72

    GL.glPushMatrix
    GL.glTranslatef(@x, @y, @z)
    GL.glRotatef(-180.0, 0.0, 1.0, 0.0)
    GL.glRotatef(-CAMERA_YAW, 0.0, 1.0, 0.0)
    GL.glRotatef(CAMERA_PITCH, 1.0, 0.0, 0.0)
    GL.glRotatef(-CAMERA_ROLL, 0.0, 0.0, 1.0)

    GL.glColor4f(@shade, @shade, @shade, alpha)
    GL.glBegin(GL_POLYGON)
    10.times do |index|
      angle = index.to_f / 10.0 * Math::PI * 2.0
      GL.glVertex3f(Math.cos(angle) * radius, Math.sin(angle) * radius, 0.0)
    end
    GL.glEnd

    GL.glColor4f(0.05, 0.05, 0.06, alpha * 0.9)
    GL.glLineWidth(2.0)
    GL.glBegin(GL_LINE_LOOP)
    10.times do |index|
      angle = index.to_f / 10.0 * Math::PI * 2.0
      GL.glVertex3f(Math.cos(angle) * radius, Math.sin(angle) * radius, 0.01)
    end
    GL.glEnd
    GL.glPopMatrix
  end
end


def draw_car_smoke(smoke_puffs)
  return if smoke_puffs.empty?

  GL.glDisable(GL_TEXTURE_2D)
  GL.glEnable(GL_BLEND)
  GL.glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  smoke_puffs.reverse_each(&:draw)
  GL.glLineWidth(1.0)
  GL.glDisable(GL_BLEND)
  GL.glColor4f(1.0, 1.0, 1.0, 1.0)
  GL.glEnable(GL_TEXTURE_2D)
end


def player_hits_pedestrian?(player, pedestrian)
  horizontal_distance = (player[:x] - pedestrian.x).abs
  forward_distance = (player[:z] - pedestrian.z).abs

  horizontal_distance < PLAYER_HALF_WIDTH + PEDESTRIAN_HALF_WIDTH &&
    forward_distance < PLAYER_LENGTH / 2.0 + 1.0
end


def player_hits_obstacle?(player, obstacle)
  horizontal_distance = (player[:x] - obstacle.x).abs
  forward_distance = (player[:z] - obstacle.z).abs

  horizontal_distance < PLAYER_HALF_WIDTH + OBSTACLE_HALF_WIDTH &&
    forward_distance < PLAYER_LENGTH / 2.0 + 1.0
end


def draw_explosions(explosions)
  return if explosions.empty?

  GL.glDisable(GL_TEXTURE_2D)
  GL.glEnable(GL_BLEND)
  GL.glBlendFunc(GL_SRC_ALPHA, GL_ONE)

  explosions.each(&:draw_glow)
  explosions.each(&:draw_shockwaves)
  explosions.each(&:draw_fireburst)
  explosions.each(&:draw_sparks)

  GL.glPointSize(1.0)
  GL.glLineWidth(1.0)
  GL.glDisable(GL_BLEND)
  GL.glColor4f(1.0, 1.0, 1.0, 1.0)
  GL.glEnable(GL_TEXTURE_2D)
end


# ============================================================
# TEMPORARY PLAYER BOX
# ============================================================

def key_down?(window, key)
  GLFW.glfwGetKey(window, key) == GLFW_PRESS
end


def update_player(player, window, delta)
  horizontal = 0.0
  forward = 0.0

  # The scene's 180-degree camera turn mirrors world X on screen.
  horizontal += 1.0 if key_down?(window, GLFW_KEY_A)
  horizontal -= 1.0 if key_down?(window, GLFW_KEY_D)
  forward += 1.0 if key_down?(window, GLFW_KEY_W)
  forward -= 1.0 if key_down?(window, GLFW_KEY_S)

  player[:x] += horizontal * PLAYER_SPEED * delta
  player[:z] += forward * PLAYER_SPEED * delta

  player[:x] = player[:x].clamp(
    TRACK_LEFT + PLAYER_HALF_WIDTH,
    TRACK_RIGHT - PLAYER_HALF_WIDTH
  )
  player[:z] = player[:z].clamp(24.0, 90.0)
end


def draw_colored_prism(left, right, near_z, far_z, bottom, top, colours)
  GL.glBegin(GL_QUADS)

  # Top, left/right sides, front, back, and underside.
  GL.glColor4f(*colours[:top])
  GL.glVertex3f(left, top, near_z)
  GL.glVertex3f(right, top, near_z)
  GL.glVertex3f(right, top, far_z)
  GL.glVertex3f(left, top, far_z)

  GL.glColor4f(*colours[:side])
  GL.glVertex3f(left, bottom, near_z)
  GL.glVertex3f(left, bottom, far_z)
  GL.glVertex3f(left, top, far_z)
  GL.glVertex3f(left, top, near_z)
  GL.glVertex3f(right, bottom, far_z)
  GL.glVertex3f(right, bottom, near_z)
  GL.glVertex3f(right, top, near_z)
  GL.glVertex3f(right, top, far_z)

  GL.glColor4f(*colours[:front])
  GL.glVertex3f(left, bottom, far_z)
  GL.glVertex3f(right, bottom, far_z)
  GL.glVertex3f(right, top, far_z)
  GL.glVertex3f(left, top, far_z)

  GL.glColor4f(*colours[:back])
  GL.glVertex3f(right, bottom, near_z)
  GL.glVertex3f(left, bottom, near_z)
  GL.glVertex3f(left, top, near_z)
  GL.glVertex3f(right, top, near_z)

  GL.glEnd

  # Slightly oversized edge geometry keeps the outline visible over the faces.
  edge = 0.018
  outline_left = left - edge
  outline_right = right + edge
  outline_near = near_z - edge
  outline_far = far_z + edge
  outline_bottom = bottom - edge
  outline_top = top + edge
  corners = [
    [outline_left, outline_bottom, outline_near],
    [outline_right, outline_bottom, outline_near],
    [outline_right, outline_bottom, outline_far],
    [outline_left, outline_bottom, outline_far],
    [outline_left, outline_top, outline_near],
    [outline_right, outline_top, outline_near],
    [outline_right, outline_top, outline_far],
    [outline_left, outline_top, outline_far]
  ]

  GL.glColor4f(0.0, 0.0, 0.0, 1.0)
  GL.glLineWidth(CAR_OUTLINE_WIDTH)
  GL.glBegin(GL_LINES)
  [[0, 1], [1, 2], [2, 3], [3, 0],
   [4, 5], [5, 6], [6, 7], [7, 4],
   [0, 4], [1, 5], [2, 6], [3, 7]].each do |from, to|
    GL.glVertex3f(*corners[from])
    GL.glVertex3f(*corners[to])
  end
  GL.glEnd
  GL.glLineWidth(1.0)
end


def draw_turret(player, aim)
  dx = aim[:x] - player[:x]
  dz = aim[:z] - player[:z]
  length = Math.sqrt(dx ** 2 + dz ** 2)
  direction_x = length.zero? ? 0.0 : dx / length
  direction_z = length.zero? ? 1.0 : dz / length

  draw_colored_prism(
    player[:x] - 0.72, player[:x] + 0.72,
    player[:z] - 0.72, player[:z] + 0.72,
    2.36, 2.78,
    {
      top: [0.22, 0.24, 0.29, 1.0],
      side: [0.07, 0.08, 0.11, 1.0],
      front: [0.16, 0.17, 0.21, 1.0],
      back: [0.05, 0.05, 0.07, 1.0]
    }
  )

  GL.glLineWidth(7.0)
  GL.glColor4f(0.08, 0.09, 0.12, 1.0)
  GL.glBegin(GL_LINES)
  GL.glVertex3f(player[:x], 2.70, player[:z])
  GL.glVertex3f(
    player[:x] + direction_x * 4.2,
    2.55,
    player[:z] + direction_z * 4.2
  )
  GL.glEnd
  GL.glLineWidth(2.0)
  GL.glColor4f(0.56, 0.62, 0.70, 1.0)
  GL.glBegin(GL_LINES)
  GL.glVertex3f(player[:x], 2.72, player[:z])
  GL.glVertex3f(
    player[:x] + direction_x * 4.25,
    2.57,
    player[:z] + direction_z * 4.25
  )
  GL.glEnd
  GL.glLineWidth(1.0)
end


def draw_player_car(player, aim, elapsed)
  left = player[:x] - PLAYER_HALF_WIDTH
  right = player[:x] + PLAYER_HALF_WIDTH
  near_z = player[:z] - PLAYER_LENGTH / 2.0
  far_z = player[:z] + PLAYER_LENGTH / 2.0

  GL.glDisable(GL_TEXTURE_2D)

  # A translucent footprint anchors the car to the road beneath its bounce.
  GL.glEnable(GL_BLEND)
  GL.glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  GL.glColor4f(0.0, 0.0, 0.0, CAR_SHADOW_ALPHA)
  GL.glBegin(GL_QUADS)
  GL.glVertex3f(left - 0.45, 0.055, near_z - 0.55)
  GL.glVertex3f(right + 0.45, 0.055, near_z - 0.55)
  GL.glVertex3f(right + 0.45, 0.055, far_z + 0.55)
  GL.glVertex3f(left - 0.45, 0.055, far_z + 0.55)
  GL.glEnd
  GL.glDisable(GL_BLEND)

  # Layered frequencies avoid a perfectly mechanical bob while remaining smooth.
  bounce = (Math.sin(elapsed * 18.0) + Math.sin(elapsed * 31.0) * 0.35) * CAR_BOUNCE_HEIGHT
  vibration_x = Math.sin(elapsed * 43.0) * CAR_VIBRATION_AMOUNT
  vibration_z = Math.sin(elapsed * 37.0 + 1.7) * CAR_VIBRATION_AMOUNT
  GL.glPushMatrix
  GL.glTranslatef(vibration_x, bounce.abs, vibration_z)

  # Low, wide body: front points toward +Z (up the road).
  draw_colored_prism(
    left, right, near_z, far_z, 0.09, 1.12,
    {
      top: [0.12, 0.55, 1.0, 1.0],
      side: [0.03, 0.21, 0.62, 1.0],
      front: [0.2, 0.68, 1.0, 1.0],
      back: [0.02, 0.12, 0.38, 1.0]
    }
  )

  # Raised glass cabin gives the otherwise simple car its silhouette.
  draw_colored_prism(
    player[:x] - 1.75, player[:x] + 1.75,
    player[:z] - 0.75, player[:z] + 1.55,
    1.10, 2.40,
    {
      top: [0.12, 0.18, 0.28, 1.0],
      side: [0.05, 0.12, 0.22, 1.0],
      front: [0.32, 0.82, 1.0, 1.0],
      back: [0.08, 0.18, 0.30, 1.0]
    }
  )

  # Four chunky wheels, kept as boxes for the same deliberately
  # low-poly style as the body.
  wheel_colours = {
    top: [0.12, 0.12, 0.14, 1.0],
    side: [0.025, 0.025, 0.03, 1.0],
    front: [0.08, 0.08, 0.1, 1.0],
    back: [0.05, 0.05, 0.06, 1.0]
  }
  [near_z + 0.45, far_z - 1.45].each do |wheel_z|
    draw_colored_prism(left - 0.35, left + 0.45, wheel_z, wheel_z + 1.0, 0.08, 0.62, wheel_colours)
    draw_colored_prism(right - 0.45, right + 0.35, wheel_z, wheel_z + 1.0, 0.08, 0.62, wheel_colours)
  end

  # Simple emissive-style lamps: yellow at the front, red at the rear.
  GL.glBegin(GL_QUADS)
  GL.glColor4f(1.0, 0.9, 0.22, 1.0)
  [[left + 0.45, left + 1.25], [right - 1.25, right - 0.45]].each do |lamp_left, lamp_right|
    GL.glVertex3f(lamp_left, 0.48, far_z + 0.015)
    GL.glVertex3f(lamp_right, 0.48, far_z + 0.015)
    GL.glVertex3f(lamp_right, 0.82, far_z + 0.015)
    GL.glVertex3f(lamp_left, 0.82, far_z + 0.015)
  end
  GL.glColor4f(1.0, 0.05, 0.02, 1.0)
  [[left + 0.45, left + 1.25], [right - 1.25, right - 0.45]].each do |lamp_left, lamp_right|
    GL.glVertex3f(lamp_left, 0.48, near_z - 0.015)
    GL.glVertex3f(lamp_right, 0.48, near_z - 0.015)
    GL.glVertex3f(lamp_right, 0.82, near_z - 0.015)
    GL.glVertex3f(lamp_left, 0.82, near_z - 0.015)
  end
  GL.glEnd

  draw_turret(player, aim)

  GL.glPopMatrix

  GL.glColor4f(1.0, 1.0, 1.0, 1.0)
  GL.glEnable(GL_TEXTURE_2D)
end


def draw_track_bounds
  GL.glDisable(GL_TEXTURE_2D)
  GL.glColor4f(1.0, 0.08, 0.08, 1.0)
  GL.glLineWidth(2.0)
  GL.glBegin(GL_LINES)

  # Side boundaries define the road edges. The short near edge makes
  # the editable track footprint immediately obvious.
  GL.glVertex3f(TRACK_LEFT, 0.04, TRACK_NEAR_Z)
  GL.glVertex3f(TRACK_LEFT, 0.04, TRACK_FAR_Z)
  GL.glVertex3f(TRACK_RIGHT, 0.04, TRACK_NEAR_Z)
  GL.glVertex3f(TRACK_RIGHT, 0.04, TRACK_FAR_Z)
  GL.glVertex3f(TRACK_LEFT, 0.04, TRACK_NEAR_Z)
  GL.glVertex3f(TRACK_RIGHT, 0.04, TRACK_NEAR_Z)

  GL.glEnd
  GL.glLineWidth(1.0)
  GL.glColor4f(1.0, 1.0, 1.0, 1.0)
  GL.glEnable(GL_TEXTURE_2D)
end



# ============================================================
# MOUSE AIM, CROSSHAIR, AND SHOT TRACERS
# ============================================================

def mouse_ground_aim(window, x_pointer, y_pointer)
  GLFW.glfwGetCursorPos(window, x_pointer, y_pointer)
  mouse_x = x_pointer[0, Fiddle::SIZEOF_DOUBLE].unpack1("d")
  mouse_y = y_pointer[0, Fiddle::SIZEOF_DOUBLE].unpack1("d")

  ndc_x = mouse_x / WIDTH * 2.0 - 1.0
  ndc_y = 1.0 - mouse_y / HEIGHT * 2.0
  tan_y = Math.tan(CAMERA_FOV * Math::PI / 360.0)
  tan_x = tan_y * WIDTH / HEIGHT.to_f

  # Convert a projection-space ray back through the fixed camera pitch
  # and 180-degree scene turn, then intersect it with the ground.
  eye_x = ndc_x * tan_x
  eye_y = ndc_y * tan_y
  eye_z = -1.0
  pitch = -CAMERA_PITCH * Math::PI / 180.0
  pre_x = eye_x
  pre_y = Math.cos(pitch) * eye_y + Math.sin(pitch) * eye_z
  pre_z = -Math.sin(pitch) * eye_y + Math.cos(pitch) * eye_z
  direction_x = -pre_x
  direction_y = pre_y
  direction_z = -pre_z
  camera_z = -CAMERA_Z

  distance = -CAMERA_Y / [direction_y, -0.01].min
  {
    # Aim may reach the whole ground, including pedestrians on sidewalks.
    # Only the car movement itself is constrained to the track.
    x: (CAMERA_X + direction_x * distance).clamp(GROUND_LEFT, GROUND_RIGHT),
    z: (camera_z + direction_z * distance).clamp(12.0, 260.0),
    screen_x: mouse_x,
    screen_y: mouse_y
  }
end


def pedestrian_contains_cursor?(pedestrian, screen_x, screen_y)
  # Pedestrians are camera-facing billboards, so convert their feet to
  # screen space and test the cursor against the resulting screen box.
  pitch = -CAMERA_PITCH * Math::PI / 180.0
  eye_x = -pedestrian.x
  eye_y = Math.cos(pitch) * -CAMERA_Y -
          Math.sin(pitch) * (-pedestrian.z - CAMERA_Z)
  eye_z = Math.sin(pitch) * -CAMERA_Y +
          Math.cos(pitch) * (-pedestrian.z - CAMERA_Z)
  depth = -eye_z
  return false if depth <= OPENGL_NEAR

  tan_y = Math.tan(CAMERA_FOV * Math::PI / 360.0)
  tan_x = tan_y * WIDTH / HEIGHT.to_f
  feet_x = WIDTH * (0.5 + eye_x / (2.0 * depth * tan_x))
  feet_y = HEIGHT * (0.5 - eye_y / (2.0 * depth * tan_y))
  pixels_per_world_unit = HEIGHT / (2.0 * depth * tan_y)
  half_width = PEDESTRIAN_HALF_WIDTH * pixels_per_world_unit + 8.0
  height = PEDESTRIAN_HEIGHT * pixels_per_world_unit + 10.0

  screen_x.between?(feet_x - half_width, feet_x + half_width) &&
    screen_y.between?(feet_y - height, feet_y + 5.0)
end


def draw_crosshair(aim)
  size = 1.35
  GL.glDisable(GL_TEXTURE_2D)
  GL.glEnable(GL_BLEND)
  GL.glBlendFunc(GL_SRC_ALPHA, GL_ONE)
  GL.glLineWidth(2.0)
  GL.glColor4f(0.25, 1.0, 0.6, 0.9)
  GL.glBegin(GL_LINES)
  GL.glVertex3f(aim[:x] - size, 0.12, aim[:z])
  GL.glVertex3f(aim[:x] - size * 0.32, 0.12, aim[:z])
  GL.glVertex3f(aim[:x] + size * 0.32, 0.12, aim[:z])
  GL.glVertex3f(aim[:x] + size, 0.12, aim[:z])
  GL.glVertex3f(aim[:x], 0.12, aim[:z] - size)
  GL.glVertex3f(aim[:x], 0.12, aim[:z] - size * 0.32)
  GL.glVertex3f(aim[:x], 0.12, aim[:z] + size * 0.32)
  GL.glVertex3f(aim[:x], 0.12, aim[:z] + size)
  GL.glEnd
  GL.glLineWidth(1.0)
  GL.glDisable(GL_BLEND)
  GL.glColor4f(1.0, 1.0, 1.0, 1.0)
  GL.glEnable(GL_TEXTURE_2D)
end


def draw_tracers(tracers)
  return if tracers.empty?

  GL.glDisable(GL_TEXTURE_2D)
  GL.glEnable(GL_BLEND)
  GL.glBlendFunc(GL_SRC_ALPHA, GL_ONE)
  GL.glLineWidth(3.0)
  GL.glBegin(GL_LINES)
  tracers.each do |tracer|
    alpha = (1.0 - tracer[:age] / 0.08).clamp(0.0, 1.0)
    GL.glColor4f(1.0, 0.92, 0.38, alpha)
    GL.glVertex3f(tracer[:from_x], 2.7, tracer[:from_z])
    GL.glColor4f(1.0, 0.18, 0.02, 0.0)
    GL.glVertex3f(tracer[:to_x], 0.14, tracer[:to_z])
  end
  GL.glEnd
  GL.glLineWidth(1.0)
  GL.glDisable(GL_BLEND)
  GL.glColor4f(1.0, 1.0, 1.0, 1.0)
  GL.glEnable(GL_TEXTURE_2D)
end


def update_window_title(window, score, health)
  GLFW.glfwSetWindowTitle(
    window,
    "Road Run | Score #{score} | Hull #{health}%"
  )
end



# ============================================================
# HUD
# ============================================================

HUD_GLYPHS = {
  " " => ["000", "000", "000", "000", "000"],
  "0" => ["111", "101", "101", "101", "111"],
  "1" => ["010", "110", "010", "010", "111"],
  "2" => ["111", "001", "111", "100", "111"],
  "3" => ["111", "001", "111", "001", "111"],
  "4" => ["101", "101", "111", "001", "001"],
  "5" => ["111", "100", "111", "001", "111"],
  "6" => ["111", "100", "111", "101", "111"],
  "7" => ["111", "001", "010", "010", "010"],
  "8" => ["111", "101", "111", "101", "111"],
  "9" => ["111", "101", "111", "001", "111"],
  "A" => ["010", "101", "111", "101", "101"],
  "B" => ["110", "101", "110", "101", "110"],
  "C" => ["111", "100", "100", "100", "111"],
  "D" => ["110", "101", "101", "101", "110"],
  "E" => ["111", "100", "110", "100", "111"],
  "F" => ["111", "100", "110", "100", "100"],
  "G" => ["111", "100", "101", "101", "111"],
  "H" => ["101", "101", "111", "101", "101"],
  "I" => ["111", "010", "010", "010", "111"],
  "K" => ["101", "101", "110", "101", "101"],
  "L" => ["100", "100", "100", "100", "111"],
  "M" => ["101", "111", "111", "101", "101"],
  "N" => ["101", "111", "111", "111", "101"],
  "O" => ["111", "101", "101", "101", "111"],
  "P" => ["111", "101", "111", "100", "100"],
  "Q" => ["111", "101", "101", "111", "001"],
  "R" => ["110", "101", "110", "101", "101"],
  "S" => ["111", "100", "111", "001", "111"],
  "T" => ["111", "010", "010", "010", "010"],
  "U" => ["101", "101", "101", "101", "111"],
  "V" => ["101", "101", "101", "101", "010"],
  "W" => ["101", "101", "111", "111", "101"],
  "X" => ["101", "101", "010", "101", "101"],
  ":" => ["000", "010", "000", "010", "000"],
  "%" => ["101", "001", "010", "100", "101"]
}.freeze


def draw_hud_text(text, x, y, scale, colour)
  GL.glColor4f(*colour)
  GL.glBegin(GL_QUADS)
  cursor_x = x

  text.each_char do |character|
    glyph = HUD_GLYPHS.fetch(character, HUD_GLYPHS[" "])
    glyph.each_with_index do |row, row_index|
      row.each_char.with_index do |pixel, column_index|
        next unless pixel == "1"

        left = cursor_x + column_index * scale
        top = y + row_index * scale
        GL.glVertex3f(left, top, 0.0)
        GL.glVertex3f(left + scale, top, 0.0)
        GL.glVertex3f(left + scale, top + scale, 0.0)
        GL.glVertex3f(left, top + scale, 0.0)
      end
    end
    cursor_x += scale * 4
  end
  GL.glEnd
end


def draw_hud(score, road_elapsed, road_speed_multiplier, health, god_mode, shots_fired, shots_hit,
             game_started, game_has_started, music_enabled, scores_placeholder_open)
  minutes = (road_elapsed / 60.0).floor
  seconds = (road_elapsed % 60.0).floor
  speed_percent = (road_speed_multiplier * 100).round
  marksmanship = shots_fired.zero? ? 0 : (shots_hit * 100.0 / shots_fired).round

  GL.glMatrixMode(GL_PROJECTION)
  GL.glPushMatrix
  GL.glLoadIdentity
  GL.glOrtho(0.0, WIDTH.to_f, HEIGHT.to_f, 0.0, -1.0, 1.0)
  GL.glMatrixMode(GL_MODELVIEW)
  GL.glPushMatrix
  GL.glLoadIdentity

  GL.glDisable(GL_DEPTH_TEST)
  GL.glDisable(GL_TEXTURE_2D)
  GL.glEnable(GL_BLEND)
  GL.glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

  draw_hud_text(format("SCORE %06d", score), 26.0, 26.0, 4.0, [0.38, 0.95, 1.0, 1.0])
  draw_hud_text(format("SPEED %03d%%", speed_percent), 26.0, 51.0, 4.0, [1.0, 0.78, 0.18, 1.0])
  draw_hud_text(format("TIME %02d:%02d", minutes, seconds), 26.0, 76.0, 4.0, [0.82, 0.92, 1.0, 1.0])
  draw_hud_text(format("HULL %03d%%", health), 26.0, 101.0, 4.0, [1.0, 0.35, 0.2, 1.0])
  draw_hud_text(format("MARKSMANSHIP %03d%%", marksmanship), 26.0, 126.0, 4.0, [0.65, 1.0, 0.55, 1.0])
  draw_hud_text("GOD", WIDTH - 38.0, 14.0, 2.0, [1.0, 0.82, 0.18, 1.0]) if god_mode && game_started

  unless game_started
    GL.glColor4f(0.015, 0.025, 0.05, 0.86)
    GL.glBegin(GL_QUADS)
    GL.glVertex3f(0.0, 0.0, 0.0)
    GL.glVertex3f(WIDTH.to_f, 0.0, 0.0)
    GL.glVertex3f(WIDTH.to_f, HEIGHT.to_f, 0.0)
    GL.glVertex3f(0.0, HEIGHT.to_f, 0.0)
    GL.glEnd

    title = "ROAD RUN"
    title_scale = 8.0
    title_x = (WIDTH - title.length * title_scale * 4) / 2.0
    draw_hud_text(title, title_x, 175.0, title_scale, [0.25, 0.88, 1.0, 1.0])

    start_prompt = game_has_started ? "SPACE RESUME" : "SPACE START"
    ["WASD DRIVE", "MOUSE AIM", "LEFT CLICK FIRE", start_prompt].each_with_index do |line, index|
      scale = index == 3 ? 5.0 : 4.0
      x = (WIDTH - line.length * scale * 4) / 2.0
      colour = index == 3 ? [1.0, 0.78, 0.18, 1.0] : [0.88, 0.94, 1.0, 1.0]
      draw_hud_text(line, x, 300.0 + index * 48.0, scale, colour)
    end


    [[500.0, music_enabled ? "MUSIC ON" : "MUSIC OFF"],
     [548.0, "LEADERBOARD"], [596.0, "QUIT"]].each do |y, label|
      GL.glColor4f(0.06, 0.14, 0.24, 0.96)
      GL.glBegin(GL_QUADS)
      GL.glVertex3f(WIDTH / 2.0 - 150.0, y - 8.0, 0.0)
      GL.glVertex3f(WIDTH / 2.0 + 150.0, y - 8.0, 0.0)
      GL.glVertex3f(WIDTH / 2.0 + 150.0, y + 30.0, 0.0)
      GL.glVertex3f(WIDTH / 2.0 - 150.0, y + 30.0, 0.0)
      GL.glEnd
      scale = 4.0
      x = (WIDTH - label.length * scale * 4) / 2.0
      draw_hud_text(label, x, y, scale, [0.62, 0.92, 1.0, 1.0])
    end

    if scores_placeholder_open
      label = "LEADERBOARD COMING SOON"
      scale = 3.0
      x = (WIDTH - label.length * scale * 4) / 2.0
      draw_hud_text(label, x, 650.0, scale, [1.0, 0.78, 0.18, 1.0])
    end
  end

  GL.glDisable(GL_BLEND)
  GL.glColor4f(1.0, 1.0, 1.0, 1.0)
  GL.glEnable(GL_TEXTURE_2D)
  GL.glEnable(GL_DEPTH_TEST)
  GL.glMatrixMode(GL_MODELVIEW)
  GL.glPopMatrix
  GL.glMatrixMode(GL_PROJECTION)
  GL.glPopMatrix
  GL.glMatrixMode(GL_MODELVIEW)
end



def draw_game_over_message(elapsed)
  reveal_time = elapsed - 1.18
  return if reveal_time < 0.0

  message = "GAME OVER"
  visible_count = [(reveal_time / 0.13).floor + 1, message.length].min
  visible_text = message[0, visible_count]
  flash = (1.0 - (reveal_time % 0.13) / 0.13).clamp(0.0, 1.0)
  scale = 14.0
  x = (WIDTH - message.length * scale * 4) / 2.0
  y = HEIGHT * 0.29

  GL.glMatrixMode(GL_PROJECTION)
  GL.glPushMatrix
  GL.glLoadIdentity
  GL.glOrtho(0.0, WIDTH.to_f, HEIGHT.to_f, 0.0, -1.0, 1.0)
  GL.glMatrixMode(GL_MODELVIEW)
  GL.glPushMatrix
  GL.glLoadIdentity
  GL.glDisable(GL_DEPTH_TEST)
  GL.glDisable(GL_TEXTURE_2D)
  GL.glEnable(GL_BLEND)
  GL.glBlendFunc(GL_SRC_ALPHA, GL_ONE)

  # Letters ignite one at a time over the continuing road explosions.
  draw_hud_text(visible_text, x, y, scale + flash * 3.0, [1.0, 0.1, 0.01, 0.28])
  draw_hud_text(visible_text, x, y, scale, [1.0, 0.55 + flash * 0.4, 0.06, 1.0])

  if visible_count == message.length
    prompt = "SPACE RESTART  ESC EXIT"
    prompt_scale = 4.5
    prompt_x = (WIDTH - prompt.length * prompt_scale * 4) / 2.0
    pulse = 0.72 + Math.sin(elapsed * 5.0) * 0.22
    draw_hud_text(prompt, prompt_x, y + 82.0, prompt_scale, [0.72, 0.9, 1.0, pulse])
  end

  GL.glDisable(GL_BLEND)
  GL.glColor4f(1.0, 1.0, 1.0, 1.0)
  GL.glEnable(GL_TEXTURE_2D)
  GL.glEnable(GL_DEPTH_TEST)
  GL.glMatrixMode(GL_MODELVIEW)
  GL.glPopMatrix
  GL.glMatrixMode(GL_PROJECTION)
  GL.glPopMatrix
  GL.glMatrixMode(GL_MODELVIEW)
end


def game_over_explosion_points(center_x, base_z)
  glyph_scale = 1.55
  lines = [
    ["GAME", base_z + 12.0],
    ["OVER", base_z]
  ]

  lines.flat_map do |text, line_z|
    start_x = center_x - text.length * 4 * glyph_scale / 2.0

    text.chars.each_with_index.flat_map do |character, character_index|
      HUD_GLYPHS.fetch(character).each_with_index.flat_map do |row, row_index|
        row.chars.each_with_index.filter_map do |pixel, column_index|
          next unless pixel == "1"

          {
            x: start_x + (character_index * 4 + column_index) * glyph_scale,
            z: line_z + (4 - row_index) * glyph_scale
          }
        end
      end
    end
  end
end


# ============================================================
# GLOBAL TEXTURE ID
# ============================================================

$texture_id =
  texture_id


# ============================================================
# MAIN LOOP
# ============================================================

scroll =
  0.0


pedestrians =
  Array.new(6) { Pedestrian.new }

street_lamps =
  initial_street_lamps


obstacles =
  Array.new(3) { RoadObstacle.new }


pedestrian_spawn_time =
  PEDESTRIAN_SPAWN_INTERVAL


obstacle_spawn_time =
  OBSTACLE_SPAWN_INTERVAL

player =
  {
    x: 0.0,
    z: PLAYER_START_Z,
    health: CAR_MAX_HEALTH
  }


score =
  0


tracers =
  []


cursor_x_pointer =
  Fiddle::Pointer.malloc(
    Fiddle::SIZEOF_DOUBLE
  )


cursor_y_pointer =
  Fiddle::Pointer.malloc(
    Fiddle::SIZEOF_DOUBLE
  )


mouse_was_down =
  false


space_was_down =
  false


god_mode =
  false


god_key_was_down =
  false


shot_cooldown =
  0.0


burst_shots_remaining =
  0


burst_shot_time =
  0.0


burst_size =
  0


burst_aim =
  nil


shots_fired =
  0


shots_hit =
  0


update_window_title(
  window,
  score,
  player[:health]
)


explosions =
  []


car_smoke =
  []


car_smoke_time =
  0.0


game_over =
  false


game_started =
  false


game_has_started =
  false


escape_was_down =
  false


quit_requested =
  false


game_over_elapsed =
  0.0


next_game_over_burst =
  0.14


game_over_text_points =
  []


game_over_text_index =
  0


next_game_over_text_burst =
  1.25


road_elapsed =
  0.0


kill_speed_bonus =
  0.0


kills_toward_speed_bonus =
  0


music =
  BackgroundMusic.new("audio/music.ogg")


music_enabled =
  true


scores_placeholder_open =
  false


effects =
  SoundEffects.new


start_game_over = lambda do
  effects.explosion(large: true)
  game_over = true
  game_over_elapsed = 0.0
  next_game_over_burst = 0.14
  game_over_text_points = game_over_explosion_points(
    player[:x],
    player[:z] + 8.0
  )
  game_over_text_index = 0
  next_game_over_text_burst = 1.25
  GLFW.glfwSetWindowTitle(window, "Road Run | GAME OVER | Score #{score}")

  10.times do |index|
    angle = index.to_f / 10.0 * Math::PI * 2.0
    distance = index.zero? ? 0.0 : 2.0 + rand * 4.5
    explosions.shift if explosions.length >= MAX_ACTIVE_EXPLOSIONS
    explosions << Explosion.new(
      player[:x] + Math.cos(angle) * distance,
      player[:z] + Math.sin(angle) * distance
    )
  end
end


last_time =
  GLFW.glfwGetTime


puts "Starting render loop..."


loop do

  # Process the close request before starting another frame. This makes
  # the window's X button exit immediately instead of waiting on a
  # subsequent frame, and Escape provides a reliable second exit path.
  GLFW.glfwPollEvents

  break if GLFW.glfwWindowShouldClose(window) != 0

  escape_down = GLFW.glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS
  game_started = false if escape_down && !escape_was_down && game_started
  escape_was_down = escape_down


  god_key_down = GLFW.glfwGetKey(window, GLFW_KEY_G) == GLFW_PRESS
  control_down =
    GLFW.glfwGetKey(window, GLFW_KEY_LEFT_CONTROL) == GLFW_PRESS ||
    GLFW.glfwGetKey(window, GLFW_KEY_RIGHT_CONTROL) == GLFW_PRESS
  god_mode = !god_mode if control_down && god_key_down && !god_key_was_down
  god_key_was_down = god_key_down


  space_down = GLFW.glfwGetKey(window, GLFW_KEY_SPACE) == GLFW_PRESS
  if game_over && space_down && !space_was_down
    scroll = 0.0
    pedestrians = Array.new(6) { Pedestrian.new }
    pedestrian_spawn_time = PEDESTRIAN_SPAWN_INTERVAL
    street_lamps = initial_street_lamps
    obstacles = Array.new(3) { RoadObstacle.new }
    obstacle_spawn_time = OBSTACLE_SPAWN_INTERVAL
    player = { x: 0.0, z: PLAYER_START_Z, health: CAR_MAX_HEALTH }
    score = 0
    tracers = []
    explosions = []
    car_smoke = []
    car_smoke_time = 0.0
    mouse_was_down = false
    shot_cooldown = 0.0
    burst_shots_remaining = 0
    burst_shot_time = 0.0
    burst_size = 0
    burst_aim = nil
    shots_fired = 0
    shots_hit = 0
    game_over = false
    game_over_elapsed = 0.0
    next_game_over_burst = 0.14
    game_over_text_points = []
    game_over_text_index = 0
    next_game_over_text_burst = 1.25
    road_elapsed = 0.0
    kill_speed_bonus = 0.0
    kills_toward_speed_bonus = 0
    game_started = true
    game_has_started = true
    update_window_title(window, score, player[:health])
  elsif !game_started && space_down && !space_was_down
    game_started = true
    game_has_started = true
  end
  space_was_down = space_down


  # ==========================================================
  # DELTA TIME
  # ==========================================================

  now =
    GLFW.glfwGetTime


  delta =
    game_started ? now - last_time : 0.0


  last_time =
    now


  road_elapsed += delta
  road_speed_multiplier =
    1.0 +
    (road_elapsed / ROAD_SPEED_INCREASE_INTERVAL).floor *
    ROAD_SPEED_INCREASE +
    kill_speed_bonus

  pedestrian_speed_increase = road_speed_multiplier - 1.0
  pedestrian_max_count =
    PEDESTRIAN_MAX_COUNT +
    ((pedestrian_speed_increase + 1e-9) / PEDESTRIAN_COUNT_SPEED_STEP).floor


  aim = mouse_ground_aim(
    window,
    cursor_x_pointer,
    cursor_y_pointer
  )
  shot_cooldown -= delta


  # ==========================================================
  # SCROLL TEXTURE
  # ==========================================================

  scroll +=
    SCROLL_SPEED * road_speed_multiplier * delta


  #
  # GL_REPEAT means this can wrap forever.
  #

  scroll %= 1.0


  # ==========================================================
  # UPDATE PEDESTRIANS
  # ==========================================================

  pedestrians.each do |pedestrian|
    pedestrian.update(delta, road_speed_multiplier)
  end
  pedestrians.reject!(&:off_camera?)

  pedestrian_spawn_time -= delta
  # Faster roads clear pedestrians sooner, so increase throughput with both
  # road speed and the growing population cap. This makes the visible crowd
  # actually grow instead of merely raising a limit it can never reach.
  pedestrian_density_multiplier = pedestrian_max_count.to_f / PEDESTRIAN_MAX_COUNT
  pedestrian_spawn_interval =
    PEDESTRIAN_SPAWN_INTERVAL /
    (road_speed_multiplier * pedestrian_density_multiplier)

  while pedestrian_spawn_time <= 0.0 && pedestrians.length < pedestrian_max_count
    pedestrians << Pedestrian.new
    pedestrian_spawn_time += pedestrian_spawn_interval * (0.5 + rand)
  end
  pedestrian_spawn_time = 0.0 if pedestrians.length >= pedestrian_max_count


  obstacles.each { |obstacle| obstacle.update(delta, road_speed_multiplier) }
  obstacles.reject!(&:off_camera?)
  obstacle_spawn_time -= delta
  obstacle_spawn_interval = OBSTACLE_SPAWN_INTERVAL / road_speed_multiplier
  while obstacle_spawn_time <= 0.0 && obstacles.length < OBSTACLE_MAX_COUNT
    obstacles << RoadObstacle.new
    obstacle_spawn_time += obstacle_spawn_interval * (0.75 + rand * 0.5)
  end
  obstacle_spawn_time = 0.0 if obstacles.length >= OBSTACLE_MAX_COUNT


  street_lamps.each do |lamp|
    lamp.update(delta, road_speed_multiplier)
  end
  street_lamps.reject!(&:off_camera?)

  furthest_lamp_z = street_lamps.map(&:z).max
  lamp_spawn_ready = furthest_lamp_z.nil? ||
                     furthest_lamp_z <= STREET_LAMP_SPAWN_Z - STREET_LAMP_SPACING
  if lamp_spawn_ready && street_lamps.length / 2 < STREET_LAMP_MAX_PAIRS
    street_lamps << StreetLamp.new(:left)
    street_lamps << StreetLamp.new(:right)
  end


  car_smoke.each { |puff| puff.update(delta, road_speed_multiplier) }
  car_smoke.reject!(&:finished?)
  if game_started && !game_over
    car_smoke_time -= delta
    if car_smoke_time <= 0.0 && car_smoke.length < CAR_SMOKE_MAX_PUFFS
      car_smoke << CarSmokePuff.new(player)
      car_smoke_time = CAR_SMOKE_INTERVAL * (0.75 + rand * 0.5)
    end
  end

  if game_started && !game_over
    update_player(
      player,
      window,
      delta
    )
  end


  mouse_down =
    GLFW.glfwGetMouseButton(
      window,
      GLFW_MOUSE_BUTTON_LEFT
    ) == GLFW_PRESS


  if !game_started && mouse_down && !mouse_was_down
    menu_x = aim[:screen_x]
    menu_y = aim[:screen_y]
    if menu_x.between?(WIDTH / 2.0 - 150.0, WIDTH / 2.0 + 150.0)
      if menu_y.between?(492.0, 530.0)
        music_enabled = !music_enabled
        music.enabled = music_enabled
      elsif menu_y.between?(540.0, 578.0)
        scores_placeholder_open = !scores_placeholder_open
      elsif menu_y.between?(588.0, 626.0)
        quit_requested = true
      end
    end
  end

  break if quit_requested


  if game_started && !game_over && mouse_down &&
     shot_cooldown <= 0.0 && burst_shots_remaining.zero?
    shot_cooldown = SHOT_COOLDOWN
    extra_speed = [road_speed_multiplier - 1.0, 0.0].max
    burst_size = 1 + ((extra_speed + 1e-9) / MULTISHOT_SPEED_STEP).floor
    burst_shots_remaining = burst_size
    burst_shot_time = 0.0
    burst_aim = aim.dup
  end

  if game_started && !game_over && burst_shots_remaining.positive?
    burst_shot_time -= delta
    if burst_shot_time <= 0.0
      effects.shot
      shots_fired += 1
      # Keep a single centre beam on screen instead of stacking one tracer
      # per projectile during high-speed bursts.
      tracers.clear
      tracers << {
        from_x: player[:x],
        from_z: player[:z],
        to_x: burst_aim[:x],
        to_z: burst_aim[:z],
        age: 0.0
      }

      target = pedestrians
        .select do |pedestrian|
          pedestrian_contains_cursor?(
            pedestrian,
            burst_aim[:screen_x],
            burst_aim[:screen_y]
          )
        end
        .min_by(&:z)

      if target
        shots_hit += 1
        pedestrians.delete(target)
        explosions.shift if explosions.length >= MAX_ACTIVE_EXPLOSIONS
        explosions << Explosion.new(target.x, target.z)
        effects.explosion
        score += PEDESTRIAN_SCORE
        kills_toward_speed_bonus += 1
        speed_percent = (road_speed_multiplier * 100.0 + 1e-6).floor
        kills_required =
          if speed_percent < 200
            1
          else
            (speed_percent / 100 - 1) * KILLS_PER_SPEED_TIER
          end
        if kills_toward_speed_bonus >= kills_required
          kills_toward_speed_bonus -= kills_required
          kill_speed_bonus += PEDESTRIAN_KILL_SPEED_INCREASE
          road_speed_multiplier += PEDESTRIAN_KILL_SPEED_INCREASE
        end
      end

      burst_shots_remaining -= 1
      burst_shot_time = SHOT_BURST_INTERVAL
    end

    update_window_title(window, score, player[:health])
  end

  mouse_was_down = mouse_down

  tracers.each { |tracer| tracer[:age] += delta }
  tracers.reject! { |tracer| tracer[:age] >= 0.08 }


  # A hit removes the pedestrian and leaves a brief impact burst.
  pedestrians.reject! do |pedestrian|
    next false if game_over

    next false unless player_hits_pedestrian?(player, pedestrian)

    explosions.shift if explosions.length >= MAX_ACTIVE_EXPLOSIONS
    explosions << Explosion.new(pedestrian.x, pedestrian.z)
    effects.explosion
    kills_toward_speed_bonus += 1
    speed_percent = (road_speed_multiplier * 100.0 + 1e-6).floor
    kills_required =
      if speed_percent < 200
        1
      else
        (speed_percent / 100 - 1) * KILLS_PER_SPEED_TIER
      end
    if kills_toward_speed_bonus >= kills_required
      kills_toward_speed_bonus -= kills_required
      kill_speed_bonus += PEDESTRIAN_KILL_SPEED_INCREASE
      road_speed_multiplier += PEDESTRIAN_KILL_SPEED_INCREASE
    end
    player[:health] = [player[:health] - CAR_HIT_DAMAGE, 0].max unless god_mode
    update_window_title(window, score, player[:health])

    start_game_over.call if player[:health].zero?

    true
  end


  obstacles.reject! do |obstacle|
    next false if game_over
    next false unless player_hits_obstacle?(player, obstacle)

    explosions.shift if explosions.length >= MAX_ACTIVE_EXPLOSIONS
    explosions << Explosion.new(
      obstacle.x,
      obstacle.z,
      scale: OBSTACLE_EXPLOSION_SCALE
    )
    effects.explosion(large: true)
    player[:health] = [player[:health] - OBSTACLE_HIT_DAMAGE, 0].max unless god_mode
    update_window_title(window, score, player[:health])
    start_game_over.call if player[:health].zero?
    true
  end


  if game_over
    game_over_elapsed += delta

    # Follow-up detonations turn the initial impact into a short
    # cascade while the gameplay controls remain locked.
    if game_over_elapsed >= next_game_over_burst && game_over_elapsed < 1.25
      2.times do
        angle = rand * Math::PI * 2.0
        distance = rand * 7.0 + 1.5
        explosions.shift if explosions.length >= MAX_ACTIVE_EXPLOSIONS
        explosions << Explosion.new(
          player[:x] + Math.cos(angle) * distance,
          player[:z] + Math.sin(angle) * distance
        )
      end
      next_game_over_burst += 0.14
    end

    # Once the wreck's cascade clears, its smaller bursts write the
    # words GAME OVER across the road from left to right.
    if game_over_elapsed >= next_game_over_text_burst &&
       game_over_text_index < game_over_text_points.length

      5.times do
        break if game_over_text_index >= game_over_text_points.length

        point = game_over_text_points[game_over_text_index]
        explosions.shift if explosions.length >= GAME_OVER_MAX_EXPLOSIONS
        explosions << Explosion.new(point[:x], point[:z], scale: 0.32)
        game_over_text_index += 1
      end
      next_game_over_text_burst += 0.04
    end
  end

  explosions.each do |explosion|
    explosion.update(delta, road_speed_multiplier)
  end
  explosions.reject!(&:finished?)


  # ==========================================================
  # CLEAR
  # ==========================================================

  GL.glClear(
    GL_COLOR_BUFFER_BIT |
    GL_DEPTH_BUFFER_BIT
  )


  # ==========================================================
  # CAMERA
  # ==========================================================

  GL.glMatrixMode(
    GL_MODELVIEW
  )


  GL.glLoadIdentity


  # ----------------------------------------------------------
  # ROLL
  # ----------------------------------------------------------

  GL.glRotatef(
    CAMERA_ROLL,
    0.0,
    0.0,
    1.0
  )


  # ----------------------------------------------------------
  # PITCH
  # ----------------------------------------------------------
  #
  # IMPORTANT:
  #
  # We retain your original camera convention.
  #
  # CAMERA_PITCH = -30
  #
  # becomes:
  #
  # glRotatef(30)
  #

  GL.glRotatef(
    -CAMERA_PITCH,
    1.0,
    0.0,
    0.0
  )


  # ----------------------------------------------------------
  # YAW
  # ----------------------------------------------------------

  GL.glRotatef(
    CAMERA_YAW,
    0.0,
    1.0,
    0.0
  )


  # ----------------------------------------------------------
  # TURN WORLD AROUND
  # ----------------------------------------------------------
  #
  # OpenGL's default camera looks toward -Z.
  #
  # Our ground extends toward +Z.
  #

  GL.glRotatef(
    180.0,
    0.0,
    1.0,
    0.0
  )


  # ----------------------------------------------------------
  # CAMERA POSITION
  # ----------------------------------------------------------

  GL.glTranslatef(
    -CAMERA_X,
    -CAMERA_Y,
    CAMERA_Z
  )


  # ==========================================================
  # DRAW GROUND
  # ==========================================================

  draw_ground(
    scroll
  )

  draw_walls(
    scroll
  )

  draw_street_lamps(
    street_lamps
  )

  draw_obstacles(
    obstacles
  )


  # Pedestrians are vertical world-space sprites, so OpenGL's
  # projection, depth test, and fog make them grow naturally as
  # they approach the camera.
  draw_pedestrians(
    pedestrians
  )


  draw_explosions(
    explosions
  )


  draw_tracers(
    tracers
  )


  draw_car_smoke(
    car_smoke
  )


  draw_crosshair(
    aim
  )


  if game_started && !game_over
    draw_player_car(
      player,
      aim,
      road_elapsed
    )
  end


  draw_hud(
    score,
    road_elapsed,
    road_speed_multiplier,
    player[:health],
    god_mode,
    shots_fired,
    shots_hit,
    game_started,
    game_has_started,
    music_enabled,
    scores_placeholder_open
  )


  draw_game_over_message(game_over_elapsed) if game_over && game_started


  # ==========================================================
  # PRESENT FRAME
  # ==========================================================

  GLFW.glfwSwapBuffers(
    window
  )


  # VSync is disabled so this provides the same 60 FPS target on
  # monitors with refresh rates other than 60 Hz.
  frame_time = GLFW.glfwGetTime - now
  sleep(TARGET_FRAME_TIME - frame_time) if frame_time < TARGET_FRAME_TIME

end


# ============================================================
# CLEANUP
# ============================================================

puts "Cleaning up..."


effects.stop
music.stop


texture_ids = [
  texture_id,
  $pedestrian_texture_id,
  $obstacle_texture_id,
  $street_lamp_left_texture_id,
  $street_lamp_right_texture_id,
  $wall_left_texture_id,
  $wall_right_texture_id
].compact


texture_pointer =
  Fiddle::Pointer.malloc(
    Fiddle::SIZEOF_INT * texture_ids.length
  )


texture_pointer[
  0,
  Fiddle::SIZEOF_INT * texture_ids.length
] =
  texture_ids.pack("i*")


GL.glDeleteTextures(
  texture_ids.length,
  texture_pointer
)


GLFW.glfwDestroyWindow(
  window
)


GLFW.glfwTerminate


puts "Done."
