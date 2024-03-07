# Graph-a-Fantasy

*(Name courtesy of a friend who saw an early prototype)*

![](/doc/worth-a-1000.png)

This weekend project is an excuse to play with generative AI.

Inspired by my son's play with his toy characters, I created a set of quick and dirty scripts to turn arbitrary photos (of toys or people) into a set of playing cards in a specific style, presumably for a board game with unspecified rules 🙄

The real kicker was to generate cards of my alumni: I got multiple positive responses from the prototypes and very few negative ones 😅
# Quick Start

The process is very manual.

1. Create global configuration files:
```
mkdir -p ~/.graphafantasy

echo "sk-YOUR_STABILITY.AI_KEY_HERE" > ~/.graphafantasy/STABAI_KEY
echo "sk-YOUR_OPENAI.COM_KEY_HERE"   > ~/.graphafantasy/OPENAI_KEY
echo "YOUR_AWS_S3_BUCKET_NAME_HERE"  > ~/.graphafantasy/S3_BUCKET
```
2. Make your own "world" by calling `./00-new-world.sh myworld`. Everything about it will be stored under `worlds/myworld`.
3. (Skip for now). Adjust the prompts defining the world, see `worlds/myworld/*.txt`.
4. (Skip for now). Create seed information for your characters by editing `worlds/myworld/characters.tsv`:
```
1	Grumplespike	Default	It is evil, spiky and bad tempered
2	Lion	Default	Good and kind friend
```
5. (Skip for now). Obtain a set of reference images that you will turn into cards and put them under `worlds/myworld/00-ref_img/`. The file names must match character ids (first column). For now, we will use the provided sample images.
6. Upload pictures: `./00-upload-pictures.sh -w myworld`. The current implementation assumes you will upload your pictures to an S3 bucket for ChatGPT Vision to access them over HTTP. If you choose to do it differently, skip `00-upload-pictures.sh` and adjust the URL in `02-describe-ref-images.sh`.
7. Call `./01-enrich-table.sh --world myworld` to generate punch-lines for your characters in your world. Inspect `worlds/myworld/01-expanded-db/characters01*.tsv`:
```
1	Grumplespike	Default	It is evil, spiky and bad tempered	Enforcer of Chaos
2	Lion	Default	Good and kind friend	Guardian of Harmony
```
8. Use GPTV to generate fitting descriptions of your character pictures: `./02-describe-ref-images.sh --world myworld`. Inspect `worlds/myworld/02-describe-ref_img/*`:
```
The character, known as the Enforcer of Chaos, manifests a neon-orange cyberpunk appearance, bristling with vicious spikes from head to toe. Its eyes gleam with malevolence, narrow and calculating, underscored by the sharp contours of its menacing scowl. A wild array of jagged spines crowns its head, radiating the aura of an untamed force. Its skin bears a toxic hue, warning of the peril that comes with its bad-tempered nature.

This enforcer is clad in armor that resembles its spine-covered visage—a fusion of high-tech and primal rage. The chaotic neon landscape of this anarchic enforcer's world looms in the background, where flickering lights and holographic graffiti paint the scene of urban bedlam, mirroring its love for tumult and mayhem.
```
9. Use stability.ai Stable Diffusion img2img API to generate new character images from the mix of the reference ones and the descriptions: `./03-char-stability.sh --world myworld`. Inspect `worlds/myworld/03-stability/`
10. Combine images and descriptions into cards: `./04-fill-templates.sh --world myworld`, inspect `worlds/myworld/04-cards/`

Various afterthoughts:

- Put multiple cards on a sheet for printing: `./05-make-grid.sh --world myworld`
- Request and retrieve (after ~1m) videos: `./06-stability-video.sh --world myworld` and `./07-retrieve-video.sh --world myworld`
- Generate Telegram stickers - almost the same as cards but hide the name and use different dimensions: `./08-make-tg-stickers.sh --world myworld`

# Retry

The AI models will generate different result each time you run them. I find it useful to retry multiple times and pick the best results. The scripts keep AI generated results in timestamped files and by default use the last one.

Often times you want to regenerate a single character only, use the `--target CHAR_ID` option for that.

# Advanced Configuration

## Customize stability.ai step
You can adjust image generation per world. The following scripts are copied into world directories and may be tweaked:
- `03-image-prep.sh`. The default implementation prepares input to img2img by resizing the source to a max of 832x1216 and filling the rest with noise. For a Dune themed world you may want to colorize the reference images to help img2img move in the right direction:
```
#!/bin/bash
set -o nounset
set -o errexit

SRC_IMAGE="$1"
DST_IMAGE="$2"

echo "Custom image preparation script"
convert -size 832x1216 xc: +noise Random /tmp/noise_background.jpg
convert ${SRC_IMAGE} -resize 832x1216 /tmp/input_resized.jpg
convert /tmp/noise_background.jpg /tmp/input_resized.jpg -gravity center -composite \
    \( +clone -fill '#DAA520' -colorize 90% \) \
    -compose overlay -composite \
    "${DST_IMAGE}"
```

- `03-stabai-call.sh` implements the call to stability API. This is an opportunity to adjust style, image strength etc. Currently relies on very specific positional parameters passed into it. Sample script:
```
#!/bin/bash
set -o nounset
set -o errexit

STABAI_KEY="$1"
URL="$2"
IMAGE_PATH="$3"
PROMPT="$4"
OUT_FILE="$5"

curl -f -sS -X POST "${URL}" \
     -H 'Content-Type: multipart/form-data' \
     -H 'Accept: image/png' \
     -H "Authorization: Bearer ${STABAI_KEY}" \
     -F "init_image=@${IMAGE_PATH}" \
     -F 'init_image_mode=IMAGE_STRENGTH' \
     -F 'image_strength=0.33' \
     -F "text_prompts[0][text]=${PROMPT}" \
     -F "text_prompts[0][weight]=1" \
     -F "text_prompts[1][text]=blurry, bad, low detail, out of focus" \
     -F "text_prompts[1][weight]=-1" \
     -F 'cfg_scale=10' \
     -F 'samples=1' \
     -F 'steps=20' \
     -F "style_preset=photographic" \
     -o "${OUT_FILE}"
 ```

## Card Templates
The third column of `worlds/sample/characters.tsv` reads `Default`. This is a reference to the card template `worlds/sample/templates/Defaults.svg` used to produce a new card. Adjust this to create custom visuals of the cards.
