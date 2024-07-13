from flask import Flask, render_template, request, send_file
from rembg import remove
from PIL import Image
from io import BytesIO
import requests

app = Flask(__name__)

@app.route('/', methods=['GET', 'POST'])
def upload_file():
    if request.method == 'POST':
        if 'file' not in request.files:
            return 'No file uploaded', 400
        file = request.files['file']
        if file.filename == '':
            return 'No file selected', 400
        if file:
            input_image = Image.open(file.stream)
            output_image = remove(input_image, post_process_mask=True)
            img_io = BytesIO()
            output_image.save(img_io, 'PNG')
            img_io.seek(0)
            # return send_file(img_io, mimetype='image/png')  # Change download in separatre browser tab
            return send_file(img_io, mimetype='image/png', as_attachment=True, download_name='_rmbg.png')
    return render_template('index.html')

@app.route('/remove_background', methods=['POST'])
def remove_background():
    if 'image_url' not in request.json:
        return 'No image URL provided', 400
    image_url = request.json['image_url']
    
    # Download the image from the provided URL
    response = requests.get(image_url)
    if response.status_code != 200:
        return 'Failed to download image', 400
    
    # Open the downloaded image using PIL
    input_image = Image.open(BytesIO(response.content))
    
    # Remove the background using the 'remove' function from the 'rembg' library
    output_image = remove(input_image, post_process_mask=True)
    
    # Save the output image to a BytesIO object
    img_io = BytesIO()
    output_image.save(img_io, 'PNG')
    img_io.seek(0)
    
    # Return the output image as a response
    return send_file(img_io, mimetype='image/png')

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True, port=5100)