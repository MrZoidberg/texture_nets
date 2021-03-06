require 'nn'
require 'image'
require 'InstanceNormalization'
require 'src/utils'

local lfs = require "lfs"

local cmd = torch.CmdLine()

cmd:option('-input_path', '', 'Paths of image to stylize.')
cmd:option('-image_size', 0, 'Resize input image to. Do not resize if 0.')
cmd:option('-model_t7', '', 'Path to trained model.')
cmd:option('-save_path', '', 'Path to save stylized image.')
cmd:option('-cpu', false, 'use this flag to run on CPU')
cmd:option('-original_colors', false, 'original colors')

local params = cmd:parse(arg)

-- Load model and set type
local model = torch.load(params.model_t7)

-- Combine the Y channel of the generated image and the UV channels of the
-- content image to perform color-independent style transfer.
function original_colors(content, generated)
  local generated_y = image.rgb2yuv(generated)[{{1, 1}}]
  local content_uv = image.rgb2yuv(content)[{{2, 3}}]
  return image.yuv2rgb(torch.cat(generated_y, content_uv, 1))
end

if params.cpu then
  tp = 'torch.FloatTensor'
else
  require 'cutorch'
  require 'cunn'
  require 'cudnn'

  tp = 'torch.CudaTensor'
  model = cudnn.convert(model, cudnn)
end

model:type(tp)
model:evaluate()

-- Load image and scale
for file in lfs.dir(params.input_path) do
   local file_path = params.input_path .. '/' .. file
   print(file_path)
   if lfs.attributes(file_path, "mode") == "file" then
     print("Processing image " .. file)

     -- Load
     local img = image.load(file_path, 3):float()
     if params.image_size > 0 then
       img = image.scale(img, params.image_size, params.image_size)
     end

     -- Stylize
     local input = img:add_dummy()
     local stylized = model:forward(input:type(tp)):double()
     stylized = deprocess(stylized[1])

     -- Maybe color correct.
     if params.correct_color then
      stylized = original_colors(img:double(), stylized:double())
     end

     -- Save
     image.save(params.save_path .. '/' .. file, torch.clamp(stylized,0,1))
   end
end
