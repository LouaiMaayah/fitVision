import base64
import numpy as np
from io import BytesIO
from PIL import Image
from flask import Flask, request
import tensorflow as tf
import keras
from flask import jsonify

app = Flask(__name__)

with open('model.json', 'r') as json_file:
    json_savedModel= json_file.read()

model_j = keras.models.model_from_json(json_savedModel)
model_j.load_weights('model.h5')

@app.route("/")
def hello():
    return "hello"

@app.route('/process_image', methods=['POST'])
def process_image():
    image_data = request.form['image']
    image_bytes = base64.b64decode(image_data)
    image = Image.open(BytesIO(image_bytes)).convert('RGB')
    image_array = np.array(image, dtype=np.float32)
    img = tf.image.resize(image_array, (224, 224))
    img = tf.expand_dims(img, 0)
    prediction = np.argmax(model_j.predict(img))
    return jsonify({'prediction': int(prediction)})
    


if __name__ == "__main__":
    app.run(host="0.0.0.0") 