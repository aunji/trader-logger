#!/usr/bin/env python3
"""
Create app icon with ZENTRY theme
- Background: Deep navy (#0A0E27)
- Circle: Gold (#FFD700)
- Icon: Candlestick chart (Green-Red-Green for uptrend)
"""

try:
    from PIL import Image, ImageDraw
    import math
except ImportError:
    print("Installing Pillow...")
    import subprocess
    subprocess.check_call(['pip3', 'install', 'Pillow'])
    from PIL import Image, ImageDraw
    import math

# Icon size
SIZE = 1024

# Colors from AppTheme
BACKGROUND_COLOR = (10, 14, 39)  # #0A0E27 - backgroundDark
GOLD_COLOR = (255, 215, 0)  # #FFD700 - accentGold
GREEN_COLOR = (0, 200, 83)  # #00C853 - primaryGreen
RED_COLOR = (255, 23, 68)  # #FF1744 - primaryRed

# Create image
img = Image.new('RGB', (SIZE, SIZE), BACKGROUND_COLOR)
draw = ImageDraw.Draw(img)

# Draw gold circle
center = SIZE // 2
radius = int(SIZE * 0.35)
draw.ellipse(
    [(center - radius, center - radius), (center + radius, center + radius)],
    fill=GOLD_COLOR
)

# Candlestick parameters
candle_width = int(SIZE * 0.055)
wick_width = int(SIZE * 0.015)

# Define candlesticks: (x_pos, high, open, close, low, color)
# Green = bullish (close > open), Red = bearish (close < open)
candlesticks = [
    # Green candle 1 (bullish - going up)
    {
        'x': int(SIZE * 0.32),
        'high': int(SIZE * 0.52),
        'open': int(SIZE * 0.68),
        'close': int(SIZE * 0.58),
        'low': int(SIZE * 0.72),
        'color': GREEN_COLOR
    },
    # Red candle (bearish - small pullback)
    {
        'x': int(SIZE * 0.45),
        'high': int(SIZE * 0.50),
        'open': int(SIZE * 0.56),
        'close': int(SIZE * 0.60),
        'low': int(SIZE * 0.64),
        'color': RED_COLOR
    },
    # Green candle 2 (bullish - strong uptrend)
    {
        'x': int(SIZE * 0.58),
        'high': int(SIZE * 0.32),
        'open': int(SIZE * 0.58),
        'close': int(SIZE * 0.40),
        'low': int(SIZE * 0.62),
        'color': GREEN_COLOR
    },
    # Green candle 3 (continuation)
    {
        'x': int(SIZE * 0.71),
        'high': int(SIZE * 0.28),
        'open': int(SIZE * 0.42),
        'close': int(SIZE * 0.32),
        'low': int(SIZE * 0.46),
        'color': GREEN_COLOR
    },
]

# Draw each candlestick
for candle in candlesticks:
    x = candle['x']
    high = candle['high']
    low = candle['low']
    open_price = candle['open']
    close = candle['close']
    color = candle['color']

    # Determine body top and bottom
    body_top = min(open_price, close)
    body_bottom = max(open_price, close)

    # Draw upper wick (from high to body top)
    wick_x = x
    draw.line([(wick_x, high), (wick_x, body_top)], fill=color, width=wick_width)

    # Draw lower wick (from body bottom to low)
    draw.line([(wick_x, body_bottom), (wick_x, low)], fill=color, width=wick_width)

    # Draw candlestick body
    body_left = x - candle_width // 2
    body_right = x + candle_width // 2
    draw.rectangle(
        [(body_left, body_top), (body_right, body_bottom)],
        fill=color,
        outline=color
    )

# Save as PNG
img.save('assets/icon.png', 'PNG')
print(f'✓ App icon created successfully at: assets/icon.png')
print(f'  Size: {SIZE}x{SIZE}px')
print(f'  Design: Candlestick chart with Green-Red-Green pattern (uptrend)')
