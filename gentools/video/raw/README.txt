Audio files required for video generation are already in this folder

However, raw video files shall be downloaded to this folder.

For GSMA video streams based on Tears of Steel movie, simply do what follows:


# =====================================================================
# Fetch RAW video stream
# =====================================================================

1-Optional: set http_proxy if behind a proxy (replace <fields> with custom values)
	export http_proxy=http://<proxy_host>:<proxy_port>
2- Download file
	wget http://media.xiph.org/tearsofsteel/tearsofsteel-4k.y4m.xz
3- Untar file
	tar xJf tearsofsteel-4k.y4m.xz

# =====================================================================
# Crop the video file and change frame rate to 29.97 fps
# =====================================================================
ffmpeg -i tearsofsteel-4k.y4m -r 30 -filter:v "crop=3040:1712:528:0" tearsofsteel-ff-crop-29.97fps.y4m

