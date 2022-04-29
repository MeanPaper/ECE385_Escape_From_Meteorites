from PIL import Image
from collections import Counter
from scipy.spatial import KDTree
import numpy as np
def hex_to_rgb(num):
    h = str(num)
    return int(h[0:4], 16), int(('0x' + h[4:6]), 16), int(('0x' + h[6:8]), 16)
def rgb_to_hex(num):
    h = str(num)
    return int(h[0:4], 16), int(('0x' + h[4:6]), 16), int(('0x' + h[6:8]), 16)
filename = input("What's the image name? ")
new_w, new_h = map(int, input("What's the new height x width? Like 28 28. ").split(' '))


#this is the palette for the asteroid
#palette_hex = ['0xFF00FF','0x313129','0x5A5A52', '0x848C73', '0xA5AD94']  

#this is the palette for the text
palette_hex = ['0x000000','0xF8F8F8','0x780000','0xB00000','0xF03000','0xF89018','0xF86800','0xF8D030']

#this is the palette for the spaceship and its animations
#palette_hex = ['0xFF00FF','0x000000','0xFFFFFF', '0x313129', '0x5A5A52', '0x848C73', '0x840000' , '0xFF0000', '0x848400', '0xFFFF00', '0xA5AD94', '0x0084FF', '0x0042BD']    

palette_rgb = [hex_to_rgb(color) for color in palette_hex]
pixel_tree = KDTree(palette_rgb)
im = Image.open("../sprite_originals/" + filename+ ".png") #Can be many different formats.
im = im.convert("RGBA")
layer = Image.new('RGBA',(new_w, new_h), (0,0,0,0))
layer.paste(im, (0, 0))
im = layer
#im = im.resize((new_w, new_h),Image.ANTIALIAS) # regular resize
pix = im.load()
pix_freqs = Counter([pix[x, y] for x in range(im.size[0]) for y in range(im.size[1])])
pix_freqs_sorted = sorted(pix_freqs.items(), key=lambda x: x[1])
pix_freqs_sorted.reverse()
print(pix)
outImg = Image.new('RGB', im.size, color='white')
outFile = open("../sprite_bytes/" + filename + '.txt', 'w')
i = 0
for y in range(im.size[1]):
    for x in range(im.size[0]):
        pixel = im.getpixel((x,y))
        print(pixel)
        if(pixel[3] < 200):
            outImg.putpixel((x,y), palette_rgb[0])
            outFile.write("%x\n" %(0))
            print(i)
        else:
            index = pixel_tree.query(pixel[:3])[1]
            outImg.putpixel((x,y), palette_rgb[index])
            outFile.write("%x\n" %(index))
        i += 1
outFile.close()
outImg.save("../sprite_converted/" + filename + ".png" )
