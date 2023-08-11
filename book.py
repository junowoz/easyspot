import requests
from bs4 import BeautifulSoup

def download_video(url):
    # Send a GET request
    response = requests.get(url)
    # Parse the response content as HTML
    soup = BeautifulSoup(response.content, 'html.parser')
    # Find the <video> tag
    video_tag = soup.find('video')
    # Get the URL of the video file
    video_url = video_tag['src']

    # Send a GET request to the video URL
    video_response = requests.get(video_url)
    # Write the content of the response to a file
    with open('video.mp4', 'wb') as f:
        f.write(video_response.content)

    print('Download completed.')

download_video('https://us.bbcollab.com/collab/ui/session/playback')
